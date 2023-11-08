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

if [[ $type != "background" ]] && [[ $type != "logo" ]]; then
    echo -e "\033[0;31mExpected type [background|logo]. Got $type instead"
    exit 1
fi


(echo -n "{\"extension\": \"$extension\", \"type\": \"$type\", \"image\": \""; base64 $filepath; echo '"}') \
        | curl -k -X POST -H "Content-Type: application/json" -d @- https://$ip:$port/set-$type

