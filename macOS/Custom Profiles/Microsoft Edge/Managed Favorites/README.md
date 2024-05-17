# Managed Favorites for Microsoft Edge
On corporate environments, you might came across situation that you need to deploy managed favorites to different user groups or countries. Therefore, you should not deploy managed bookmarks using your basline policy that will be deployed to all users, instead you should deploy managed favorites to different user groups or countries using custom profile.

This custom profile has been created as an example how to deploy managed bookmarks of Microsoft Edge to specific user group or country.

## Things you'll need to do
- From line 48, replace "Microsoft" from your corporate name e.g. "Contoso".
- Starting from line 50, gather your managed favorites following [documented instructions(https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#description-407).
- From Intune, deploy custom profile to specific security group that contains members of specific user group or users from specific country.