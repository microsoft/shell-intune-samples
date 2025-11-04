# Migration Script

There are mutliple scripts in this repository. The scripts are designed to help you migrate from Jamf to Intune or from Intune to Intune. The scripts are designed to be run on macOS devices and require administrative privileges.

[Jamf to Intune Migration Script](#jamf-to-intune-migration-script)

[Intune to Intune Migration Script](#intune-to-intune-migration-script)

# Jamf To Intune Migration Script

This script facilitates the migration of macOS devices from Jamf to Microsoft Intune. It handles the **removal of the Jamf framework**, **installation** of the Microsoft Intune Company Portal app (if required), and ensures a smooth transition to Intune. The script uses **swiftDialog** for user interactions and provides clear progress and status messages throughout the migration.

---

https://github.com/user-attachments/assets/5669bd8d-7642-4321-bc46-cd38b97e28a6

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

4. **Intune Enrollment Experience**
   - In the demo video 1m 21s where the screen shows 'Status: Waiting for Intune', this is where this script has finished performing actions. At this stage we are waiting for the Intune enrollment actions to begin. This is on YOU to configure and deploy. If you just deploy this script it will wait on this screen forever. In the demo video the Intune onboarding experience is provided by the [swiftDialog onboarding sample](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Swift%20Dialog%20(PKG)).

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

# Intune To Intune Migration Script

This script facilitates the migration of macOS devices from Microsoft Intune to Microsoft Intune. It handles the **removal of the Intune Managment**, **removal of Sidecar**, **installation** of the Microsoft Intune Company Portal app (if required), and ensures a smooth transition to Intune. The script uses **swiftDialog** for user interactions and provides clear progress and status messages throughout the migration.

---

https://github.com/user-attachments/assets/5669bd8d-7642-4321-bc46-cd38b97e28a6

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
   - The script will detect if the device is managed by Intune. If not, it exits.  
   - If it detects Intune, it installs `swiftDialog` (if missing) and then prompts the user to either **Migrate** or **Exit**.  
   - If **Exit** is chosen, the script cancels and leaves Intune in place.  
   - If **Migrate** is chosen, the script proceeds to remove the Intune and prepare the device for another Intune tenant.

---

## Prerequisites

1. **Device Enrollment**  
   - If your organization uses **Apple Business Manager (ABM)** and **ADE** (Automated Device Enrollment), ensure the device is assigned to Intune in ABM before starting.  

2. **swiftDialog**  
   - The script will install **swiftDialog** automatically if it’s not already present.  

3. **Internet Connectivity**  
   - Required to download the Microsoft Intune Company Portal and any other dependencies.

4. **Intune Enrollment Experience**
   - When the screen shows 'Status: Waiting for Intune', this is where this script has finished performing actions. At this stage we are waiting for the Intune enrollment actions to begin. This is on YOU to configure and deploy. If you just deploy this script it will wait on this screen forever. An example can be found in [swiftDialog onboarding sample](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/Swift%20Dialog%20(PKG)).

5. **Graph API Permissions**  
   - Ensure the script has the necessary permissions to call the Graph API for unmanaging the device. This typically requires **DeviceManagementManagedDevices.ReadWrite.All** permissions. To do this, you need to create an **Azure AD App** and assign the required permissions. To do this, follow the steps below:

      1. Go to Azure Portal
         - Navigate to: https://portal.azure.com
         - Open Azure Active Directory > App registrations

      2. Register a New App
         - Click + New registration
         - Name your app (e.g., IntuneDeviceMigration)
         - Set Supported account types (usually “Single tenant” is fine)
         - Click Register

      3. Create a Client Secret
         - Go to Certificates & secrets
         - Click + New client secret
         - Add a description and expiry, then Copy the value and save it somewhere safe

      4. Add Graph API Permissions
         - Go to API permissions > + Add a permission
         - Choose Microsoft Graph
         - Select Application permissions
         - Search for and add: `DeviceManagementManagedDevices.ReadWrite.All`

      5. Grant Admin Consent
         - Still under API permissions, click Grant admin consent for your tenant

      6. Save App Info for Use in Scripts

      You’ll need the following values:
         - Tenant ID
         - Client ID
         - Client Secret (from step 3)

---

## Features

1. **User Prompts via `swiftDialog`**  
   - Displays clear dialogs to guide the user through the migration.  
   - Provides progress updates during the removal and installation steps.

2. **Automatic Intune Removal**  
   - Unmanages the device via Graph API calls and removes Intune only after user confirmation.

3. **ADE Enrollment Handling**  
   - If the device is **ADE-enrolled**, the script renews the device’s profiles and launches Apple’s Setup Assistant steps as needed.

4. **Company Portal Installation**  
   - Checks if **Microsoft Intune Company Portal** is installed. Installs it if missing.

5. **Real-Time Progress Updates**  
   - Uses progress bars (via `swiftDialog`) to keep the user informed.

6. **Graceful Cleanup**  
   - Kills any leftover `Dialog` processes as needed, preventing orphaned processes.

---

## Configuration Options

- **Graph API Details**  
  - Inside the script, you can edit your `CLIENT_ID`, `CLIENT_SECRET`, and `TENANT_ID` to point to the correct Intune instance.  
- **Script Functions**  
  - The script is modularized into functions (e.g., `check_if_managed`, `remove_intune_management`, etc.), which you can rearrange or customize for your environment.
- **max_deferral_count** 
  - Allows you to set the maximum number of deferrals for the user. The default is 0.
- **uninstall_swiftdialog** 
  - The script will uninstall `swiftDialog` automatically if set to true.
- **reset_office** 
  - The script will reset `Microsoft Office` automatically if set to true using office-reset.com
- **blur_screen** 
  - SwiftDialog will blur the screen by default. Can be set to false if you want to disable this feature.
- **title_font_options** 
  - Allows you to set the font options for the title. The default is "shadow=0,name=SFProDisplay-Regular".
- **banner_colour** 
  - Allows you to set the banner colour. The default is "blue".
- **migration_message_intune** 
  - Allows you to set the migration message.
- **progress_message_intune**
   - Allows you to set the progress message.

---

## What the Script Does

1. **Checks Intune Management**  
   - Looks for `Microsoft.Profiles.MDM` profiles. If not present, it exits immediately.

2. **Installs `swiftDialog`** (if needed)  
   - Downloads and installs `swiftDialog` to provide user prompts.

3. **Prompts the User to Migrate**  
   - Presents a dialog with the option to **Migrate** or **Exit**.  
   - If the user exits, the script ends (no changes made to Jamf).

4. **Removes Intune** (After User Consent)  
   - Obtains the **Graph API auth token**, looks up the **serial number**, then “unmanages” the device through Graph API.  
   - Removes **Sidecar** to fully clean up before enrollment to a new tenant.

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
   - Run the script on a test Mac enrolled in Intune to verify that the framework is removed and Intune enrollment steps appear.  

2. **User Experience**  
   - Confirm that the user sees dialogs at the correct steps (migration prompt, progress bar, sign-in prompt).  
   - Validate that exiting from the first prompt really does leave Intune in place.

3. **Network/Connectivity**  
   - Ensure the test Mac can reach the necessary endpoints (Intune, Microsoft CDN for Company Portal, etc.).

---

## Deployment

- **Intune Script**  
  - You can host this script in Intune and assign to devices that should migrate.  
  - Once the user clicks “Run,” they’ll receive the migration prompt.

- **Manual Execution**  
  - SSH into the Mac or run the script locally with `sudo ./intuneMigration.sh`.

---

## Logs

- Logs are saved to:  
  `/Library/Logs/Microsoft/IntuneScripts/intuneMigration/intuneMigration.log`

  This includes status messages, API responses, and installation details. Review it if you encounter issues.

---

# Feedback

For questions or feedback, please reach out to:
- **Neil Johnson**: neiljohn@microsoft.com

---

# Disclaimer

This script is provided **“AS IS”** without warranty of any kind. Microsoft disclaims all implied warranties, including, without limitation, any implied warranties of merchantability or fitness for a particular purpose. The entire risk arising out of the use or performance of this script remains with you.
