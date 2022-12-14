# This section of scripts is for App Deployment

The scripts in this section are mostly related to app installation via the the [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts). There are a number of reasons why you might want to use the Scripting Agent to handle installation.

- App isn't signed and you don't have access to the correct certificate
- App is complex, has embedded apps or multiple payloads (not compatible with macOS MDM stack pkg delivery)
- App has complex dependencies and you want to handle those via a script
- You just don't want the hassle of packaging the app regularly
