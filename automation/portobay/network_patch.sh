#!/bin/bash

adb connect $1:5555

adb -s $1 shell input keyevent 4;
adb -s $1 shell input keyevent 4;
adb -s $1 shell input keyevent 4;
adb -s $1 shell input keyevent 4;

adb -s $1 shell input keyevent 13;
adb -s $1 shell input keyevent 16;
adb -s $1 shell input keyevent 13;
adb -s $1 shell input keyevent 16;
adb -s $1 shell input keyevent 20;

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


