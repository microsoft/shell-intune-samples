# Intune MDM Log Gather Script for macOS

This script collects comprehensive diagnostics and logs from a macOS device to assist with Microsoft Intune troubleshooting. It is designed for deployment via [Intune Shell Scripts](https://learn.microsoft.com/mem/intune/apps/macos-shell-scripts) and can be run locally or through Intune.

---

## Features

- **Collects**:
  - MDM client queries and logs
  - App Store install logs
  - System install.log* and system.log* files
  - Per-user Company Portal logs
  - Intune Agent logs (last 30 days)
  - Optional sysdiagnose bundle (with timeout)
- **Organizes** output into a timestamped folder under `/var/tmp`
- **Optionally zips** results to the Desktop of the logged-in user
- **Configurable**: Enable/disable collectors via environment variables

---

## Usage

**Run as root:**
```sh
sudo ./gatherIntuneLogs.sh
```

**Disable sysdiagnose or ZIP output (optional):**
```sh
sudo GATHER_SYSDIAGNOSE=false ZIP_OUTPUT=false ./gatherIntuneLogs.sh
```

**Environment variable switches:**
- `GATHER_MDMCLIENT` (default: true)
- `GATHER_APP_INSTALL` (default: true)
- `GATHER_INSTALL_LOGS` (default: true)
- `GATHER_SYSTEM_LOGS` (default: true)
- `GATHER_COMPANY_PORTAL` (default: true)
- `GATHER_INTUNE_AGENT` (default: true)
- `GATHER_SYSDIAGNOSE` (default: true)
- `ZIP_OUTPUT` (default: true)

---

## Output

- **Primary folder:** `/var/tmp/IntuneDiagnostics_<YYYYMMDD_HHMMSS>`
- **Subfolders:** `mdmclient`, `appInstall`, `installLogs`, `systemLogs`, `companyPortal`, `intuneAgent`, `sysdiagnose`
- **Log file:** `gatherIntuneLogs.log` in the root of the output folder
- **ZIP archive:** (if enabled and a console user is detected) on the user's Desktop

---

## Example Output

```
2025-04-17 13:52:52 | Starting Intune diagnostics → /var/tmp/IntuneDiagnostics_20250417_135252
2025-04-17 13:52:52 | Detected console user: neiljohnson
2025-04-17 13:52:52 | Gathering mdmclient → /var/tmp/IntuneDiagnostics_20250417_135252/mdmclient
...
2025-04-17 13:55:43 | Diagnostics collected into /var/tmp/IntuneDiagnostics_20250417_135252
    /var/tmp/IntuneDiagnostics_20250417_135252/gatherIntuneLogs.log
    /var/tmp/IntuneDiagnostics_20250417_135252/sysdiagnose/sysdiagnose.tar.gz
    /var/tmp/IntuneDiagnostics_20250417_135252/intuneAgent/Intune/IntuneMDMDaemon*.log
    /var/tmp/IntuneDiagnostics_20250417_135252/mdmclient/mdmclientLogs.txt
    /var/tmp/IntuneDiagnostics_20250417_135252/companyPortal/com.microsoft.CompanyPortalMac*.log
    /var/tmp/IntuneDiagnostics_20250417_135252/appInstall/appInstallLogs.txt
    /var/tmp/IntuneDiagnostics_20250417_135252/systemLogs/system.log*
    /var/tmp/IntuneDiagnostics_20250417_135252/installLogs/install.log*
2025-04-17 13:55:43 | Creating ZIP → /Users/neiljohnson/Desktop/IntuneDiagnostics_20250417_135252.zip
2025-04-17 13:55:52 | ZIP creation succeeded
2025-04-17 13:55:52 | Collection complete
```

---

## Notes

- **Must be run as root** to access all required logs.
- **Disk space:** Ensure sufficient space under `/var/tmp` and on the Desktop for ZIP output.
- **sysdiagnose** may take several minutes and produces a large archive.
- **Company Portal logs** are only collected if a console user is detected.

---

## Troubleshooting

- Review `gatherIntuneLogs.log` in the output folder for errors or warnings.
- If ZIP creation fails, check disk space and permissions on the Desktop.

---

## References

- [Intune Shell Scripts Documentation](https://learn.microsoft.com/mem/intune/apps/macos-shell-scripts)
- [Intune Log Collection](https://learn.microsoft.com/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

---
