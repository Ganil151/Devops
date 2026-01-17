# Serverless Boto3: AWS Lambda

AWS Lambda allows you to run Python code without provisioning servers. SREs use it for event-driven automation (e.g., "If file uploaded, scan for viruses").

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `lambda_handler.py` (API Gateway pattern).
- **[CHALLENGES](./CHALLENGES.md)**: S3 Triggers, Auto-Remediation.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Handler** | The function AWS calls (e.g., `lambda_function.lambda_handler`). |
| **Event** | Dictionary containing the data (Request body, S3 details). |
| **Context** | Runtime info (Time remaining, Memory limit). |
| **Cold Start** | Initial delay when AWS spins up a container. |

---

## 🏗️ The "Warm Start" Pattern

Code outside the handler runs only once per container lifecycle. Use this for connections.

```python
import boto3

# Initialize OUTSIDE the handler
# Reused across invitations (Warm Start)
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Use the client
    s3_client.list_buckets()
```

---

## 📖 Real-World Story: The "Infinite Loop" Bill

**Problem**: A junior engineer wrote a Lambda that detected an S3 upload, compressed the file, and uploaded it BACK to the same bucket.
**Crisis**: The upload trigger fired the Lambda again... and again. Millions of invocations in an hour.
**Solution**: Always separate "Source" and "Destination" buckets, or check metadata to prevent recursion.

---

## ❓ Interview Questions

1.  **What limits does Lambda have?**
    - *Answer*: 15 minute timeout, 10GB Memory, 6MB Request Payload (sync).
2.  **How do you handle dependencies (e.g. `pandas`)?**
    - *Answer*: Zip them into a "Lambda Layer" and attach it to the function.
3.  **Difference between Event vs Context objects?**
    - *Answer*: Event has the *data* (what caused the trigger). Context has the *environment* (time remaining, log group).

---

[Next: Testing with Pytest](../07-Testing-Automation-with-Pytest/README.md)
