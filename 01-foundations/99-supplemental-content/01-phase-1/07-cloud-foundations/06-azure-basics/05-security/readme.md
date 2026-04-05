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

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Active Directory</b>
</details>


<b>2. Which service stores secrets?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Key Vault</b>
</details>


<b>3. Managed Identities remove the need for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Storing credentials in code</b>
</details>


<b>4. RBAC stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Role-Based Access Control</b>
</details>


<b>5. Which is a valid scope for RBAC?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Subscription, Resource Group, Resource</b>
</details>


<b>6. Conditional Access policies are enforced by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure AD (Entra ID)</b>
</details>


<b>7. Azure DDoS Protection Standard is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A paid service with advanced mitigation and cost protection</b>
</details>


<b>8. Which service scans container images for vulnerabilities?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Defender for Containers (part of Defender for Cloud)</b>
</details>


<b>9. To encrypt a Virtual Machine disk, use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Disk Encryption (ADE)</b>
</details>


<b>10. Service Principals are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Identities for applications/services</b>
</details>


<b>11. Azure Policy is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Governance and Compliance (e.g. restrict regions)</b>
</details>


<b>12. "Blueprints" allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup</b>
</details>


<b>13. Azure Sentinel is a:</b>
<details>
<summary>Show Answer</summary>
Answer: A) SIEM/SOAR solution</b>
</details>


<b>14. MFA is enabled via:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure AD (Entra ID) / Conditional Access</b>
</details>


<b>15. Secure Score helps you:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Understand your security posture and gives recommendations</b>
</details>


<b>16. Can Key Vault store SSL Certificates?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>17. Which is an example of "Identity as the perimeter"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Using AuthN/AuthZ to control access regardless of network location</b>
</details>


<b>18. Guest Users in Entra ID (B2B) allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Inviting external users to your tenant</b>
</details>


<b>19. Privileged Identity Management (PIM) provides:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Just-in-Time access to high-privilege roles (Admin)</b>
</details>


<b>20. What protocol does Azure AD use for modern auth?</b>
<details>
<summary>Show Answer</summary>
Answer: A) OIDC / OAuth 2.0 / SAML</b>
</details>


<b>21. Resource Locks prevent:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Accidental deletion or modification of resources</b>
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

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Active Directory</b>
</details>


<b>2. Which service stores secrets?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Key Vault</b>
</details>


<b>3. Managed Identities remove the need for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Storing credentials in code</b>
</details>


<b>4. RBAC stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Role-Based Access Control</b>
</details>


<b>5. Which is a valid scope for RBAC?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Subscription, Resource Group, Resource</b>
</details>


<b>6. Conditional Access policies are enforced by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure AD (Entra ID)</b>
</details>


<b>7. Azure DDoS Protection Standard is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A paid service with advanced mitigation and cost protection</b>
</details>


<b>8. Which service scans container images for vulnerabilities?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Defender for Containers (part of Defender for Cloud)</b>
</details>


<b>9. To encrypt a Virtual Machine disk, use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Disk Encryption (ADE)</b>
</details>


<b>10. Service Principals are:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Identities for applications/services</b>
</details>


<b>11. Azure Policy is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Governance and Compliance (e.g. restrict regions)</b>
</details>


<b>12. "Blueprints" allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Define a repeatable set of Azure resources (RG, Policy, RBAC) for environment setup</b>
</details>


<b>13. Azure Sentinel is a:</b>
<details>
<summary>Show Answer</summary>
Answer: A) SIEM/SOAR solution</b>
</details>


<b>14. MFA is enabled via:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure AD (Entra ID) / Conditional Access</b>
</details>


<b>15. Secure Score helps you:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Understand your security posture and gives recommendations</b>
</details>


<b>16. Can Key Vault store SSL Certificates?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>17. Which is an example of "Identity as the perimeter"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Using AuthN/AuthZ to control access regardless of network location</b>
</details>


<b>18. Guest Users in Entra ID (B2B) allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Inviting external users to your tenant</b>
</details>


<b>19. Privileged Identity Management (PIM) provides:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Just-in-Time access to high-privilege roles (Admin)</b>
</details>


<b>20. What protocol does Azure AD use for modern auth?</b>
<details>
<summary>Show Answer</summary>
Answer: A) OIDC / OAuth 2.0 / SAML</b>
</details>


<b>21. Resource Locks prevent:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Accidental deletion or modification of resources</b>
</details>
