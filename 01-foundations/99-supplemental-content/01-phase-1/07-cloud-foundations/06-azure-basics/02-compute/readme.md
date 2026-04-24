# Azure Compute Services

Comprehensive guide to Azure compute services including Virtual Machines, Container Instances, and serverless computing.

## Virtual Machines

### VM Creation and Management
```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create VM
az vm create \
  --resource-group myResourceGroup \
  --name myVM \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B2s

# List available VM sizes
az vm list-sizes --location eastus --output table

# Start/Stop VM
az vm start --resource-group myResourceGroup --name myVM
az vm stop --resource-group myResourceGroup --name myVM
az vm deallocate --resource-group myResourceGroup --name myVM
```

### VM Scale Sets
```bash
# Create VM Scale Set
az vmss create \
  --resource-group myResourceGroup \
  --name myScaleSet \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --instance-count 2 \
  --admin-username azureuser \
  --generate-ssh-keys

# Scale out/in
az vmss scale --resource-group myResourceGroup --name myScaleSet --new-capacity 5
az vmss scale --resource-group myResourceGroup --name myScaleSet --new-capacity 2
```

## Container Services

### Azure Container Instances
```bash
# Create container instance
az container create \
  --resource-group myResourceGroup \
  --name mycontainer \
  --image nginx \
  --dns-name-label mycontainer-dns \
  --ports 80

# View container logs
az container logs --resource-group myResourceGroup --name mycontainer

# Execute command in container
az container exec --resource-group myResourceGroup --name mycontainer --exec-command "/bin/bash"
```

### Azure Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Scale cluster
az aks scale --resource-group myResourceGroup --name myAKSCluster --node-count 5
```

## Serverless Computing

### Azure Functions
```bash
# Create Function App
az functionapp create \
  --resource-group myResourceGroup \
  --consumption-plan-location eastus \
  --runtime python \
  --runtime-version 3.8 \
  --functions-version 3 \
  --name myFunctionApp \
  --storage-account mystorageaccount

# Deploy function
func azure functionapp publish myFunctionApp
```

This guide covers Azure compute services for scalable cloud applications.