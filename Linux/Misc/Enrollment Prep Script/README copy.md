# Deploying Azure Linux VM for Intune Testing
This script simplifies installing the depoendencies for getting an Ubuntu client ready to enroll into Intune.

It performs the following commands:


```
sudo apt install wget apt-transport-https software-properties-common
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
rm packages-microsoft-prod.deb
sudo apt install intune-portal
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"
sudo apt install microsoft-edge-stable
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main"
```

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://github.com/microsoft/shell-intune-samples/raw/master/Linux/Misc/Enrollment%20Prep%20Script/LinuxIntuneEnrollmentPrep.sh)"
```
