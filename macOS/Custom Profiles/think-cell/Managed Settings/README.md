# think-cell - Managed Settings
This custom profile installs managed settings to think-cell. This custom profile has been created as an example and can be customized on your business needs if needed.

With this custom profile, deploying managed settings to think-cell via Microsoft Intune is really easy.

More information of managed settings of think-cell: https://www.think-cell.com/en/resources/manual/deploymentguide

### Note  
- **Deploy this to all users (also for those users that are not using think-cell).** 
- If you need to deploy the think-cell -license key, check this custom profile.
- For deploying your corporate default style file to your users, please check this.

## Managed settings for think-cell
| Setting | Preference key| Value | Description |
| ------- | ------------- | ----- | ----------- |
| Automatic Updates | ``com.think-cell.settings.updates``| true | think-cell has built-in automatic update support. If automatic updates are enabled and PowerPoint is started, the software checks whether a new version is available. The user then has the option to either accept or delay the update.|
| Default Style File | ``com.think-cell.settings.defaultstyle``| ``/Library/Application Support/Microsoft/think-cell/styles/Corporate style.xml`` | N/A |
| Error Reporting | ``com.think-cell.settings.reports``| true | think-cell has built-in error reporting to help us find and fix bugs quickly. Here you can enable or disable this error reporting. |
| Support | ``com.think-cell.settings.support``| ```helpdesk@example.com``` | think-cell offers to send email to support whenever an error occurs, or whenever the user selects More - Request Support. Here you may change the default recipient for such support emails. think-cell uses Simple MAPI to send email, so the exact format of this address may depend on your email system. |
| Suppress First Start Actions | ``com.think-cell.settings.nofirststart``| true | Suppresses actions associated with the first start of think-cell, such as switching to the Insert ribbon and opening the Getting Started web page. |
| Product Access Control | ``com.think-cell.settings.products``| 3 | Controls access to the various think-cell products, on top of any restrictions imposed by the license key.<ul> 0. think-cell chart, layout and round</ul><ul>1. think-cell chart and layout</ul><ul>2. think-cell chart, layout, and round</ul><ul>3. think-cell chart, layout, and round  |

## Configuration settings for Intune
- **Custom configuration profile name:** *think-cell - Managed Settings*
- **Deployment channel:** *Device Channel*
- **Configuration profile name:** *think-cell - Managed Settings.mobileconfig*