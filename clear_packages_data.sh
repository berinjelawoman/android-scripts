#!/bin/bash


for package in $(adb shell pm list packages | cut -d: -f2); do
	res=$(adb shell pm clear $package)
	echo "$package returned result $res"
done
