#!/bin/bash

IP=$1
echo Starting for IP $IP
while  true; do
	timeout 5 adb connect $IP:5555
	
	adb -s $IP shell monkey -p com.example.webviewtemplate 1
	curl -k -X POST -H "Content-Type: application/json" -d'{"data": "com.tivicon.tv2smart.atv"}' https://$IP:8080/set-tvapp
	res=$(adb -s $IP install apks/apks/com.tivicon.tv2smart.atv/*)
	echo $res
	if [[ "$res" == *"Success"* ]] ; then
		break
	fi
	
	sleep 10
done

adb -s $IP shell monkey -p com.tivicon.tv2smart.atv 1
echo done
