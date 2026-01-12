# 🔐 AWS S3 Server-Side Encryption: SSE-S3 vs. SSE-KMS

Data security is paramount in the cloud. When storing sensitive data (like Terraform State, database backups, or PII) in Amazon S3, **Server-Side Encryption (SSE)** ensures that your data is encrypted before it is saved to disk and decrypted only when you download it.

Amazon offers three main types of SSE, but the two most critical for DevOps engineers to understand are **SSE-S3** and **SSE-KMS**.

> "Encryption at rest is not just a checkbox; it's the last line of defense against physical theft and unauthorized volume access."

---

## 🆚 Overview Comparison

| Feature | SSE-S3 (AES-256) | SSE-KMS (Key Management Service) |
| :--- | :--- | :--- |
| **Description** | S3 manages the encryption keys for you. | You manage the keys (or use AWS managed keys) via KMS. |
| **Cost** | Free (integrated into S3). | Costs money per API call (encrypt/decrypt). |
| **Key Rotation** | Handled transparently by AWS. | Configurable rotation (Automatic yearly or manual). |
| **Access Control** | Controlled via S3 Bucket Policies / IAM. | **Double Layer**: Requires both S3 access AND KMS Key permissions. |
| **Audit Compliance** | Shows "S3" encrypted it. | **Detailed**: CloudTrail shows *exactly* who decrypted the object and which key was used. |
| **Batch Ops** | Unlimited throughput. | Subject to KMS API quotas (Request-Per-Second limits). |

---

## 1. 🛡️ SSE-S3 (Managed Keys)

**SSE-S3** implies that Amazon handles the heavy lifting. It uses **AES-256** (Advanced Encryption Standard).

### How it works
1.  You upload a file.
2.  S3 generates a unique data key.
3.  S3 encrypts your data with that key.
4.  S3 encrypts the data key with a master key that it holds.
5.  All keys are stored securely by Amazon.

### Setup (Terraform)
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### When to use
*   **General Purpose**: Access logs, static assets, non-sensitive config.
*   **Cost Sensitive**: You don't want to pay for KMS API calls.
*   **Simple**: You just need "Encryption at Rest" to check a compliance box without complex RBAC.

---

## 2. 🔑 SSE-KMS (Key Management Service)

**SSE-KMS** provides a separation of duties. S3 stores the data, but KMS manages the keys. This allows for **Customer Managed Keys (CMKs)**.

### How it works
1.  You upload a file.
2.  S3 calls KMS to generate a Data Key.
3.  KMS verifies you have `kms:GenerateDataKey` permission.
4.  S3 uses the key to encrypt the data.
5.  When you download, S3 calls KMS to decrypt the key (checking `kms:Decrypt`).

### The "Double Lock" Security 🔒
With SSE-KMS, even if an attacker has full S3 Admin access (`s3:*`), they **CANNOT** read the file if they don't *also* have permission on the KMS Key. This is critical for **Terraform State** files.

### Setup (Terraform)
```hcl
resource "aws_kms_key" "mykey" {
  description             = "KMS key for State Bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.mykey.arn
    }
  }
}
```

### When to use
*   **High Compliance**: HIPAA, PCI-DSS, SOC2 requiring "Separation of Duties".
*   **Terraform State**: To strictly control who can read infrastructure secrets.
*   **Audit capability**: To see exactly *who* accessed a file and *when* via CloudTrail.

---

## 🕵️ Deep Dive: The Audit Trail difference

**Scenario**: You have a sensitive PDF `salary_report.pdf` in S3.

**With SSE-S3:**
*   **CloudTrail**: Shows `EventName: GetObject`, `User: Alice`.
*   *Limitation*: You assume Alice read it, but S3 just served it.

**With SSE-KMS:**
*   **CloudTrail (S3)**: Shows `EventName: GetObject`, `User: Alice`.
*   **CloudTrail (KMS)**: Shows `EventName: Decrypt`, `User: Alice`, `KeyId: 1234-abcd`, `Context: {bucket: 'hr-data'}`.
*   *Benefit*: You have cryptographic proof that the key was used to decrypt *that specific* bucket's data.

---

## ⚠️ Common Pitfalls

1.  **KMS API Limits**: If you upload 10,000 files at once (e.g., a Spark job), S3 calls KMS 10,000 times. You might hit the KMS throttling limit, causing uploads to fail.
    *   *Fix*: Use S3 Bucket Keys (`bucket_key_enabled = true`) to reduce KMS calls.
2.  **Cross-Account Access**: If Account A owns the Bucket + Key, and Account B tries to write to it, Account B needs permissions on **BOTH** the Bucket Policy AND the KMS Key Policy. This is the #1 cause of Terraform backend errors in multi-account setups.
3.  **Cost**: KMS charges ~$0.03 per 10,000 requests. For data lakes, this adds up. For state files, it's negligible.

---

## ❓ Interview Questions

**1. A developer has `s3:FullAccess` but gets "Access Denied" when trying to download a file. Why?**
> **Answer**: The object is likely encrypted with a custom KMS key, and the developer's IAM role does not have `kms:Decrypt` permission for that specific key. This is the "Double Lock" feature of SSE-KMS.

**2. Explain the strict separation of duties regarding Terraform State encryption.**
> **Answer**: By using SSE-KMS, the Storage Team can manage the S3 bucket (storage), while the Security Team manages the KMS Key (access). Even if a Storage Admin abuses their power to download the state file, they cannot decrypt it without the Security Team's explicit grant.

**3. What is the difference between SSE-C and SSE-KMS?**
> **Answer**:
> *   **SSE-KMS**: AWS manages the key hardware, you manage the policy.
> *   **SSE-C** (Customer Provided): **You** send the raw encryption key in the HTTP header with every request. AWS doesn't store the key at all. If you lose the key, the data is gone forever. SSE-C is rarely used in modern DevOps compared to KMS.

**4. How does "S3 Bucket Keys" reduce cost?**
> **Answer**: It creates a "derived" key that lives in S3 for a short time. Instead of calling KMS for *every* object, S3 uses the derived key for multiple objects, reducing KMS API calls by up to 99%.

---

## 🏆 Assessment Quiz

1.  **Which encryption method handles key rotation automatically without user configuration?**
    *   A) SSE-S3 (and SSE-KMS if managed)
    *   B) Client-Side Encryption
    *   C) PGP
    *   D) SSH
    *   <details><summary>Answer</summary>A</details>

2.  **To allow a different AWS account to read your KMS-encrypted object, you must update:**
    *   A) Only the S3 Bucket Policy
    *   B) Only the IAM Role
    *   C) The S3 Bucket Policy AND The KMS Key Policy
    *   D) The Security Group
    *   <details><summary>Answer</summary>C</details>

3.  **Which feature allows you to audit EXACTLY who decrypted a specific file?**
    *   A) SSE-S3
    *   B) SSE-KMS
    *   C) SSL/TLS
    *   D) VPC Flow Logs
    *   <details><summary>Answer</summary>B</details>

4.  **True/False: SSE-KMS is more expensive than SSE-S3.**
    *   A) True (due to API calls and key storage costs)
    *   B) False
    *   <details><summary>Answer</summary>A</details>

5.  **For Terraform State files containing database passwords, which is the recommended encryption?**
    *   A) None (State is internal)
    *   B) SSE-S3
    *   C) SSE-KMS (Customer Managed Key)
    *   D) Base64 Encoding
    *   <details><summary>Answer</summary>C</details>
