# Intune Company Portal Installation Scripts

This folder contains two scripts that both install the **same standard Company Portal app** from the Microsoft CDN. There are no special PSSO components or modified builds — the difference is purely in which pre-install checks each script performs.

## Scripts

### installCompanyPortal.zsh

The full install script for general use. Suitable for DEP/ADE enrolled Macs and end-user driven installs.

**What it does:**
- Checks for and installs Rosetta 2 (Apple Silicon)
- Checks if Company Portal is already installed and whether an update is available
- Waits for the macOS desktop (Dock) to be ready before downloading
- Downloads and validates the Company Portal PKG
- Downloads and installs Microsoft AutoUpdate (MAU)
- Terminates any running Company Portal process before installing

### installCompanyPortalPSSO.zsh

A simplified install script designed for **Platform SSO (PSSO) during Setup Assistant** in Intune (available from late April 2026). Since this script runs before the user reaches the desktop, it skips checks that are unnecessary or would cause it to hang during Setup Assistant.

> **Important:** This installs the exact same Company Portal app as the standard script. There is nothing PSSO-specific about the app itself — this script simply removes checks that don't apply during Setup Assistant.

**What it skips (and why):**
- Rosetta 2 check — not required for Company Portal's universal binary
- Desktop readiness wait — Setup Assistant runs before the Dock is available, waiting would hang
- Update check — Company Portal won't already be installed during first-time setup
- Process termination — nothing to terminate on a fresh install

**What it keeps:**
- PKG download with file validation
- Microsoft AutoUpdate (MAU) install
- Logging

## Scenarios

| Scenario | Script to use |
|----------|---------------|
| DEP/ADE enrolled Macs needing device registration for Conditional Access | `installCompanyPortal.zsh` |
| End-user self-enrolment | `installCompanyPortal.zsh` |
| Platform SSO registration during Setup Assistant | `installCompanyPortalPSSO.zsh` |

## Quick Run

```
sudo /bin/zsh -c "$(curl -L https://aka.ms/installcp)" ; open "/Applications/Company Portal.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log Files

| Script | Log location |
|--------|-------------|
| `installCompanyPortal.zsh` | `/Library/Logs/Microsoft/IntuneScripts/installCompanyPortal/Company Portal.log` |
| `installCompanyPortalPSSO.zsh` | `/Library/Logs/Microsoft/IntuneScripts/installCompanyPortalPSSO/Company Portal.log` |

Exit status is either 0 (success) or 1 (failure). To gather logs remotely see [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
