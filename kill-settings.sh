SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

while true; do
    while IFS= read -r ip; do
        (adb -s $ip shell am force-stop com.android.tv.settings)
    done < "$SCRIPT_DIR/IPs.txt"
done