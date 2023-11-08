#!/bin/bash

IP=$1
WLAN=$(adb -s $IP shell ip addr | grep wlan0 -A 1 | awk '/ether/{print $2}')
ETH=$(adb -s $IP shell ip addr | grep eth0 -A 1 | awk '/ether/{print $2}')

echo "$ETH,$WLAN"
