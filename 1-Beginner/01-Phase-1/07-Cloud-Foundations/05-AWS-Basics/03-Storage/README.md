# AWS Storage Services

Overview of AWS storage options: S3 (Object), EFS (File), and EBS (Block).

## Storage Decision Matrix
```mermaid
graph TD
    Data[Do you need to store data?]
    Data --> DB{Is it a Database?}

DB -- Yes --> RDS[RDS / DynamoDB]
    DB -- No --> FileType{File Type?}

FileType -- "Static Assets (Img/Video)" --> S3[S3 Object Storage]
    FileType -- "OS Boot / High I/O" --> EBS[EBS Block Storage]
    FileType -- "Shared Network File" --> EFS[EFS File Storage]

classDef storage fill:#e3f2fd,stroke:#0d47a1
    class S3,EBS,EFS,RDS storage
```

## Real World Scenarios
### Scenario: CMS Media Library
**Context:** Wordpress site needs to store user uploads and be accessible by multiple servers.
**Solution:**
- **EFS:** Mount EFS to /var/www/html/wp-content/uploads on all web servers.
**Benefit:** All servers see the same files instantly. S3 could work with a plugin, but EFS is native filesystem access.

<b>1. S3 bucket names must be:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Unique across all AWS accounts globally</b>
</details>


<b>2. Which S3 storage class is for "Unknown Access Patterns"?</b>
<details>
<summary>Show Answer</summary>
Answer: B) Intelligent-Tiering</b>
</details>


<b>3. EBS Volumes persist independently of the EC2 instance unless:</b>
<details>
<summary>Show Answer</summary>
Answer: A) "Delete on Termination" is checked</b>
</details>


<b>4. EFS is compatible with:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Linux only (NFS)</b>
</details>


<b>5. Does S3 support file locking?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No (It is object storage, not a file system)</b>
</details>


<b>6. Maximum size of a single S3 object?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 5 TB</b>
</details>


<b>7. Which service is best for long-term audit logs that you hope never to read?</b>
<details>
<summary>Show Answer</summary>
Answer: A) S3 Glacier Deep Archive</b>
</details>


<b>8. Can you resize an EBS volume while it is attached and in use?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (Elastic Volumes)</b>
</details>


<b>9. S3 Transfer Acceleration uses:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Edge Locations</b>
</details>


<b>10. What keeps track of object versions in S3?</b>
<details>
<summary>Show Answer</summary>
Answer: A) S3 Versioning</b>
</details>


<b>11. EFS grows and shrinks automatically. (True/False)</b>
<details>
<summary>Show Answer</summary>
Answer: A) True</b>
</details>


<b>12. EBS Multi-Attach is supported on:</b>
<details>
<summary>Show Answer</summary>
Answer: A) io1/io2 volumes only (Provisioned IOPS)</b>
</details>


<b>13. S3 Select allows you to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Retrieve only a subset of data from an object using SQL</b>
</details>


<b>14. Which EBS type is cheapest for infrequent access (boot volumes)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Cold HDD (sc1) (Though technically sc1 cannot be boot volume. For boot volume it's usually gp2/gp3. But sc1 is cheapest block storage)</b>
</details>


<b>15. S3 Object Lock helps with:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Compliance (WORM)</b>
</details>


<b>16. Can you access EFS from On-Premises?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, via Direct Connect or VPN</b>
</details>


<b>17. FSx for Windows File Server uses which protocol?</b>
<details>
<summary>Show Answer</summary>
Answer: A) SMB</b>
</details>


<b>18. What is the durability of S3 Standard?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 99.999999999% (11 9s)</b>
</details>


<b>19. S3 Cross-Region Replication (CRR) requires:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Versioning enabled on both source and destination buckets</b>
</details>


<b>20. To serve S3 content privately to specific users, use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Pre-signed URLs or CloudFront Signed Cookies</b>
</details>


<b>21. Does S3 support directory structure natively?</b>
<details>
<summary>Show Answer</summary>
Answer: A) No, it uses "Prefixes" to simulate folders</b>
</details>
