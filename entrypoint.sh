#!/bin/bash

echo "starting xvfb"
Xvfb :99 -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
Xvfb_pid="$!"

echo "start the x11 vnc server"
x11vnc -display :99 &

echo "starting window manager"
jwm &

echo "starting sshd"
/etc/init.d/ssh restart

echo "checking openGl support"
glxinfo | grep '^direct rendering:'

echo "starting noVNC"
/novnc/noVNC/utils/launch.sh --vnc localhost:5900 &

source /opt/ros/melodic/setup.bash
/code-server/code-server --user-data-dir /workspace --allow-http --password $PASSWORD --auth password
