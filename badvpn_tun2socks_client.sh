#!/bin/bash

function pusage () {
	echo 'Quickly redirect traffic from tunnel device to socket interface.'
	echo ''
	echo 'Usage: '$0' [-u hostname:port] [-H hostname] <port>'
	echo ''
	echo '-H hostname			specify hostname'
	echo '-u hostname:port		enable udp forwarding'
	echo ''
}

udphostname=''
hostname='127.0.0.1'
port=''

while getopts 'u:H:' flag; do
	case "${flag}" in
		u) udphostname="${OPTARG}" ;;
		H) hostname="${OPTARG}" ;;
		*) pusage
		   exit;;
	esac
done

shift "$((OPTIND-1))"

if [ "$#" != "1" ]; then
	pusage
	exit
fi

port="$1"

if [ -z "$udphostname" ]; then
	badvpn-tun2socks --tundev tun0 --netif-ipaddr 192.168.0.2 --netif-netmask 255.255.255.0 --socks-server-addr "$hostname:$port"
else
	badvpn-tun2socks --tundev tun0 --netif-ipaddr 192.168.0.2 --netif-netmask 255.255.255.0 --socks-server-addr "$hostname:$port" --udpgw-remote-server-addr "$udphostname"

fi

