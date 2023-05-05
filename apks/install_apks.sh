#!/bin/bash

apksFolders=$(ls apks)

for folder in $apksFolders; do
    path="apks/$folder"
    apks=$(ls --width=0 $path)
    echo "Installing $folder"
    adb -s $1 install-multiple $path/*
done