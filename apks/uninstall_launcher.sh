#!/bin/bash

adb -s $1 shell pm uninstall -k --user 0 com.google.android.tvlauncher
adb -s $1 shell pm uninstall -k --user 0 com.android.vending