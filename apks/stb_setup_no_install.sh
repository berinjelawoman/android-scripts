#!/bin/bash

if [ $# -lt 1 ]; then
	echo "uso: ./setup.sh ip_fixo_desejado"; echo "ex: ./setup.sh 10.124.224.40"
	exit 1
fi

IP=$1
echo Tentando conectar com $IP
adb connect $IP:5555
echo "aguardando confirmacao na TV..."

ok=$(adb devices | grep "${1}:5" | awk '{print($2)}')
while [[ "$ok" == "unauthorized" ]];
do
	ok=$(adb devices | grep "${1}:5" | awk '{print($2)}')
	sleep 1
done
echo "confirmacao recebida... continuando..."
sleep 2

echo Ativando conexão permanente
adb -s $IP shell settings put global adb_allowed_connection_time 0

#adb -s $IP uninstall com.example.webviewtemplate
adb -s $IP install-multiple apks/com.example.webviewtemplate/*
adb -s $IP install-multiple apks/com.blincast.videoplayer/*
adb -s $IP install-multiple apks/com.termux/*

./automate-termux $IP

adb -s $IP shell monkey -p 'com.example.webviewtemplate' 1
sleep 5
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/clear-packages.sh -o clear-packages.sh
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/get-curr-app.sh -o get-curr-app.sh
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/kill-settings.sh -o kill-settings.sh
curl -X POST -H "Content-Type: application/json" -d @fix-remote.json http://$IP:8080/create-file
adb -s $IP push main.mp4 /sdcard/

echo Tudo pronto
