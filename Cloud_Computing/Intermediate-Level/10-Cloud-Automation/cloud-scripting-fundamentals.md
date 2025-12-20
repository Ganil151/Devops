# Cloud Scripting Fundamentals: Bash vs. Python

## Introduction

Effective cloud automation requires writing scripts that are not just functional, but robust, secure, and maintainable. This guide explores the two most common tools for cloud scripting—Bash and Python—and the fundamental principles of "Defensive Scripting" in the cloud.

## Bash vs. Python: When to Use Which?

Choosing the right language depends on the complexity of the task and the environment.

### Bash (AWS CLI)
- **Best For**: Simple, linear tasks; one-liners; quick resource lookups; shell-native operations (piping, file management).
- **Pros**: Zero dependencies (usually pre-installed); very fast for simple CLI calls; concise for sequential commands.
- **Cons**: Difficult to handle complex logic/nested loops; poor error handling; parsing JSON is painful without `jq`.

### Python (Boto3 SDK)
- **Best For**: Complex logic; multi-step workflows with conditional branching; heavy data transformation; long-running automation tasks.
- **Pros**: Robust error handling (try-except); excellent JSON/data structure support; highly readable; large ecosystem of libraries.
- **Cons**: Requires Python and `boto3` installed; slower to write for simple one-off tasks.

---

## The Principle of Idempotency

**Idempotency** means that running your script multiple times will result in the same state without causing errors or duplicate resources.

### Example: Creating an S3 Bucket

**Bad Script (Non-idempotent)**:
```bash
# This will fail on the second run because the bucket already exists.
aws s3 mb s3://my-unique-automation-bucket
```

**Good Script (Idempotent - Bash)**:
```bash
BUCKET_NAME="my-unique-automation-bucket"

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Bucket $BUCKET_NAME already exists. Skipping creation."
else
    echo "Creating bucket $BUCKET_NAME..."
    aws s3 mb "s3://$BUCKET_NAME"
fi
```

**Good Script (Idempotent - Python)**:
```python
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
bucket_name = 'my-unique-automation-bucket'

try:
    s3.head_bucket(Bucket=bucket_name)
    print(f"Bucket {bucket_name} already exists.")
except ClientError as e:
    # If a 404 error occurs, the bucket does not exist
    if e.response['Error']['Code'] == '404':
        print(f"Creating bucket {bucket_name}...")
        s3.create_bucket(Bucket=bucket_name)
    else:
        raise
```

---

## Robust Error Handling

Cloud environments are transient. Networks fail, API limits are hit, and resources disappear.

### 1. The "Fail-Fast" Rule in Bash
Use `set -e` at the start of your scripts to ensure they stop immediately if a command fails.

```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on error
# -u: Exit on unset variables
# -o pipefail: Catch errors in piped commands
```

### 2. Structured Exceptions in Python
Always wrap SDK calls in `try...except` blocks and check for specific AWS error codes.

```python
import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2')

try:
    response = ec2.run_instances(ImageId='ami-invalid', MinCount=1, MaxCount=1)
except ClientError as e:
    print(f"Critical Error: {e.response['Error']['Code']}")
    if e.response['Error']['Code'] == 'InvalidAMIID.NotFound':
        print("Fixing: The provided AMI ID was not found.")
```

---

## Authentication Patterns

Never hardcode credentials in your scripts. Use the standard AWS credential chain.

### 1. Local Development
Use `aws configure` or environment variables.
```bash
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

### 2. Automation Servers (EC2/Lambda/GitHub Actions)
**NEVER** use IAM User keys on an EC2 instance. Use **IAM Roles**.

- **EC2**: Attach an IAM Instance Profile. The SDK/CLI will automatically find the credentials.
- **Lambda**: Uses the Execution Role assigned to it.
- **GitHub Actions**: Use OIDC to assume a role rather than storing long-lived secrets.

---

## Automation Hacks & Tips

> [!TIP]
> **Bash Hack**: Use `jq` for advanced parsing. 
> `aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId'`
> 
> **Python Hack**: Use `waiters` to pause execution until a resource is ready.
> `ec2.get_waiter('instance_running').wait(InstanceIds=['i-1234567890abcdef0'])`

## Troubleshooting Common Scripting Errors

| Symptom | Probable Cause | Fix |
|---------|----------------|-----|
| `AccessDenied` | Missing IAM permissions | Verify the IAM Policy attached to the user/role. |
| `ExpiredToken` | Temporary credentials expired | Refresh credentials or check IAM role session duration. |
| `SyntaxError` (Bash) | Missing quotes or brackets | Use `shellcheck` to lint your Bash scripts. |
| `ImportError` (Python) | `boto3` not installed | Run `pip install boto3`. |

---

## Next Steps

Now that you understand the fundamentals, move on to **[Resource Management Automation](resource-management-automation.md)** to see these principles in action with real-world scenarios.
