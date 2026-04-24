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

## Real World Scenarios

### Scenario 1: Big Data Lake
**Context:** Need cost-effective storage for 5PB of logs that are barely accessed but must be kept for 7 years (Audit).
**Solution:**
- **Azure Blob Storage (Archive Tier):** Store the data here.
- **Lifecycle Management Policy:** Automatically move data from Cool to Archive after 30 days.
**Benefit:** Lowest possible storage cost.

### Scenario 2: Lift and Shift File Server
**Context:** Migrating legacy app that uses SMB file shares (`\\server\share`).
**Solution:**
- **Azure Files:** Create a standard file share.
- **Mount:** Mount on VMs.
- **Azure File Sync:** Sync on-prem Windows Server with cloud share for caching.
**Benefit:** No code changes required.

---

## Interview Questions

### Basic Level
1. **What is Azure Blob Storage?**
   - Object storage solution for the cloud. Optimized for storing massive amounts of unstructured data (text, binary).
2. **What are the 3 main Blob access tiers?**
   - Hot (frequent access), Cool (infrequent access), Archive (rare access).
3. **What is Azure Files?**
   - Fully managed file shares in the cloud that are accessible via SMB or NFS.

### Intermediate Level
4. **Explain the difference between Managed Disks vs Unmanaged Disks.**
   - **Managed:** AWS handles the storage account creation and management behind the scenes. Scalable and reliable.
   - **Unmanaged:** You manage the storage account. Legacy, simpler to start but harder to manage at scale.
5. **What is LRS vs GRS?**
   - **LRS (Locally Redundant):** 3 copies in a single datacenter.
   - **GRS (Geo-Redundant):** 3 copies in primary region + 3 copies in secondary paired region.
6. **When would you use "Ultra Disk"?**
   - For mission-critical I/O intensive workloads (e.g., SAP HANA, top-tier SQL).

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) LRS (Locally Redundant Storage)</b>
</details>


<b>2. Which tier has the highest retrieval cost?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Archive</b>
</details>


<b>3. Azure Files usually uses which port?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 445 (SMB)</b>
</details>


<b>4. Which tool is best for moving 100TB of data physically to Azure?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure Data Box</b>
</details>


<b>5. Can you host a static website on Azure Blob Storage?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>6. What is "AzCopy"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Command-line utility to copy data to/from Azure Storage</b>
</details>


<b>7. ZRS replicates data across:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 3 Availability Zones in the same region</b>
</details>


<b>8. Premium SSDs are backed by:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Solid State Drives</b>
</details>


<b>9. Which service allows syncing on-prem Windows Servers with Azure Files?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Azure File Sync</b>
</details>


<b>10. Is Data Lake Gen2 compatible with Hadoop (HDFS)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, via ABFS driver</b>
</details>


<b>11. What is the max size of a Block Blob?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Approx 4.75 TB (Higher with recent updates, but standard answer)</b>
</details>


<b>12. Storage Explorer is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A desktop GUI app for managing Azure Storage</b>
</details>


<b>13. Soft Delete allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Recover deleted blobs for a retention period</b>
</details>


<b>14. Can you use Azure AD to authenticate to Blob Storage?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (RBAC)</b>
</details>


<b>15. Which redundancy option protects against a region-wide disaster?</b>
<details>
<summary>Show Answer</summary>
Answer: A) GRS or GZRS</b>
</details>


<b>16. Shared Disks allow:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Mapping a single Managed Disk to multiple VMs simultaneously (Clustering)</b>
</details>


<b>17. How many keys does a Storage Account have by default?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 2 (Primary and Secondary)</b>
</details>


<b>18. Azure Queue Storage is for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Storing large numbers of messages (for decoupling)</b>
</details>


<b>19. Table Storage is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A NoSQL key-value store</b>
</details>


<b>20. Access Tiers apply to which kind of storage?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Blob Storage (and Data Lake)</b>
</details>


<b>21. Ephemeral OS Disks:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Store OS on the local VM cache (faster, lower cost, but data lost if VM moves)</b>
</details>


This guide covers Azure storage services for data management and persistence.