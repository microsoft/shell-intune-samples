
        __    _                              ___                      
       / /   (_)___  __  ___  __     __     /   |____  __  __________ 
      / /   / / __ \/ / / / |/_/  __/ /_   / /| /_  / / / / / ___/ _ \
     / /___/ / / / / /_/ />  <   /_  __/  / ___ |/ /_/ /_/ / /  /  __/
    /_____/_/_/ /_/\__,_/_/|_|    /_/    /_/  |_/___/\__,_/_/   \___/ 
                                                                  


# Instructions to Create and prepare an Ubuntu Virtual Machine in Azure for Intune Testing

This document is a guide to creating an Ubuntu Linux Virtual Machine in
Azure that you can use for Intune testing.

Contact: <neiljohn@microsoft.com> for errors and omissions.

This guide is based on the following documentation:

- [Install and configure xrdp to use Remote Desktop with Ubuntu](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop?tabs=azure-cli)
- [Enroll Linux Device in Intune](https://learn.microsoft.com/en-us/mem/intune/user-help/enroll-device-linux)
- [Get The Microsoft App for Linux](https://learn.microsoft.com/en-us/mem/intune/user-help/microsoft-intune-app-linux)


---
## Step 1 -- Create VM

-   Use the Azure Portal to create a new Virtual Machine

    -   Instance Details

        -   Image: **Ubuntu Server 20.04 LTS -- x64 Gen2**
        -   VM Architecture: **x64**
        -   Size: **Standard_B2s -- 2 vcpus, 4GiB memory**

    -   Administrator Account

        -   Authentication type: **SSH public key**
        -   Username: **azureuser** (*Choose whatever you like*)
        -   SSH public key source: **Generate new key pair**
        -   Key pair name: **Linux-Test_key** (*Choose whatever you
            like*)

    -   Inbound port rules

        -   Public inbound ports: **None**

-   Click \> **Review + create** \> **Create** \> **Download private key
    and create.**

    -   Download private key somewhere safe.

-   Wait for resource to be created.

[Bastion Host]
Azure Bastion allows us to have Virtual Machines running in the cloud with no external access. We can then manage them via the Azure web portal, either via RDP or SSH.

>
> Note: If you already have Azure Bastion configured, make sure that
> it's configured as **Standard** and not **Basic** otherwise you won't
> get the option to connect via RDP to Linux.

-   Open the [Azure Portal](https://portal.azure.com/)

    -   Search for **Virtual Machines** and **launch** the blade
    -   Find your Virtual Machine and click on it in the UI
    -   Click \> **Bastion** \> **Create Azure Bastion using defaults**
    -   Once created (this can take 15-20 mins), search for **Bastions**
        in the Azure UI search box and click on the one you've just
        created.

        -   Click \> **Configuration** \> **Standard**
        -   Click \> **Copy and paste**
        -   Click \> **Apply** (this can take 15-20 mins)
---
## Step 2 -- Install ubuntu-desktop and XRDP

-   Open the [Azure Portal](https://portal.azure.com/)

    -   Search for **Virtual Machines** and **launch** the blade
    -   Find your Virtual Machine and click on it in the UI

-   Click \> **Bastion**

    -   Expand **Connection Settings**
    -   Ensure Protocol is **SSH/22**
    -   Username: **azureuser** (*or whatever you used*)
    -   Authentication Type: **SSH private key from Local File**
    -   Local File: **Profile path to key saved earlier.**
    -   Click \> **Connect** (*A terminal should appear in the browser*)

-   Copy and paste the following to run a script that will install Ubuntu Desktop and XRDP

```
sudo /bin/bash -c "$(curl -fsSL https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Azure%20VM/installUbuntuDesktopandXRDP.sh)"
```

-   Enter the following command to set a password for your user account (if you didn't use azureuser, make sure you specify the correct username). You'll need this later to sign in with RDP, so make it memorable.

```
sudo passwd azureuser
```

## Step 3 -- Configure XRDP

-   Copy and paste the following to edit Edit the XRDP sesman file
```
sudo wget -O /etc/pam.d/xrdp-sesman https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Azure%20VM/xrdp-sesman
```
-   Now we have everything installed, lets reboot before we login via RDP

```
sudo reboot
```
---
## Step 4 -- Configure and Install Intune

-   Open the [Azure Portal](https://portal.azure.com/)

    -   Search for **Virtual Machines** and **launch** the blade
    -   Find your Virtual Machine and click on it in the UI

-   Click \> **Bastion**

    -   Expand **Connection Settings**
    -   Ensure Protocol is **RDP/3389**
    -   Username: **azureuser** (or whatever you used)
    -   Authentication Type: **Password**
    -   Password: **(whatever you set it to)**
    -   Click \> **Connect** (The ubuntu desktop should appear in the
        browser)

-   Follow Ubuntu Welcome screens and change whatever you need to for
    your region
-   Press \> **Windows Key** \> Type **Terminal** and press **Enter**
-   Paste the following command into the terminal window, which will run a script to install dependencies, plus the Intune Portal and Microsoft Edge Stable apps. 


```
sudo /bin/bash -c "$(curl -fsSL https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Enrollment%20Prep%20Script/LinuxIntuneEnrollmentPrep.sh)"
```

---

## Step 5 -- Enroll into Intune

-   Press **Windows Key** \> Type **Microsoft Intune** \> Press
    **Enter**

-   Follow enrolment flow in Microsoft Intune app

> Note: If you do not get the UI to enter your password, it's most
> likely an error in your xrdp-sesman file. Please repeat that section
> and try again.