#!/bin/bash

# Parse command-line options

# Option strings
ARGUMENT_LIST=(
    pose_file
    real_robots_file
    map_name
    participants
    localization_type
    base_global_planner
    base_local_planner
    rviz_config
)

# read the options
OPTS=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# set initial values


helpFunction()
{
   echo ""
   echo "$0 [Options]:"
   echo -e "\t--pose_file Pose file name"
   echo -e "\t--real_robots_file The file containing the username and the address of the robobot"
   echo -e "\t--map_name The name of the map created with the mapping module"
   echo -e "\t--participants Number of the spawned robots"
   echo -e "\t--localization_type Type of localization algorithm used"
   echo -e "\t--base_global_planner Global navigation planner"
   echo -e "\t--base_local_planner Local navigation planner"
   echo -e "\t--rviz_config Global navigation planner"
   exit 1 # Exit script after printing help
}

# extract options and their arguments into variables.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pose_file )
      pose_file="$2"
      shift 2
      ;;
    --real_robots_file )
      real_robots_file="$2"
      shift 2
      ;;
    --map_name )
      map_name="$2"
      shift 2
      ;;
    --participants )
      participants="$2"
      shift 2
      ;;
    --localization_type )
      localization_type="$2"
      shift 2
      ;;
    --base_global_planner )
      base_global_planner="$2"
      shift 2
      ;;
    --base_local_planner )
      base_local_planner="$2"
      shift 2
      ;;
    --rviz_config )
      rviz_config="$2"
      shift 2
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$pose_file" ] || [ -z "$real_robots_file" ] || [ -z "$map_name" ] || [ -z "$participants" ] || [ -z "$localization_type" ] || [ -z "$base_global_planner" ] || [ -z "$base_local_planner" ] || [ -z "$rviz_config" ]
then
  echo "";
  echo "Some or all of the parameters are empty";
  helpFunction
fi

echo "pose_file = $pose_file"
echo "real_robots_file = $real_robots_file"
echo "map_name = $map_name"
echo "participants = $participants"
echo "localization_type = $localization_type"
echo "base_global_planner = $base_global_planner"
echo "base_local_planner = $base_local_planner"
echo "rviz_config = $rviz_config"

echo "Launching pioneer_description..."
roslaunch pioneer_description pioneer_initialization.launch robot_URDF_model:="pioneer_kinect_real" pose_file:="$pose_file" real_robots_file:="$real_robots_file" &
pid="$pid $!"
sleep 5s

echo "Launching map server..."
roslaunch pioneer_nav2d map_server.launch map_name:="$map_name" use_sim_time:=false &
pid="$pid $!"
sleep 5s

echo "Launching RosAria stack..."
for i in `seq 1 $participants`;
do
  roslaunch pioneer_description pioneer_description.launch robot_name:="pioneer$i" robot_pose:="-x $(rosparam get /pioneer$i/x) -y $(rosparam get /pioneer$i/y) -Y $(rosparam get /pioneer$i/a)" environment:="real_world" use_real_kinect:=true kinect_to_laserscan:=true real_robot_username:="$(rosparam get /pioneer$i/username)" real_robot_address:="$(rosparam get /pioneer$i/address)" connect_robot_pc:=true &
  pid="$pid $!"
  sleep 5s
done

echo "Launching AMCL localisation stack..."
for i in `seq 1 $participants`;
do
  roslaunch pioneer_nav2d localisation_launcher.launch robot_name:=pioneer$i x:="$(rosparam get /pioneer$i/x)" y:="$(rosparam get /pioneer$i/y)" yaw:="$(rosparam get /pioneer$i/a)" localization_type:="$localization_type" real_robot_username:="$(rosparam get /pioneer$i/username)" real_robot_address:="$(rosparam get /pioneer$i/address)" connect_robot_pc:=true &
  pid="$pid $!"
  sleep 5s
done

echo "Launching move_base stack..."
sleep 5s
for i in `seq 1 $participants`;
do
  roslaunch pioneer_nav2d move_base.launch robot_name:="pioneer$i" move_base_type:="move_base" base_global_planner:="$base_global_planner" base_local_planner:="$base_local_planner" mcp_use:=false real_robot_username:="$(rosparam get /pioneer$i/username)" real_robot_address:="$(rosparam get /pioneer$i/address)" connect_robot_pc:=true &
  pid="$pid $!"
  sleep 5s
done

echo "Launching rviz..."
roslaunch pioneer_description pioneer_visualization.launch rviz_config:="$rviz_config" &
pid="$pid $!"
sleep 5s

echo "$pid" > /home/$(whoami)/script_pid.txt

trap "echo Killing all processes.; kill -2 TERM $pid; exit" SIGINT SIGTERM

sleep 24h
