#!/bin/bash

processes=$(adb shell ps -A | grep -E "^shell")
echo "$processes" > "processes.txt"
count=$(echo "$processes" | wc -l)

sleep 2
processes2=$(adb shell ps -A | grep -E "^shell")
echo "$processes2" > "processes2.txt"
count2=$(echo "$processes2" | wc -l)

if [[ $count != $count2 ]]; then
	filename="processes_disc.txt"
	echo "Discrepancy between process count" >> $filename
	echo "Old process list" >> $filename
	echo "$processes" >> $filename
	echo "New process list" >> $filename
	echo "$processes2" >> $filename
fi

echo "$count $count2 $res"

