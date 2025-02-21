# Block Selected Port Numbers from macOS Firewall
This custom script blocks following port numbers from macOS Firewall:

 Port Number| Port | More information |
| -------- | ------- | -------- |
| 135 (TCP) | Remote Procedure Call (RPC) Endpoint Mapper service | Blocks Port Number 135 TCP used by Microsoft RPC, which can be exploited for remote code execution. |
| 135 (UDP) | Remote Procedure Call (RPC) Endpoint Mapper service | Blocks Port Number 135 UDP used by Microsoft RPC, which can be exploited for remote code execution. |
| 137-139 (TCP) | NetBIOS| Blocks Port Numbers 137-139 TCP used by NetBIOS, which can be a vector for various attacks. |
| 137-139 (UDP) | NetBIOS | Blocks Port Numbers 137-139 UDP used by NetBIOS, which can be a vector for various attacks. |
| 445 (TCP) | Microsoft-DS (Active Directory, Windows shares)| Blocks Port Number 445 TCP used by Microsoft-DS (Active Directory, Windows shares), which is often targeted by malware. |
| 1433-1434 (TCP) | Microsoft SQL Server | Blocks Port Numbers 1433-1434 TCP used by Microsoft SQL Server, which can be exploited if not properly secured. |
| 1433-1434 (UDP) | Microsoft SQL Server | Blocks Port Numbers 1433-1434 UDP used by Microsoft SQL Server, which can be exploited if not properly secured. |
| 3389 (TCP) | Remote Desktop Protocol (RDP) | Blocks Port Number 3389 TCP used by Remote Desktop Protocol (RDP), which is common target for brute force attacks. |
| 1900 (UDP) | Universal Plud and Play (UPnP)| Blocks Port Number 1900 UDP used by Universal Plud and Play (UPnP), which can be exploited for network discovery and attacks. |
| 20-21 (TCP) | FTP | Blocks Port Numbers 20-21 TCP used by FTP, which can be insecure if not properly configured. |
| 20-21 (UDP) | FTP | Blocks Port Numbers 20-21 UDP used by FTP, which can be insecure if not properly configured. |
| 23 (TCP) | Telnet | Blocks Port Numbers 23 TCP used by Telnet, which transmits data in plaintext and is insecure. |

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
# Sun Feb 16 23:16:14 PST 2025 | Starting running of script FirewallBlockPortNumbers
############################################################

Sun Feb 16 23:16:15 PST 2025 | Backing up firewall configurations...
Sun Feb 16 23:16:15 PST 2025 | Done.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 135/tcp permanently...
Sun Feb 16 23:16:15 PST 2025 | Port 135/tcp has been disabled permanently.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 135/udp permanently...
Sun Feb 16 23:16:15 PST 2025 | Port 135/udp has been disabled permanently.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 137/tcp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Disabling port 138/tcp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Disabling port 139/tcp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Ports 137 138 139/tcp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 137/udp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Disabling port 138/udp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Disabling port 139/udp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Ports 137 138 139/udp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 445/tcp permanently...
Sun Feb 16 23:16:15 PST 2025 | Port 445/tcp has been disabled permanently.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 1433/tcp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Disabling port 1434/tcp in pf.conf...
Sun Feb 16 23:16:15 PST 2025 | Ports 1433 1434/tcp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:15 PST 2025 | Disabling port 1433/udp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Disabling port 1434/udp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Ports 1433 1434/udp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:16 PST 2025 | Disabling port 3389/tcp permanently...
Sun Feb 16 23:16:16 PST 2025 | Port 3389/tcp has been disabled permanently.
Sun Feb 16 23:16:16 PST 2025 | Disabling port 1900/udp permanently...
Sun Feb 16 23:16:16 PST 2025 | Port 1900/udp has been disabled permanently.
Sun Feb 16 23:16:16 PST 2025 | Disabling port 20/tcp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Disabling port 21/tcp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Ports 20 21/tcp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:16 PST 2025 | Disabling port 20/udp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Disabling port 21/udp in pf.conf...
Sun Feb 16 23:16:16 PST 2025 | Ports 20 21/udp have been disabled permanently in pf.conf.
Sun Feb 16 23:16:16 PST 2025 | Disabling port 23/tcp permanently...
Sun Feb 16 23:16:16 PST 2025 | Port 23/tcp has been disabled permanently.
Sun Feb 16 23:16:16 PST 2025 | Done. Closing script...
```
