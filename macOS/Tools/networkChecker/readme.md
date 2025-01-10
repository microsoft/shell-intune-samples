
# Intune Endpoint Checker

`intuneEndpointChecker.sh` is a Bash script designed to verify IPv4 connectivity to a predefined list of critical endpoints used by Microsoft Intune. It resolves hostnames to their IPv4 addresses and performs connectivity tests on specified ports using either TCP or UDP protocols. Results are presented in a real-time, color-coded table indicating the connectivity status for each address.

---

## Features

- **Hostname Resolution**: Dynamically resolves hostnames to their IPv4 addresses, handling CNAMEs where applicable.
- **Connectivity Testing**: Verifies connectivity using TCP or UDP protocols on specified ports.
- **Real-Time Feedback**: Displays results in a neatly formatted, color-coded table.
- **Extensible**: Easily update the list of endpoints and protocols.

---

## Requirements

- **Bash** (standard shell on macOS/Linux)
- **Dependencies**:
  - `dig` (for DNS lookups)
  - `nc` (Netcat, for network connectivity testing)

---

## Usage

### 1. Make the Script Executable
```bash
chmod +x intuneEndpointChecker.sh
```

### 2. Run the Script
```bash
./intuneEndpointChecker.sh
```

### 3. Optional: Log Output to File
```bash
./intuneEndpointChecker.sh | tee connectivity_log.txt
```

---

## Endpoint Configuration

The script includes a predefined list of endpoints critical for Microsoft Intune and Apple services. Each endpoint is specified in the format:
```
hostname:port:protocol
```

Example:
```bash
login.microsoftonline.com:443:TCP
time.apple.com:123:UDP
```

You can add, modify, or remove endpoints directly in the `ENDPOINTS` array within the script.

The endpoints were taken from public documentation available here:

 - [Network endpoints for Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-endpoints?tabs=north-america)
 - [Use Apple products on enterprise networks](https://support.apple.com/en-gb/101555)

---

## Example Output

```
=== IPv4 Connectivity ===
IP Address       Endpoint                              Port  Protocol Status
------------     -----------------------------------   ----  -------- ---------------
13.82.28.61      login.microsoftonline.com             443   TCP      SUCCESS
20.190.132.1     graph.microsoft.com                   443   TCP      FAILURE
N/A              time.apple.com                        123   UDP      No IPv4 addresses found
```

---

## Error Handling

- The script checks for missing dependencies (`dig` and `nc`) before execution.
- Errors during hostname resolution or connectivity testing are gracefully handled and logged.

---

## License

This script is provided **AS IS**, without warranty of any kind. Use it at your own risk. See the script's header for full disclaimers.

---

## Feedback and Contributions

Feedback or contributions are welcome. Please contact **Neil Johnson** at `neiljohn@microsoft.com`.

---
