#!/bin/bash

for package in $(adb shell pm list packages | cut -d: -f2); do
    if [[ "$package" != *"settings"* ]] \
            && [[ "$package" != *"webviewtemplate"* ]] \
            && [[ "$package" != *"blincast"* ]] \
            && [[ "$package" != *"termux"* ]]; then
        adb shell pm clear $package
    fi
done