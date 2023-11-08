#!/bin/bash
target_apps="$HOME/.checkapps/target-packages.txt"
current_apps="$HOME/.checkapps/current-packages.txt"

if [ ! -f "$target_apps" ]; then
	adb shell pm list packages | cut -d: -f2 > $target_apps
fi

function f() {	
	adb shell pm list packages | cut -d: -f2 > $current_apps

	# check if every package is installed
	while IFS= read -r package; do
		# Loop through each line in the file
		while IFS= read -r line; do
			# Check if the package name matches the line in the file
			found=false
			if [[ "$line" == "$package" ]]; then
				found=true
				break
			fi
		done < $current_apps
		
		if ! $found; then
			echo -e "Installed package not found: $package"
		fi
	done < $target_apps


	# check if any new package has been installed
	while IFS= read -r package; do
		# Loop through each line in the file
		while IFS= read -r line; do
			# Check if the package name matches the line in the file
			found=false
			if [[ "$line" == "$package" ]]; then
				found=true
				break
			fi
		done < $target_apps
		
		if ! $found; then
			echo Newly installed package: $package
			echo Uninstalling app $package
			adb uninstall $package
		fi
	done < $current_apps
}

while true; do
	f
	sleep 10
done