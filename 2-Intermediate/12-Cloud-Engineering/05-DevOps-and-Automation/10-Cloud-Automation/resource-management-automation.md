# Resource Management Automation

## Introduction

Managing a few dozen resources is easy. Managing thousands across multiple regions requires automation. This guide provides practical scripts in both Bash and Python to automate common resource management tasks: Tagging, Inventory, and Cleanup.

---

## 1. Automated Tagging

Consistent tagging is critical for cost allocation, security, and automation.

### Scenario: Tag all Untagged EC2 Instances
We want to add a tag `Compliance: Verified` to all running EC2 instances that are missing tags.

#### Bash (AWS CLI)
```bash
#!/bin/bash
# Find instances without tags and apply a compliance tag

INSTANCE_IDS=$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[?!Tags].InstanceId' \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
    echo "No untagged instances found."
else
    echo "Found untagged instances: $INSTANCE_IDS"
    aws ec2 create-tags \
      --resources $INSTANCE_IDS \
      --tags Key=Compliance,Value=Verified
    echo "Tags applied successfully."
fi
```

#### Python (Boto3)
```python
import boto3

ec2 = boto3.client('ec2')

def tag_untagged_instances():
    # Only find instances where the 'Tags' key is missing
    instances = ec2.describe_instances(
        Filters=[{'Name': 'tag-key', 'Values': []}]
    )
    
    ids = []
    for res in instances['Reservations']:
        for inst in res['Instances']:
            if not inst.get('Tags'):
                ids.append(inst['InstanceId'])
    
    if ids:
        print(f"Tagging instances: {ids}")
        ec2.create_tags(Resources=ids, Tags=[{'Key': 'Compliance', 'Value': 'Verified'}])
    else:
        print("All instances have tags.")

if __name__ == '__main__':
    tag_untagged_instances()
```

---

## 2. Resource Inventory Reports

Quickly gathering data about your infrastructure.

### Scenario: List all S3 Buckets and their Regions

#### Bash (AWS CLI + jq)
```bash
#!/bin/bash
# Generate a CSV report of buckets and regions

echo "BucketName,Region"
aws s3api list-buckets | jq -r '.Buckets[].Name' | while read bucket; do
    region=$(aws s3api get-bucket-location --bucket "$bucket" | jq -r '.LocationConstraint // "us-east-1"')
    echo "$bucket,$region"
done
```

#### Python (Boto3)
```python
import boto3

s3 = boto3.client('s3')

def generate_bucket_report():
    response = s3.list_buckets()
    print("BucketName,Region")
    for bucket in response['Buckets']:
        name = bucket['Name']
        try:
            loc = s3.get_bucket_location(Bucket=name)
            region = loc['LocationConstraint'] or 'us-east-1'
            print(f"{name},{region}")
        except Exception:
            print(f"{name},Unknown")

if __name__ == '__main__':
    generate_bucket_report()
```

---

## 3. Automated Cleanup (The "Janitor" Script)

Cost-saving automation by removing orphaned resources.

### Scenario: Delete Unattached EBS Volumes
Find and delete EBS volumes that are in the `available` state (meaning not attached to any instance).

#### Bash (AWS CLI)
```bash
#!/bin/bash
# Find and delete unattached volumes

VOLUMES=$(aws ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query 'Volumes[].VolumeId' \
  --output text)

for vol in $VOLUMES; do
    echo "Deleting orphaned volume: $vol"
    aws ec2 delete-volume --volume-id "$vol"
done
```

#### Python (Boto3)
```python
import boto3

ec2 = boto3.client('ec2')

def cleanup_orphaned_volumes():
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    
    for vol in volumes['Volumes']:
        vid = vol['VolumeId']
        print(f"Deleting orphaned volume: {vid} (Size: {vol['Size']}GB)")
        ec2.delete_volume(VolumeId=vid)

if __name__ == '__main__':
    cleanup_orphaned_volumes()
```

---

## Automation Hacks & Tips

> [!IMPORTANT]
> **Safety First**: When writing cleanup scripts, always implement a **Dry Run** flag to see what would happen before actually deleting anything.
> 
> **Bash Hack**: Use `--dry-run` with AWS CLI commands that support it.
> 
> **Python Hack**: Create a variable `DRY_RUN = True` and wrap your destructive calls in an `if not DRY_RUN:` block.

## Troubleshooting Resource Automation

| Issue | Symptom | Hack / Fix |
|-------|---------|------------|
| API Throttling | `RateExceeded` Error | Use **Exponential Backoff**. Python's Boto3 does this automatically for most errors. |
| Multi-Region Support | Misses resources in other regions | Wrap your loop around a list of all regions: `aws ec2 describe-regions --query 'Regions[].RegionName'` |
| Large Scale Failures | Script times out | Use **Paginators** in Boto3 or `--max-items` in the CLI. |

---

## Next Steps

Finalize your automation skills with **[Automation Troubleshooting & Hacks](automation-troubleshooting-hacks.md)** to learn how to debug and optimize complex workflows.
