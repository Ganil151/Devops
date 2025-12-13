# Azure Storage Services

Comprehensive guide to Azure storage solutions including Blob Storage, Files, and managed disks.

## Storage Account Management
```bash
# Create storage account
az storage account create \
  --name mystorageaccount \
  --resource-group myResourceGroup \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

# Get storage account keys
az storage account keys list \
  --resource-group myResourceGroup \
  --account-name mystorageaccount

# Set default account
export AZURE_STORAGE_ACCOUNT=mystorageaccount
export AZURE_STORAGE_KEY=$(az storage account keys list --resource-group myResourceGroup --account-name mystorageaccount --query '[0].value' -o tsv)
```

## Blob Storage
```bash
# Create container
az storage container create --name mycontainer

# Upload blob
az storage blob upload \
  --file myfile.txt \
  --container-name mycontainer \
  --name myblob

# List blobs
az storage blob list --container-name mycontainer --output table

# Download blob
az storage blob download \
  --container-name mycontainer \
  --name myblob \
  --file downloaded-file.txt
```

## Azure Files
```bash
# Create file share
az storage share create --name myfileshare

# Upload file to share
az storage file upload \
  --share-name myfileshare \
  --source myfile.txt \
  --path myfile.txt

# Mount file share (Linux)
sudo mkdir /mnt/myfileshare
sudo mount -t cifs //mystorageaccount.file.core.windows.net/myfileshare /mnt/myfileshare -o username=mystorageaccount,password=$AZURE_STORAGE_KEY
```

## Managed Disks
```bash
# Create managed disk
az disk create \
  --resource-group myResourceGroup \
  --name myDisk \
  --size-gb 128 \
  --sku Premium_LRS

# Attach disk to VM
az vm disk attach \
  --resource-group myResourceGroup \
  --vm-name myVM \
  --name myDisk
```

This guide covers Azure storage services for data management and persistence.