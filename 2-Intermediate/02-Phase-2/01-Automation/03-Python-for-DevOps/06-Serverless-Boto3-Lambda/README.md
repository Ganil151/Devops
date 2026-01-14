# Serverless Automation: Python & Boto3 in Lambda
*Event-Driven Automation without Servers*

Moving your Python scripts from a laptop to AWS Lambda is the ultimate step in modern DevOps. This guide bridges the gap between local `boto3` scripts and serverless event handlers.

---

## 🏗️ The Lambda Environment

When you run Python in AWS Lambda, you are not running a script in a vacuum. You are responding to an **Event**.

### The Anatomy of a Handler
Every Lambda function requires a "Handler" function that AWS calls when the lambda is triggered.

```python
def lambda_handler(event, context):
    """
    Standard entry point for AWS Lambda.
    
    :param event:   Dict containing data about WHAT triggered the function (S3, CloudWatch, API Gateway)
    :param context: Object containing metadata about the execution (Time remaining, Request ID)
    """
    print(f"Received event: {event}")
    return {"statusCode": 200, "body": "Success"}
```

---

## ⚡ Performance Pattern: "The Warm Start"

A common mistake is initializing the `boto3` client *inside* the handler. This is inefficient.

### ❌ Bad Practice (Cold Start Penalty)
Initializes the client every single time the function runs, adding 200ms-500ms latency per detailed call.
```python
import boto3

def lambda_handler(event, context):
    # CLIENT CREATED EVERY TIME
    s3 = boto3.client('s3') 
    s3.list_buckets()
```

### ✅ Best Practice (Reuse Connections)
Initialize clients at the **top level** (Global Scope). AWS "freezes" the execution environment and reuses it for subsequent requests ("Warm Start").
```python
import boto3

# CLIENT CREATED ONCE, REUSED MANY TIMES
s3 = boto3.client('s3')

def lambda_handler(event, context):
    s3.list_buckets()
```

---

## 📦 Handling Events

Lambda doesn't take command-line arguments. It takes a JSON dictionary called `event`.

### 1. Scheduled Event (CloudWatch/EventBridge)
Used for cron jobs (e.g., "Run every night at 3 AM").
```json
{
  "id": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
  "detail-type": "Scheduled Event",
  "source": "aws.events",
  "time": "2020-09-02T03:00:00Z"
}
```

### 2. S3 Trigger Event
Used when a file is uploaded.
```python
def lambda_handler(event, context):
    # Extract bucket and key from the event
    record = event['Records'][0]
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']
    
    print(f"Processing new file: s3://{bucket}/{key}")
```

---

## 🛠️ Real-World Scenario: The Auto-Remediator

**Scenario**: You want to ensure that NO Security Group ever has Port 22 (SSH) open to the world (`0.0.0.0/0`).
**Solution**: A Lambda function triggered by `CloudWatch Events` (Scheduled) that scans and closes these ports automatically.

### The Code
```python
import boto3
import os

# Initialize outside handler
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # 1. Find exposed security groups
    response = ec2.describe_security_groups(
        Filters=[
            {'Name': 'ip-permission.from-port', 'Values': ['22']},
            {'Name': 'ip-permission.to-port', 'Values': ['22']},
            {'Name': 'ip-permission.cidr', 'Values': ['0.0.0.0/0']}
        ]
    )
    
    violation_count = 0
    
    for sg in response['SecurityGroups']:
        sg_id = sg['GroupId']
        print(f"⚠️ Found Violation: {sg_id}")
        
        # 2. Revoke the rule (Remediation)
        try:
            ec2.revoke_security_group_ingress(
                GroupId=sg_id,
                IpPermissions=[
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 22,
                        'ToPort': 22,
                        'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                    }
                ]
            )
            print(f"✅ Remediated {sg_id}")
            violation_count += 1
        except Exception as e:
            print(f"❌ Failed to remediate {sg_id}: {e}")
            
    return f"Remediated {violation_count} security groups."
```

---

## 🧩 Common Pitfalls

### 1. Hardcoded Credentials
**NEVER** put `aws_access_key_id` in your Lambda code.
*   **Solution**: Assign an **IAM Role** to the Lambda function. Boto3 automatically finds these credentials.

### 2. Timeouts
Lambda has a maximum timeout of 15 minutes.
*   **Solution**: If you need to process thousands of items, use **Pagination** carefully or split the work into multiple Lambdas (Fan-Out pattern).

### 3. Missing Dependencies
Lambda only includes the standard Python library and `boto3` (usually an older version).
*   **Solution**: To use libraries like `requests` or `pandas`, you must create a **Lambda Layer**.

---

## ❓ Interview Questions

1.  **Why do we initialize boto3 clients outside the `lambda_handler`?**
    *   *Answer*: To take advantage of "Warm Starts." Variables defined in the global scope are preserved between function invocations, saving the time cost of re-establishing SSL connections and authentication.
2.  **How does Boto3 authentication work inside Lambda?**
    *   *Answer*: It relies on the **Execution Role**. Boto3 automatically queries the internal metadata service to retrieve temporary credentials associated with that IAM role. You do not pass keys manually.
3.  **What is the maximum execution time for a Lambda function?**
    *   *Answer*: 15 minutes (900 seconds). For longer jobs, use AWS Batch or Step Functions.
4.  **How can you read Environment Variables in Logic?**
    *   *Answer*: Use `os.environ.get('MY_VARIABLE')`. These variables can be set in the Lambda configuration console or via Infrastructure as Code (Terraform/SAM).

---

## 🛠️ Hands-On Challenges

Master serverless automation by building these event-driven cloud utilities.

| Challenge | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- |
| **01. S3 Extractor** | Extract image metadata automatically upon upload and store as JSON in a S3 data lake. | [Link](./challenges/challenge_01_s3_extractor.py) | [Link](./challenges/solutions/solution_01_s3_extractor.py) |
| **02. IAM Auditor** | Build a daily scheduled Lambda that identifies and alerts on stale IAM access keys. | [Link](./challenges/challenge_02_iam_auditor.py) | [Link](./challenges/solutions/solution_02_iam_auditor.py) |
| **03. EC2 Scheduler** | Save thousands in AWS costs by automatically stopping dev instances outside office hours. | [Link](./challenges/challenge_03_ec2_scheduler.py) | [Link](./challenges/solutions/solution_03_ec2_scheduler.py) |
| **04. Layer Builder** | Create a local utility that automates the packaging of third-party Python libraries for Lambda. | [Link](./challenges/challenge_04_layer_builder.py) | [Link](./challenges/solutions/solution_04_layer_builder.py) |

> **Pro Tip**: Always enable "X-Ray" tracing for your Lambda functions. It helps you visualize where Boto3 calls are slow and identifies bottleneck APIs in your automation pipelines.

---

## 🧠 Quiz

1.  **What is the first argument passed to every Lambda handler?**
    *   a) `context`
    *   b) `event` ✅
    *   c) `request`
    *   d) `callback`

2.  **Where should you define your database connection string?**
    *   a) Hardcoded in the file
    *   b) Environment Variables ✅
    *   c) In a text file in the zip
    *   d) In the `event` object

3.  **If a Lambda function times out, what happens to the Boto3 script running inside?**
    *   a) It pauses and resumes later
    *   b) It is forcefully terminated immediately ✅
    *   c) It finishes the current line of code
    *   d) It sends an email to the owner

4.  **To use a library like `numpy` in Lambda, you must use:**
    *   a) `pip install` inside the code
    *   b) A Lambda Layer ✅
    *   c) A larger instance type
    *   d) `import numpy` is supported by default

---

**Next Step**: [Testing Automation with Pytest →](../07-Testing-Automation-with-Pytest/README.md)
