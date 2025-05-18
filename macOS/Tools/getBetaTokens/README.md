# Apple MDM Beta Token Automation

This project automates the process of obtaining, extracting, and managing Apple MDM server tokens (`*.p7m`) for beta OS enrollment via Apple Business Manager (ABM).

## Why?
Apple's beta OS programs require special MDM server tokens for device enrollment and management. The process for obtaining, decrypting, and using these tokens is manual and error-prone. This script streamlines the workflow for IT administrators, ensuring secure handling of credentials and easy access to all available beta tokens. For background, see Apple's official documentation on MDM Beta Management and Software Updates.

## Features
- Generates a private key and self-signed certificate if needed
- Watches for new `*.p7m` tokens in your Downloads folder
- Decrypts and extracts OAuth credentials from the server token
- Authenticates to Apple's MDM service and fetches available beta enrollment tokens
- Displays all available beta tokens in a readable, sortable table (sorted by title)

## Requirements
- macOS
- `openssl`, `jq`, `curl`, `perl`

## Usage
1. **Clone this repository** and open a terminal in the project directory.
2. **Run the script:**
   ```sh
   ./betaTokens.sh
   ```
3. If no valid tokens are found, the script will:
   - Generate a private key and self-signed certificate
   - Prompt you to upload the PEM certificate to Apple Business Manager (Settings → MDM Servers)
   - Watch your `~/Downloads` folder for a new `*.p7m` token
   - Copy the token to the working directory and proceed
4. The script will decrypt the token, extract credentials, authenticate, and display all available beta enrollment tokens in a formatted table, sorted by title.

## Output Example
```
┌───────────────┬──────┬──────────────────────────────┐
│ Title         │ OS   │ Token                        │
├───────────────┼──────┼──────────────────────────────┤
│ iOS 18 Beta   │ iOS  │ ...                          │
│ macOS 15 Beta │ mac  │ ...                          │
└───────────────┴──────┴──────────────────────────────┘
```

## Learn More
For more information on Apple beta software deployment and MDM, see the official Apple documentation: [Deploy Apple beta software in your organization](https://support.apple.com/en-gb/guide/deployment/depe8583cf10/web)

## Security
- All keys, certificates, and tokens are stored in the `abm_auth/` directory.
- Never share your private key or decrypted tokens.

## Troubleshooting
- Ensure all dependencies are installed: `openssl`, `jq`, `curl`, `perl`
- If decryption fails, verify that the PEM uploaded to ABM matches the generated one
- For URL encoding issues, ensure `perl` is available (macOS default)

## Support
This project is provided as-is, with no support or warranty.

## License
This project is provided as-is for educational and administrative use. For official guidance, refer to Apple's documentation on MDM Beta Management and Software Updates.
