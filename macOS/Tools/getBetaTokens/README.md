# Apple MDM Beta Token Automation

`betaTokens.sh` retrieves the Apple Business Manager (ABM) **beta seeding tokens** for your organization, and this README explains how to use those tokens to move managed devices onto, or keep them off, Apple's beta OS programs.

There are two stages:

1. **Get the token**: run `betaTokens.sh` to authenticate to Apple Business Manager and list every beta enrollment token available to your organization (covered immediately below).
2. **Use the token**: create Intune profiles to **block** beta for everyone and **allow** or **enforce** it for your early testers (see [Control beta in your organization](#control-beta-in-your-organization)).

## Why?
Apple's beta OS programs require a special token from Apple Business Manager before a managed device can enrol. Getting that token by hand (generating a key pair, uploading a certificate to ABM, downloading the encrypted `*.p7m`, decrypting it, then signing the OAuth request) is manual and error-prone. This script automates the whole flow and prints the tokens in a readable table.

## What the script does
1. Generates a private key and self-signed certificate (only if one isn't already present).
2. Waits for you to upload the certificate to ABM, then watches `~/Downloads` for the issued `*.p7m` token.
3. Decrypts the token and extracts the OAuth credentials.
4. Authenticates to Apple's MDM service and fetches the available beta enrollment tokens.
5. Prints every available beta token in a table, sorted by title.

## Requirements
- macOS
- `openssl`, `jq`, `curl`, `perl` (all ship with macOS)

## Running the script
1. **Clone this repository** and open a terminal in this folder (`macOS/Tools/getBetaTokens`).
2. **Run the script:**
   ```sh
   ./betaTokens.sh
   ```
3. On first run, when no token exists yet, the script will:
   - Generate a private key and self-signed certificate in `abm_auth/`.
   - Print the PEM and prompt you to upload it to **Apple Business Manager → Settings → MDM Servers**.
   - Watch `~/Downloads` for the issued `*.p7m` token and copy it into `abm_auth/`.
4. The script then decrypts the token, authenticates, and prints the available beta enrollment tokens, sorted by title.

Keep the **Token** value for the program you want. You'll paste it into an Intune profile as shown in [Control beta in your organization](#control-beta-in-your-organization).

## Output Example
```
┌───────────────┬──────┬──────────────────────────────┐
│ Title         │ OS   │ Token                        │
├───────────────┼──────┼──────────────────────────────┤
│ iOS 18 Beta   │ iOS  │ ...                          │
│ macOS 15 Beta │ mac  │ ...                          │
└───────────────┴──────┴──────────────────────────────┘
```

## Control beta in your organization

Once you have a token, you control beta with **Software Update Settings** profiles in the Intune **Settings Catalog**. Each profile below is one policy you assign to a group.

A typical rollout is three profiles:

1. **Block beta for everyone**: your baseline, assigned to everyone.
2. **Allow beta for testers**: let a pilot group opt in.
3. **Enforce beta for testers**: auto-enrol a pilot group, no opt-in.

**Assigning them, keep it simple.** You want to block beta for everyone, then exclude your testers. The catch: Intune won't let you exclude a **user** group from a policy that's assigned to **devices**, because the include and the exclude must be the same type. Since you'll want to exclude specific people, do everything by **user**. Assign **Block** to **All users**, put your testers in a **user** group (e.g. `Beta Testers`), and add that group to Block's **Excluded groups**; an exclusion always overrides the include. Then assign **Allow** or **Enforce** to that same group. Keeping it user-based also means membership follows the person, so it survives a wipe and re-enrol, whereas a device group would drop the Mac when re-enrolment issues a new device ID. After that, manage testers by editing the group; you never touch the policies again. For the mechanics, see [Assign policies in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign) and [exclude groups from an assignment](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign#exclude-groups-from-a-policy-assignment).

### Create a profile in Intune
Each scenario below starts the same way. In the [Microsoft Intune admin center](https://intune.microsoft.com):

1. Go to **Devices → macOS → Configuration**.
2. Click **Create → New Policy**.
3. Set **Profile type** to **Settings Catalog**, then click **Create**.
4. Give the policy a **Name** (e.g. `[macOS Beta] Allow - Allowed`) and click **Next**.
5. Click **+ Add settings**, then browse to **Declarative Device Management (DDM) → Software Update Settings** and add the **Beta** settings.
6. Configure the settings for your scenario (see steps 1–3 below), then **Next**.
7. Assign the policy to the right audience (**everyone** for the block profile, or your **testers** for allow/enforce; see the assignment note above), then finish the wizard.

> **Requirements:** Beta settings apply to **supervised** devices on **macOS 15.4+ / iOS 18+ / iPadOS 18+**, in the **system** scope, via Declarative Device Management (DDM). On older OS versions or unsupervised devices they're ignored.

> **"(Unsupported)" labels:** in the Settings Catalog these keys show as *Beta (Unsupported)*, *Token (Unsupported)*, etc. This only means Intune hasn't finished building end-to-end support for the workflow yet (for example, fetching the tokens for you). The keys themselves are fully supported by Apple, and Intune will still deploy them to your devices.

Everything is driven by one setting, **Program Enrollment**:

| Program Enrollment | Effect |
| --- | --- |
| `Allowed` (default) | Users can opt into the beta programs you offer. |
| `AlwaysOn` | The device is auto-enrolled into the program you require; users can't choose their own. |
| `AlwaysOff` | Beta is blocked, and the device is removed from any beta it's already on. |

Each scenario below has a ready-made sample in [`Intune Samples/`](Intune%20Samples). The quickest path is to grab the matching sample, change one line (your token), and assign it. If you'd rather click through the UI instead, follow the **Configure in the UI** steps. To import a sample, see [Using the samples](#using-the-samples).

### 1. Block beta for everyone
Your baseline. No token needed; assign this to **everyone** so nobody drifts onto a beta by accident.

- **Sample:** [\[macOS Beta\] Block - AlwaysOff.json](Intune%20Samples/%5BmacOS%20Beta%5D%20Block%20-%20AlwaysOff.json): no editing required, just import and assign.
- **Configure in the UI:** in the Beta settings, set **Program Enrollment** to **AlwaysOff**.

### 2. Allow beta for testers (opt-in)
Offer the beta to a pilot group and let them choose to join. Assign to your **testers** group only.

- **Sample:** [\[macOS Beta\] Allow - Allowed.json](Intune%20Samples/%5BmacOS%20Beta%5D%20Allow%20-%20Allowed.json): replace `REPLACE-WITH-TOKEN-FROM-SCRIPT` (**line 69**) with your token, then import and assign.
- **Configure in the UI:** under **Beta → Offer Programs**, click **Add**, then set **Description** (e.g. `macOS Beta`) and **Token** (paste from the script). Leave **Program Enrollment** at **Allowed**.

### 3. Enforce beta for testers (auto-enrol)
Automatically enrol a pilot group, with no opt-in. Assign to your **testers** group only.

- **Sample:** [\[macOS Beta\] Enforce - AlwaysOn.json](Intune%20Samples/%5BmacOS%20Beta%5D%20Enforce%20-%20AlwaysOn.json): replace `REPLACE-WITH-TOKEN-FROM-SCRIPT` (**line 80**) with your token, then import and assign.
- **Configure in the UI:** set **Program Enrollment** to **AlwaysOn**, then under **Beta → Require Program** set **Description** and **Token** (paste from the script). Don't also add an Offer Program.

### Using the samples
Each sample is a settings catalog policy exported to JSON, ready to import straight back into Intune. The tenant `id` is zeroed and the beta token is replaced by the placeholder `REPLACE-WITH-TOKEN-FROM-SCRIPT`.

1. Download the sample for your scenario from [`Intune Samples/`](Intune%20Samples).
2. For the **Allow** and **Enforce** samples, open the file in a text editor and replace `REPLACE-WITH-TOKEN-FROM-SCRIPT` with the **Token** from the script's output (the line is called out above). The **Block** sample needs no edit.
3. In the [Microsoft Intune admin center](https://intune.microsoft.com), go to **Devices → macOS → Configuration**, then select **Create → Import policy**.
4. Choose your edited JSON file, give the policy a **Name**, and **Save**.
5. Open the new policy, select **Properties → Assignments → Edit**, and assign it to the right audience (**everyone** for Block, or your **testers** for Allow/Enforce; see the assignment note above).

> **How do I import a JSON policy?** Many admins haven't used this before. Microsoft documents the exact steps (with screenshots) here: [Import and export a settings catalog profile](https://learn.microsoft.com/intune/device-configuration/settings-catalog/#import-and-export-a-profile). The **Import policy** button lives under **Create** on the Configuration page; the platform (macOS) is already baked into the sample, so the imported policy lands as a macOS profile.

Prefer to configure it by hand instead? The **Configure in the UI** steps under each scenario, combined with [Create a profile in Intune](#create-a-profile-in-intune), produce exactly the same policy.

> **Tip:** for the auto-enrol profile, set **both** Program Enrollment = `AlwaysOn` **and** Require Program. Adding Require Program on its own leaves enrollment at the `Allowed` default and nothing is enforced.

## References
- [`softwareupdate.settings.yaml`](https://github.com/apple/device-management/blob/release/declarative/declarations/configurations/softwareupdate.settings.yaml): Apple's authoritative schema for the configuration, including every `Beta` key and its constraints.
- [SoftwareUpdateSettings](https://developer.apple.com/documentation/devicemanagement/softwareupdatesettings): Apple Developer reference for the declaration (see the **Beta** object for `ProgramEnrollment`, `OfferPrograms`, and `RequireProgram`).
- [Deploy Apple beta software in your organization](https://support.apple.com/en-gb/guide/deployment/depe8583cf10/web): Apple deployment guide.

## Security
- All keys, certificates, and tokens are written to the `abm_auth/` directory.
- `mdm_private.key` and the decrypted `*.p7m` tokens are secrets. Don't share them or move them outside `abm_auth/`.
- Treat the beta tokens themselves as sensitive: they enroll devices into your organization's beta programs.

## Troubleshooting
- Ensure all dependencies are installed: `openssl`, `jq`, `curl`, `perl`.
- If decryption fails, verify that the PEM uploaded to ABM matches the one in `abm_auth/` (`mdm_public_cert.pem`).
- For URL-encoding issues, ensure `perl` is available (it ships with macOS).
- If the `Beta` settings seem to have no effect, confirm the device is **supervised**, on **macOS 15.4+ / iOS 18+**, and that the configuration is scoped to the **system**.

## Support
This project is provided as-is, with no support or warranty.

## License
This project is provided as-is for educational and administrative use. For official guidance, refer to Apple's documentation linked under [References](#references).
