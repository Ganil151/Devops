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

### Advanced Level
7. **What is Azure NetApp Files?**
   - Enterprise-class, high-performance file storage service (Powered by NetApp). Used for extremely demanding workloads.
8. **Explain "Immutable Storage" (WORM).**
   - Write Once, Read Many. Prevents data modification or deletion for a specified period (Legal hold).
9. **How does Azure Data Lake Storage Gen2 differ from Blob Storage?**
   - Gen2 is built on Blob Storage but adds a hierarchical namespace (folders), making it optimized for Big Data analytics.
10. **What is a "Shared Access Signature" (SAS)?**
    - A URI that grants restricted access rights to Azure Storage resources (e.g., read-only for 1 hour).

---

## Quiz: Azure Storage

<details>
<summary><b>1. Default storage redundancy (lowest cost)?</b></summary>
A) LRS (Locally Redundant Storage)<br>
B) GRS (Geo-Redundant Storage)<br>
C) ZRS (Zone-Redundant Storage)<br>
D) RA-GRS<br>
<br>
<b>Answer: A) LRS (Locally Redundant Storage)</b>
</details>

<details>
<summary><b>2. Which tier has the highest retrieval cost?</b></summary>
A) Archive<br>
B) Cool<br>
C) Hot<br>
D) Premium<br>
<br>
<b>Answer: A) Archive</b>
</details>

<details>
<summary><b>3. Azure Files usually uses which port?</b></summary>
A) 445 (SMB)<br>
B) 80<br>
C) 22<br>
D) 443<br>
<br>
<b>Answer: A) 445 (SMB)</b>
</details>

<details>
<summary><b>4. Which tool is best for moving 100TB of data physically to Azure?</b></summary>
A) Azure Data Box<br>
B) AzCopy<br>
C) Upload via Browser<br>
D) FTP<br>
<br>
<b>Answer: A) Azure Data Box</b>
</details>

<details>
<summary><b>5. Can you host a static website on Azure Blob Storage?</b></summary>
A) Yes<br>
B) No<br>
<br>
<b>Answer: A) Yes</b>
</details>

<details>
<summary><b>6. What is "AzCopy"?</b></summary>
A) Command-line utility to copy data to/from Azure Storage<br>
B) A printer<br>
C) A backup service<br>
D) A virus<br>
<br>
<b>Answer: A) Command-line utility to copy data to/from Azure Storage</b>
</details>

<details>
<summary><b>7. ZRS replicates data across:</b></summary>
A) 3 Availability Zones in the same region<br>
B) 3 Regions<br>
C) 3 Racks<br>
D) 3 Continents<br>
<br>
<b>Answer: A) 3 Availability Zones in the same region</b>
</details>

<details>
<summary><b>8. Premium SSDs are backed by:</b></summary>
A) Solid State Drives<br>
B) Tape<br>
C) HDD<br>
D) Floppy<br>
<br>
<b>Answer: A) Solid State Drives</b>
</details>

<details>
<summary><b>9. Which service allows syncing on-prem Windows Servers with Azure Files?</b></summary>
A) Azure File Sync<br>
B) OneDrive<br>
C) Dropbox<br>
D) Robocopy<br>
<br>
<b>Answer: A) Azure File Sync</b>
</details>

<details>
<summary><b>10. Is Data Lake Gen2 compatible with Hadoop (HDFS)?</b></summary>
A) Yes, via ABFS driver<br>
B) No<br>
<br>
<b>Answer: A) Yes, via ABFS driver</b>
</details>

<details>
<summary><b>11. What is the max size of a Block Blob?</b></summary>
A) Approx 4.75 TB (Higher with recent updates, but standard answer)<br>
B) 1 GB<br>
C) 100 MB<br>
D) Unlimited<br>
<br>
<b>Answer: A) Approx 4.75 TB (Higher with recent updates, but standard answer)</b>
</details>

<details>
<summary><b>12. Storage Explorer is:</b></summary>
A) A desktop GUI app for managing Azure Storage<br>
B) A CLI<br>
C) A web portal<br>
D) A paid service<br>
<br>
<b>Answer: A) A desktop GUI app for managing Azure Storage</b>
</details>

<details>
<summary><b>13. Soft Delete allows you to:</b></summary>
A) Recover deleted blobs for a retention period<br>
B) Delete quickly<br>
C) Delete quietly<br>
D) Compress data<br>
<br>
<b>Answer: A) Recover deleted blobs for a retention period</b>
</details>

<details>
<summary><b>14. Can you use Azure AD to authenticate to Blob Storage?</b></summary>
A) Yes (RBAC)<br>
B) No, only Key<br>
C) No, only SAS<br>
D) Only via VPN<br>
<br>
<b>Answer: A) Yes (RBAC)</b>
</details>

<details>
<summary><b>15. Which redundancy option protects against a region-wide disaster?</b></summary>
A) GRS or GZRS<br>
B) LRS<br>
C) ZRS<br>
D) None<br>
<br>
<b>Answer: A) GRS or GZRS</b>
</details>

<details>
<summary><b>16. Shared Disks allow:</b></summary>
A) Mapping a single Managed Disk to multiple VMs simultaneously (Clustering)<br>
B) Sharing files via HTTP<br>
C) Sharing passwords<br>
D) Free disks<br>
<br>
<b>Answer: A) Mapping a single Managed Disk to multiple VMs simultaneously (Clustering)</b>
</details>

<details>
<summary><b>17. How many keys does a Storage Account have by default?</b></summary>
A) 2 (Primary and Secondary)<br>
B) 1<br>
C) 5<br>
D) 0<br>
<br>
<b>Answer: A) 2 (Primary and Secondary)</b>
</details>

<details>
<summary><b>18. Azure Queue Storage is for:</b></summary>
A) Storing large numbers of messages (for decoupling)<br>
B) Storing videos<br>
C) Storing tables<br>
D) Storing code<br>
<br>
<b>Answer: A) Storing large numbers of messages (for decoupling)</b>
</details>

<details>
<summary><b>19. Table Storage is:</b></summary>
A) A NoSQL key-value store<br>
B) A SQL database<br>
C) A spreadsheet<br>
D) A file server<br>
<br>
<b>Answer: A) A NoSQL key-value store</b>
</details>

<details>
<summary><b>20. Access Tiers apply to which kind of storage?</b></summary>
A) Blob Storage (and Data Lake)<br>
B) Managed Disks<br>
C) Queue Storage<br>
D) Table Storage<br>
<br>
<b>Answer: A) Blob Storage (and Data Lake)</b>
</details>

<details>
<summary><b>21. Ephemeral OS Disks:</b></summary>
A) Store OS on the local VM cache (faster, lower cost, but data lost if VM moves)<br>
B) Persist forever<br>
C) Are slow<br>
D) Are expensive<br>
<br>
<b>Answer: A) Store OS on the local VM cache (faster, lower cost, but data lost if VM moves)</b>
</details>

This guide covers Azure storage services for data management and persistence.