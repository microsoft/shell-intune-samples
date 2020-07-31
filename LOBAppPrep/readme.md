# DmgToIntuneMac Script

This script is provided to assist with the creation of macOS MDM stack compatible pkg files. More information on this process can be found in our documentation [How to add macOS line-of-business apps to Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/apps/lob-apps-macos).

# Usage

From a terminal window, run this dmg conversion script, including the input arguments as required below.
The output file will be written to the location the script is ran from.
Input flags + arguments
 -d: (required) dmg path
 -n: (required) desired output filename (no extension)
 -s: (optional) DeveloperID to sign pkg (common cert)
 -p: (optional) Output a .pkg rather than .intunemac

# Example:
./DmgtoIntunemac.sh -d ~/Downloads/Spotify.dmg -n SpotifyFinal

>Notes:
>1. Make sure that the DmgtoIntunemac.sh shell script is located in the same directory as the Intune App Wrapping Tool (IntuneAppUtil) found at https://github.com/msintuneappsdk/intune-app-wrapping-tool-mac. The name of this directory when downloaded from Microsoft is: intune-app-wrapping-tool-mac-master.
>2. Although the signing flag is optional for this conversion script, packages must be signed in order to successfully install as a managed app. 
