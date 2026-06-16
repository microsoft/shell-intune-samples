# Quick Start Guide

## Testing the Tools

### CLI Tool (Interactive Mode - Recommended)

1. **Run the interactive tool**:
   ```bash
   cd macos_security_intune_mapper
   python cli_generate.py
   ```

2. **Follow the prompts**:
   - **Step 1**: Enter path to `settingsCatalog.json` (or press Enter for default)
   - **Step 2**: Enter path to `macos_security` folder (or press Enter for default)
   - **Step 3**: Choose a baseline from the numbered list (1-X)
   - **Step 4**: Enter output directory (or press Enter for current directory)

3. **Partial prompts** - Skip some steps by providing parameters:
   ```bash
   # Provide catalog and macos_security paths, only prompt for baseline
   python cli_generate.py -c settingsCatalog.json -m ../macos_security
   
   # Provide all paths, only prompt for baseline selection
   python cli_generate.py -c settingsCatalog.json -m ../macos_security -o ./output
   ```
   The tool will use provided values and only prompt for what's missing!

3. **Example interactive session**:
   ```
   macOS Security Baselines Generator - Interactive Mode
   
   Step 1: Settings Catalog JSON file
   Enter path to settingsCatalog.json [./settingsCatalog.json]: 
   
   Step 2: macOS Security folder
   Enter path to macos_security folder [../macos_security]: 
   
   ✓ Found 15 baselines
   
   Available Baselines:
   ============================================================
     1. cis_lvl1
     2. cis_lvl2
     3. 800-53r5_high
     ...
   
   Enter baseline number (1-15) or 'q' to quit: 2
   
   ✓ Selected: cis_lvl2
   
   Step 3: Output directory
   Enter output directory [.]: ./output
   ```

4. **Using command-line parameters to skip prompts**:
   ```bash
   # If you already know the paths, provide them to skip those prompts
   python cli_generate.py \
     -c "C:\path\to\settingsCatalog.json" \
     -m "C:\path\to\macos_security" \
     -o "C:\output"
   
   # This will ONLY prompt you for baseline selection
   # Everything else is pre-filled from your parameters
   ```

### CLI Tool (Advanced Command-Line Mode)

For automation or scripting:

```bash
cd macos_security_intune_mapper

# Full command with all parameters
python cli_generate.py -b cis_lvl2 -c settingsCatalog.json -m ../macos_security -o ./output

# With verbose logging
python cli_generate.py -b 800-53r5_high -c ./settingsCatalog.json -m ../macos_security -v
```

### GUI Tool

1. **Launch the GUI**:
   ```bash
   cd macos_security_intune_mapper
   python gui_main.py
   ```

2. **Using the GUI**:
   - Select a baseline from the dropdown
   - Click "Map to Intune" to process
   - Review the mapping results
   - Click "Export" to generate files
   - Choose export format:
     - **Combined**: Single file with all settings (default)
       - Generates: `baseline-name.json` and `baseline-name.mobileconfig`
     - **Split by Section**: Separate files per section
       - Generates: `baseline-name-section.json` files
   - Select output directory
   - Click "Export" to save files

## File Naming Convention

Both CLI and GUI now use consistent naming:

### Combined Mode (Default)
- **Settings Catalog**: `baseline-name.json`
- **Mobileconfig**: `baseline-name.mobileconfig`

### Split by Section Mode
- **Settings Catalog**: `baseline-name-section.json`
- **Mobileconfig by Type**: `baseline-name-type.mobileconfig`

Examples:
- `cis-lvl2.json`
- `cis-lvl2.mobileconfig`
- `800-53r5-high.json`
- `800-53r5-high.mobileconfig`

## What Gets Generated

### Settings Catalog JSON
Rules that can be mapped to Microsoft Intune Settings Catalog are exported as a JSON file that can be:
- Imported via Microsoft Graph API
- Used as reference for manual configuration in Intune portal

### Mobileconfig Files
Rules that cannot be mapped to Settings Catalog are exported as traditional Apple Configuration Profiles (.mobileconfig). These can be:
- Deployed via Intune as Custom Profiles
- Used with other MDM solutions
- Manually installed on devices

### Organizational Default Values (ODV)
Both the GUI and CLI automatically resolve **ODV placeholders** in rules:
- Each baseline may have different recommended values for the same setting
- The tool automatically uses the correct value for your selected baseline
- Example: Password length might be 14 for CIS Level 1 and 15 for CIS Level 2
- No manual configuration needed - it happens automatically!

## Common Issues

### "Baselines path does not exist"
The tool expects a `macos_security/baselines` folder with YAML baseline files. When running interactively, you'll be prompted to specify the location of this folder.

**Solution**: 
- In interactive mode, enter the correct path when prompted in Step 2
- Make sure the path points to the root `macos_security` folder (not `macos_security/baselines`)

### Import to Intune fails
If Intune rejects the JSON import:
1. Check the error message for missing dependencies
2. The tool now automatically adds required child settings with defaults (like FileVault2 enable)
3. Regenerate the policy to get the latest fixes

### GUI doesn't launch
Make sure wxPython is installed:
```bash
pip install wxpython
```

### "Module not found" error
Make sure you're running from the correct directory:
```bash
cd macos_security_intune_mapper
python cli_generate.py
# or
python gui_main.py
```

## Next Steps

1. Review the generated JSON file structure
2. Test import into Intune (see Intune documentation)
3. Deploy mobileconfig files for unmapped settings
4. Customize the policies as needed for your environment
