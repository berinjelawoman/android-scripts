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

echo Tudo pronto
