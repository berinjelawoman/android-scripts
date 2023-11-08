#!/bin/bash

SERVER_ADDRESS=$1
SERVER_PORT=$2

CURR_APP=$(adb shell dumpsys window windows | grep "Window #1" | rev | cut -d" " -f1 | rev | cut -d'/' -f1)
curl -X POST -H "Content-Type: application/json" -d "{\"app\":\"$CURR_APP\", \"time\": \"$(date)\"}" http://$SERVER_ADDRESS:$SERVER_PORT
