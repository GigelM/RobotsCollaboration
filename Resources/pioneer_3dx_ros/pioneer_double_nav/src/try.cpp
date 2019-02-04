//ROS
#include "ros/ros.h"
#include "geometry_msgs/Twist.h"

using namespace std;



const float l = 0.5;
const float r = 0.12;
float v_r, th;

void cmdTransformCallback(const geometry_msgs::Twist& cmd_input)
{
    v_r = cmd_input.linear.x;
    th = cmd_input.angular.z;


}


int main(int argc, char **argv)
{
    ros::init(argc, argv, "try");
    ros::NodeHandle nh("~");

    ros::Subscriber cmd_sub = nh.subscribe("/pioneer1/cmd_vel", 10, cmdTransformCallback);
    ros::Publisher cmd_pub = nh.advertise<geometry_msgs::Twist>("/pioneer2/cmd_vel",10);

    ros::Rate rate(10);

    while(ros::ok()){

       geometry_msgs::Twist msg;
       msg.linear.x = v_r * r - th * l;
       msg.angular.z = th;

       cmd_pub.publish(msg);

       rate.sleep();
       ros::spinOnce();
    }

    return 0;
}
