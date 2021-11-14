#!/bin/bash

if [ $(whoami) != 'root' ]; then
	echo 'This script must be run as root!'
	exit
fi


if [ -d /sys/fs/cgroup/net_cls/per-app-proxy ]; then
	echo 'Looks like the relay network tunnel has been setup!'
	echo 'Resetting the network environment...'

	ip route del default table per-app-proxy
	ip rule del fwmark 25 table per-app-proxy
	sed -i '/25 per-app-proxy/d' /etc/iproute2/rt_tables
	ip link set down dev tun0
	ip tuntap del dev tun0 mode tun
	iptables -t mangle -D OUTPUT -m cgroup --cgroup 0x00250025 -j MARK --set-mark 25
	rmdir /sys/fs/cgroup/net_cls/per-app-proxy

	echo 'If no errors were reported, the network configuration has been successfully restored to default.'
else
	if [ "$#" != "1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		echo 'Usage: '$0' <User>'
		exit
	fi

	if id "$1" &>/dev/null; then
		echo "Working with proxy tunnel as user "$1
	else
		echo "User "$1" does not exist!"
		exit
	fi
	echo 'Looks like the relay network tunnel has not been setup yet!'
	echo 'Setting up the network environment...'

	if ! [ -d /sys/fs/cgroup/net_cls ]; then
		mkdir -p /sys/fs/cgroup/net_cls/
	fi
	if ! grep -qs 'net_cls' /proc/mounts; then
		mount -t cgroup -onet_cls net_cls /sys/fs/cgroup/net_cls
	fi
	mkdir /sys/fs/cgroup/net_cls/per-app-proxy
	echo 0x00250025 > /sys/fs/cgroup/net_cls/per-app-proxy/net_cls.classid
	iptables -t mangle -A OUTPUT -m cgroup --cgroup 0x00250025 -j MARK --set-mark 25
	ip tuntap add dev tun0 mode tun user "$1"
	ip addr replace 192.168.0.1 dev tun0
	ip link set up dev tun0
	echo '25 per-app-proxy' >> /etc/iproute2/rt_tables
	ip rule add fwmark 25 table per-app-proxy
	ip route add default via 192.168.0.1 table per-app-proxy

	echo 'If no errors were reported, the network configureation has been successfully established.'
fi
