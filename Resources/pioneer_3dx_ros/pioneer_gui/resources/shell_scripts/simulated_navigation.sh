#!/bin/bash
source ~/my_local_repo/devel/setup.bash
my_pid=$$
 
echo "My process ID is $my_pid"

echo "Launching Gazebo..."
roslaunch pioneer_gazebo gazebo_world.launch world:="$1" &
pid="$pid $!"
sleep 5s

echo "Loading initialisation parameters..."
roslaunch pioneer_description pioneer_initialization.launch robot_URDF_model:="$2" pose_file:="${3}" &
pid="$pid $!"
sleep 2s

echo "Launching Pioneers in Gazebo stack..."
for i in `seq 1 ${12}`;
do
  roslaunch pioneer_description pioneer_description.launch robot_name:="pioneer$i" robot_pose:="-x $(rosparam get /pioneer$i/x) -y $(rosparam get /pioneer$i/y) -Y $(rosparam get /pioneer$i/a)" environment:="$4" use_real_kinect:=$5 kinect_to_laserscan:=$6 &
  pid="$pid $!"
  sleep 2s
done

echo "Launching map server..."
roslaunch pioneer_nav2d map_server.launch map_name:="$1" &
pid="$pid $!"
sleep 2s

echo "Launching AMCL localisation stack..."
for i in `seq 1 ${12}`;
do
  roslaunch pioneer_nav2d localisation_launcher.launch robot_name:="pioneer$i" robot_pose_x:="$(rosparam get /pioneer$i/x)" robot_pose_y:="$(rosparam get /pioneer$i/y)" robot_pose_yaw:="$(rosparam get /pioneer$i/a)" localization_type:="$7" &
  pid="$pid $!"
  sleep 2s
done

echo "Launching move_base stack..."

for i in `seq 1 ${12}`;
do
  roslaunch pioneer_nav2d move_base.launch robot_name:="pioneer$i" move_base_type:="move_base" base_global_planner:="$8" base_local_planner:="$9" mcp_use:=${10} &
  pid="$pid $!"
  sleep 2s
done

echo "Launching rviz..."
roslaunch pioneer_description pioneer_visualization.launch rviz_config:="${11}" &
pid="$pid $!"

echo "$pid" > /home/$(whoami)/script_pid.txt

trap "echo Killing all processes.; kill -2 TERM $pid; exit" SIGINT SIGTERM

sleep 24h
