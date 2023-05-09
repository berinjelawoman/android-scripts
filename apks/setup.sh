#!/bin/bash

./install_apks.sh $1
sleep 1
./uninstall_launcher.sh $1
