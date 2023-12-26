IP=$1
ERROR_THRESH=10
SCREENCAP_FILE=screencap$IP.png

adb -s $IP shell monkey -p com.termux 1

# wait for termux initial setup
echo Waiting for initial setup
while true; do 
    adb -s $IP shell 'screencap -p /sdcard/screencap.png'
    adb -s $IP pull /sdcard/screencap.png $SCREENCAP_FILE
    convert $SCREENCAP_FILE -crop x500+0+0 $SCREENCAP_FILE
    diff=$(compare -channel red -metric MSE \
        termux-home.png $SCREENCAP_FILE out.png 2>&1 | cut -d' ' -f1)
    if (( $(echo "$diff < $ERROR_THRESH" | bc -l) )); then
        break
    fi
    diff=$(compare -channel red -metric MSE \
        termux-home-keyboard.png $SCREENCAP_FILE out.png 2>&1 | cut -d' ' -f1)
    if (( $(echo "$diff < $ERROR_THRESH" | bc -l) )); then
        break
    fi
    sleep 1
done
rm out.png

# change package using termux-change packages and install packages
echo Running install commands
read -r -d '' CMDS << EOM
 input text termux-change-repo && \
    for i in $(seq -s ' ' 1 3); do input keyevent KEYCODE_ENTER; done && \
    input text "echo%s'allow-external-apps=true'>>~/.termux/termux.properties" && \
    input keyevent KEYCODE_ENTER && \
    input text "pkg%sinstall%sandroid-tools%s-y&&adb%sdevices" && \
    input keyevent KEYCODE_ENTER
EOM

adb -s $IP shell "$CMDS"

# check for confirmation box
echo Waiting for confirmation box
adb -s $IP shell input keyevent KEYCODE_HOME
while true; do
    adb -s $IP shell 'screencap -p /sdcard/screencap.png'
    adb -s $IP pull /sdcard/screencap.png $SCREENCAP_FILE
    convert $SCREENCAP_FILE -crop 600x300+350+150 $SCREENCAP_FILE
    res=$(tesseract $SCREENCAP_FILE stdout)
    if [[ "$res" == *"chave RSA"* || "$res" == *"RSA key"* ]]; then
        break
    fi
    sleep 1
done
rm $SCREENCAP_FILE

sleep 1
adb -s $IP shell input keyevent KEYCODE_ENTER
adb -s $IP shell input keyevent KEYCODE_DPAD_DOWN
adb -s $IP shell input keyevent KEYCODE_DPAD_RIGHT
adb -s $IP shell input keyevent KEYCODE_ENTER
