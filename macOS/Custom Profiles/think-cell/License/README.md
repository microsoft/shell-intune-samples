# think-cell - License
This Custom Profile installs think-cell license key.

More information of think-cell: https://www.think-cell.com/en

### Notes
- **Deploy this custom profile only for users that have think-cell available on Company Portal and those users that are using think-cell -application.**
- If you need to deploy managed settings to think-cell, check this custom profile.
- For deploying your corporate default style file to your users, please check this.  

## Task that needs to be done before deploying this custom profile
From line 45, you will see placeholder of the license key:
``
ABCDE-ABCDE-ABCDE-ABCDE-ABCDE
``
<br>
Replace this placeholder with your actual think-cell -license key. After that, you are now ready to deploy the custom profile.
 
## Configuration settings for Intune
- **Custom configuration profile name:** *think-cell - License*
- **Deployment channel:** *Device Channel*
- **Configuration profile name:** *think-cell - License.mobileconfig*