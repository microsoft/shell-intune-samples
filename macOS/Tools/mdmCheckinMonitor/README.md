# MDM Check-in Monitor

## Overview
Real-time monitoring tool that detects and displays Microsoft Intune MDM check-in events on macOS by streaming unified log entries from the `mdmclient` process.

## Prerequisites
- macOS device enrolled in Microsoft Intune
- Terminal access
- Root/sudo privileges (required for log streaming)

## Usage
1. Navigate to the tool directory:
   ```bash
   cd macOS/Tools/mdmCheckinMonitor
   ```

2. Make the script executable (if needed):
   ```bash
   chmod +x monitorMdmCheckin.zsh
   ```

3. Run the monitor with sudo:
   ```bash
   sudo ./monitorMdmCheckin.zsh
   ```

4. The script will continuously monitor for MDM check-in events. Press `Ctrl+C` to stop monitoring.

## What it monitors
The script watches for MDM client check-in events by filtering the unified log stream for:
- Process: `mdmclient`
- Event type: DeclarativeManagement requests for Device context
- Message pattern: `"Processing server request: DeclarativeManagement for"` containing `"<Device>"`

## Output
When an MDM check-in is detected, the script displays:
- Timestamp of detection
- Full log entry from `mdmclient`
- Separator line for readability

Example output:
```
Monitoring for MDM client check-in events...
Press Ctrl+C to exit

[2025-11-04 14:32:15] MDM Check-in detected:
2025-11-04 14:32:15.123456+0000 0x12345  Info       0x0    mdmclient: Processing server request: DeclarativeManagement for <Device>
-------------------------
```

## Use cases
- Verify MDM check-in timing and frequency
- Troubleshoot MDM communication issues
- Monitor device management activity in real-time
- Correlate MDM events with other system behavior

## Notes
- The script runs continuously until manually stopped with `Ctrl+C`
- This is a monitoring-only tool and takes no actions on the system
- Log streaming may show a brief "Filtering the log data..." header at startup (automatically ignored)
