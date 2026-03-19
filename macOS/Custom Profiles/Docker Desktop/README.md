# Docker Desktop - Sign-in Enforcement
> [!NOTE]  
> [This configuration profile is originated from Docker](https://docs.docker.com/enterprise/security/enforce-sign-in/methods/), that have been forked and further customized.

This Custom Profile set sign-in enforcement to Docker Desktop.

## Prerequisites
Before deploying this configuration profile, you need to do following prerequisites:

1. [Read documentation](https://docs.docker.com/enterprise/security/enforce-sign-in/) from Docker regarding to sign-in enforcement.
2. From configuration profile, go to line 25 and replace placeholder organizations  `first_org;second_org;third_org;fouth_org` with your real organization or organizations 

**Examples:**

- If there is only one (1) organization:
    ```
    <key>allowedOrgs</key>
    <string>contoso</string>
    ```

- If there are multiple organizations:
    ```
    <key>allowedOrgs</key>
    <string>contoso;fabrikam;adatum;alpineskihouse</string>
    ```

## Configuration settings for Intune
- **Custom configuration profile name:** *Docker Desktop - Sign-in Enforcement*
- **Deployment channel:** *Device Channel*
- **Configuration profile name:** *Docker Desktop - Sign-in Enforcement.mobileconfig*
