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

## Quiz
<details>
<summary><b>1. S3 bucket names must be:</b></summary>
A) Unique across all AWS accounts globally<br>
B) Unique within your account<br>
C) Unique within region<br>
D) Anything you want<br>
<br>
<b>Answer: A) Unique across all AWS accounts globally</b>
</details>

<details>
<summary><b>2. Which S3 storage class is for "Unknown Access Patterns"?</b></summary>
A) Standard<br>
B) Intelligent-Tiering<br>
C) Glacier<br>
D) One Zone-IA<br>
<br>
<b>Answer: B) Intelligent-Tiering</b>
</details>

<details>
<summary><b>3. EBS Volumes persist independently of the EC2 instance unless:</b></summary>
A) "Delete on Termination" is checked<br>
B) You pay extra<br>
C) They are SSD<br>
D) It is raining<br>
<br>
<b>Answer: A) "Delete on Termination" is checked</b>
</details>

<details>
<summary><b>4. EFS is compatible with:</b></summary>
A) Linux only (NFS)<br>
B) Windows only (SMB)<br>
C) Both<br>
D) Android<br>
<br>
<b>Answer: A) Linux only (NFS)</b>
</details>

<details>
<summary><b>5. Does S3 support file locking?</b></summary>
A) No<br>
B) Yes<br>
<br>
<b>Answer: A) No (It is object storage, not a file system)</b>
</details>

<details>
<summary><b>6. Maximum size of a single S3 object?</b></summary>
A) 5 TB<br>
B) 1 GB<br>
C) 100 GB<br>
D) unlimited<br>
<br>
<b>Answer: A) 5 TB</b>
</details>

<details>
<summary><b>7. Which service is best for long-term audit logs that you hope never to read?</b></summary>
A) S3 Glacier Deep Archive<br>
B) EBS io2<br>
C) EFS<br>
D) RDS<br>
<br>
<b>Answer: A) S3 Glacier Deep Archive</b>
</details>

<details>
<summary><b>8. Can you resize an EBS volume while it is attached and in use?</b></summary>
A) Yes (Elastic Volumes)<br>
B) No<br>
<br>
<b>Answer: A) Yes (Elastic Volumes)</b>
</details>

<details>
<summary><b>9. S3 Transfer Acceleration uses:</b></summary>
A) Edge Locations<br>
B) Magic<br>
C) VPN<br>
D) nothing<br>
<br>
<b>Answer: A) Edge Locations</b>
</details>

<details>
<summary><b>10. What keeps track of object versions in S3?</b></summary>
A) S3 Versioning<br>
B) Git<br>
C) Nothing<br>
D) CloudTrail<br>
<br>
<b>Answer: A) S3 Versioning</b>
</details>

<details>
<summary><b>11. EFS grows and shrinks automatically. (True/False)</b></summary>
A) True<br>
B) False<br>
<br>
<b>Answer: A) True</b>
</details>

<details>
<summary><b>12. EBS Multi-Attach is supported on:</b></summary>
A) io1/io2 volumes only (Provisioned IOPS)<br>
B) gp2 volumes<br>
C) all volumes<br>
D) none<br>
<br>
<b>Answer: A) io1/io2 volumes only (Provisioned IOPS)</b>
</details>

<details>
<summary><b>13. S3 Select allows you to:</b></summary>
A) Retrieve only a subset of data from an object using SQL<br>
B) Select a bucket<br>
C) Delete objects<br>
D) Encrypt objects<br>
<br>
<b>Answer: A) Retrieve only a subset of data from an object using SQL</b>
</details>

<details>
<summary><b>14. Which EBS type is cheapest for infrequent access (boot volumes)?</b></summary>
A) Cold HDD (sc1)<br>
B) Throughput Optimized HDD (st1)<br>
C) General Purpose SSD (gp3)<br>
D) Provisioned IOPS (io2)<br>
<br>
<b>Answer: A) Cold HDD (sc1) (Though technically sc1 cannot be boot volume. For boot volume it's usually gp2/gp3. But sc1 is cheapest block storage)</b>
</details>

<details>
<summary><b>15. S3 Object Lock helps with:</b></summary>
A) Compliance (WORM)<br>
B) Speed<br>
C) Cost<br>
D) Uploads<br>
<br>
<b>Answer: A) Compliance (WORM)</b>
</details>

<details>
<summary><b>16. Can you access EFS from On-Premises?</b></summary>
A) Yes, via Direct Connect or VPN<br>
B) No<br>
<br>
<b>Answer: A) Yes, via Direct Connect or VPN</b>
</details>

<details>
<summary><b>17. FSx for Windows File Server uses which protocol?</b></summary>
A) SMB<br>
B) NFS<br>
C) FTP<br>
D) HTTP<br>
<br>
<b>Answer: A) SMB</b>
</details>

<details>
<summary><b>18. What is the durability of S3 Standard?</b></summary>
A) 99.999999999% (11 9s)<br>
B) 99.9%<br>
C) 99.99%<br>
D) 100%<br>
<br>
<b>Answer: A) 99.999999999% (11 9s)</b>
</details>

<details>
<summary><b>19. S3 Cross-Region Replication (CRR) requires:</b></summary>
A) Versioning enabled on both source and destination buckets<br>
B) Nothing<br>
C) Public access<br>
D) Root access<br>
<br>
<b>Answer: A) Versioning enabled on both source and destination buckets</b>
</details>

<details>
<summary><b>20. To serve S3 content privately to specific users, use:</b></summary>
A) Pre-signed URLs or CloudFront Signed Cookies<br>
B) Public buckets<br>
C) E-mail<br>
D) FTP<br>
<br>
<b>Answer: A) Pre-signed URLs or CloudFront Signed Cookies</b>
</details>

<details>
<summary><b>21. Does S3 support directory structure natively?</b></summary>
A) No, it uses "Prefixes" to simulate folders<br>
B) Yes, it is a file system<br>
<br>
<b>Answer: A) No, it uses "Prefixes" to simulate folders</b>
</details>
