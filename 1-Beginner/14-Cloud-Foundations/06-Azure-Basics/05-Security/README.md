# Azure Security

Comprehensive guide to Azure security services including Azure Active Directory, Key Vault, and Security Center.

## Azure Active Directory
```bash
# Create user
az ad user create \
  --display-name "John Doe" \
  --user-principal-name john@contoso.com \
  --password TempPassword123!

# Create group
az ad group create \
  --display-name "Developers" \
  --mail-nickname developers

# Add user to group
az ad group member add \
  --group developers \
  --member-id $(az ad user show --id john@contoso.com --query objectId -o tsv)

# Create service principal
az ad sp create-for-rbac \
  --name myServicePrincipal \
  --role contributor \
  --scopes /subscriptions/{subscription-id}
```

## Azure Key Vault
```bash
# Create Key Vault
az keyvault create \
  --name myKeyVault \
  --resource-group myResourceGroup \
  --location eastus

# Store secret
az keyvault secret set \
  --vault-name myKeyVault \
  --name mySecret \
  --value "MySecretValue"

# Retrieve secret
az keyvault secret show \
  --vault-name myKeyVault \
  --name mySecret \
  --query value -o tsv

# Create key
az keyvault key create \
  --vault-name myKeyVault \
  --name myKey \
  --protection software

# Store certificate
az keyvault certificate import \
  --vault-name myKeyVault \
  --name myCertificate \
  --file certificate.pfx
```

## Role-Based Access Control
```bash
# List role definitions
az role definition list --output table

# Create custom role
az role definition create --role-definition '{
  "Name": "Custom VM Operator",
  "Description": "Can start and stop VMs",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/powerOff/action"
  ],
  "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'

# Assign role to user
az role assignment create \
  --assignee john@contoso.com \
  --role "Virtual Machine Contributor" \
  --scope /subscriptions/{subscription-id}/resourceGroups/myResourceGroup
```

## Azure Security Center
```bash
# Get security contacts
az security contact list

# Set security contact
az security contact create \
  --name default1 \
  --email admin@contoso.com \
  --phone "555-1234" \
  --alert-notifications-minimal-severity medium \
  --alerts-to-admins on

# Get security assessments
az security assessment list

# Get security alerts
az security alert list
```

This guide covers Azure security services for identity management and threat protection.

## Real World Scenarios

### Scenario 1: Zero Trust Access
**Context:** Developers need access to Prod DB but shouldn't know the password.
**Solution:**
- **Managed Identity:** Assign Managed Identity to Dev VM.
- **Key Vault:** Store DB password in Key Vault.
- **Access Policy:** Grant VM's Identity "Get Secret" permission on Key Vault.
**Benefit:** No credentials in code. Access is auditable and revocable.

### Scenario 2: Regulatory Compliance Monitoring
**Context:** CTO needs to prove to auditors that all storage is encrypted.
**Solution:**
- **Microsoft Defender for Cloud (Security Center):** Enable secure score.
- **Regulatory Compliance Dashboard:** View compliance against ISO 27001 / PCI-DSS.
**Benefit:** Automated, continuous compliance auditing.

---

## Interview Questions

### Basic Level
1. **What is Azure Active Directory (Entra ID)?**
   - Cloud-based identity and access management service (SaaS). Handles auth, SSO, MFA.
2. **What is MFA?**
   - Multi-Factor Authentication. Requires 2+ forms of verification (Password + Phone).
3. **What is a Network Security Group (NSG)?**
   - Basic firewall for VNet subnets/NICs to filter traffic.

### Intermediate Level
4. **Explain Managed Identities.**
   - An identity automatically managed by Azure for an Azure resource (like a VM). Allows the resource to authenticate to services (like Key Vault) without storing credentials in code.
5. **What is the purpose of Conditional Access?**
   - Policies that make access decisions based on conditions (e.g., If User=Admin AND Location=China -> Force MFA).
6. **Difference between Authentication (AuthN) and Authorization (AuthZ)?**
   - **AuthN:** Who are you? (Login)
   - **AuthZ:** What can you do? (Permissions/RBAC)

### Advanced Level
7. **What is Azure Key Vault used for?**
   - Securely storing secrets (passwords), keys (encryption keys), and certificates.
8. **What is Microsoft Defender for Cloud?**
   - A Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP). Monitors security state and detects threats.
9. **Explain "Just-In-Time" (JIT) VM Access.**
   - A Defender for Cloud feature that locks down management ports (22/3389) and opens them only on request for a limited time window.
10. **What is Azure Sentinel?**
    - A cloud-native SIEM (Security Information and Event Management) and SOAR solution for security analytics and threat intelligence.

---

## Quiz: Azure Security

<details>
<summary><b>1. Entra ID was formerly known as:</b></summary>
A) Azure Active Directory<br>
B) Azure Identity<br>
C) Windows Server AD<br>
D) Azure Passport<br>
<br>
<b>Answer: A) Azure Active Directory</b>
</details>

<details>
<summary><b>2. Which service stores secrets?</b></summary>
A) Key Vault<br>
B) Storage Account<br>
C) SQL DB<br>
D) VM<br>
<br>
<b>Answer: A) Key Vault</b>
</details>

<details>
<summary><b>3. Managed Identities remove the need for:</b></summary>
A) Storing credentials in code<br>
B) Passwords entirely<br>
C) RBAC<br>
D) Identity<br>
<br>
<b>Answer: A) Storing credentials in code</b>
</details>

<details>
<summary><b>4. RBAC stands for:</b></summary>
A) Role-Based Access Control<br>
B) Rule-Based Access Control<br>
C) Remote Basic Access Control<br>
D) Real Bad Access Control<br>
<br>
<b>Answer: A) Role-Based Access Control</b>
</details>

<details>
<summary><b>5. Which is a valid scope for RBAC?</b></summary>
A) Subscription, Resource Group, Resource<br>
B) Region<br>
C) Internet<br>
D) Laptop<br>
<br>
<b>Answer: A) Subscription, Resource Group, Resource</b>
</details>

<details>
<summary><b>6. Conditional Access policies are enforced by:</b></summary>
A) Azure AD (Entra ID)<br>
B) Router<br>
C) Firewall<br>
D) ISP<br>
<br>
<b>Answer: A) Azure AD (Entra ID)</b>
</details>

<details>
<summary><b>7. Azure DDoS Protection Standard is:</b></summary>
A) A paid service with advanced mitigation and cost protection<br>
B) Free<br>
C) Not available<br>
D) For emails<br>
<br>
<b>Answer: A) A paid service with advanced mitigation and cost protection</b>
</details>

<details>
<summary><b>8. Which service scans container images for vulnerabilities?</b></summary>
A) Defender for Containers (part of Defender for Cloud)<br>
B) Docker<br>
C) Kubernetes<br>
D) S3<br>
<br>
<b>Answer: A) Defender for Containers (part of Defender for Cloud)</b>
</details>

<details>
<summary><b>9. To encrypt a Virtual Machine disk, use:</b></summary>
A) Azure Disk Encryption (ADE)<br>
B) SSL<br>
C) SSH<br>
D) VPN<br>
<br>
<b>Answer: A) Azure Disk Encryption (ADE)</b>
</details>

<details>
<summary><b>10. Service Principals are:</b></summary>
A) Identities for applications/services<br>
B) The main admins<br>
C) School principals<br>
D) Servers<br>
<br>
<b>Answer: A) Identities for applications/services</b>
</details>

<details>
<summary><b>11. Azure Policy is used for:</b></summary>
A) Governance and Compliance (e.g. restrict regions)<br>
B) Authentication<br>
C) Networking<br>
D) Storage<br>
<br>
<b>Answer: A) Governance and Compliance (e.g. restrict regions)</b>
</details>

<details>
<summary><b>12. "Blueprints" allows you to:</b></summary>
A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup<br>
B) Draw pictures<br>
C) Print files<br>
D) Delete resources<br>
<br>
<b>Answer: A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup</b>
</details>

<details>
<summary><b>13. Azure Sentinel is a:</b></summary>
A) SIEM/SOAR solution<br>
B) Firewall<br>
C) Identity provider<br>
D) Database<br>
<br>
<b>Answer: A) SIEM/SOAR solution</b>
</details>

<details>
<summary><b>14. MFA is enabled via:</b></summary>
A) Azure AD (Entra ID) / Conditional Access<br>
B) Key Vault<br>
C) VM settings<br>
D) BIOS<br>
<br>
<b>Answer: A) Azure AD (Entra ID) / Conditional Access</b>
</details>

<details>
<summary><b>15. Secure Score helps you:</b></summary>
A) Understand your security posture and gives recommendations<br>
B) Win a game<br>
C) Pay less<br>
D) Run faster<br>
<br>
<b>Answer: A) Understand your security posture and gives recommendations</b>
</details>

<details>
<summary><b>16. Can Key Vault store SSL Certificates?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>17. Which is an example of "Identity as the perimeter"?</b></summary>
A) Using AuthN/AuthZ to control access regardless of network location<br>
B) Firewalls<br>
C) VPNs<br>
D) Air gap<br>
<br>
<b>Answer: A) Using AuthN/AuthZ to control access regardless of network location</b>
</details>

<details>
<summary><b>18. Guest Users in Entra ID (B2B) allow:</b></summary>
A) Inviting external users to your tenant<br>
B) Nothing<br>
C) Free VMs<br>
D) Root access<br>
<br>
<b>Answer: A) Inviting external users to your tenant</b>
</details>

<details>
<summary><b>19. Privileged Identity Management (PIM) provides:</b></summary>
A) Just-in-Time access to high-privilege roles (Admin)<br>
B) Passwords<br>
C) Keys<br>
D) MFA<br>
<br>
<b>Answer: A) Just-in-Time access to high-privilege roles (Admin)</b>
</details>

<details>
<summary><b>20. What protocol does Azure AD use for modern auth?</b></summary>
A) OIDC / OAuth 2.0 / SAML<br>
B) Kerberos (Legacy)<br>
C) Telnet<br>
D) HTTP<br>
<br>
<b>Answer: A) OIDC / OAuth 2.0 / SAML</b>
</details>

<details>
<summary><b>21. Resource Locks prevent:</b></summary>
A) Accidental deletion or modification of resources<br>
B) Access<br>
C) Viewing<br>
D) Billing<br>
<br>
<b>Answer: A) Accidental deletion or modification of resources</b>
</details>


## Real World Scenarios

### Scenario 1: Zero Trust Access
**Context:** Developers need access to Prod DB but shouldn't know the password.
**Solution:**
- **Managed Identity:** Assign Managed Identity to Dev VM.
- **Key Vault:** Store DB password in Key Vault.
- **Access Policy:** Grant VM's Identity "Get Secret" permission on Key Vault.
**Benefit:** No credentials in code. Access is auditable and revocable.

### Scenario 2: Regulatory Compliance Monitoring
**Context:** CTO needs to prove to auditors that all storage is encrypted.
**Solution:**
- **Microsoft Defender for Cloud (Security Center):** Enable secure score.
- **Regulatory Compliance Dashboard:** View compliance against ISO 27001 / PCI-DSS.
**Benefit:** Automated, continuous compliance auditing.

---

## Interview Questions

### Basic Level
1. **What is Azure Active Directory (Entra ID)?**
   - Cloud-based identity and access management service (SaaS). Handles auth, SSO, MFA.
2. **What is MFA?**
   - Multi-Factor Authentication. Requires 2+ forms of verification (Password + Phone).
3. **What is a Network Security Group (NSG)?**
   - Basic firewall for VNet subnets/NICs to filter traffic.

### Intermediate Level
4. **Explain Managed Identities.**
   - An identity automatically managed by Azure for an Azure resource (like a VM). Allows the resource to authenticate to services (like Key Vault) without storing credentials in code.
5. **What is the purpose of Conditional Access?**
   - Policies that make access decisions based on conditions (e.g., If User=Admin AND Location=China -> Force MFA).
6. **Difference between Authentication (AuthN) and Authorization (AuthZ)?**
   - **AuthN:** Who are you? (Login)
   - **AuthZ:** What can you do? (Permissions/RBAC)

### Advanced Level
7. **What is Azure Key Vault used for?**
   - Securely storing secrets (passwords), keys (encryption keys), and certificates.
8. **What is Microsoft Defender for Cloud?**
   - A Cloud Security Posture Management (CSPM) and Cloud Workload Protection Platform (CWPP). Monitors security state and detects threats.
9. **Explain "Just-In-Time" (JIT) VM Access.**
   - A Defender for Cloud feature that locks down management ports (22/3389) and opens them only on request for a limited time window.
10. **What is Azure Sentinel?**
    - A cloud-native SIEM (Security Information and Event Management) and SOAR solution for security analytics and threat intelligence.

---

## Quiz: Azure Security

<details>
<summary><b>1. Entra ID was formerly known as:</b></summary>
A) Azure Active Directory<br>
B) Azure Identity<br>
C) Windows Server AD<br>
D) Azure Passport<br>
<br>
<b>Answer: A) Azure Active Directory</b>
</details>

<details>
<summary><b>2. Which service stores secrets?</b></summary>
A) Key Vault<br>
B) Storage Account<br>
C) SQL DB<br>
D) VM<br>
<br>
<b>Answer: A) Key Vault</b>
</details>

<details>
<summary><b>3. Managed Identities remove the need for:</b></summary>
A) Storing credentials in code<br>
B) Passwords entirely<br>
C) RBAC<br>
D) Identity<br>
<br>
<b>Answer: A) Storing credentials in code</b>
</details>

<details>
<summary><b>4. RBAC stands for:</b></summary>
A) Role-Based Access Control<br>
B) Rule-Based Access Control<br>
C) Remote Basic Access Control<br>
D) Real Bad Access Control<br>
<br>
<b>Answer: A) Role-Based Access Control</b>
</details>

<details>
<summary><b>5. Which is a valid scope for RBAC?</b></summary>
A) Subscription, Resource Group, Resource<br>
B) Region<br>
C) Internet<br>
D) Laptop<br>
<br>
<b>Answer: A) Subscription, Resource Group, Resource</b>
</details>

<details>
<summary><b>6. Conditional Access policies are enforced by:</b></summary>
A) Azure AD (Entra ID)<br>
B) Router<br>
C) Firewall<br>
D) ISP<br>
<br>
<b>Answer: A) Azure AD (Entra ID)</b>
</details>

<details>
<summary><b>7. Azure DDoS Protection Standard is:</b></summary>
A) A paid service with advanced mitigation and cost protection<br>
B) Free<br>
C) Not available<br>
D) For emails<br>
<br>
<b>Answer: A) A paid service with advanced mitigation and cost protection</b>
</details>

<details>
<summary><b>8. Which service scans container images for vulnerabilities?</b></summary>
A) Defender for Containers (part of Defender for Cloud)<br>
B) Docker<br>
C) Kubernetes<br>
D) S3<br>
<br>
<b>Answer: A) Defender for Containers (part of Defender for Cloud)</b>
</details>

<details>
<summary><b>9. To encrypt a Virtual Machine disk, use:</b></summary>
A) Azure Disk Encryption (ADE)<br>
B) SSL<br>
C) SSH<br>
D) VPN<br>
<br>
<b>Answer: A) Azure Disk Encryption (ADE)</b>
</details>

<details>
<summary><b>10. Service Principals are:</b></summary>
A) Identities for applications/services<br>
B) The main admins<br>
C) School principals<br>
D) Servers<br>
<br>
<b>Answer: A) Identities for applications/services</b>
</details>

<details>
<summary><b>11. Azure Policy is used for:</b></summary>
A) Governance and Compliance (e.g. restrict regions)<br>
B) Authentication<br>
C) Networking<br>
D) Storage<br>
<br>
<b>Answer: A) Governance and Compliance (e.g. restrict regions)</b>
</details>

<details>
<summary><b>12. "Blueprints" allows you to:</b></summary>
A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup<br>
B) Draw pictures<br>
C) Print files<br>
D) Delete resources<br>
<br>
<b>Answer: A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup</b>
</details>

<details>
<summary><b>13. Azure Sentinel is a:</b></summary>
A) SIEM/SOAR solution<br>
B) Firewall<br>
C) Identity provider<br>
D) Database<br>
<br>
<b>Answer: A) SIEM/SOAR solution</b>
</details>

<details>
<summary><b>14. MFA is enabled via:</b></summary>
A) Azure AD (Entra ID) / Conditional Access<br>
B) Key Vault<br>
C) VM settings<br>
D) BIOS<br>
<br>
<b>Answer: A) Azure AD (Entra ID) / Conditional Access</b>
</details>

<details>
<summary><b>15. Secure Score helps you:</b></summary>
A) Understand your security posture and gives recommendations<br>
B) Win a game<br>
C) Pay less<br>
D) Run faster<br>
<br>
<b>Answer: A) Understand your security posture and gives recommendations</b>
</details>

<details>
<summary><b>16. Can Key Vault store SSL Certificates?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>17. Which is an example of "Identity as the perimeter"?</b></summary>
A) Using AuthN/AuthZ to control access regardless of network location<br>
B) Firewalls<br>
C) VPNs<br>
D) Air gap<br>
<br>
<b>Answer: A) Using AuthN/AuthZ to control access regardless of network location</b>
</details>

<details>
<summary><b>18. Guest Users in Entra ID (B2B) allow:</b></summary>
A) Inviting external users to your tenant<br>
B) Nothing<br>
C) Free VMs<br>
D) Root access<br>
<br>
<b>Answer: A) Inviting external users to your tenant</b>
</details>

<details>
<summary><b>19. Privileged Identity Management (PIM) provides:</b></summary>
A) Just-in-Time access to high-privilege roles (Admin)<br>
B) Passwords<br>
C) Keys<br>
D) MFA<br>
<br>
<b>Answer: A) Just-in-Time access to high-privilege roles (Admin)</b>
</details>

<details>
<summary><b>20. What protocol does Azure AD use for modern auth?</b></summary>
A) OIDC / OAuth 2.0 / SAML<br>
B) Kerberos (Legacy)<br>
C) Telnet<br>
D) HTTP<br>
<br>
<b>Answer: A) OIDC / OAuth 2.0 / SAML</b>
</details>

<details>
<summary><b>21. Resource Locks prevent:</b></summary>
A) Accidental deletion or modification of resources<br>
B) Access<br>
C) Viewing<br>
D) Billing<br>
<br>
<b>Answer: A) Accidental deletion or modification of resources</b>
</details>