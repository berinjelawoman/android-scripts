#!/bin/bash

if [ $# -lt 2 ]; then
	echo "uso: ./setup.sh ip_local ip_fixo_desejado"; echo "ex: ./setup.sh 192.168.70.34 10.124.224.40"
	exit 1
fi

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
sleep 2

./install_apks.sh $IP
sleep 1
./uninstall_launcher.sh $IP
sleep 10
../automation/automation.sh
echo "tudo pronto"
