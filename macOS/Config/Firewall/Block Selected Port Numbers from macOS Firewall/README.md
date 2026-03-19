# Block Selected Port Numbers from macOS Firewall
This custom script blocks the following port numbers from macOS Firewall:

 Port Number| Direction | Port | More information |
| -------- | ---------- | ------- | -------- |
| 135 (TCP) | Inbound | Remote Procedure Call (RPC) Endpoint Mapper service | Blocks Port Number 135 TCP used by Microsoft RPC, which can be exploited for remote code execution. |
| 135 (UDP) | Inbound | Remote Procedure Call (RPC) Endpoint Mapper service | Blocks Port Number 135 UDP used by Microsoft RPC, which can be exploited for remote code execution. |
| 137-139 (TCP) | Inbound | NetBIOS and Windows Internet Naming Service (WINS)| Blocks Port Numbers 137-139 TCP used by NetBIOS and WINS, which can be a vector for various attacks. |
| 137-139 (UDP) | Inbound | NetBIOS and Windows Internet Naming Service (WINS) | Blocks Port Numbers 137-139 UDP used by NetBIOS and WINS, which can be a vector for various attacks. |
| 445 (TCP) | Inbound | Microsoft SMB Domain Server / Microsoft-DS (Active Directory, Windows shares)| Blocks Port Number 445 TCP used by Microsoft SMB Domain Server / Microsoft-DS (Active Directory, Windows shares), which is often targeted by malware. |
| 1433-1434 (TCP) | Inbound | Microsoft SQL Server | Blocks Port Numbers 1433-1434 TCP used by Microsoft SQL Server, which can be exploited if not properly secured. |
| 1433-1434 (UDP) | Inbound | Microsoft SQL Server | Blocks Port Numbers 1433-1434 UDP used by Microsoft SQL Server, which can be exploited if not properly secured. |
| 3389 (TCP) | Inbound | Remote Desktop Protocol (RDP) | Blocks Port Number 3389 TCP used by Remote Desktop Protocol (RDP), which is common target for brute force attacks. |
| 1900 (UDP) | Inbound | SSDP, Universal Plug and Play (UPnP), Bonjour| Blocks Port Number 1900 UDP used by SSDP, Universal Plug and Play (UPnP) and Bonjour, which can be exploited for network discovery and attacks. |
| 20-21 (TCP) | Inbound | FTP | Blocks Port Numbers 20-21 TCP used by FTP, which can be insecure if not properly configured. |
| 20-21 (UDP) | Inbound | FTP | Blocks Port Numbers 20-21 UDP used by FTP, which can be insecure if not properly configured. |
| 23 (TCP) | Inbound | Telnet | Blocks Port Number 23 TCP used by Telnet, which transmits data in plaintext and is insecure. |
| 110 (TCP) | Outbound | Post Office Protocol version 3 (POP3) | Blocks outbound TCP port 110 used by POP3 to prevent retrieval of email via POP3 clients. |
| 995 (TCP) | Outbound | Post Office Protocol version 3 over SSL/TLS (POP3S) | Blocks outbound TCP port 995 used by secure POP3 to prevent retrieval of email via POP3 clients. |
| 143 (TCP) | Outbound | Internet Message Access Protocol (IMAP) | Blocks outbound TCP port 143 used by IMAP to prevent retrieval of email via IMAP clients. |
| 993 (TCP) | Outbound | Internet Message Access Protocol over SSL/TLS (IMAPS) | Blocks outbound TCP port 993 used by secure IMAP to prevent retrieval of email via IMAP clients. |

> [!IMPORTANT]  
> Please note that there is a possibility that your Managed Mac-device may not use some of these port numbers or services above. Some of the services may also heavily related only to Windows-environment e.g. Remote Procedure Call (RPC) Endpoint Mapper service or Microsoft SQL Server. This script have been created in order to block these port numbers that are, in general, and usually used for malicious purposes.

> [!NOTE]  
> More information of port numbers used by Apple software products can be found [here](https://support.apple.com/en-us/103229) and [here](https://chadstechnoworks.com/wptech/os/mac_os_x_default_port_list.html)

## Prerequisities
**It is strongly recommended to deployed following script and policies to make sure that these services, that are using one of these port numbers, are not enabled and trying to calling to these blocked port numbers for nothing.**

| Port Numbers| Port | Link | More information
| -------- | ------- | -------- | -------- |
| 137-139 (TCP & UDP) | NetBIOS and Windows Internet Naming Service (WINS) | [Disable SMB 1, NetBIOS and netbiosd](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Disable%20SMB%201%2C%20NetBIOS%20and%20netbiosd) | Disables NetBIOS and WINS. |
| 1900 (UDP) | Bonjour | [Disable Bonjour Advertising Services](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Disable%20Bonjour%20Advertising%20Services) | Disables Bonjour Advertising Services. |

### Define device ownership

Before deploying this script, you also need to define value to `ownership` variable of the devices, where do you want to deploy this script. The `ownership` variable can be found from line number 23. Available ownership values are:

| Device Ownership | Value | More information
| -------- | ------- | -------- |
| Bring Your Own Device (BYOD) | byod | Use this value if you need to deploy this script to personal devices, that are not owned by your company.
| Corporate | corporate | Use this value if you need to deploy the script only to corporate devices. **NOTE:** Corporate-devices must be managed by Apple Business Manager.
| Bring Your Own Device (BYOD) **and** Corporate | all | Use this value if you want to deploy script to all devices ownership types.

## Script workflow diagram

Here is the workflow of the script (click to enlarge the image):
 
![Getting Started](Diagram.png)

 
## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/FirewallBlockPortNumbers/FirewallBlockPortNumbers.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Aug  8 23:59:33 EEST 2025 | Starting running of script FirewallBlockPortNumbers
############################################################

Fri Aug  8 23:59:33 EEST 2025 | Backing up firewall configurations...
Fri Aug  8 23:59:33 EEST 2025 | Done.
Fri Aug  8 23:59:34 EEST 2025 | Disabling inbound port 135/tcp permanently...
Fri Aug  8 23:59:34 EEST 2025 | Inbound port 135/tcp has been disabled permanently.
Fri Aug  8 23:59:34 EEST 2025 | Disabling inbound port 135/udp permanently...
Fri Aug  8 23:59:34 EEST 2025 | Inbound port 135/udp has been disabled permanently.
Fri Aug  8 23:59:34 EEST 2025 | Disabling inbound port 137/tcp permanently...
Fri Aug  8 23:59:34 EEST 2025 | Inbound port 137/tcp have been disabled permanently.
Fri Aug  8 23:59:34 EEST 2025 | Disabling inbound port 138/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 138/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 139/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 139/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 137/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 137/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 138/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 138/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 139/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 139/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 445/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 445/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 1433/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 1433/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 1434/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 1434/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 1433/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 1433/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 1434/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 1434/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 3389/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 3389/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 1900/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 1900/udp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 20/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 20/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 21/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 21/tcp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 20/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 20/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 21/udp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 21/udp have been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling inbound port 23/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Inbound port 23/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling outbound port 110/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Outbound port 110/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling outbound port 995/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Outbound port 995/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling outbound port 143/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Outbound port 143/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Disabling outbound port 993/tcp permanently...
Fri Aug  8 23:59:35 EEST 2025 | Outbound port 993/tcp has been disabled permanently.
Fri Aug  8 23:59:35 EEST 2025 | Done. Closing script...
```
