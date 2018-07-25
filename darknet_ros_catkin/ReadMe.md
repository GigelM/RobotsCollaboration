Download or clone from git into your workspace:

$ git clone https://github.com/leggedrobotics/darknet_ros.git

To maximize performance, make sure to build in Release mode. 

$ catkin_make -DCMAKE_BUILD_TYPE=Release

	Download weights

The yolo-voc.weights and tiny-yolo-voc.weights are downloaded automatically in the CMakeLists.txt file. If you need to download them again, go into the weights folder and download the two pre-trained weights from the COCO data set:

cd catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/weights/
wget http://pjreddie.com/media/files/yolov2.weights
wget http://pjreddie.com/media/files/yolov2-tiny.weights

And weights from the VOC data set can be found here:

wget http://pjreddie.com/media/files/yolov2-voc.weights
wget http://pjreddie.com/media/files/yolov2-tiny-voc.weights

And the pre-trained weight from YOLO v3 can be found here:

wget http://pjreddie.com/media/files/yolov3-voc.weights
wget http://pjreddie.com/media/files/yolov3.weights

	Use your own detection objects

In order to use your own detection objects you need to provide your weights and your cfg file inside the directories:

catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/weights/
catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/cfg/

In addition, you need to create your config file for ROS where you define the names of the detection objects. You need to include it inside:

catkin_workspace/src/darknet_ros/darknet_ros/config/

Then in the launch file you have to point to your new config file in the line:

<rosparam command="load" ns="darknet_ros" file="$(find darknet_ros)/config/your_config_file.yaml"/>
	
Open darknet_ros package and copy and replace the cmakelists from this folder into there.

	How to run it:

$ roslaunch darknet_ros yolo_v3.launch 
running with all classes

or

$ roslaunch darknet_ros darknet_ros.launch 
running with fewer classes (improving the FPS)