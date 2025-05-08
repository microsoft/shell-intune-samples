# Set Microsoft Office as Default Apps Script

This script automates setting Microsoft Word, Excel, PowerPoint, and Outlook as the default handlers for their respective document types and URL schemes on macOS. It is designed for deployment via [Microsoft Intune](https://learn.microsoft.com/mem/intune/apps/macos-shell-scripts).

## Features

- Detects and installs [`utiluti`](https://github.com/scriptingosx/utiluti) v1.1 if not present.
- Detects the current console (GUI) user and applies associations in their context.
- Associates common Office file types (Word, Excel, PowerPoint) with the corresponding Microsoft app.
- Sets Outlook as the default handler for email-related document types and URL schemes (e.g., `mailto:`).
- Logs all actions to `/Library/Logs/IntuneScripts/setOfficeDefaultApps/setOfficeDefaultApps.log`.

## Requirements

- macOS 13 (Ventura) or later (tested up to Sonoma).
- Must be run as root (e.g., via Intune, Jamf, or sudo).
- Microsoft Office apps (Word, Excel, PowerPoint, Outlook) must be installed in `/Applications`.
- Internet access to download `utiluti` if not already installed.

## Usage

Deploy or run the script as root. For Intune deployment instructions, see:  
[Use shell scripts on macOS devices in Intune](https://learn.microsoft.com/mem/intune/apps/macos-shell-scripts)

To run manually:

```sh
sudo ./setOfficeDefaultApps.sh
```

The script will:

1. Ensure `utiluti` is installed.
2. Detect the logged-in console user.
3. Set default app associations for Office file types and email schemes for that user.

## File Associations Set

- **Word:** `.doc`, `.docx`, `.dotx`, `.rtf`
- **Excel:** `.xls`, `.xlsx`, `.csv`
- **PowerPoint:** `.ppt`, `.pptx`, `.ppsx`
- **Outlook:** `.ics`, `.eml`, `.email`, `mailto:`, `message:`

## Logging

All output is logged to:

```
/Library/Logs/IntuneScripts/setOfficeDefaultApps/setOfficeDefaultApps.log
```

## Exit Codes

- `0`: Success
- `1`: Error (e.g., not run as root, missing Office app, or no console user)

## Support & Disclaimer

This script is provided as-is and is not covered under any Microsoft standard support program or service. Use at your own risk. For feedback or issues, contact neiljohn@microsoft.com.

---

**Related:**  
- [`setOfficeDefaultApps.sh`](setOfficeDefaultApps.sh)
- [utiluti GitHub](https://github.com/scriptingosx/utiluti)