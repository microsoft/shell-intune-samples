# Instructions to Create and prepare an Ubuntu Virtual Machine in Azure for Intune Testing

This document is a guide to creating an Ubuntu Linux Virtual Machine in
Azure that you can use for Intune testing.

Contact: <neiljohn@microsoft.com> for errors and omissions.

The guide assumes the following:

1.  You have a functioning Azure environment and have the permissions to create virtual machines
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

-   Run the following script and enter a new password for the local user when prompted - you'll need this to login, so make sure you remember it!

```
sudo /bin/bash -c "$(curl -fsSL https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Azure%20VM/installUbuntuDesktopandXRDP.sh)"
```


## Step 3 -- Configure XRDP

-   Edit the XRDP sesman file by running the following script
    terminal session
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
-   Paste the following commands into the terminal session

```
sudo apt install wget apt-transport-https software-properties-common -y
wget -q "https://packages.microsoft.com/config/ubuntu/\$(lsb_release-rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
rm packages-microsoft-prod.deb
sudo apt install intune-portal -y
sudo add-apt-repository "deb [arch=amd64]
https://packages.microsoft.com/repos/edge stable main"
sudo apt install microsoft-edge-stable -y
```

Alternatively, you can pase this line, which will download a script that executes the previous commands in one go

```
sudo /bin/bash -c "$(curl -fsSL https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Enrollment%20Prep%20Script/LinuxIntuneEnrollmentPrep.sh)"
```

---

## Step 5 -- Enrol into Intune

-   Press **Windows Key** \> Type **Microsoft Intune** \> Press
    **Enter**

-   Follow enrolment flow in Microsoft Intune app

> Note: If you do not get the UI to enter your password, it's most
> likely an error in your xrdp-sesman file. Please repeat that section
> and try again.