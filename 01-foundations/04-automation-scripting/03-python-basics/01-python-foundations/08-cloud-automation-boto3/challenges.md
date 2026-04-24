# 🧩 Hands-On Challenges: Cloud Automation with Boto3

## Target: Cloud Control & Security Audit

Mastering Boto3 means moving from "Manual Operator" to "Scale Engineer." In these challenges, you will build scripts to manage storage, audit compute costs, and enforce security policies.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: The S3 Janitor**
**Mission**: Automate the cleanup and inventory of S3 storage.
1. List all S3 buckets in the account.
2. Upload a file named `heartbeat.txt` to a specific bucket.
3. Print the total number of objects in that bucket.

**Script Template (`s3_manager.py`)**:
```python
import boto3

def manage_s3():
    s3 = boto3.resource('s3')
    
    # 1. List all buckets
    print("Listing Buckets:")
    for bucket in s3.buckets.all():
        print(f" - {bucket.name}")

    # 2. Upload file
    target_bucket = "your-unique-bucket-name"
    s3.Bucket(target_bucket).upload_file('heartbeat.txt', 'heartbeat.txt')
    print(f"\nUploaded heartbeat.txt to {target_bucket}")

if __name__ == "__main__":
    manage_s3()
```

---

### **Challenge 2: The EC2 Cost Saver (Stopped Instance Finder)**
**Mission**: Find all EC2 instances that are currently "Stopped" to help the team identify unused resources and save costs.
1. Use an EC2 **Filter** to find instances with `State: stopped`.
2. Print the `InstanceId` and `InstanceType` of each.

**Script Template (`ec2_audit.py`)**:
```python
import boto3

def find_stopped_instances():
    ec2 = boto3.resource('ec2')
    
    # Filter for stopped instances
    instances = ec2.instances.filter(
        Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}]
    )

    print("--- Stopped Instances (Cost Saving Targets) ---")
    for instance in instances:
        print(f"ID: {instance.id} | Type: {instance.instance_type}")

if __name__ == "__main__":
    find_stopped_instances()
```

---

## 🟡 **INTERMEDIATE CHALLENGES (4-5)**

### **Challenge 3: The IAM Security Auditor (Access Keys)**
**Mission**: Security policy requires rotating access keys every 90 days. Write a script that identifies "Stale" users.
1. Iterate through all IAM users.
2. Check the `CreateDate` of their Access Keys.
3. If a key is older than 90 days, print a warning.

**Script Template (`iam_auditor.py`)**:
```python
import boto3
from datetime import datetime, timezone, timedelta

def audit_keys():
    iam = boto3.client('iam')
    users = iam.list_users()['Users']
    
    now = datetime.now(timezone.utc)
    stale_limit = now - timedelta(days=90)

    print(f"{'Username':<20} | {'Key ID':<25} | {'Age (Days)':<10}")
    print("-" * 60)

    for user in users:
        username = user['UserName']
        keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
        
        for key in keys:
            creation_date = key['CreateDate']
            age = (now - creation_date).days
            
            if creation_date < stale_limit:
                print(f"{username:<20} | {key['AccessKeyId']:<25} | {age:<10} ⚠️ STALE")

if __name__ == "__main__":
    audit_keys()
```

---

### **Challenge 4: The Tag-Based Tagging Robot**
**Mission**: Enforce best practices. If an EC2 instance is missing the `Environment` tag, add `Environment: Unknown`.
1. Use a **Resource** to find all instances.
2. Check the `tags` attribute.
3. Use `create_tags()` to fix missing metadata.

---

## 🔗 **NEXT STEPS**
Proceed to **[Time & Date Operations](../09-time-and-date/readme.md)** →
