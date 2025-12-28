# Microsoft Azure Fundamentals

Comprehensive guide to Microsoft Azure cloud platform for DevOps engineers.

## What is Microsoft Azure?

Microsoft Azure is a comprehensive cloud computing platform that provides over 200 services including computing, analytics, storage, and networking. Azure enables organizations to build, deploy, and manage applications through Microsoft's global network of data centers.

## Azure Global Infrastructure

### Regions and Availability Zones

```bash
# List all Azure regions
az account list-locations --output table

# Get current subscription
az account show --output table

# List availability zones in region
az vm list-skus --location eastus --zone-info --output table

# Set default location
az configure --defaults location=eastus
```

### Azure Infrastructure Components

```
Azure Global Infrastructure
├── Regions (60+ worldwide)
│   ├── Availability Zones (3+ per region)
│   │   └── Data Centers (1+ per AZ)
│   └── Paired Regions (disaster recovery)
├── Edge Locations (170+ worldwide)
│   ├── Azure CDN
│   └── Azure Front Door
└── Special Regions
    ├── Government Clouds
    └── Sovereign Clouds
```

## Core Azure Services

### Compute Services

#### Virtual Machines
```bash
# List VM sizes
az vm list-sizes --location eastus --output table

# Create resource group
az group create --name DevOpsRG --location eastus

# Create virtual machine
az vm create \
    --resource-group DevOpsRG \
    --name DevOpsVM \
    --image UbuntuLTS \
    --size Standard_B2s \
    --admin-username azureuser \
    --generate-ssh-keys \
    --public-ip-sku Standard

# Start/Stop VM
az vm start --resource-group DevOpsRG --name DevOpsVM
az vm stop --resource-group DevOpsRG --name DevOpsVM
az vm deallocate --resource-group DevOpsRG --name DevOpsVM

# Get VM details
az vm show --resource-group DevOpsRG --name DevOpsVM --output table

# List all VMs
az vm list --output table

# Create VM from custom image
az vm create \
    --resource-group DevOpsRG \
    --name CustomVM \
    --image /subscriptions/{subscription-id}/resourceGroups/myRG/providers/Microsoft.Compute/images/myImage \
    --size Standard_D2s_v3
```

#### Azure Container Instances (ACI)
```bash
# Create container instance
az container create \
    --resource-group DevOpsRG \
    --name devops-container \
    --image nginx \
    --cpu 1 \
    --memory 1 \
    --ports 80 \
    --dns-name-label devops-nginx \
    --location eastus

# List container instances
az container list --output table

# Get container logs
az container logs --resource-group DevOpsRG --name devops-container

# Execute command in container
az container exec \
    --resource-group DevOpsRG \
    --name devops-container \
    --exec-command "/bin/bash"

# Delete container instance
az container delete --resource-group DevOpsRG --name devops-container
```

#### Azure Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create \
    --resource-group DevOpsRG \
    --name DevOpsCluster \
    --node-count 3 \
    --node-vm-size Standard_D2s_v3 \
    --enable-addons monitoring \
    --generate-ssh-keys

# Get AKS credentials
az aks get-credentials --resource-group DevOpsRG --name DevOpsCluster

# Scale AKS cluster
az aks scale --resource-group DevOpsRG --name DevOpsCluster --node-count 5

# Upgrade AKS cluster
az aks upgrade --resource-group DevOpsRG --name DevOpsCluster --kubernetes-version 1.25.0

# List AKS clusters
az aks list --output table
```

#### Azure Functions (Serverless)
```bash
# Create function app
az functionapp create \
    --resource-group DevOpsRG \
    --consumption-plan-location eastus \
    --runtime python \
    --runtime-version 3.9 \
    --functions-version 4 \
    --name DevOpsFunctionApp \
    --storage-account devopsstorage

# Deploy function code
func azure functionapp publish DevOpsFunctionApp

# List function apps
az functionapp list --output table

# Get function app settings
az functionapp config appsettings list \
    --name DevOpsFunctionApp \
    --resource-group DevOpsRG
```

### Storage Services

#### Azure Storage Account
```bash
# Create storage account
az storage account create \
    --name devopsstorage \
    --resource-group DevOpsRG \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2

# Get storage account keys
az storage account keys list \
    --account-name devopsstorage \
    --resource-group DevOpsRG

# Create blob container
az storage container create \
    --name devops-container \
    --account-name devopsstorage

# Upload blob
az storage blob upload \
    --file local-file.txt \
    --container-name devops-container \
    --name remote-file.txt \
    --account-name devopsstorage

# Download blob
az storage blob download \
    --container-name devops-container \
    --name remote-file.txt \
    --file downloaded-file.txt \
    --account-name devopsstorage

# List blobs
az storage blob list \
    --container-name devops-container \
    --account-name devopsstorage \
    --output table
```

#### Azure Files
```bash
# Create file share
az storage share create \
    --name devops-share \
    --account-name devopsstorage

# Upload file to share
az storage file upload \
    --share-name devops-share \
    --source local-file.txt \
    --path remote-file.txt \
    --account-name devopsstorage

# Mount file share (Linux)
sudo mkdir /mnt/devops-share
sudo mount -t cifs //devopsstorage.file.core.windows.net/devops-share /mnt/devops-share \
    -o vers=3.0,username=devopsstorage,password=STORAGE_KEY,dir_mode=0777,file_mode=0777
```

#### Azure Managed Disks
```bash
# Create managed disk
az disk create \
    --resource-group DevOpsRG \
    --name DevOpsDisk \
    --size-gb 128 \
    --sku Premium_LRS

# Attach disk to VM
az vm disk attach \
    --resource-group DevOpsRG \
    --vm-name DevOpsVM \
    --name DevOpsDisk

# Create snapshot
az snapshot create \
    --resource-group DevOpsRG \
    --name DevOpsDiskSnapshot \
    --source DevOpsDisk

# List disks
az disk list --output table
```

### Database Services

#### Azure SQL Database
```bash
# Create SQL server
az sql server create \
    --name devops-sql-server \
    --resource-group DevOpsRG \
    --location eastus \
    --admin-user sqladmin \
    --admin-password MySecurePassword123

# Create SQL database
az sql db create \
    --resource-group DevOpsRG \
    --server devops-sql-server \
    --name DevOpsDB \
    --service-objective Basic

# Configure firewall rule
az sql server firewall-rule create \
    --resource-group DevOpsRG \
    --server devops-sql-server \
    --name AllowMyIP \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255

# List databases
az sql db list --resource-group DevOpsRG --server devops-sql-server --output table
```

#### Azure Cosmos DB
```bash
# Create Cosmos DB account
az cosmosdb create \
    --name devops-cosmosdb \
    --resource-group DevOpsRG \
    --kind GlobalDocumentDB \
    --locations regionName=eastus failoverPriority=0 isZoneRedundant=False

# Create database
az cosmosdb sql database create \
    --account-name devops-cosmosdb \
    --resource-group DevOpsRG \
    --name DevOpsDatabase

# Create container
az cosmosdb sql container create \
    --account-name devops-cosmosdb \
    --resource-group DevOpsRG \
    --database-name DevOpsDatabase \
    --name DevOpsContainer \
    --partition-key-path "/id"

# List Cosmos DB accounts
az cosmosdb list --output table
```

## Networking in Azure

### Virtual Networks (VNet)

```bash
# Create virtual network
az network vnet create \
    --resource-group DevOpsRG \
    --name DevOpsVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name DevOpsSubnet \
    --subnet-prefix 10.0.1.0/24

# Create additional subnet
az network vnet subnet create \
    --resource-group DevOpsRG \
    --vnet-name DevOpsVNet \
    --name DatabaseSubnet \
    --address-prefix 10.0.2.0/24

# List virtual networks
az network vnet list --output table

# Create network security group
az network nsg create \
    --resource-group DevOpsRG \
    --name DevOpsNSG

# Add security rule
az network nsg rule create \
    --resource-group DevOpsRG \
    --nsg-name DevOpsNSG \
    --name AllowSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

# Associate NSG with subnet
az network vnet subnet update \
    --resource-group DevOpsRG \
    --vnet-name DevOpsVNet \
    --name DevOpsSubnet \
    --network-security-group DevOpsNSG
```

### Load Balancer

```bash
# Create public IP
az network public-ip create \
    --resource-group DevOpsRG \
    --name DevOpsLBPublicIP \
    --sku Standard

# Create load balancer
az network lb create \
    --resource-group DevOpsRG \
    --name DevOpsLoadBalancer \
    --public-ip-address DevOpsLBPublicIP \
    --frontend-ip-name DevOpsFrontEnd \
    --backend-pool-name DevOpsBackEndPool \
    --sku Standard

# Create health probe
az network lb probe create \
    --resource-group DevOpsRG \
    --lb-name DevOpsLoadBalancer \
    --name DevOpsHealthProbe \
    --protocol tcp \
    --port 80

# Create load balancer rule
az network lb rule create \
    --resource-group DevOpsRG \
    --lb-name DevOpsLoadBalancer \
    --name DevOpsLBRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name DevOpsFrontEnd \
    --backend-pool-name DevOpsBackEndPool \
    --probe-name DevOpsHealthProbe
```

### Application Gateway

```bash
# Create application gateway
az network application-gateway create \
    --name DevOpsAppGateway \
    --location eastus \
    --resource-group DevOpsRG \
    --vnet-name DevOpsVNet \
    --subnet DevOpsSubnet \
    --capacity 2 \
    --sku Standard_v2 \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --public-ip-address DevOpsAppGWPublicIP

# List application gateways
az network application-gateway list --output table
```

## Identity and Access Management

### Azure Active Directory (Azure AD)

```bash
# Create user
az ad user create \
    --display-name "DevOps User" \
    --password MySecurePassword123 \
    --user-principal-name devopsuser@yourdomain.onmicrosoft.com

# Create group
az ad group create \
    --display-name "DevOps Team" \
    --mail-nickname devopsteam

# Add user to group
az ad group member add \
    --group "DevOps Team" \
    --member-id $(az ad user show --id devopsuser@yourdomain.onmicrosoft.com --query objectId -o tsv)

# List users
az ad user list --output table

# List groups
az ad group list --output table
```

### Role-Based Access Control (RBAC)

```bash
# List role definitions
az role definition list --output table

# Assign role to user
az role assignment create \
    --assignee devopsuser@yourdomain.onmicrosoft.com \
    --role "Virtual Machine Contributor" \
    --scope /subscriptions/{subscription-id}/resourceGroups/DevOpsRG

# Assign role to group
az role assignment create \
    --assignee-object-id $(az ad group show --group "DevOps Team" --query objectId -o tsv) \
    --role "Storage Blob Data Contributor" \
    --scope /subscriptions/{subscription-id}/resourceGroups/DevOpsRG

# List role assignments
az role assignment list --assignee devopsuser@yourdomain.onmicrosoft.com --output table

# Create custom role
az role definition create --role-definition '{
    "Name": "DevOps Custom Role",
    "Description": "Custom role for DevOps team",
    "Actions": [
        "Microsoft.Compute/*/read",
        "Microsoft.Storage/*/read",
        "Microsoft.Network/*/read"
    ],
    "NotActions": [],
    "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'
```

## Monitoring and Management

### Azure Monitor

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
    --resource-group DevOpsRG \
    --workspace-name DevOpsLogAnalytics \
    --location eastus

# Create action group
az monitor action-group create \
    --resource-group DevOpsRG \
    --name DevOpsActionGroup \
    --short-name DevOpsAG \
    --email-receivers name=admin email=admin@company.com

# Create metric alert
az monitor metrics alert create \
    --name "High CPU Alert" \
    --resource-group DevOpsRG \
    --scopes /subscriptions/{subscription-id}/resourceGroups/DevOpsRG/providers/Microsoft.Compute/virtualMachines/DevOpsVM \
    --condition "avg Percentage CPU > 80" \
    --action DevOpsActionGroup \
    --description "Alert when CPU exceeds 80%"

# Query logs
az monitor log-analytics query \
    --workspace DevOpsLogAnalytics \
    --analytics-query "Heartbeat | summarize count() by Computer"
```

### Azure Resource Manager (ARM) Templates

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmName": {
            "type": "string",
            "defaultValue": "DevOpsVM"
        },
        "adminUsername": {
            "type": "string",
            "defaultValue": "azureuser"
        }
    },
    "variables": {
        "storageAccountName": "[concat('storage', uniqueString(resourceGroup().id))]"
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2021-04-01",
            "name": "[variables('storageAccountName')]",
            "location": "[resourceGroup().location]",
            "sku": {
                "name": "Standard_LRS"
            },
            "kind": "StorageV2"
        }
    ],
    "outputs": {
        "storageAccountName": {
            "type": "string",
            "value": "[variables('storageAccountName')]"
        }
    }
}
```

```bash
# Deploy ARM template
az deployment group create \
    --resource-group DevOpsRG \
    --template-file template.json \
    --parameters vmName=MyVM adminUsername=azureuser

# Validate template
az deployment group validate \
    --resource-group DevOpsRG \
    --template-file template.json

# Export template
az group export \
    --name DevOpsRG \
    --include-comments \
    --include-parameter-default-value
```

## Azure DevOps Integration

### Azure DevOps Services

```bash
# Install Azure DevOps CLI extension
az extension add --name azure-devops

# Configure Azure DevOps
az devops configure --defaults organization=https://dev.azure.com/yourorg project=DevOpsProject

# Create project
az devops project create --name DevOpsProject --description "DevOps project for cloud infrastructure"

# List projects
az devops project list --output table

# Create repository
az repos create --name DevOpsRepo --project DevOpsProject

# Create build pipeline
az pipelines create \
    --name DevOpsPipeline \
    --repository DevOpsRepo \
    --branch main \
    --yml-path azure-pipelines.yml
```

### Azure Pipelines YAML

```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  azureServiceConnection: 'azure-service-connection'
  resourceGroupName: 'DevOpsRG'
  location: 'eastus'

stages:
- stage: Build
  jobs:
  - job: BuildJob
    steps:
    - task: AzureCLI@2
      displayName: 'Deploy Infrastructure'
      inputs:
        azureSubscription: $(azureServiceConnection)
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          az group create --name $(resourceGroupName) --location $(location)
          az deployment group create \
            --resource-group $(resourceGroupName) \
            --template-file infrastructure/template.json

- stage: Deploy
  dependsOn: Build
  jobs:
  - deployment: DeployJob
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy Web App'
            inputs:
              azureSubscription: $(azureServiceConnection)
              appName: 'DevOpsWebApp'
              package: '$(Pipeline.Workspace)/drop/app.zip'
```

## Security Best Practices

### Azure Security Center

```bash
# Enable Security Center
az security auto-provisioning-setting update \
    --name default \
    --auto-provision on

# Get security contacts
az security contact list

# Create security contact
az security contact create \
    --contact-name "Security Team" \
    --email security@company.com \
    --phone "+1234567890" \
    --alert-notifications on \
    --alerts-admins on

# Get security assessments
az security assessment list --output table
```

### Key Vault

```bash
# Create Key Vault
az keyvault create \
    --name DevOpsKeyVault \
    --resource-group DevOpsRG \
    --location eastus \
    --enabled-for-disk-encryption true \
    --enabled-for-deployment true \
    --enabled-for-template-deployment true

# Set secret
az keyvault secret set \
    --vault-name DevOpsKeyVault \
    --name DatabasePassword \
    --value MySecurePassword123

# Get secret
az keyvault secret show \
    --vault-name DevOpsKeyVault \
    --name DatabasePassword

# Create certificate
az keyvault certificate create \
    --vault-name DevOpsKeyVault \
    --name DevOpsCert \
    --policy "$(az keyvault certificate get-default-policy)"

# List secrets
az keyvault secret list --vault-name DevOpsKeyVault --output table
```

## Cost Management

### Azure Cost Management

```bash
# Get cost analysis
az costmanagement query \
    --type Usage \
    --dataset-aggregation '{totalCost:{name:PreTaxCost,function:Sum}}' \
    --dataset-grouping name=ResourceGroup type=Dimension \
    --timeframe MonthToDate

# Create budget
az consumption budget create \
    --budget-name DevOpsBudget \
    --amount 1000 \
    --time-grain Monthly \
    --time-period start-date=2024-01-01 end-date=2024-12-31 \
    --resource-group DevOpsRG

# List budgets
az consumption budget list --output table
```

### Resource Tagging

```bash
# Tag resources
az resource tag \
    --tags Environment=Production Project=DevOps Owner=DevOpsTeam \
    --resource-group DevOpsRG \
    --name DevOpsVM \
    --resource-type Microsoft.Compute/virtualMachines

# Find resources by tag
az resource list --tag Environment=Production --output table

# Get cost by tags
az costmanagement query \
    --type Usage \
    --dataset-filter '{tags:{name:Environment,operator:In,values:[Production]}}' \
    --dataset-grouping name=ResourceGroup type=Dimension \
    --timeframe MonthToDate
```

## Automation and Scripting

### Azure PowerShell

```powershell
# Install Azure PowerShell module
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect to Azure
Connect-AzAccount

# Create resource group
New-AzResourceGroup -Name "DevOpsRG" -Location "East US"

# Create virtual machine
New-AzVm `
    -ResourceGroupName "DevOpsRG" `
    -Name "DevOpsVM" `
    -Location "East US" `
    -VirtualNetworkName "DevOpsVNet" `
    -SubnetName "DevOpsSubnet" `
    -SecurityGroupName "DevOpsNSG" `
    -PublicIpAddressName "DevOpsPublicIP" `
    -Image "UbuntuLTS"

# Get VM status
Get-AzVM -ResourceGroupName "DevOpsRG" -Name "DevOpsVM" -Status
```

### Azure REST API


## Real World Scenarios

### Scenario 1: Multi-Region Compliance
**Context:** A European bank needs to deploy an app but customer data MUST stay within Germany due to GDPR.
**Solution:**
- **Azure Regions:** Deploy resources strictly to `Germany West Central` and `Germany North`.
- **Azure Policy:** Use Azure Policy to deny resource creation in any other region.
**Benefit:** Ensures strict legal compliance while leveraging cloud capabilities.

### Scenario 2: Protecting Public Endpoints
**Context:** You have a VM with RDP/SSH open to the world for management, which is a security risk.
**Solution:**
- **Azure Bastion:** Deploy Azure Bastion in the VNet.
- **Security Group:** Lock down NSG to only allow traffic from Bastion.
**Benefit:** Secure, browser-based RDP/SSH access without exposing public IPs.

---

## Interview Questions

### Basic Level
1. **What is an Azure Resource Group?**
   - A logical container that holds related resources for an Azure solution. Resources share a lifecycle (creation, update, deletion).
2. **What is the Azure CLI command to login?**
   - `az login`
3. **Difference between Region and Availability Zone?**
   - Region: A set of datacenters deployed within a latency-defined perimeter.
   - Availability Zone: Unique physical locations within a region with independent power, cooling, and networking.

### Intermediate Level
4. **Explain the purpose of Azure Resource Manager (ARM).**
   - It's the deployment and management service for Azure. It provides a management layer that enables you to create, update, and delete resources in your Azure account.
5. **What is an Azure Subscription?**
   - A logical unit of Azure services that links to an Azure account. It's a boundary of billing and access control.
6. **How do you move resources between Resource Groups?**
   - Using the `az resource move` command or the Portal. Both source and destination RGs must be in the same tenant.

### Advanced Level
7. **What is Azure Arc?**
   - A bridge that extends the Azure platform to help you build applications and services with the flexibility to run across datacenters, edge, and multi-cloud environments.
8. **Explain the difference between Azure Policy and RBAC.**
   - **RBAC:** Focuses on *user actions* (Who can do what?).
   - **Policy:** Focuses on *resource properties* (What can be created/modified? e.g., enforce tagging, restrict regions).
9. **What are "Management Groups"?**
   - Containers for managing access, policy, and compliance for multiple subscriptions. They sit above subscriptions in the hierarchy.
10. **How does Azure Cost Management differ from Billing?**
    - Billing is about invoicing and payment. Cost Management is about analyzing spend, setting budgets, and optimizing costs.

---

## Quiz: Azure Fundamentals

<details>
<summary><b>1. Which command group manages Azure Resources?</b></summary>
A) az vm<br>
B) az resource<br>
C) az group<br>
D) az storage<br>
<br>
<b>Answer: B) az resource (or az group for the container)</b>
</details>

<details>
<summary><b>2. What is the scope of a Resource Group?</b></summary>
A) Global<br>
B) Region<br>
C) Subscription<br>
D) Tenant<br>
<br>
<b>Answer: C) Subscription (It lives within a subscription, though resources inside can be in different regions)</b>
</details>

<details>
<summary><b>3. Which service provides a browser-based shell?</b></summary>
A) Azure Cloud Shell<br>
B) PowerShell<br>
C) Bash<br>
D) CMD<br>
<br>
<b>Answer: A) Azure Cloud Shell</b>
</details>

<details>
<summary><b>4. Availability Zones protect against:</b></summary>
A) Region failure<br>
B) Datacenter failure<br>
C) Human error<br>
D) Billing issues<br>
<br>
<b>Answer: B) Datacenter failure</b>
</details>

<details>
<summary><b>5. Which is NOT a valid Azure subscription support plan?</b></summary>
A) Developer<br>
B) Standard<br>
C) Professional Direct<br>
D) Enterprise Premium Plus<br>
<br>
<b>Answer: D) Enterprise Premium Plus</b>
</details>

<details>
<summary><b>6. "Tags" in Azure are:</b></summary>
A) Name/Value pairs for organizing resources<br>
B) Price stickers<br>
C) Security rules<br>
D) DNS records<br>
<br>
<b>Answer: A) Name/Value pairs for organizing resources</b>
</details>

<details>
<summary><b>7. Azure Marketplace is:</b></summary>
A) A shop for buying hardware<br>
B) An online store for certified cloud applications and services<br>
C) A job board<br>
D) A forum<br>
<br>
<b>Answer: B) An online store for certified cloud applications and services</b>
</details>

<details>
<summary><b>8. Which file format is used for ARM templates?</b></summary>
A) XML<br>
B) JSON<br>
C) YAML<br>
D) CSV<br>
<br>
<b>Answer: B) JSON</b>
</details>

<details>
<summary><b>9. To delete a Resource Group and all resources inside it:</b></summary>
A) az group delete<br>
B) az rm -rf<br>
C) az delete<br>
D) az destroy<br>
<br>
<b>Answer: A) az group delete</b>
</details>

<details>
<summary><b>10. Can a resource exist in multiple Resource Groups?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: B) No</b>
</details>

<details>
<summary><b>11. Azure Service Health provides:</b></summary>
A) Personalized guidance and support when Azure service issues affect you<br>
B) Doctor appointments<br>
C) Server CPU usage<br>
D) Billing info<br>
<br>
<b>Answer: A) Personalized guidance and support when Azure service issues affect you</b>
</details>

<details>
<summary><b>12. Which tool analyzes your Azure usage and provides recommendations?</b></summary>
A) Azure Advisor<br>
B) Azure Manager<br>
C) Azure Helper<br>
D) Clippy<br>
<br>
<b>Answer: A) Azure Advisor</b>
</details>

<details>
<summary><b>13. Azure Sovereign Clouds include:</b></summary>
A) Azure Government & Azure China<br>
B) Azure Space<br>
C) Azure Mars<br>
D) Azure Home<br>
<br>
<b>Answer: A) Azure Government & Azure China</b>
</details>

<details>
<summary><b>14. What is the SLA for a single VM with Premium SSD?</b></summary>
A) 99.9%<br>
B) 100%<br>
C) 95%<br>
D) 99%<br>
<br>
<b>Answer: A) 99.9%</b>
</details>

<details>
<summary><b>15. Azure "Spot" VMs offer discounts up to:</b></summary>
A) 90%<br>
B) 50%<br>
C) 10%<br>
D) 30%<br>
<br>
<b>Answer: A) 90%</b>
</details>

<details>
<summary><b>16. CapEx vs OpEx: Azure is primarily:</b></summary>
A) OpEx (Operational Expenditure)<br>
B) CapEx (Capital Expenditure)<br>
<br>
<b>Answer: A) OpEx (Operational Expenditure)</b>
</details>

<details>
<summary><b>17. Which resource type is Global?</b></summary>
A) Traffic Manager Profile<br>
B) Virtual Machine<br>
C) Storage Account<br>
D) VNet<br>
<br>
<b>Answer: A) Traffic Manager Profile (and Azure AD, DNS)</b>
</details>

<details>
<summary><b>18. IoT Hub is used for:</b></summary>
A) Managing IoT devices and bidirectional communication<br>
B) Internet browsing<br>
C) Networking<br>
D) Storage<br>
<br>
<b>Answer: A) Managing IoT devices and bidirectional communication</b>
</details>

<details>
<summary><b>19. Azure DevOps includes:</b></summary>
A) Boards, Repos, Pipelines, Test Plans, Artifacts<br>
B) Just Git<br>
C) Just CI/CD<br>
D) Just Jira<br>
<br>
<b>Answer: A) Boards, Repos, Pipelines, Test Plans, Artifacts</b>
</details>

<details>
<summary><b>20. Access to Azure Preview features is:</b></summary>
A) Controlled via "Preview Features" blade<br>
B) Impossible<br>
C) Automatic<br>
D) Costly<br>
<br>
<b>Answer: A) Controlled via "Preview Features" blade</b>
</details>

<details>
<summary><b>21. Azure "Cloud Shell" persists files in:</b></summary>
A) An Azure File Share<br>
B) Local RAM<br>
C) S3<br>
D) Nowhere<br>
<br>
<b>Answer: A) An Azure File Share</b>
</details>

This comprehensive Azure fundamentals guide provides DevOps engineers with essential knowledge for effectively using Microsoft Azure services in cloud infrastructure and application deployment workflows.

## Real World Scenarios

### Scenario 1: Multi-Region Compliance
**Context:** A European bank needs to deploy an app but customer data MUST stay within Germany due to GDPR.
**Solution:**
- **Azure Regions:** Deploy resources strictly to `Germany West Central` and `Germany North`.
- **Azure Policy:** Use Azure Policy to deny resource creation in any other region.
**Benefit:** Ensures strict legal compliance while leveraging cloud capabilities.

### Scenario 2: Protecting Public Endpoints
**Context:** You have a VM with RDP/SSH open to the world for management, which is a security risk.
**Solution:**
- **Azure Bastion:** Deploy Azure Bastion in the VNet.
- **Security Group:** Lock down NSG to only allow traffic from Bastion.
**Benefit:** Secure, browser-based RDP/SSH access without exposing public IPs.

---

## Interview Questions

### Basic Level
1. **What is an Azure Resource Group?**
   - A logical container that holds related resources for an Azure solution. Resources share a lifecycle (creation, update, deletion).
2. **What is the Azure CLI command to login?**
   - `az login`
3. **Difference between Region and Availability Zone?**
   - Region: A set of datacenters deployed within a latency-defined perimeter.
   - Availability Zone: Unique physical locations within a region with independent power, cooling, and networking.

### Intermediate Level
4. **Explain the purpose of Azure Resource Manager (ARM).**
   - It's the deployment and management service for Azure. It provides a management layer that enables you to create, update, and delete resources in your Azure account.
5. **What is an Azure Subscription?**
   - A logical unit of Azure services that links to an Azure account. It's a boundary of billing and access control.
6. **How do you move resources between Resource Groups?**
   - Using the `az resource move` command or the Portal. Both source and destination RGs must be in the same tenant.

### Advanced Level
7. **What is Azure Arc?**
   - A bridge that extends the Azure platform to help you build applications and services with the flexibility to run across datacenters, edge, and multi-cloud environments.
8. **Explain the difference between Azure Policy and RBAC.**
   - **RBAC:** Focuses on *user actions* (Who can do what?).
   - **Policy:** Focuses on *resource properties* (What can be created/modified? e.g., enforce tagging, restrict regions).
9. **What are "Management Groups"?**
   - Containers for managing access, policy, and compliance for multiple subscriptions. They sit above subscriptions in the hierarchy.
10. **How does Azure Cost Management differ from Billing?**
    - Billing is about invoicing and payment. Cost Management is about analyzing spend, setting budgets, and optimizing costs.

---

## Quiz: Azure Fundamentals

<details>
<summary><b>1. Which command group manages Azure Resources?</b></summary>
A) az vm<br>
B) az resource<br>
C) az group<br>
D) az storage<br>
<br>
<b>Answer: B) az resource (or az group for the container)</b>
</details>

<details>
<summary><b>2. What is the scope of a Resource Group?</b></summary>
A) Global<br>
B) Region<br>
C) Subscription<br>
D) Tenant<br>
<br>
<b>Answer: C) Subscription (It lives within a subscription, though resources inside can be in different regions)</b>
</details>

<details>
<summary><b>3. Which service provides a browser-based shell?</b></summary>
A) Azure Cloud Shell<br>
B) PowerShell<br>
C) Bash<br>
D) CMD<br>
<br>
<b>Answer: A) Azure Cloud Shell</b>
</details>

<details>
<summary><b>4. Availability Zones protect against:</b></summary>
A) Region failure<br>
B) Datacenter failure<br>
C) Human error<br>
D) Billing issues<br>
<br>
<b>Answer: B) Datacenter failure</b>
</details>

<details>
<summary><b>5. Which is NOT a valid Azure subscription support plan?</b></summary>
A) Developer<br>
B) Standard<br>
C) Professional Direct<br>
D) Enterprise Premium Plus<br>
<br>
<b>Answer: D) Enterprise Premium Plus</b>
</details>

<details>
<summary><b>6. "Tags" in Azure are:</b></summary>
A) Name/Value pairs for organizing resources<br>
B) Price stickers<br>
C) Security rules<br>
D) DNS records<br>
<br>
<b>Answer: A) Name/Value pairs for organizing resources</b>
</details>

<details>
<summary><b>7. Azure Marketplace is:</b></summary>
A) A shop for buying hardware<br>
B) An online store for certified cloud applications and services<br>
C) A job board<br>
D) A forum<br>
<br>
<b>Answer: B) An online store for certified cloud applications and services</b>
</details>

<details>
<summary><b>8. Which file format is used for ARM templates?</b></summary>
A) XML<br>
B) JSON<br>
C) YAML<br>
D) CSV<br>
<br>
<b>Answer: B) JSON</b>
</details>

<details>
<summary><b>9. To delete a Resource Group and all resources inside it:</b></summary>
A) az group delete<br>
B) az rm -rf<br>
C) az delete<br>
D) az destroy<br>
<br>
<b>Answer: A) az group delete</b>
</details>

<details>
<summary><b>10. Can a resource exist in multiple Resource Groups?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: B) No</b>
</details>

<details>
<summary><b>11. Azure Service Health provides:</b></summary>
A) Personalized guidance and support when Azure service issues affect you<br>
B) Doctor appointments<br>
C) Server CPU usage<br>
D) Billing info<br>
<br>
<b>Answer: A) Personalized guidance and support when Azure service issues affect you</b>
</details>

<details>
<summary><b>12. Which tool analyzes your Azure usage and provides recommendations?</b></summary>
A) Azure Advisor<br>
B) Azure Manager<br>
C) Azure Helper<br>
D) Clippy<br>
<br>
<b>Answer: A) Azure Advisor</b>
</details>

<details>
<summary><b>13. Azure Sovereign Clouds include:</b></summary>
A) Azure Government & Azure China<br>
B) Azure Space<br>
C) Azure Mars<br>
D) Azure Home<br>
<br>
<b>Answer: A) Azure Government & Azure China</b>
</details>

<details>
<summary><b>14. What is the SLA for a single VM with Premium SSD?</b></summary>
A) 99.9%<br>
B) 100%<br>
C) 95%<br>
D) 99%<br>
<br>
<b>Answer: A) 99.9%</b>
</details>

<details>
<summary><b>15. Azure "Spot" VMs offer discounts up to:</b></summary>
A) 90%<br>
B) 50%<br>
C) 10%<br>
D) 30%<br>
<br>
<b>Answer: A) 90%</b>
</details>

<details>
<summary><b>16. CapEx vs OpEx: Azure is primarily:</b></summary>
A) OpEx (Operational Expenditure)<br>
B) CapEx (Capital Expenditure)<br>
<br>
<b>Answer: A) OpEx (Operational Expenditure)</b>
</details>

<details>
<summary><b>17. Which resource type is Global?</b></summary>
A) Traffic Manager Profile<br>
B) Virtual Machine<br>
C) Storage Account<br>
D) VNet<br>
<br>
<b>Answer: A) Traffic Manager Profile (and Azure AD, DNS)</b>
</details>

<details>
<summary><b>18. IoT Hub is used for:</b></summary>
A) Managing IoT devices and bidirectional communication<br>
B) Internet browsing<br>
C) Networking<br>
D) Storage<br>
<br>
<b>Answer: A) Managing IoT devices and bidirectional communication</b>
</details>

<details>
<summary><b>19. Azure DevOps includes:</b></summary>
A) Boards, Repos, Pipelines, Test Plans, Artifacts<br>
B) Just Git<br>
C) Just CI/CD<br>
D) Just Jira<br>
<br>
<b>Answer: A) Boards, Repos, Pipelines, Test Plans, Artifacts</b>
</details>

<details>
<summary><b>20. Access to Azure Preview features is:</b></summary>
A) Controlled via "Preview Features" blade<br>
B) Impossible<br>
C) Automatic<br>
D) Costly<br>
<br>
<b>Answer: A) Controlled via "Preview Features" blade</b>
</details>

<details>
<summary><b>21. Azure "Cloud Shell" persists files in:</b></summary>
A) An Azure File Share<br>
B) Local RAM<br>
C) S3<br>
D) Nowhere<br>
<br>
<b>Answer: A) An Azure File Share</b>
</details>