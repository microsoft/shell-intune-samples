# Intune Migration Script

This script facilitates the migration of macOS devices from Jamf to Microsoft Intune. It handles the **removal of the Jamf framework**, **installation** of the Microsoft Intune Company Portal app (if required), and ensures a smooth transition to Intune. The script uses **swiftDialog** for user interactions and provides clear progress and status messages throughout the migration.

---

https://github.com/user-attachments/assets/9f788360-61be-4c9f-93c3-9e4018d45194

## General Usage

1. **Make the Script Executable**  
   ```bash
   chmod +x intuneMigration.sh
   ```

2. **Run the Script**  
   ```bash
   sudo ./intuneMigration.sh
   ```

3. **Follow On-Screen Prompts**  
   - The script will detect if the device is managed by Jamf. If not, it exits.  
   - If it detects Jamf, it installs `swiftDialog` (if missing) and then prompts the user to either **Migrate** or **Exit**.  
   - If **Exit** is chosen, the script cancels and leaves Jamf in place.  
   - If **Migrate** is chosen, the script proceeds to remove the Jamf framework and prepare the device for Intune.

---

## Prerequisites

1. **Device Enrollment**  
   - If your organization uses **Apple Business Manager (ABM)** and **ADE** (Automated Device Enrollment), ensure the device is assigned to Intune in ABM before starting.  

2. **swiftDialog**  
   - The script will install **swiftDialog** automatically if it’s not already present.  

3. **Internet Connectivity**  
   - Required to download the Microsoft Intune Company Portal and any other dependencies.

---

## Features

1. **User Prompts via `swiftDialog`**  
   - Displays clear dialogs to guide the user through the migration.  
   - Provides progress updates during the removal and installation steps.

2. **Automatic Jamf Framework Removal**  
   - Unmanages the device via Jamf Pro API calls and removes the Jamf framework only after user confirmation.

3. **ADE Enrollment Handling**  
   - If the device is **ADE-enrolled**, the script renews the device’s profiles and launches Apple’s Setup Assistant steps as needed.

4. **Company Portal Installation**  
   - Checks if **Microsoft Intune Company Portal** is installed. Installs it if missing.

5. **Real-Time Progress Updates**  
   - Uses progress bars (via `swiftDialog`) to keep the user informed.

6. **Graceful Cleanup**  
   - Kills any leftover `Dialog` or `jamf` processes as needed, preventing orphaned processes.

---

## Configuration Options

- **Jamf Pro Credentials**  
  - Inside the script, you can edit your `USERNAME`, `PASSWORD`, and `JAMF_PRO_URL` to point to the correct Jamf Pro instance.  
- **Script Functions**  
  - The script is modularized into functions (e.g., `check_if_managed`, `remove_jamf_framework`, etc.), which you can rearrange or customize for your environment.

---

## What the Script Does

1. **Checks Jamf Management**  
   - Looks for `com.jamfsoftware` profiles. If not present, it exits immediately.

2. **Installs `swiftDialog`** (if needed)  
   - Downloads and installs `swiftDialog` to provide user prompts.

3. **Prompts the User to Migrate**  
   - Presents a dialog with the option to **Migrate** or **Exit**.  
   - If the user exits, the script ends (no changes made to Jamf).

4. **Removes Jamf** (After User Consent)  
   - Obtains the **Jamf Pro auth token**, looks up the **computer_id**, then “unmanages” the device through the Jamf Pro API.  
   - Runs `jamf removeFramework` to fully remove the Jamf agent.

5. **Installs or Validates Company Portal**  
   - Checks if **Company Portal** is installed.  
   - If not, downloads and installs it from Microsoft.

6. **Checks ADE Enrollment**  
   - Determines if the Mac is enrolled via **ADE (DEP)**.

7. **Handles ADE and Profile Renewals**  
   - If ADE-enrolled, prompts the user to complete Setup Assistant screens, then **renews** the device’s profiles.  
   - Shows a **“waiting for Intune”** dialog until the user completes the ADE steps.

8. **Non-ADE Flow**  
   - If not ADE-enrolled, guides the user to **sign in to Company Portal** for Intune onboarding.

9. **Progress Dialog and Cleanup**  
   - Provides real-time status updates via a progress dialog.  
   - Ends by cleaning up `Dialog` processes.

---

## Testing

1. **Local Testing**  
   - Run the script on a test Mac enrolled in Jamf to verify that the framework is removed and Intune enrollment steps appear.  

2. **User Experience**  
   - Confirm that the user sees dialogs at the correct steps (migration prompt, progress bar, sign-in prompt).  
   - Validate that exiting from the first prompt really does leave Jamf in place.

3. **Network/Connectivity**  
   - Ensure the test Mac can reach the necessary endpoints (Jamf Pro URL, Microsoft CDN for Company Portal, etc.).

---

## Deployment

- **Jamf Self Service**  
  - You can host this script in Jamf and present it via Self Service for users to self-initiate.  
  - Once the user clicks “Run,” they’ll receive the migration prompt.

- **Manual Execution**  
  - SSH into the Mac or run the script locally with `sudo ./intuneMigration.sh`.

---

## Logs

- Logs are saved to:  
  `/Library/Logs/Microsoft/IntuneScripts/intuneMigration/intuneMigration.log`

  This includes status messages, API responses, and installation details. Review it if you encounter issues.

---

## Feedback

For questions or feedback, please reach out to:
- **Neil Johnson**: neiljohn@microsoft.com

---

## Disclaimer

This script is provided **“AS IS”** without warranty of any kind. Microsoft disclaims all implied warranties, including, without limitation, any implied warranties of merchantability or fitness for a particular purpose. The entire risk arising out of the use or performance of this script remains with you.
