# Readme: Intune Migration Script

This script facilitates the migration of macOS devices from Jamf to Microsoft Intune. It handles the removal of the Jamf framework, installation of the Microsoft Intune Company Portal app (if required), and ensures a smooth transition to Intune.

---

## General Usage

The script uses `swiftDialog` for its UI and relies on core macOS commands to perform the migration steps. It ensures proper communication with the end user during the migration process and automates key tasks like app installation, framework removal, and profile renewal.

---

## Prerequisites

1. **Device Enrollment**:
   - If the device is registered in Apple Business Manager, the device must be assigned to Intune through ABM before starting the migration process.

2. **Dependencies**:
   - `swiftDialog` must be installed (handled by the script if not present).
   - Internet connectivity is required for downloading necessary components like the Company Portal app.

---

## Features

### User Prompts
- Provides clear instructions to users during the migration process.
- Displays progress dialogs and actionable prompts.

### Automatic Installation
- Installs the Microsoft Intune Company Portal app if it's not already present.

### Jamf Framework Removal
- Detects and removes the Jamf framework from the device.

### ADE Enrollment Handling
- Ensures the device completes ADE enrollment when required, renewing profiles as necessary.

### Seamless Transition
- Launches the Company Portal app and guides users to sign in for a smooth onboarding experience.

---

## Configuration Options

- The script includes predefined functions for key steps. No external configuration is needed for typical usage.

---

## What the Script Does

1. **Checks for Jamf Management**:
   - Verifies if the device is managed by Jamf before proceeding.
   
2. **Installs `swiftDialog`**:
   - Ensures `swiftDialog` is available for UI dialogs.
   
3. **Prompts User**:
   - Notifies users about the migration and allows them to start or defer the process.

4. **Removes Jamf Framework**:
   - Unmanages the device by removing Jamf framework files.

5. **Handles ADE Enrollment**:
   - Confirms ADE status and ensures required profiles are renewed.

6. **Installs Microsoft Intune Company Portal**:
   - Downloads and installs the app if it's not already available.

7. **Provides Real-Time Progress Updates**:
   - Uses `swiftDialog` progress bars to keep users informed.

8. **Final Steps**:
   - Guides users to sign in to the Company Portal or completes ADE-based setup.

---

## Testing

1. **Run the Script**:
   - Execute the script in a Bash shell with administrative privileges:
     ```bash
     sudo ./intuneMigration.sh
     ```

2. **Follow the Prompts**:
   - The script will provide guidance at every step. Users can follow on-screen instructions to complete the migration.

---

## Deployment

### Jamf Self-Service
- Upload the script to Jamf and make it available via self-service

---

## Logs

- Logs are saved to:
/Library/Logs/Microsoft/IntuneScripts/intuneMigration/intuneMigration.log
---

## Feedback

For issues or feedback, please contact:
- **Neil Johnson**: neiljohn@microsoft.com

---

## Disclaimer

This script is provided "AS IS" without warranty of any kind. Microsoft disclaims all implied warranties, including, without limitation, any implied warranties of merchantability or fitness for a particular purpose. The entire risk arising out of the use of this script and associated documentation remains with you.