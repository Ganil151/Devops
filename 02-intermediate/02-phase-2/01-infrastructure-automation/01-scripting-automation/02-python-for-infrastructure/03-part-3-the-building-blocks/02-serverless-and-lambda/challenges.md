# 🛠️ Serverless Architecture Challenges (Staff Level)

These challenges are designed to test your ability to build **safe**, **idempotent**, and **observable** cloud logic.

---

## 🏗️ Challenge 1: The "Atomic" S3 Image Scrubber
**Goal**: Build a Lambda that scans newly uploaded files for PII (Personal Identifiable Information) and removes them if they are insecure.

### 📝 Requirements:
1.  **Trigger**: S3 `ObjectCreated:*` events.
2.  **Logic**: 
    *   Parse the bucket and key.
    *   **Staff Pattern**: Your script must handle the `Records` list correctly (S3 events can contain multiple records).
    *   Scan the text content of the file for regex patterns (e.g., Credit Card numbers).
3.  **Governance**: 
    *   If PII is found, move the file to a `quarantine-bucket` and delete it from the original.
    *   **Idempotency**: Use a DynamoDB table to ensure a file isn't processed twice if the S3 trigger retries.
4.  **Security**: Use a **Least-Privilege IAM Role**—do NOT give the function `S3:*`.

---

## ⚡ Challenge 2: The "Self-Healing" Fleet Controller
**Goal**: Create a reactive system that detects "Zombie" EC2 instances (high CPU but no web traffic) and terminates them automatically via EventBridge.

### 📝 Requirements:
1.  **Trigger**: A CloudWatch Alarm sent via **Amazon EventBridge**.
2.  **Logic**: 
    *   Parse the Instance ID from the EventBridge JSON.
    *   Verify the instance has the tag `Automation: Allowed`.
3.  **Resilience**: 
    *   Implement a **Fail-Fast** check: If the instance is part of the `Database` tier, **Abuse/Abort** the termination and send a Slack alert instead.
4.  **Observability**: 
    *   Use `logger.info(json.dumps(event))` to ensure you have a full audit trail of the triggering event.
    *   Configure a **Dead Letter Queue (DLQ)** to capture any events that fail during processing.

---

## 🧪 Challenge 3: The "Multi-Account" Secret Rotator
**Goal**: Build a Lambda that rotates an API key stored in **Secrets Manager** and updates a configuration file in an S3 bucket across a different account.

### 📝 Requirements:
1.  **Trigger**: Secrets Manager Scheduled Rotation.
2.  **Logic**: 
    *   Generate a new random UUID key.
    *   Update Secrets Manager version.
    *   **Cross-Account**: Use Boto3 `sts.assume_role()` to access the S3 bucket in the destination account.
3.  **Pattern**: Implement the **Circuit Breaker**—if the assume-role fails 3 times, stop retrying and alert an SRE.
