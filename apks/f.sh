IP=$1
adb connect $IP:5555
adb -s $IP install rtpplayer.apk 
adb -s $IP install apks/com.manage.mvideoviewer/com.manage.mvideoviewer.apk
adb -s $IP install-multiple apks/com.radio.fmradio/*
