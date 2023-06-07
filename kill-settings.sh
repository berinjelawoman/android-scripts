SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

stop_settings() {
    while true; do
        adb -s $1 shell am force-stop com.android.tv.settings >/dev/null 2>/dev/null
        sleep 1
    done
} 


while IFS= read -r ip; do
    stop_settings $ip &
done < "$SCRIPT_DIR/IPs.txt"
