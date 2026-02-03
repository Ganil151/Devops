# 🧪 Testing & Observability: The Safety Net

> **"If it isn't tested, it's broken. If it isn't logged, it never happened."**

This reference covers how to prove your code works (`pytest`) and how to debug it when it fails in production (`logging`).

---

## 🚦 1. Testing Framework (`pytest`)

The standard for Python testing. No boilerplate classes required.

### Fixtures (Setup/Teardown)
Reusable dependency injection (`db`, `s3_client`, `config`).
```python
import pytest

@pytest.fixture
def db_conn():
    conn = connect_db()
    yield conn      # Test runs here
    conn.close()    # Teardown

def test_query(db_conn):
    assert db_conn.query("SELECT 1") == 1
```

### Parametrization (Data-Driven Tests)
Run one test logic with 10 different inputs.
```python
@pytest.mark.parametrize("input,expected", [
    ("10.0.0.1", True),
    ("999.999", False),
    ("::1", True)
])
def test_ip_validator(input, expected):
    assert is_valid_ip(input) == expected
```

---

## 🎭 2. AWS Mocking (`moto`)

Test Boto3 logic without spending money or needing credentials.

```python
from moto import mock_aws
import boto3

@mock_aws
def test_s3_logic():
    # 1. Setup Mock
    s3 = boto3.client('s3', region_name='us-east-1')
    s3.create_bucket(Bucket='test-bucket')
    
    # 2. Run YOUR code
    my_upload_function('test-bucket', 'file.txt')
    
    # 3. Assert Side Effects
    obj = s3.get_object(Bucket='test-bucket', Key='file.txt')
    assert obj['Body'].read() == b'data'
```

---

## 📝 3. Structured Logging (`logging`)

Don't use `print()`. Print goes to stdout (ephemeral). Logs go to Datadog/Splunk.

| Level | When to use |
| :--- | :--- |
| `DEBUG` | Payload dumps, loop iterations. Hidden in Prod. |
| `INFO` | "Job Started", "Job Finished". Key lifecycle events. |
| `WARNING`| "Retrying connection...", "Config missing, using default". |
| `ERROR` | "Job Failed". Alerting threshold. |
| `CRITICAL`| App Crash. Wake up the on-call. |

**Staff Pattern (JSON Logs)**:
Use `python-json-logger` to output logs as JSON lines for easy parsing by ELK/Splunk.
```json
{"time": "2024-01-01T12:00:00", "level": "ERROR", "msg": "DB Timeout", "app": "payment"}
```

---

## 🛡️ 4. Error Handling (`try/except`)

Catch specific errors. Never catch `Exception` blindly unless at the top-level main loop.

```python
import requests

try:
    resp = requests.get(url, timeout=5)
    resp.raise_for_status() # Raises HTTPError for 4xx/5xx

except requests.exceptions.Timeout:
    logging.error("Service timed out after 5s")

except requests.exceptions.ConnectionError:
    logging.error("DNS or Network failure")

except requests.exceptions.HTTPError as e:
    logging.error(f"API API returned {e.response.status_code}")

else:
    # Only runs if NO exception occurred
    logging.info("Success!")
```

---

[⬅️ Back to Reference Hub](./README.md)
