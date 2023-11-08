IP=$1
ERROR_THRESH=10

adb -s $IP shell monkey -p com.termux 1

# wait for termux initial setup
echo Waiting for initial setup
while true; do 
    adb -s $IP exec-out screencap -p > screencap.png
    diff=$(compare -channel red -metric MSE \
        termux-home.png screencap.png out.png 2>&1 | cut -d' ' -f1)
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
    input text "pkg%sinstall%sandroid-tools%s-y&&adb%sdevices" && \
    input keyevent KEYCODE_ENTER
EOM

adb -s $IP shell "$CMDS"

# check for confirmation box
echo Waiting for confirmation box
while true; do
    adb -s $IP exec-out screencap -p > screencap.png
    convert screencap.png -crop 600x300+500+350 screencap.png
    res=$(tesseract screencap.png stdout)
    if [[ "$res" == *"chave RSA"* ]]; then
        break
    fi
    sleep 1
done
rm screencap.png

sleep 1
adb -s $IP shell input keyevent KEYCODE_ENTER
adb -s $IP shell input keyevent KEYCODE_DPAD_DOWN
adb -s $IP shell input keyevent KEYCODE_DPAD_RIGHT
adb -s $IP shell input keyevent KEYCODE_ENTER
