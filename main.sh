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
	echo -e "${RED}SEND_TO_IP: IP to send errors to${NOCOLOR}"
	exit 1
fi


source "$SCRIPT_DIR/env.sh"

#"$SCRIPT_DIR/kill-settings.sh" &

echo -e "${GREEN}Loaded with RESET_HOUR=$RESET_HOUR and SEND_TO_IP=$SEND_TO_IP${NOCOLOR}"

connect() {
	if [ ! -f "$SCRIPT_DIR/IPs.txt" ]; then
		echo -e "${RED}File IPs.txt doesn't exist"
		echo -e "${RED}Please create a IPs.txt file with the list of IPs to try to connect to${NOCOLOR}"
		exit 1
	fi

	while IFS= read -r ip; do
		adb connect $ip:5555
	done < "$SCRIPT_DIR/IPs.txt"
}


disconnected() {
	while IFS= read -r ip; do
		local out=$( adb -s $ip shell ls 2>&1 )
		if [[ "$out" == *"failed"* ]] || [[ "$out" == *"error"* ]] || [[ "$out" == *"unable"* ]] || [[ "$out" == *"error: device"* ]]; then
			echo $ip 
		fi
	done < "$SCRIPT_DIR/IPs.txt"
}



check_su() {
	local IP=$1
	res=$(adb -s $IP shell su 0 echo 1 2>&1)
	if [[ "$res" == "1" ]]; then
		echo "issu"
	fi
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
		if [[ "$package" != *"settings"* ]] && [[ "$package" != *"webviewtemplate"* ]] && [[ "$package" != "com.blincast.rtpplayer" ]]; then
			local res=$(adb -s $1 shell pm clear $package)
		fi
	done
	# adb -s $1 shell reboot
}


check_apps() {
	local filename="$SCRIPT_DIR/packages.txt"
	local filename2="$SCRIPT_DIR/new_packages.txt"
	local IP=$1

	if [ ! -f "$filename" ]; then
		echo -e "${RED}File $filename doesn't exist"
		echo -e "${RED}Please create a $filename file with the list of Android TV apps"
		echo -e "${RED}You can create one by running \"adb -s ip shell pm list packages | cut -d: -f2 > $filename\"${NOCOLOR}"
		exit 1
	fi

	adb -s $IP shell pm list packages | cut -d: -f2 > $filename2

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
				# install package if it does exist in the apk list
				if [ $( ls "$SCRIPT_DIR/apks/apks" | grep $package | wc -l ) -gt 0 ]; then
					adb -s $IP install-multiple $SCRIPT_DIR/apks/apks/$package/*
				else
					adb -s $IP shell pm uninstall -k --user 0 $package
				fi
			fi
		done < $2
	}

	_check_apps $filename $filename2
	_check_apps $filename2 $filename

	unset -f _check_apps
}


function send_process_app_error() {
	local process_errors=$(echo "${2//[^a-zA-Z0-9\.\:]/,}")
	local app_errors=$(echo "${3//[^a-zA-Z0-9\.\:]/,}")
	local json=$( 
		printf '%s' \
				"{\"content\" : " \
					"{ \"$log_time_string\": " \
						"{ \"ip\": \"$1\", " \
						"  \"process_errors\":\"$process_errors\", " \
						"  \"app_errors\":\"$app_errors\" }}}"
		)

	echo $json
	curl --header "Content-Type: application/json" \
		--request POST \
		--data "$json" \
		$SEND_TO_IP
}


do_reset=true
declare -A ips_reset_status
while IFS= read -r ip; do
	ips_reset_status["$ip"]=false
done < "$SCRIPT_DIR/IPs.txt"

while true; do
	hour=$( date +"%H" )
	local_time=$( date +"%Y:%m:%d-%H:%M:%S" )
	log_time_string="$local_time"

	ip_array=( $(adb devices | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}") )

	connect
	dc_errors=$(disconnected)
	echo "dc errors $dc_errors"
	for ip in ${ip_array[@]}; do
		echo "checking $ip"
		if ! [[ "$dc_errors" == *"$ip"* ]]; then
			su_errors=$(check_su $ip)
			app_errors=$(check_apps $ip)
			if [ -n "$su_errors" ] || [ -n "$app_errors" ]; then
				send_process_app_error "$ip" "$su_errors" "$app_errors"
			fi
		fi
	done
	
	if [ -n "$dc_errors" ]; then
		dc_errors=$(echo "${dc_errors//[^a-zA-Z0-9\.\:]/,}") # remove some weird whitespace leftover from echo
		json=$( 
			printf '%s' \
					"{\"content\" : " \
						"{ \"$log_time_string\": " \
							"{ \"dc_errors\":\"$dc_errors\" }}}"
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
		echo "[ $local_time ] Setting Reset"
		do_reset=false
		while IFS= read -r ip; do
			ips_reset_status["$ip"]=true
		done < "$SCRIPT_DIR/IPs.txt"
	elif ! $do_reset && [ "$hour" -gt "$RESET_HOUR" ] ; then
		echo "[ $local_time ] Set do reset as true"
		do_reset=true
	fi

	for ip in "${!ips_reset_status[@]}"; do
		if "${ips_reset_status[$ip]}" && ! [[ "$dc_errors" == *"$ip"* ]]; then
			echo "Resetting $ip"
			clear_packages $ip &
			ips_reset_status["$ip"]=false
		fi
	done
		
done
