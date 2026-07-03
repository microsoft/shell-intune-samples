# Payloadless PKGs

This script is an example to show how to create payloadless PKGs as referenced in this blog:

[Exploring the use cases of payloadless packages in Microsoft Intune for macOS](https://techcommunity.microsoft.com/blog/intunecustomersuccess/exploring-the-use-cases-of-payloadless-packages-in-microsoft-intune-for-macos/4382728)

## CreatePayloadlessPkg.sh

An interactive script that creates a payloadless PKG file. When run, it prompts for:

1. **Application name** – used as both the PKG filename and the bundle identifier (e.g., `com.yourcompany.<AppName>`)
2. **Version** – the version string embedded in the package (e.g., `1.0`)

The script creates a temporary empty directory, builds the package with `pkgbuild`, cleans up, and reveals the resulting `.pkg` file in Finder on success.

### Usage

```bash
chmod +x CreatePayloadlessPkg.sh
./CreatePayloadlessPkg.sh
```

### Things you'll need to do

1. Update the `--identifier` prefix in the script (default `com.yourcompany`) to match your organization's reverse-domain identifier

