#!/bin/bash

while true; do
	adb shell am force-stop com.android.tv.settings >/dev/null 2>/dev/null
	sleep 1
done
