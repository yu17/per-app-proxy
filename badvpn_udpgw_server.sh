#!/bin/bash

if [ "$#" != "1" ]; then
	echo 'UDP proxy server for badvpn t2s.'
	echo ''
	echo 'Usage: '$0' <port>'

	exit
fi

badvpn-udpgw --listen-addr 127.128.0.1:"$1"
