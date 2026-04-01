# Intune Portal Installer

Automates installation of Microsoft Intune Portal and dependencies (including
Microsoft Edge) on supported Linux distributions.

## Supported Distributions

- Ubuntu 22.04, 24.04
- RHEL / AlmaLinux 8, 9

## Usage

```bash
# Basic install
./installer.sh

# Use insiders-fast channel
./installer.sh --insiders-fast

# Install from a local .deb/.rpm
./installer.sh --local-package ./intune-portal-1.2404.1-1.deb

# Show detailed output in terminal
./installer.sh --verbose
```

## Flags

| Flag                     | Description                                          |
|--------------------------|------------------------------------------------------|
| `--insiders-fast`        | Use the insiders-fast channel instead of prod        |
| `--local-package <path>` | Install from a local .deb/.rpm instead of the repo   |
| `--verbose`              | Show detailed output in the terminal                 |
| `-h`, `--help`           | Show usage information                               |

## Notes

- The script auto-elevates to root if not already running as root.
- All output is logged to `~/intune-installer.log`.
- Safe to run multiple times (idempotent repo config and GPG key import).

