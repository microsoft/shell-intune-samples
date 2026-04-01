# Intune Agent Timing Custom Attributes for macOS

This folder contains two Microsoft Intune custom attribute scripts that measure how long it takes a macOS device to move from initial MDM profile installation to key Intune agent milestones.

Both scripts are designed to return a single value suitable for Intune custom attribute ingestion:

- A decimal number of seconds when the required markers are found
- `unknown` when the relevant historical log entries are no longer available

## Included Scripts

| Script | Purpose | Data sources | Default output |
|---|---|---|---|
| `intune_agent_install_time_from_mdm.sh` | Measures time from MDM profile installation to Microsoft Intune Agent installation | Unified log (`mdmclient`, `appstored`) | Seconds or `unknown` |
| `intune_agent_health_time_from_mdm.sh` | Measures time from MDM profile installation to the first healthy Intune agent marker | Unified log plus `/Library/Logs/Microsoft/Intune/IntuneMDMDaemon *.log` | Seconds or `unknown` |

## What Each Script Looks For

### `intune_agent_install_time_from_mdm.sh`

Start marker:
- `mdmclient` log entry showing installation of the Microsoft MDM management profile

End marker:
- Preferred: `Application was installed at:` for `com.microsoft.intuneMDMAgent`
- Fallback: `installClientDidFinish`

### `intune_agent_health_time_from_mdm.sh`

Start marker:
- `mdmclient` log entry showing installation of the Microsoft MDM management profile

End marker priority:
1. `HealthCheckWorkflow | Completed health check Domain: regular`
2. `VerifyEnrollmentStatus | Successfully verified enrollment status.`
3. `VerifyEnrollmentStatus | Successfully verified device status.`
4. `VerifyEnrollmentStatus | Retrieved enrollment info.`

## Requirements

- macOS device with Microsoft Intune enrollment activity in the local logs
- Access to unified logs via `/usr/bin/log`
- For the health script, Intune agent log files under `/Library/Logs/Microsoft/Intune`

## Usage

These scripts are intended for Microsoft Intune custom attributes and should be uploaded without additional arguments.

### Local validation

Run locally to verify the current output:

```bash
./intune_agent_install_time_from_mdm.sh
./intune_agent_health_time_from_mdm.sh
```

Use verbose mode when you want to see the markers that were selected:

```bash
./intune_agent_install_time_from_mdm.sh --last 7d --verbose
./intune_agent_health_time_from_mdm.sh --last 7d --verbose
```

`--last` accepts values supported by `log show --last`, such as `12h`, `7d`, or `30d`.

## Intune Notes

- Keep the scripts in their default output mode for custom attribute collection
- Do **not** use `--verbose` in Intune, because verbose mode prints multiple lines for troubleshooting
- If the required historical markers have already rolled out of the available logs, the script returns `unknown` instead of failing

## Example Output

```text
482.153
```

or

```text
unknown
```

## Troubleshooting

If a script returns `unknown`, common reasons include:

- The requested lookback window does not reach the original enrollment event
- Relevant unified log entries have already aged out
- For the health script, the Intune daemon log files are unavailable or no healthy marker exists after the MDM install event

Increase the lookback window and run with `--verbose` locally to see which markers were found.
