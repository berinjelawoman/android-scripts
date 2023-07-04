# Android Scripts
Collection of scripts to setup Android TV boxes.


## Initial Setup
First, turn on developer mode on your TV Box and be sure that USB Debugging is turned on.
Check what's your IP and connect to your STB using ADB. A pop-up asking for confirmation will appear - mark
the option to always accept connection from this computer and confirm the connection.


## Installing APKs
Add every APK you wish to install in the `apks/apks` folder then run `apks/install_apks.sh`. Be sure to add
Blincast's launcher and our other apps that must go into the specific TV box, such as the RTPPlayer and
IPTVviewer.If you wish to retrieve APKs from a STB box and save it into `apks/apks` then run `apks/get_apks.sh`. Add to the `appsArray`
variable the APKs your wish to extract.


## Uninstalling APKs
Before sending the STB to hotels we must remove the default launcher and Google's Play Store. Run `apks/uninstall_launcher.sh`
to remove it. Now, the default launcher will be th one developed by Blincast. Now, set-up the launcher to finish the installation
process.


## Monitoring 
By default, adb only allows 15 devices. To bypass that limitation, make sure you are using a recent adb build and set
the environment variable `ADB_LOCAL_TRANSPORT_MAX_PORT` to the number of devices you will be monitoring.
It is crucial that a recent enough adb build is used since only those support the use of the environment variable.
Example:

```
export ADB_LOCAL_TRANSPORT_MAX_PORT=100 # monitoring 100 devices (or less)
```


To monitor the installed STBs run `main.sh`. It monitors the following:
 - Disconnected boxes
 - New shell processes
 - The list of installed apps

It also disables the settings app by continuously closing it and reboots the STB at a given time.


### Configuration Files
To use it you must create an `IPs.txt` file with the IPs you wish to monitor. Each line must be a new IP and it must end with an empty line.

E.g
```
192.168.0.2
192.168.0.3

```

To monitor the installed apps a `packages.txt` must be created with the apps that must be present in the monitored STBs. 
You can create one from a box by running `adb -s <ip> shell pm list packages | cut -d: -f2 > packages.txt`. If the program
can not find an app from `packages.txt` or finds and app that isn't on `packages.txt`, then it will send an error to a 
central server.

Finally, a `env.sh` file must be created to define at which hour should the STBs be rebooted and the IP of the server to 
send the STBs information.


### Configure Termux
To run `termux`commands you need to grant the `run commands in termux environment` permission to the Home Screen app.
It is also needed to grant `termux` the `Draw Over Apps` permission.

Finally, on termux, set `allow-external-apps=true` on `~/.termux/termux.properties`.