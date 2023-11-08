#!/bin/bash


IP=$1
echo $IP
adb connect $IP:5555
echo "aguardando confirmacao na TV..."

ok=$(adb devices | grep "${1}:5" | awk '{print($2)}')
while [[ "$ok" == "unauthorized" ]];
do
	ok=$(adb devices | grep "${1}:5" | awk '{print($2)}')
	sleep 1
done
echo "confirmacao recebida... continuando..."

adb -s $IP install apks/com.example.webviewtemplate/com.example.webviewtemplate.apk

./uninstall_launcher.sh $IP
echo "tudo pronto"
