#!/bin/bash

### Code to send new logos and background images to the ipv box

while getopts i:p:f:e:t: flag
do
    case "${flag}" in
        i) ip=${OPTARG};;
        p) port=${OPTARG};;
        f) filepath=${OPTARG};;
        e) extension=${OPTARG};;
        t) type=${OPTARG};;
    esac
done


(echo -n "{\"extension\": \"$extension\", \"type\": \"$type\", \"image\": \""; base64 $filepath; echo '"}') \
    | curl -X POST -H "Content-Type: application/json" -d @- http://$ip:$port/b64-image