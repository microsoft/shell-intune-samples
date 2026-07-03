# Check-PSSO

A script that verifies Platform SSO (PSSO) registration and enables the AutoFill from Company Portal extension on macOS devices.

## What the Script Does

1. **Waits for the user session** — Polls for the Dock process (up to 10 minutes) to ensure a user is logged in.
2. **Checks Platform SSO registration** — Runs `app-sso platform -s` as the console user and verifies `registrationCompleted` is `true`.
3. **Waits for the AutoFill extension** — Polls `pluginkit` for up to 5 minutes until Company Portal's `com.microsoft.CompanyPortalMac.Mac-Autofill-Extension` extension is registered.
4. **Enables AutoFill from Company Portal** — Runs `pluginkit -e use -i` to enable the extension, which also activates the toggle in **System Settings > General > AutoFill & Passwords**.

Logs are written to `/Library/Logs/Microsoft/IntuneScripts/checkPSSO/Check-PSSO.log`.

## Requirements

- macOS 13 (Ventura) or later
- Company Portal installed on the device
- Platform SSO configured via an Intune SSO extension profile

## Deploying via Payloadless PKG in Intune

A payloadless PKG is an empty package with no payload and no embedded scripts. The `Check-PSSO.zsh` script is added separately as a **pre-install script** when uploading the PKG to Intune.

### Step 1 — Build the Payloadless PKG

Use [CreatePayloadlessPkg.sh](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Apps/Payloadless) from the shell-intune-samples repo to create the empty PKG:

```bash
curl -O https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Payloadless/CreatePayloadlessPkg.sh
chmod +x CreatePayloadlessPkg.sh
./CreatePayloadlessPkg.sh
```

When prompted, enter:

- **Application name:** `CheckPSSO`
- **Version:** `1.0`

This creates `CheckPSSO.pkg` in the current directory.

### Step 2 — Upload the PKG to Intune

1. Sign in to the [Microsoft Intune admin center](https://intune.microsoft.com).
2. Navigate to **Apps** > **macOS** > **Add**.
3. Select **macOS app (PKG)** as the app type and click **Select**.
4. Click **Select app package file** and upload the `CheckPSSO.pkg` you built in Step 1.
5. On the **Pre-install script** step, upload `Check-PSSO.zsh` as the pre-install script.
6. Fill in the app information:
   - **Name:** Check Platform SSO
   - **Description:** Verifies PSSO registration and enables AutoFill from Company Portal.
   - **Publisher:** Your organization name
7. On the **Detection rules** step, the PKG receipt identifier `com.yourcompany.CheckPSSO` is used automatically.
8. Assign the app:
   - **Required** — to run automatically on targeted devices.
   - **Available for enrolled devices** — to let users install it from Company Portal on-demand.
9. Click **Create**.

### Step 3 — Verify Deployment

After the PKG is deployed to a device, check the log file to confirm the pre-install script ran:

```bash
cat /Library/Logs/Microsoft/IntuneScripts/checkPSSO/Check-PSSO.log
```

You should see entries indicating the PSSO registration status and AutoFill extension state.

## Verbose Mode

The script includes a `verbose` variable (line 7, default `false`). Set it to `true` for detailed diagnostic output including:

- macOS version, hardware model, and script execution context
- Full `app-sso platform -s` JSON output with exit code
- Company Portal version and install path
- AutoFill extension bundle path verification
- All registered `pluginkit` credential provider extensions

This is useful when troubleshooting why a check is failing on a specific device.

## Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | PSSO registered **and** AutoFill from Company Portal enabled |
| `1` | A check failed (no user session, PSSO not configured/registered, AutoFill not found or failed to enable) |

## References

- [Exploring the use cases of payloadless packages in Microsoft Intune for macOS](https://techcommunity.microsoft.com/blog/intunecustomersuccess/exploring-the-use-cases-of-payloadless-packages-in-microsoft-intune-for-macos/4382728)
- [Add an unmanaged macOS PKG app to Microsoft Intune](https://learn.microsoft.com/mem/intune/apps/macos-unmanaged-pkg)
- [Understand pre-install and post-install scripts for macOS in Microsoft Intune](https://aka.ms/Intune/macOS-install-types)
- [CreatePayloadlessPkg.sh (shell-intune-samples)](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Apps/Payloadless)
