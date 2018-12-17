#!/bin/bash
my_pid=$$
 
echo "My process ID is $my_pid"

echo "Launching Pioneers in Gazebo stack..."
for i in `seq 1 1`;
do
  roslaunch pioneer_description pioneer_description.launch robot_name:=pioneer$i pose:="-x $(rosparam get /pioneer$i/x) -y $(rosparam get /pioneer$i/y) -Y $(rosparam get /pioneer$i/a)" use_kinect:=true sim:=false real_kinect:=true &
  pid="$pid $!"
  sleep 5s
done

echo "Launching AMCL localisation stack..."
sleep 5s
for i in `seq 1 1`;
do
  roslaunch pioneer_nav2d localisation_launcher.launch robot_name:=pioneer$i x:="$(rosparam get /pioneer$i/x)" y:="$(rosparam get /pioneer$i/y)" yaw:="$(rosparam get /pioneer$i/a)" &
  pid="$pid $!"
  sleep 10s
done

echo "Launching move_base stack..."
sleep 5s
for i in `seq 1 1`;
do
  roslaunch pioneer_nav2d single_navigation.launch robot_name:=pioneer$i x:="$(rosparam get /pioneer$i/x)" y:="$(rosparam get /pioneer$i/y)" yaw:="$(rosparam get /pioneer$i/a)" movement_type:=fast controller:=dwa &
  pid="$pid $!"
  sleep 10s
done

trap "echo Killing all processes.; kill -2 TERM $pid; exit" SIGINT SIGTERM

sleep 24h