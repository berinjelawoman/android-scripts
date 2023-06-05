#!/bin/bash


function online_status() {
    local IP=$1
    while [[ $(adb connect $IP | awk '{print($1)}')=="failed" ]]; 
    do
        sleep 1
    done

    while [[ "$(adb devices | grep "$IP:5" | awk '{print($2)}')" == "unauthorized" ]];
    do
        sleep 1
    done


    sleep 5

    adb -s $1 install rtpplayer.apk
    sleep 2
    adb -s $1 com.manager.mvideoviewer.apk
    sleep 2
    adb -s $1 shell < fix_sleep.txt
    sleep 2
}


for i in $(seq 10 255); do
    IP="10.124.224.${i}"
    if [[ $IP == "10.124.224.57" ]] || [[ $IP == "10.124.224.199" ]]; then
        continue    
    fi
    online_status $IP &
done