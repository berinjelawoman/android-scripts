#!/bin/bash

RESET_HOUR=16
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'


connect() {
	if [ ! -f "IPs.txt" ]; then
		echo -e "${RED}File IPs.txt doesn't exist"
		echo -e "${RED}Please create a IPs.txt file with the list of IPs to try to connect to"
		exit 1
	fi

	while IFS= read -r ip; do
		adb connect $ip:5555
	done < IPs.txt
}


disconnected() {
	local ip_array=( $(adb devices | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}") )

    while IFS= read -r line; do
		if ! [[ " ${ip_array[*]} " == *" $line "* ]]; then
			echo -e "$log_time_string disconnected: $line"
		fi
	done < IPs.txt
}


get_processes() {
	local processes=$(adb -s $1 shell ps -A | grep -E "^shell")
	echo "$processes" > "processes.txt"
	local count=$(echo "$processes" | wc -l)

	sleep 2
	local processes2=$(adb -s $1 shell ps -A | grep -E "^shell")
	echo "$processes2" > "processes2.txt"
	local count2=$(echo "$processes2" | wc -l)

	local res=0 && [ $count == $count2 ] && res=1
	if [[ $count != $count2 ]]; then
		local filename="processes_disc.txt"
		echo "Discrepancy between process count" >> $filename
		echo "Old process list" >> $filename
		echo "$processes" >> $filename
		echo "New process list" >> $filename
		echo "$processes2" >> $filename
	fi

	if [[ $res == 0 ]]; then
		echo -e "$log_time_string get_processes: $res"
	fi
}


clear_packages() {
	for package in $(adb -s $1 shell pm list packages | cut -d: -f2); do
		if [[ "$package" != *"settings"* ]]; then
			local res=$(adb -s $1 shell pm clear $package)
		fi
	done
	adb -s $1 shell reboot
}


check_apps() {
	local filename="packages.txt"
	local filename2="new_packages.txt"

	if [ ! -f "$filename" ]; then
		echo -e "${RED}File $filename doesn't exist"
		echo -e "${RED}Please create a $filename file with the list of Android TV apps"
		exit 1
	fi

	adb -s $1 shell pm list packages | cut -d: -f2 > $filename2

	_check_apps() {
		# Loop through each package name extracted from adb
		while IFS= read -r package; do
			# Loop through each line in the file
			while IFS= read -r line; do
				# Check if the package name matches the line in the file
				local found=false
				if [[ "$line" == "$package" ]]; then
					found=true
					break
				fi
			done < "$1"
			
			if ! $found; then
				echo -e "$log_time_string check_apps: $package"
			fi
		done < $2
	}

	_check_apps $filename $filename2
	_check_apps $filename2 $filename

	unset -f _check_apps
}


do_reset=true
while true; do
	connect

	hour=$( date +"%H" )
	local_time=$( date +"%Y:%m:%d-%H:%M:%S" )
	log_time_string="[ $local_time ]"

	ip_array=( $(adb devices | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}") )

	dc_erros=$(disconnected)
	for ip in ${ip_array[@]}; do
		process_errors=$(get_processes $ip)
		app_errors=$(check_apps $ip)
	done

	if [ -z "$dc_erros" ] || [ -z "$process_errors" ] || [ -z "$app_errors" ]; then
		echo -e "$dc_erros\n$process_errors\n$app_errors"
	fi

	# reset everything at RESET_HOUR
	echo "Do reset: $do_reset"
	if $do_reset && [ "$hour" -eq "$RESET_HOUR" ] ; then
		echo "[ $local_time ] Reseting"
		do_reset=false
		for ip in ${ip_array[@]}; do
			clear_packages $ip
		done
		sleep 60
	elif ! $do_reset && [ "$hour" -gt "$RESET_HOUR" ] ; then
		echo "[ $local_time ] Set do reset as true"
		do_reset=true
	fi
done
