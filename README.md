# mSCP CLI tool recommendation for Intune custom compliance

This repository is a **tool recommendation and integration guide**. It does not contain or claim to be the mSCP CLI. It recommends using the CLI from the official [NIST macOS Security Compliance Project](https://github.com/usnistgov/macos_security) to generate a macOS security baseline and discovery script for Microsoft Intune custom compliance.

The workflow selects an mSCP baseline, uses the recommended CLI to generate the macOS discovery script that detects target identifiers, validates its JSON output, and creates the matching Intune rules JSON.

## Important compatibility note

The recommended mSCP CLI generates the discovery script. The script detects target identifiers such as `system_settings_firewall_enable` and returns their current values. A separate Intune rules JSON file matches those identifiers and defines which values are compliant:

- It is a zsh audit/remediation script.
- It requires root.
- It writes audit results to local plist, log, and CSV files.
- The script can produce human-readable audit output or JSON discovery output, depending on the source revision.
- Intune requires one valid JSON object whose property names match the rules JSON `SettingName` values.

This guide assumes that the checked-out mSCP source supports `--json`. Verify `./mscp.py guidance --help` and the generated script before deployment. If the checked-out official source does not provide JSON output, the generated audit script cannot yet be used directly as an Intune discovery script; use a reviewed JSON-output implementation before uploading it.

## Prerequisites

Run the generation and testing steps on a Mac:

- macOS supported by the selected mSCP rule set
- Python 3.12 or later
- administrator access for audit testing
- `/bin/zsh` and the macOS utilities used by the selected checks
- `/usr/bin/jq` if your JSON-output integration uses it
- an Intune tenant with permission to create macOS compliance policies

## Step 1: clone the official mSCP repository

```bash
git clone https://github.com/usnistgov/macos_security.git
cd macos_security
```

Use a tagged release or a reviewed commit for production instead of silently changing source versions.

## Step 2: create the Python environment

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -e .
```

Confirm that the CLI starts:

```bash
./mscp.py --help
```

## Step 3: generate a baseline

Generate a CIS Level 1 baseline:

```bash
./mscp.py baseline -k cis_lvl1
```

The CLI searches the mSCP rule library for the `cis_lvl1` keyword and writes a YAML baseline similar to:

```text
custom/baselines/cis_lvl1_macos_26.0.yaml
```

The reported rule count is the number of selected rules. It is not a device compliance score.

You can inspect available baseline keywords before choosing one:

```bash
./mscp.py baseline --list_tags
```

## Step 4: generate the native mSCP compliance script

Use the baseline YAML as the positional argument and request script generation:

```bash
./mscp.py guidance \
  custom/baselines/cis_lvl1_macos_26.0.yaml \
  --script \
  --no-docs
```

The short form is:

```bash
./mscp.py guidance -s custom/baselines/cis_lvl1_macos_26.0.yaml
```

The generated files are placed under a directory similar to:

```text
build/cis_lvl1_macos_26.0/
  cis_lvl1_macos_26.0_compliance.sh
  preferences/
    org.cis_lvl1_macos_26.0.audit.plist
```

The script contains the check and remediation commands derived from the selected mSCP rules. `--no-docs` skips the AsciiDoc, PDF, and HTML guidance documents.

## Step 5: test the generated script safely

Run an audit-only check as root:

```bash
sudo ./build/cis_lvl1_macos_26.0/cis_lvl1_macos_26.0_compliance.sh \
  --check \
  --quiet=2
```

Do not use `--fix` or `--cfc` during Intune discovery testing. Those options can change device settings.

The native mSCP script records audit state in locations similar to:

```text
/Library/Preferences/org.cis_lvl1_macos_26.0.audit.plist
/Library/Logs/<hostname>_cis_lvl1_macos_26.0_baseline.log
/Library/Logs/<hostname>_cis_lvl1_macos_26.0_baseline.csv
```

Review the audit output and confirm that every selected check works on the target macOS version. Investigate empty values, command errors, and checks that report explanatory text instead of a simple value.

## Step 6: create the Intune rules JSON for the discovery identifiers

The discovery script returns target identifiers as JSON property names. Create an Intune rules JSON file that matches those identifiers exactly. It must contain a top-level `Rules` array. Each rule must map to a property returned by the discovery script:

- `SettingName` is case-sensitive and must match the discovered JSON property.
- `DataType` must match the returned type.
- `Operator` defines the comparison.
- `Operand` is the value considered compliant.
- `RemediationStrings` explains how to restore compliance.

Intune supports these operators:

```text
IsEquals
NotEquals
GreaterThan
GreaterEquals
LessThan
LessEquals
```

Example rule for a JSON property named `system_settings_firewall_enable`:

```json
{
  "Rules": [
    {
      "SettingName": "system_settings_firewall_enable",
      "Operator": "IsEquals",
      "DataType": "Boolean",
      "Operand": true,
      "MoreInfoUrl": "https://github.com/usnistgov/macos_security",
      "RemediationStrings": [
        {
          "Language": "en_US",
          "Title": "The firewall must be enabled. Value discovered was {ActualValue}.",
          "Description": "Enable the macOS firewall or apply the required management configuration."
        }
      ]
    }
  ]
}
```

The rules JSON matches the discovery identifiers; it does not run the checks. Build it from the reviewed mSCP rule metadata and the exact JSON output of the generated discovery script. Do not map a value such as `"FAIL  RUNNING"` to a Boolean rule without explicitly normalizing it first.

## Step 7: validate discovery identifiers and JSON output

Intune macOS custom compliance requires the uploaded discovery script to return one valid JSON object. Confirm that the generated discovery script:

1. Runs the selected mSCP checks in read-only mode.
2. Returns every intended target identifier as a stable JSON property name.
3. Returns booleans, integers, versions, and strings using the types declared in the rules JSON.
4. JSON-escapes multiline and special-character values.
5. Writes diagnostic logs to stderr or a file, never into the JSON response on stdout.
6. Returns a nonzero exit code when the discovery operation itself fails.

The expected shape is similar to:

```json
{
  "system_settings_firewall_enable": true,
  "audit_folders_mode_configure": 700,
  "system_settings_ssh_disable": "FAIL  RUNNING"
}
```

That object is the device's discovered state. Intune compares it with the `Rules` array; the object is not an overall compliance score.

Validate the final output on a pilot Mac:

```bash
sudo ./build/cis_lvl1_macos_26.0/cis_lvl1_macos_26.0_compliance.sh \
  --check \
  --quiet=2 \
  --json | /usr/bin/python3 -m json.tool
```

Use the JSON property names from this output as the `SettingName` values in the matching rules JSON. Do not upload a script until the discovery identifiers, output types, and rules JSON have been tested together.

## Step 8: upload the discovery script to Intune

1. Open **Intune admin center**.
2. Go to **Devices** -> **macOS** -> **Compliance** -> **Scripts**.
3. Select **Add** and create a macOS custom compliance discovery script.
4. Enter a descriptive name, such as `mSCP CIS Level 1 macOS 26.0`.
5. Upload the tested mSCP-generated JSON discovery script.
6. Set **Run this script using the logged on credentials** to **No** when the integration requires root, as the native mSCP audit script does.
7. Save the script.

## Step 9: create the Intune compliance policy

1. Go to **Devices** -> **macOS** -> **Compliance**.
2. Select **Create policy**.
3. Select **macOS** and the Mac compliance policy profile.
4. On **Compliance settings**, enable **Custom Compliance**.
5. Select the discovery script uploaded in Step 8.
6. Upload the rules JSON whose `SettingName` values match the identifiers returned by the discovery script.
7. Configure the noncompliance actions required for the pilot.
8. Assign the policy to a small pilot device group.
9. Review the policy and select **Create**.

The script and rules JSON are inseparable. Every `SettingName` in the rules JSON must be returned by the script with the declared data type.

## Step 10: validate device compliance

1. On a pilot Mac, open **Company Portal**.
2. Select **Devices**, select the Mac, and choose **Check Status**.
3. Wait for the device to check in.
4. In Intune, open **Reports** -> **Device compliance** -> **Noncompliant devices and settings**.
5. Filter for macOS and review each custom setting.

For troubleshooting, compare:

```text
mSCP rule metadata
  -> generated check
  -> JSON discovery property and value
  -> Intune rules JSON
  -> Intune per-setting result
```

Custom compliance evaluates and reports device state. It does not remediate the Mac. Use mSCP configuration profiles, DDM, another management policy, or a separately governed remediation process to enforce settings.

## Updating the baseline

When updating mSCP:

1. Review the selected source commit or release.
2. Regenerate the baseline YAML.
3. Regenerate the compliance script.
4. Re-test every JSON property and data type.
5. Update the Intune rules JSON when rule IDs, expected values, or supported checks change.
6. Pilot the updated script and policy before broad assignment.

Keep the generated baseline, script, rules JSON, source version, and test evidence together so the Intune policy can be reproduced and audited.
