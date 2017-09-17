#!/bin/bash

#Sagnik Basu
#2017-9-15
#Call this Script for installing Turtlebot in ROS2
#version - the version of ros

#Before Installing be sure to add ros_1 path and ros_2 path in environment variable

# check if presently inside ROS Directory

if [ -z "$ROS_2_DIR" ]
then
echo "ROS2_DIR was not set, please enter the entire valid path"
read input_variable
export ROS2_DIR=$input_variable
fi

echo "Enter your ROS_1 version(indigo/kinetic/lunar/any other version currently installed)"
read ros_1_ver

cd $ROS2_DIR
echo "Downloading TurtleBot2 demos specific code "
wget https://raw.githubusercontent.com/ros2/turtlebot2_demo/release-latest/turtlebot2_demo.repos
echo "Importing Turtlebot2 Source Repository"
vcs import src < turtlebot2_demo.repos

echo "Installing Dependencies for running TurlteBot2"


function install_dependency {
    echo "--- Installing dependency: $1"
    sudo apt-get -y install $1
}


install_dependency libboost-iostreams-dev 
install_dependency libboost-regex-dev 
install_dependency libboost-system-dev 
install_dependency libboost-thread-dev 
install_dependency libceres-dev 
install_dependency libgoogle-glog-dev 
install_dependency liblua5.2-dev libpcl-dev 
install_dependency libprotobuf-dev libsdl1.2-dev 
install_dependency libsdl-image1.2-dev 
install_dependency libsuitesparse-dev 
install_dependency libudev-dev 
install_dependency libusb-1.0.0-dev 
install_dependency libyaml-cpp-dev 
install_dependency protobuf-compiler 
install_dependency python-sphinx 
install_dependency ros-kinetic-kobuki-driver 
install_dependency ros-kinetic-kobuki-ftdi



echo "Building ROS 2 code while skipping some packages"

src/ament/ament_tools/scripts/ament.py build --isolated --symlink-install --parallel --skip-packages cartographer cartographer_ros ceres_solver ros1_bridge turtlebot2_amcl turtlebot2_drivers turtlebot2_follower turtlebot2_cartographer turtlebot2_teleop

echo "Building ROS 2 with turltebot"
echo "If you have a low spec machine it is advisable to do any other work"

echo "Sourcing ROS 1 Directory "
echo "/opt/ros/$ros_1_ver/setup.bash"
source /opt/ros/$ros_1_ver/setup.bash

echo "Starting Ament Build"


src/ament/ament_tools/scripts/ament.py build --isolated --symlink-install --parallel --only cartographer cartographer_ros ceres_solver turtlebot2_amcl turtlebot2_cartographer turtlebot2_drivers turtlebot2_follower turtlebot2_teleop --make-flags -j2 -l

echo "Setting up Udev rules"

cd $ROS2_DIR/src/ros_astra_camera
sudo cp 56-orbbec-usb.rules /etc/udev/rules.d
sudo cp `rospack find kobuki_ftdi`/57-kobuki.rules /etc/udev/rules.d

echo "Restarting the udev service"

sudo service udev reload
sudo service udev restart

echo "Sourcing the Workspacw"

source /opt/ros/$ros_1_ver/setup.bash
source $ROS2_DIR/install/local_setup.bash

echo "Installation finished----now run the demos"







