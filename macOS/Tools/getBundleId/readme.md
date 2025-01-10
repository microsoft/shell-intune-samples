
# getBundleId.py

## Overview

The `getBundleId.py` script extracts package receipts (PkgIDs) and bundle identifiers (BundleIDs) from `.pkg` files on macOS. It allows users to analyze `.pkg` files for compatibility, validate configurations, or gather information about installed packages.

This tool is designed for IT Administrators who need to determine the right bundleid to use in Intune detection without having to install the PKG.

## Features

- **Expand `.pkg` files**: Uses macOS's `pkgutil` to expand `.pkg` files into a temporary directory.
- **Extract IDs**: Gathers PkgIDs from `PackageInfo` and `Distribution` files, as well as BundleIDs from `PackageInfo` and associated `Info.plist` files.
- **ID Comparison**: Compares PkgIDs with BundleIDs for exact or substring matches.
- **Verbose Logging**: Provides detailed logging for troubleshooting.

## Requirements

- macOS with Python 3.7 or later.
- `pkgutil` must be available on the system (default on macOS).
- Python modules: `argparse`, `os`, `subprocess`, `tempfile`, `xml.etree.ElementTree`, `plistlib`, `sys`, `logging`, `platform`.

## Installation

1. Clone or download the script to your local machine.
2. Ensure the script is executable:

   ```bash
   chmod +x getBundleId.py
   ```

3. Run the script with Python 3.

## Usage

Run the script with the required arguments:

```bash
./getBundleId.py --pkg_path <path_to_pkg> [--exact] [--verbose]
```

### Options:

- `--pkg_path`: (Required) The path to the `.pkg` file to analyze.
- `--exact`: (Optional) Enable exact matching between PkgIDs and BundleIDs. By default, partial matches are allowed.
- `--verbose`: (Optional) Enable detailed logging for debugging purposes.

### Example:

Analyze a package with verbose output:

```bash
./getBundleId.py --pkg_path example.pkg --verbose
```

Enable exact matching for PkgIDs and BundleIDs:

```bash
./getBundleId.py --pkg_path example.pkg --exact
```

## Output

The script outputs the matched BundleIDs (one per line) that correspond to the extracted PkgIDs. Use redirection to save the results to a file:

```bash
./getBundleId.py --pkg_path example.pkg > matched_bundleids.txt
```

## Limitations

- Currently supports `.pkg` analysis only on macOS.
- Non-macOS systems are not supported (future work may address this limitation).
- Requires `pkgutil` for package expansion.

## Contributing

Feel free to submit issues or pull requests to improve functionality or address bugs. Contributions are welcome!
