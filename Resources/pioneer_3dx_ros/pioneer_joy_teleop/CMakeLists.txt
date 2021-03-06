cmake_minimum_required(VERSION 2.8.11)
project(pioneer_joy_teleop)
set (CMAKE_CXX_STANDARD 11)
find_package(catkin REQUIRED COMPONENTS
  roscpp
  roslib
  std_msgs
  sensor_msgs
  geometry_msgs
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5Widgets REQUIRED)

qt5_wrap_cpp(MOC src/pioneer_joy_teleop.h)
qt5_wrap_ui(UIC src/pioneer_joy_teleop.ui)

catkin_package(
#  LIBRARIES client_plugin
   CATKIN_DEPENDS roscpp roslib std_msgs geometry_msgs sensor_msgs geometry_msgs
#  DEPENDS system_lib
)

include_directories(
  INCLUDE_DIRS include
  ${CMAKE_CURRENT_BINARY_DIR}/..
  ${catkin_INCLUDE_DIRS}
)

## Declare a C++ executable
add_executable(joy2twist_node src/joy2twist.cpp)

target_link_libraries(joy2twist_node ${catkin_LIBRARIES})

add_executable(${PROJECT_NAME}_node src/main.cpp src/pioneer_joy_teleop.cpp src/pioneer_joy_teleop.h src/pioneer_joy_teleop.ui)
target_link_libraries(${PROJECT_NAME}_node ${catkin_LIBRARIES} Qt5::Widgets)

