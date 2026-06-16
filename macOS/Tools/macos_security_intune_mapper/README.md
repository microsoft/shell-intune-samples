# macOS Security Baselines Generator for Microsoft Intune

Initially written by Chien Yee Lim

Convert macOS security baselines to Microsoft Intune Settings Catalog policies and mobileconfig files.

## Features

- **GUI Application**: User-friendly interface for generating policies
- **CLI Tool**: Command-line interface for automation and scripting
- **Settings Catalog Mapping**: Automatically maps baseline rules to Intune Settings Catalog format
- **Mobileconfig Generation**: Creates mobileconfig files for unmapped rules
- **Multiple Export Formats**: Combined or split by section/type
- **Dependency Analysis**: Identifies and handles rule dependencies
- **ODV Resolution**: Automatically resolves Organizational Default Values (ODV) based on the selected baseline

## Installation

### Prerequisites

- Python 3.8 or higher
- Required packages (see below)

### Install Dependencies

```bash
pip install pyyaml wxpython
```

## Usage

### GUI Application

Launch the graphical interface:

```bash
cd macos_security_intune_mapper
python gui_main.py
```

The GUI allows you to:
1. Select a baseline from the dropdown
2. View mapping results and statistics
3. Choose export format (combined or split by section)
4. Export to your chosen directory

**Output Files** (Combined mode):
- `baseline-name.json` - Settings Catalog policy
- `baseline-name.mobileconfig` - Mobileconfig for unmapped rules

### Command-Line Interface

#### Interactive Mode (Recommended)

Simply run the CLI tool without arguments for an interactive experience:

```bash
cd macos_security_intune_mapper
python cli_generate.py
```

The tool will prompt you for:
1. **Settings Catalog JSON location** - Path to `settingsCatalog.json`
2. **macOS Security folder** - Path to the `macos_security` folder containing baselines
3. **Baseline selection** - Choose from a numbered list of available baselines
4. **Output directory** - Where to save the generated files

**Partial parameters**: You can also provide some parameters via command-line to skip those prompts:

```bash
# Provide paths, only prompt for baseline selection
python cli_generate.py -c settingsCatalog.json -m ../macos_security -o ./output

# The tool will skip asking for catalog/macos_security/output and only prompt for baseline
```

Example session:
```
============================================================
macOS Security Baselines Generator - Interactive Mode
============================================================

Step 1: Settings Catalog JSON file
Enter path to settingsCatalog.json [./settingsCatalog.json]: 

Step 2: macOS Security folder
Enter path to macos_security folder [../macos_security]: 

✓ Found 15 baselines

============================================================
Available Baselines:
============================================================
  1. cis_lvl1
  2. cis_lvl2
  3. 800-53r5_high
  4. 800-53r5_moderate
  ...

Enter baseline number (1-15) or 'q' to quit: 2

✓ Selected: cis_lvl2

Step 3: Output directory
Enter output directory [.]: ./output
```

#### Advanced Command-Line Mode

For automation and scripting, you can provide all parameters:

```bash
cd macos_security_intune_mapper

# Full command with all parameters
python cli_generate.py -b cis_lvl2 -c settingsCatalog.json -m ../macos_security -o ./output

# With verbose output
python cli_generate.py -b 800-53r5_high -c ./settingsCatalog.json -m ../macos_security -v
```

**Output Files**:
- `baseline-name.json` - Settings Catalog policy (JSON format for Intune)
- `baseline-name.mobileconfig` - Combined mobileconfig for unmapped rules

### CLI Options

```
optional arguments:
  -h, --help            Show help message and exit
  -b BASELINE, --baseline BASELINE
                        Name of the baseline to process (skips interactive mode)
  -c CATALOG, --catalog CATALOG
                        Path to settingsCatalog.json file
  -m MACOS_SECURITY, --macos-security MACOS_SECURITY
                        Path to macos_security folder
  -o OUTPUT, --output OUTPUT
                        Output directory (default: current directory)
  -v, --verbose         Enable verbose output
```

## Project Structure

```
macos_security_baselines_generator/
├── macos_security_intune_mapper/
│   ├── cli_generate.py         # Command-line tool (interactive & advanced modes)
│   ├── gui_main.py             # GUI application entry point
│   ├── settingsCatalog.json    # Microsoft Intune Settings Catalog
│   ├── core/                   # Core functionality
│   │   ├── baseline_loader.py  # Loads baselines from YAML
│   │   ├── rules_loader.py     # Loads individual rules
│   │   ├── settings_catalog.py # Settings Catalog interface
│   │   ├── policy_mapper.py    # Maps rules to policies
│   │   └── exporter.py         # Exports to JSON/mobileconfig
│   ├── gui/                    # GUI components
│   │   ├── main_window.py      # Main application window
│   │   └── export_dialog.py    # Export configuration dialog
│   └── models/                 # Data models
│       ├── baseline.py         # Baseline model
│       ├── rule.py             # Rule model
│       └── policy.py           # Policy model
├── example_usage.py            # Programmatic usage example
├── README.md                   # This file
└── QUICKSTART.md               # Quick start guide
```

External dependency (required):
```
macos_security/                 # macOS security baselines repository
├── baselines/                  # YAML baseline definitions
└── rules/                      # Individual rule definitions
```

## Output Formats

### Settings Catalog JSON

A JSON file compatible with Microsoft Intune's Settings Catalog API. Can be imported directly into Intune using Graph API or manually via the Intune portal.

### Mobileconfig

Traditional Apple Configuration Profile format (.mobileconfig) for rules that cannot be mapped to Settings Catalog. Can be deployed through MDM solutions.

## Organizational Default Values (ODV)

The tools automatically resolve **ODV (Organizational Default Values)** placeholders in rules based on the selected baseline. Some rules use `$ODV` as a placeholder that gets replaced with baseline-specific values:

- Each baseline (e.g., CIS Level 1, CIS Level 2, NIST 800-53) may have different recommended values for the same setting
- The tool automatically looks up the correct value for your chosen baseline
- Falls back to the "recommended" value if baseline-specific value is not found
- Both GUI and CLI handle this automatically - no manual configuration needed

**Example**: A password length rule might have:
- CIS Level 1: 14 characters
- CIS Level 2: 15 characters  
- NIST 800-53 High: 15 characters

When you select a baseline, the tool automatically uses the correct value.

## Examples

### Interactive Mode (Easiest)

```bash
cd macos_security_intune_mapper
python cli_generate.py
```

Follow the prompts to:
1. Specify settings catalog location
2. Specify macos_security folder
3. Choose a baseline from the numbered list
4. Choose output directory

### Generate CIS Level 2 Baseline (Advanced Mode)

```bash
cd macos_security_intune_mapper
python cli_generate.py -b cis_lvl2 -c settingsCatalog.json -m ../macos_security -o ./output
```

Generates:
- `./output/cis-lvl2.json`
- `./output/cis-lvl2.mobileconfig`

### Generate NIST 800-53 High Impact (Advanced Mode)

```bash
cd macos_security_intune_mapper
python cli_generate.py -b 800-53r5_high -c settingsCatalog.json -m ../macos_security
```

Generates:
- `./800-53r5-high.json`
- `./800-53r5-high.mobileconfig`

## Logging

Both GUI and CLI generate logs in `macos_security_intune_mapper.log` with detailed information about the mapping process, including:
- Rules successfully mapped to Settings Catalog
- Rules exported as mobileconfig
- Dependencies detected
- Any warnings or errors

## Troubleshooting

### "Baseline not found"

Make sure the `macos_security` folder with baselines is in the correct location. Use `--list` to see available baselines.

### "Settings Catalog file not found"

Ensure `settingsCatalog.json` is in the `macos_security_intune_mapper/` directory.

### Import Error

The Settings Catalog JSON from Intune may reject policies with missing required dependencies. The tool now automatically adds required child settings with default values to prevent this issue.

## License

See LICENSE file for details.
