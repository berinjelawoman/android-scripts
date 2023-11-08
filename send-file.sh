#!/bin/bash

### Code to send a file to termux


while getopts i:p:f:o: flag
do
    case "${flag}" in
        i) ip=${OPTARG};;
        p) port=${OPTARG};;
        f) filepath=${OPTARG};;
        o) outname=${OPTARG};;
    esac
done

b64_content=$(base64 -w 0 "$filepath")
curl -k -X POST -H "Content-Type: application/json" -d "{\"filename\":\"$outname\", \"content\":\"$b64_content\"}" https://$ip:$port/create-file
