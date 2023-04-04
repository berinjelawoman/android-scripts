#!/bin/bash


GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


if [ ! -f "$SCRIPT_DIR/env.sh" ]; then
	echo -e "${RED}File env.sh doesn't exist"
	echo -e "${RED}Please create a env.sh file with the following variables"
	echo -e "${RED}RESET_HOUR: hour to reset the android system"
	echo -e "${RED}SEND_TO_IP: IP to send errors to"
	exit 1
fi


source "$SCRIPT_DIR/env.sh"

echo -e "${GREEN}Loaded with RESET_HOUR=$RESET_HOUR and SEND_TO_IP=$SEND_TO_IP${NOCOLOR}"

connect() {
	if [ ! -f "$SCRIPT_DIR/IPs.txt" ]; then
		echo -e "${RED}File IPs.txt doesn't exist"
		echo -e "${RED}Please create a IPs.txt file with the list of IPs to try to connect to"
		exit 1
	fi

	while IFS= read -r ip; do
		adb connect $ip:5555
	done < "$SCRIPT_DIR/IPs.txt"
}


disconnected() {
	local ip_array=( $(adb devices | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}") )

    while IFS= read -r line; do
		if ! [[ " ${ip_array[*]} " == *" $line "* ]]; then
			echo -e "$line"
		fi
	done < "$SCRIPT_DIR/IPs.txt"
}


get_processes() {
	local processes=$(adb -s $1 shell ps -A | grep -E "^shell")
	echo "$processes" > "$SCRIPT_DIR/processes.txt"
	local count=$(echo "$processes" | wc -l)

	sleep 2
	local processes2=$(adb -s $1 shell ps -A | grep -E "^shell")
	echo "$processes2" > "$SCRIPT_DIR/processes2.txt"
	local count2=$(echo "$processes2" | wc -l)

	local res=0 && [ $count == $count2 ] && res=1
	if [[ $count != $count2 ]]; then
		local filename="$SCRIPT_DIR/processes_disc.txt"
		echo "Discrepancy between process count" >> $filename
		echo "Old process list" >> $filename
		echo "$processes" >> $filename
		echo "New process list" >> $filename
		echo "$processes2" >> $filename
	fi

	if [[ $res == 0 ]]; then
		echo -e "$res"
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
	local filename="$SCRIPT_DIR/packages.txt"
	local filename2="$SCRIPT_DIR/new_packages.txt"

	if [ ! -f "$filename" ]; then
		echo -e "${RED}File $filename doesn't exist"
		echo -e "${RED}Please create a $filename file with the list of Android TV apps"
		echo -e "${RED}You can create one by running \"adb -s ip shell pm list packages | cut -d: -f2 > $filename\""
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
				echo -e "$package"
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
	log_time_string="$local_time"

	ip_array=( $(adb devices | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}") )

	dc_errors=$(disconnected)
	for ip in ${ip_array[@]}; do
		process_errors=$(get_processes $ip)
		app_errors=$(check_apps $ip)
	done

	if [ -n "$dc_errors" ] || [ -n "$process_errors" ] || [ -n "$app_errors" ]; then
		dc_errors=$(echo "${dc_errors//[^a-zA-Z0-9\.\:]/,}") # remove some weird whitespace leftover from echo
		process_errors=$(echo "${process_errors//[^a-zA-Z0-9\.\:]/,}")
		app_errors=$(echo "${app_errors//[^a-zA-Z0-9\.\:]/,}")
		json=$( 
			printf '%s' \
					"{\"content\" : " \
						"{ \"$log_time_string\": " \
							"{ \"dc_errors\":\"$dc_errors\", " \
						    "  \"process_errors\":\"$process_errors\", " \
							"  \"app_errors\":\"$app_errors\" }}}"
		 )

		echo $json
		curl --header "Content-Type: application/json" \
			--request POST \
			--data "$json" \
			$SEND_TO_IP
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
