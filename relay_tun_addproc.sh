#!/bin/bash

if [ $(whoami) != 'root' ]; then
	echo 'This script must be run as root!'
	exit
fi

if [ -z $1 ]; then
	echo 'Usage: '$0' <process name>'
	exit
fi

if ! [ -d /sys/fs/cgroup/net_cls/per-app-proxy ]; then
	echo "Per-app-proxy cgroup and tunnels hasn\'t been setup yet. Run relay_tun_setup.sh first!"
	exit
fi

for i in $(ps aux|grep $1|grep -v 'relay_tun'|grep -v 'grep'|awk '{print $2}'); do
	echo "Adding process "$i" to the proxy cgroup..."
	echo $i >> /sys/fs/cgroup/net_cls/obsrelay/tasks
done
