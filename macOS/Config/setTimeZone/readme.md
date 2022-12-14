# Script to Guesstimate TimeZone based on public IP of Mac

This script attempts to use the public IP address of the Mac to guesstimate it's TimeZone.

![Timezone Image](https://github.com/microsoft/shell-intune-samples/raw/master/img/timezone.png)

>Note:
>The process is only as good as the tools allow. If the IP address cannot be determined or the Mac is configured to use a VPN/Proxy server then this process is unlikely to work correctly.

## setTZfromIP.sh

The script is built around three processes.

Firstly, the script attempts to determine the public IP address of the Mac
```
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
```

Once we have the public IP address, we can use IPAPI to query where it thinks we are in the world
```
tz=$(curl https://ipapi.co/$myip/timezone)
```

Now we know where we think we are, we can tell macOS with the systemsetup command
```
sudo systemsetup -settimezone $tz
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3
