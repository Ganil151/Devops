# Google Cloud Storage Services

Comprehensive guide to GCP storage solutions including Cloud Storage, Persistent Disks, and databases.

## Cloud Storage
```bash
# Create bucket
gsutil mb gs://my-unique-bucket-name

# Upload file
gsutil cp myfile.txt gs://my-unique-bucket-name/

# Download file
gsutil cp gs://my-unique-bucket-name/myfile.txt ./downloaded-file.txt

# Sync directory
gsutil -m rsync -r ./local-directory gs://my-unique-bucket-name/remote-directory

# Set bucket lifecycle
gsutil lifecycle set lifecycle.json gs://my-unique-bucket-name

# Enable versioning
gsutil versioning set on gs://my-unique-bucket-name

# Set public access
gsutil iam ch allUsers:objectViewer gs://my-unique-bucket-name
```

## Persistent Disks
```bash
# Create persistent disk
gcloud compute disks create my-disk \
  --size=100GB \
  --zone=us-central1-a \
  --type=pd-ssd

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
  --disk=my-disk \
  --zone=us-central1-a

# Create snapshot
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a

# Create disk from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a
```

## Cloud SQL
```bash
# Create Cloud SQL instance
gcloud sql instances create my-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-1 \
  --region=us-central1

# Create database
gcloud sql databases create mydatabase \
  --instance=my-instance

# Create user
gcloud sql users create myuser \
  --instance=my-instance \
  --password=mypassword

# Connect to instance
gcloud sql connect my-instance --user=root
```

## Firestore
```bash
# Create Firestore database
gcloud firestore databases create --region=us-central

# Import data
gcloud firestore import gs://my-bucket/export-folder

# Export data
gcloud firestore export gs://my-bucket/export-folder
```

This guide covers GCP storage services for data management and persistence.

## Real World Scenarios

### Scenario 1: Cost-Effective Backup
**Context:** Storing 5PB of archival data that is rarely accessed (once a year).
**Solution:**
- **Cloud Storage:** Use "Archive" Storage Class.
- **Lifecycle Policy:** Auto-transition from Standard -> Archive after 30 days.
**Benefit:** Lowest cost storage ($0.0012/GB/month).

### Scenario 2: Global Consistency
**Context:** Need a relational database that scales horizontally worldwide with strong consistency.
**Solution:**
- **Cloud Spanner:** The only enterprise-grade, globally-distributed, and strongly consistent database service.
**Benefit:** Solves the problem of choosing between relational semantics (SQL) and horizontal scale (NoSQL).

---

## Interview Questions

### Basic Level
1. **What is Google Cloud Storage (GCS)?**
   - Object storage service (like S3). Stores unstructured data (files, images, backups) in buckets.
2. **What are the GCS Storage Classes?**
   - Standard, Nearline, Coldline, Archive.
3. **What is Cloud SQL?**
   - Managed relational database for MySQL, PostgreSQL, and SQL Server.

### Intermediate Level
4. **Explain the difference between Persistent Disk and Local SSD.**
   - **Persistent Disk:** Network storage. Durable, independent of VM lifecycle. Slower than local.
   - **Local SSD:** Physically attached to the server. Extremely fast (IOPS), but ephemeral (data lost if instance stops/migrates in some cases).
5. **What is Cloud Spanner?**
   - A fully managed, mission-critical, relational database aimed at global scale and strong consistency.
6. **What is Cloud Bigtable?**
   - A fully managed, scalable NoSQL database for large analytical and operational workloads (Petabyte scale, high throughput). Used for IoT, AdTech.

### Advanced Level
7. **How does Firestore differ from Cloud Bigtable?**
   - **Firestore:** Document-based NoSQL (JSON-like), flexible, good for app dev, mobile/web, live sync.
   - **Bigtable:** Wide-column NoSQL, flat, massive scale/throughput, good for analytics/time-series.
8. **Explain Regional vs Multi-Regional Storage Buckets.**
   - **Regional:** Stored in one region. Lower latency/cost for local computation.
   - **Multi-Regional:** Replicated across a continent (e.g., US). Higher availability (99.95% SLA) and geo-redundancy.
9. **What is Filestore?**
   - Managed NFS (Network File System) for applications requiring file system interface (shared POSIX).

---

## Quiz: GCP Storage

<details>
<summary><b>1. Which Command Line tool manages GCS?</b></summary>
A) gsutil<br>
B) gcloud storage (Newer)<br>
C) gcloud compute<br>
D) A and B<br>
<br>
<b>Answer: D) A and B (gsutil is legacy/standard, gcloud storage is the new optimized CLI)</b>
</details>

<details>
<summary><b>2. Lowest cost storage class for data accessed once a year?</b></summary>
A) Archive<br>
B) Coldline<br>
C) Nearline<br>
D) Standard<br>
<br>
<b>Answer: A) Archive</b>
</details>

<details>
<summary><b>3. Persistent Disks are:</b></summary>
A) Zonal or Regional network block storage<br>
B) Local physical disks<br>
C) Tapes<br>
D) RAM<br>
<br>
<b>Answer: A) Zonal or Regional network block storage</b>
</details>

<details>
<summary><b>4. Which is a Global Relational Database?</b></summary>
A) Cloud Spanner<br>
B) Cloud SQL<br>
C) BigQuery<br>
D) MongoDB<br>
<br>
<b>Answer: A) Cloud Spanner</b>
</details>

<details>
<summary><b>5. For Data Warehousing and Analytics, use:</b></summary>
A) BigQuery<br>
B) Cloud SQL<br>
C) Firestore<br>
D) Cloud Functions<br>
<br>
<b>Answer: A) BigQuery</b>
</details>

<details>
<summary><b>6. Firestore data model is:</b></summary>
A) Document (NoSQL)<br>
B) Relational<br>
C) Key-Value<br>
D) Graph<br>
<br>
<b>Answer: A) Document (NoSQL)</b>
</details>

<details>
<summary><b>7. Can you attach a Persistent Disk to multiple VMs?</b></summary>
A) Yes, in Read-Only mode (mostly), or multi-writer (specific types)<br>
B) Never<br>
C) Only in AWS<br>
D) If you ask nicely<br>
<br>
<b>Answer: A) Yes, in Read-Only mode (mostly), or multi-writer (specific types)</b>
</details>

<details>
<summary><b>8. Cloud SQL supports:</b></summary>
A) MySQL, PostgreSQL, SQL Server<br>
B) Oracle<br>
C) DB2<br>
D) Access<br>
<br>
<b>Answer: A) MySQL, PostgreSQL, SQL Server</b>
</details>

<details>
<summary><b>9. Which class has a 30-day minimum storage duration?</b></summary>
A) Nearline<br>
B) Standard<br>
C) Archive (365 days)<br>
D) Coldline (90 days)<br>
<br>
<b>Answer: A) Nearline</b>
</details>

<details>
<summary><b>10. Is Object Versioning enabled by default?</b></summary>
A) No<br>
B) Yes<br>
<br>
<b>Answer: A) No</b>
</details>

<details>
<summary><b>11. Filestore provides which protocol?</b></summary>
A) NFSv3<br>
B) SMB<br>
C) FTP<br>
D) HTTP<br>
<br>
<b>Answer: A) NFSv3</b>
</details>

<details>
<summary><b>12. Bigtable is compatible with:</b></summary>
A) HBase API<br>
B) MongoDB API<br>
C) SQL<br>
D) Redis<br>
<br>
<b>Answer: A) HBase API</b>
</details>

<details>
<summary><b>13. To transfer Petabytes of data offline to GCP, use:</b></summary>
A) Transfer Appliance<br>
B) gsutil<br>
C) USB drive<br>
D) Email<br>
<br>
<b>Answer: A) Transfer Appliance</b>
</details>

<details>
<summary><b>14. Regional buckets are best for:</b></summary>
A) Co-locating data with compute in the same region (performance/cost)<br>
B) Global distribution<br>
C) Archiving<br>
D) Nothing<br>
<br>
<b>Answer: A) Co-locating data with compute in the same region (performance/cost)</b>
</details>

<details>
<summary><b>15. Changing storage class from Standard to Nearline:</b></summary>
A) Incurs a retrieval fee if accessed too soon, but lower storage cost<br>
B) Is free<br>
C) Is impossible<br>
D) Deletes data<br>
<br>
<b>Answer: A) Incurs a retrieval fee if accessed too soon, but lower storage cost</b>
</details>

<details>
<summary><b>16. MemoryStore is a managed service for:</b></summary>
A) Redis and Memcached<br>
B) SQL<br>
C) NoSQL<br>
D) Files<br>
<br>
<b>Answer: A) Redis and Memcached</b>
</details>

<details>
<summary><b>17. Cloud SQL "High Availability" creates:</b></summary>
A) A Standby instance in a different zone<br>
B) A read replica<br>
C) A backup<br>
D) Nothing<br>
<br>
<b>Answer: A) A Standby instance in a different zone</b>
</details>

<details>
<summary><b>18. Can you resize a Persistent Disk online (without stopping VM)?</b></summary>
A) Yes (Increase only)<br>
B) Yes (Decrease only)<br>
C) No<br>
D) Yes (Both)<br>
<br>
<b>Answer: A) Yes (Increase only)</b>
</details>

<details>
<summary><b>19. Local SSD data persists through a "Stop/Start"?</b></summary>
A) No (It is cleared)<br>
B) Yes<br>
<br>
<b>Answer: A) No (It is cleared)</b>
</details>

<details>
<summary><b>20. To query data directly in GCS using SQL?</b></summary>
A) BigQuery External Tables (or Data Lake capabilities)<br>
B) You can't<br>
C) Use notepad<br>
D) Cloud SQL<br>
<br>
<b>Answer: A) BigQuery External Tables (or Data Lake capabilities)</b>
</details>

<details>
<summary><b>21. Signed URLs allow:</b></summary>
A) Temporary access to a private object without Google account<br>
B) Digital signatures<br>
C) Permanent access<br>
D) Nothing<br>
<br>
<b>Answer: A) Temporary access to a private object without Google account</b>
</details>