## How to set-up remote connection to termux
Be sure that your packages are up to date
```
pkg update
pkg upgrade
```

Install openssh:
```
pkg install openssh
```

Create a key
```
ssh-keygen -A
```

Set password
```
passwd
```

To see which user you are run `whoami`

You will need to manually start ssh everytime using
```
sshd
```

The default port is port 8022. You can check the port using `nmap localhost`

You can add sshd to `.bash_profile` to init ssh on termux boot
