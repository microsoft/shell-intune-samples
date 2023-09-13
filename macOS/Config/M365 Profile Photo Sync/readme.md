# How to setup Photo download :

This process requires three steps:

1. Create an Azure application to provide permissions
2. Deploy the Office Activation E-mail Policy
3. Deploy script to download and set profile photo

To see a demo of it working



https://github.com/microsoft/shell-intune-samples/assets/27012389/c6e01b0c-c97f-4afc-b268-ea619fb74fd5




## Step1. Create Azure Application

1. Open Azure Portal (https://portal.azure.com)
2. Open Azure active directory \> App Registrations \> New Registration
3. Complete the registration as follows:

1. **Name** : Mac Profile Photo Download
2. **Supported Account Types** : Accounts in this organizational directory only
3. Click Register when done

1. Open API Permissions
  1. Remove **User.Read** permission
  2. Add New \> Microsoft Graph \> Application permission \> User.Read.All
  3. Add permission
2. Overview \> Client Credentials \> Add a certificate or secret
  1. New client secret
  2. Description: MacPhotoDownload
  3. Expires: 3 / 12 / 18 or 24 months
  4. Add
  5. Copy the secret VALUE (not ID) you'll need it later and you cannot get at it after the app has been created.

Now we have the application, we need the following values from it. Go to [https://portal.azure.com](https://portal.azure.com/) and open AAD. Then select App registrations and open Mac Profile Photo Download.

We need the following from the overview page

- Application (client) ID
- Directory (tenant) ID

And the secret you made a note of earlier

## Step 2. Deploy Office Activation E-Mail Policy

The process needs to know the UPN of the end user. The easiest way to achieve that (and make your Office users lives easier) is to deploy the Office Activation E-Mail via Intune Settings Catalog.

1. Intune \> Devices \> macOS \> Configuration profiles
2. Create profile \> settings catalog \> Create
3. Set Name to Office Activation E-Mail \> Next
4. Add settings \> Microsoft Office \> Microsoft Office \> Select all these settings
5. Type {{mail}} into Office Activation Email Address \> Next \> Next
6. Assign to your test group \> Next

## Step 3. Deploy Client Side Script

To download and set the profile photo, we need to deploy a [script](https://github.com/microsoft/shell-intune-samples/tree/master/macOS/Config/M365%20Profile%20Photo%20Sync) on the client side.

1. Open the script and edit lines 22,23 and 24 with the values that you saved earlier.

![](RackMultipart20230913-1-md8olm_html_f610dac1d893ddf7.png)

1. Once you have the edited script, run it as root on a test machine

![](RackMultipart20230913-1-md8olm_html_dde7d8aaa3d66b95.png)

1. Once you have tested the script works as expected, deploy it [via Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to run as root. Set schedule to run weekly.
