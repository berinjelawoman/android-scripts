#!/bin/bash

adb -s $1 shell < network_commands.txt
adb -s $1 shell input text $2
adb -s $1 shell input keyevent 66;

for i in {1..16}; do
	adb -s $1 shell input keyevent 67
done
adb -s $1 shell input text "10.124.224.1"
adb -s $1 shell input keyevent 66;
adb -s $1 shell input keyevent 66;
adb -s $1 shell input keyevent 66;
adb -s $1 shell input keyevent 66;


