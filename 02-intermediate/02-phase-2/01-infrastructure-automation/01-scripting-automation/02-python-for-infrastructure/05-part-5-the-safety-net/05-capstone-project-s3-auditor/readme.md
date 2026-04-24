# 🏆 Capstone: S3 Guardian — Enterprise Security Auditor

> **"Code is your proxy. In the middle of the night, when a bucket is misconfigured, your script is the only thing standing between your company's data and a front-page headline."**

Congratulations on reaching the **Capstone Project**. This is the final proving ground. You will synthesize **Boto3**, **Pandas**, **Automated Testing**, and **CLI Design** into a production-ready security tool.

**The Mission:**
Your CISO (Chief Information Security Officer) has tasked you with building a tool called `s3-guardian`. It must scan every S3 bucket in an AWS account, detect security flaws (Public Access, Missing Encryption), and generate a Compliance Report for the auditors.

---

## 🎯 The Requirements (User Story)

**As a** Security Engineer,
**I want** a CLI tool that scans my AWS account,
**So that** I can identify leakage risks before hackers do.

### Functional Requirements
1.  **CLI Interface**: Must use `click` or `argparse`. Support `--region` and `--output-file`.
2.  **Discovery**: List ALL buckets (handling pagination for >1000 buckets).
3.  **Audits**:
    - **Public Access**: Check `get_public_access_block`.
    - **Encryption**: Check `get_bucket_encryption`.
    - **Tagging**: Check if "Owner" tag exists.
4.  **Reporting**: Generate a CSV/JSON report using **Pandas**.
5.  **Error Handling**: Must handle `AccessDenied` gracefully (some buckets might be restricted).

---

## 🏗️ Architecture Design

We will use a **Controller-Service** pattern to keep logic clean.

```mermaid
graph TD
    CLI[CLI: Click Interface] -- "1. parse args" --> Controller[Controller: AuditManager]
    Controller -- "2. init" --> AWS[Service: AWSClient (Boto3)]
    Controller -- "3. scan()" --> AWS
    AWS -- "4. list_buckets" --> S3[AWS S3 API]
    S3 -- "5. buckets" --> AWS
    Controller -- "6. audit(bucket)" --> AWS
    AWS -- "7. get_encryption / public" --> S3
    Controller -- "8. collect results" --> Data[Data: Pandas DataFrame]
    Data -- "9. to_csv()" --> Report[File: report.csv]
    
    style CLI fill:#e0f2fe,stroke:#0369a1
    style Controller fill:#fef3c7,stroke:#d97706
    style Data fill:#f0fdf4,stroke:#15803d
```

### The Data Structure (Dataclasses)

Use flexible immutable data structures.

```python
from dataclasses import dataclass

@dataclass
class AuditResult:
    bucket_name: str
    region: str
    is_public: bool
    encrypted: bool
    owner_tag: str
    compliance_score: int # 0-100
```

---

## 💻 Implementation Guide

### Step 1: The AWS Service (Boto3)

Create a class `AWSClient` that wraps Boto3 logic.
- **Why?** Makes it easier to mock in tests.
- **Fail-Fast**: Wrap API calls in `ClientError` try/catch blocks.

```python
import boto3
from botocore.exceptions import ClientError

class AWSClient:
    def __init__(self, region: str):
        self.s3 = boto3.client('s3', region_name=region)

    def get_encryption_status(self, bucket: str) -> bool:
        try:
            self.s3.get_bucket_encryption(Bucket=bucket)
            return True
        except ClientError as e:
            # If error is 'ServerSideEncryptionConfigurationNotFoundError', return False
            return False
```

### Step 2: The Logic Controller (Pandas)

Create a class `AuditManager` that handles the business logic.
- It calls `AWSClient`.
- It appends results to a list.
- It uses `pd.DataFrame(results)` to save the file.

### Step 3: The CLI (Click)

```python
import click

@click.command()
@click.option('--region', default='us-east-1', help='AWS Region')
@click.option('--output', default='report.csv', help='Output file')
def scan(region, output):
    """Audits S3 Buckets for security."""
    client = AWSClient(region)
    # ... logic ...
    click.echo(f"✅ Report saved to {output}")
```

---

## 🧪 Testing Strategy (Moto)

You cannot run this against real AWS in a CI/CD pipeline (cost/security). You MUST use `moto`.

```python
import pytest
from moto import mock_aws
import boto3

@mock_aws
def test_encryption_check():
    # 1. Setup: Create a Mock S3
    s3 = boto3.client('s3', region_name='us-east-1')
    s3.create_bucket(Bucket='secure-bucket')
    
    # 2. Logic: Enforce encryption (Mocked)
    s3.put_bucket_encryption(
        Bucket='secure-bucket',
        ServerSideEncryptionConfiguration={...}
    )
    
    # 3. Verify: Your AWSClient code
    client = AWSClient('us-east-1')
    assert client.get_encryption_status('secure-bucket') == True
```

---

## 🎭 Real-World "Definition of Done"

Your project is complete when:
1.  **Repo Structure**:
    - `s3_guardian/main.py`
    - `s3_guardian/aws.py`
    - `tests/test_audit.py`
    - `requirements.txt` (boto3, click, pandas, moto, pytest)
2.  **Linting**: Code passes `pylint` (score > 8.0).
3.  **Typos**: Functions use Type Hints (`def foo() -> bool:`).
4.  **Logging**: Uses `logging` library, NOT `print`.

---

## 🏎️ Challenge Mode (Senior Engineer)

If you finish early, add these features:
1.  **Parallel Execution**: Use `ThreadPoolExecutor` to audit 10 buckets at once.
2.  **Remediation**: Add a `--fix` flag that enables default encryption if missing.
3.  **Dashboard**: Use `streamlit` to visualize the CSV report in a browser.

---

## 🎙️ Final Defense (Interview Questions)

**1. "Why did you choose Click over Argparse?"**
- **Answer**: Click is more composable (decorators), handles types automatically (int/path), and is the standard for modern Python tools (used by Flask/Black).

**2. "How did you handle the N+1 problem (scanning buckets)?"**
- **Answer**: I used specific Boto3 API calls. While `list_buckets` gives the name, I *must* call `get_bucket_encryption` for each one. To optimize, I implemented Threading.

**3. "How would you deploy this?"**
- **Answer**:
    - **Lambda**: Scheduled CloudWatch Event every 24h.
    - **Jenkins**: Nightly pipeline job.

---

## 🎓 Final Checklist

- [ ] Does it run?
- [ ] Does it handle `AccessDenied`?
- [ ] Is it tested with `moto`?
- [ ] Is the code PEP8 compliant?

**Good luck, Guardian.**

[⬅️ Back to Pandas](readme.md)
