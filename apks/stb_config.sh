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

echo Instalando apps
./install_apks.sh $IP

echo Desinstalando play store e removendo launcher padrão
./uninstall_launcher.sh $IP

echo Configurando termux

./automate-termux.sh $IP

adb -s $IP shell monkey -p 'com.example.webviewtemplate' 1
sleep 5
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/clear-packages.sh -o clear-packages.sh
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/get-curr-app.sh -o get-curr-app.sh
../send-file.sh -i $IP -p 8080 -f ../termux-scripts/kill-settings.sh -o kill-settings.sh
curl -k -X POST -H "Content-Type: application/json" -d @fix-remote.json https://$IP:8080/create-file
adb -s $IP push main.mp4 /sdcard/
adb -s $IP shell pm grant com.example.webviewtemplate com.termux.permission.RUN_COMMAND
adb -s $IP shell appops set com.example.webviewtemplate GET_USAGE_STATS allow
adb -s $IP shell input keyevent KEYCODE_BACK
adb -s $IP shell pm grant com.example.webviewtemplate android.permission.CHANGE_CONFIGURATION
adb -s $IP shell pm grant com.example.webviewtemplate android.permission.SYSTEM_ALERT_WINDOW
echo Tudo pronto
