programs=("br.telecine.androidtv" "com.android.chrome" "com.droidlogic.videoplayer" 
          "com.globo.globotv" "com.netflix.mediaclient" "org.videolan.vlc" "com.spotify.music" 
          "com.amazon.avod.thirdpartyclient" "com.khy.videotest" "com.google.android.youtube.tv" 
          "com.droidlogic.appinstall" "com.disney.disneyplus" "com.cyx.startmanager" 
          "br.com.aquario.remoteserverapp")

# login
adb connect $1

for program in "${programs[@]}";
do
    adb uninstall --user 0 $program
done
