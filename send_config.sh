#!/bin/bash

### Code to send the config file that generates the home screen


while getopts i:p:f: flag
do
    case "${flag}" in
        i) ip=${OPTARG};;
        p) port=${OPTARG};;
        f) filepath=${OPTARG};;
    esac
done


cat $filepath | curl -X POST -H "Content-Type: application/json" -d @- http://$ip:$port/config