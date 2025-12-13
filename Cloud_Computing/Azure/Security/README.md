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