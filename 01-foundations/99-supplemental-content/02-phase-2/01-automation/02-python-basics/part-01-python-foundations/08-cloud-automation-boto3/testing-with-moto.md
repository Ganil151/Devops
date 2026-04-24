# 🧪 Zero-Cost Cloud Testing with Moto

> **"Test your infrastructure code without a credit card."**

## ❓ What is Moto?

**Moto** is a library that allows your Python tests to easily mock out AWS Services. It intercepts Boto3 calls and simulates the AWS response locally in memory.

- **No Cost**: No API calls are sent to AWS.
- **Speed**: Tests run instantly (no network latency).
- **Safety**: No risk of accidentally deleting production data.

---

## 📦 Installation

```bash
pip install moto
# OR for specific services (recommended to save space)
pip install "moto[s3,ec2,iam]"
pip install pytest
```

---

## 🛠️ Pattern 1: The Decorator (Quick & Dirty)

Use the `@mock_aws` decorator to wrap a single function. Any Boto3 call inside this function will be intercepted.

```python
import boto3
from moto import mock_aws

@mock_aws
def test_create_bucket():
    # 1. Setup the Mock
    # Note: Region is important in Moto!
    s3 = boto3.client('s3', region_name='us-east-1')

    # 2. Run your logic (This stays local!)
    s3.create_bucket(Bucket='my-test-bucket')

    # 3. Verify
    result = s3.list_buckets()
    assert result['Buckets'][0]['Name'] == 'my-test-bucket'
    print("Test Passed: Bucket created in memory!")

if __name__ == "__main__":
    test_create_bucket()
```

---

## 🏭 Pattern 2: Pytest Fixtures (Professional Standard)

In a real DevOps project, use `pytest` fixtures to handle setup and teardown.

### 1. Create `conftest.py` (Shared Configuration)

```python
# conftest.py
import pytest
import boto3
from moto import mock_aws
import os

@pytest.fixture(scope='function')
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

@pytest.fixture(scope='function')
def s3(aws_credentials):
    with mock_aws():
        yield boto3.client('s3', region_name='us-east-1')
```

### 2. Write the Test (`test_s3_janitor.py`)

```python
# test_s3_janitor.py
def test_bucket_creation(s3):
    # 's3' here is the client from the fixture above
    s3.create_bucket(Bucket='data-lake')

    response = s3.list_buckets()
    names = [b['Name'] for b in response['Buckets']]

    assert 'data-lake' in names
```

---

## ⚠️ Common Gotchas

1.  **Region Matters**: Moto is strict about regions. If you create a bucket in `us-east-1` and list in `us-west-1`, it won't be there.
2.  **Endpoint URLs**: If your code hardcodes endpoint URLs (rare), Moto might not intercept them.
3.  **Not All Services**: Moto covers most core services (S3, EC2, IAM, Lambda, DynamoDB), but obscure services might not be fully implemented.
