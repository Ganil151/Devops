# Automation Troubleshooting & Hacks

## Introduction

Automation at scale introduces unique challenges. This guide covers pro-level strategies for debugging automation, handling API limits, and performing bulk operations across complex cloud footprints.

---

## 1. Advanced Debugging for Automation

When a script fails in the middle of a 1,000-resource loop, you need visibility.

### SDK Logging (Python)
Enable debug logging to see the raw request/response from the AWS API.

```python
import boto3
import logging

# Set up logging to see raw HTTP requests
boto3.set_stream_logger('botocore', level=logging.DEBUG)

s3 = boto3.client('s3')
s3.list_buckets()
```

### CLI Dry Runs
Many AWS CLI commands support the `--dry-run` flag to verify permissions and parameters without actually performing the action.

```bash
# Check if you COULD terminate an instance
aws ec2 terminate-instances --instance-ids i-12345678 --dry-run
```

---

## 2. Handling API Throttling

AWS services have **Request Rate Limits**. If your script runs too fast, you'll get a `RateExceeded` or `Throttling` error.

### Strategy: Exponential Backoff
Instead of failing, wait and retry.

**Python (Automatic)**:
Boto3 has built-in retry logic. You can configure it specifically:
```python
from botocore.config import Config

config = Config(
   retries = {
      'max_attempts': 10,
      'mode': 'adaptive'  # Automatically handles throttling
   }
)

ec2 = boto3.client('ec2', config=config)
```

**Bash (Manual)**:
```bash
# Simple retry logic with sleep
retry_command() {
    local n=1
    local max=5
    local delay=2
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                echo "Command failed. Attempt $n/$max: Retrying in $delay seconds..."
                sleep $delay
                delay=$((delay * 2)) # Exponential backoff
            else
                echo "The command has failed after $n attempts."
                return 1
            fi
        }
    done
}

retry_command aws ec2 describe-instances
```

---

## 3. Automation Hacks

### Bulk Data Transformation (JQ)
Transforming complex JSON metadata into readable formats or IDs.

```bash
# Get all Security Group IDs in a VPC and format them as a comma-separated list
VPC_ID="vpc-123456"
SG_LIST=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID | jq -r '.SecurityGroups[].GroupId' | paste -sd "," -)
echo $SG_LIST
```

### Multi-Account Automation (AssumeRole)
Executing scripts across different accounts without managing dozens of keys.

```python
import boto3

def get_cross_account_client(account_id, role_name, service):
    sts = boto3.client('sts')
    role_arn = f'arn:aws:iam::{account_id}:role/{role_name}'
    
    # Assume the role in the destination account
    assumed_role = sts.assume_role(
        RoleArn=role_arn,
        RoleSessionName='AutomationSession'
    )
    
    credentials = assumed_role['Credentials']
    
    return boto3.client(
        service,
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )

# Now use the client to manage resources in Account B
s3_b = get_cross_account_client('111222333444', 'CrossAccountAutomationRole', 's3')
s3_b.list_buckets()
```

---

## Troubleshooting Guide for Automation

| Symptom | Diagnosis | Pro Hack |
|---------|-----------|----------|
| `LimitExceeded` | You've reached a service limit (e.g., max number of VPCs). | Request a limit increase via Service Quotas or automate resource cleanup. |
| `KeyError: 'Tags'` | Not all resources have tags. | Use `.get('Tags', [])` in Python to avoid crashes on missing keys. |
| `Slow Script` | Repeated API calls in a loop. | Use **Filters** on the API call rather than fetching everything and filtering in code. |
| `Inconsistent State` | Script failed halfway through. | Implement **Checkpoints** or logging to allow re-running from the point of failure. |

---

## Final Best Practices

1. **Never Hardcode IDs**: Use tags or metadata lookups to find resources dynamically.
2. **Log Everything**: If it's automated, you won't be watching it. Log to CloudWatch or a centralized file.
3. **Use Paginators**: For large fleets, the API won't return everything in one call. Always check for `NextToken`.

### Python Paginator Example:
```python
client = boto3.client('s3')
paginator = client.get_paginator('list_objects_v2')

# Collect ALL objects from a large bucket
for page in paginator.paginate(Bucket='giant-data-bucket'):
    for obj in page.get('Contents', []):
        print(obj['Key'])
```

---

## Next Steps

Congratulations! You've completed the Cloud Automation module. You are now ready to:
- Build self-healing infrastructure.
- Automate cost reporting and resource lifecycle.
- Integrate these scripts into your **[CI/CD Pipelines](../05-DevOps-Integration/CI-CD/README.md)**.
