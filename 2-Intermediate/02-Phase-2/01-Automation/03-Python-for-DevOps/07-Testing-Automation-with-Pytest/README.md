# Testing Automation with Pytest
*Guard Your Infrastructure with Tests*

In DevOps, a bug in your code doesn't just crash an app—it can delete a production database or revoke network access. **Testing is not optional.** Pytest is the industry-standard framework for testing Python infrastructure code.

---

## 🏗️ The Anatomy of a Test

Pytest relies on **Conventions over Configuration**.
1.  **File Naming**: Must start with `test_` (e.g., `test_ec2_cleanup.py`).
2.  **Function Naming**: Must start with `test_`.
3.  **Assertions**: Standard Python `assert` statements.

```python
# functionality.py
def is_production(env_name):
    return env_name.lower() == "prod"

# test_functionality.py
from functionality import is_production

def test_is_production_true():
    assert is_production("prod") == True

def test_is_production_case_insensitive():
    assert is_production("PROD") == True

def test_is_production_false():
    assert is_production("stage") == False
```

---

## ⚡ Fixtures: Setup & Teardown

Fixtures allow you to prepare a reliable environment for your tests (e.g., creating a dummy file, spinning up a mock database).

```python
import pytest
import os

@pytest.fixture
def temp_config_file():
    # SETUP
    filename = "test_config.json"
    with open(filename, "w") as f:
        f.write('{"timeout": 30}')
    
    yield filename  # Pass control to the test
    
    # TEARDOWN
    if os.path.exists(filename):
        os.remove(filename)

def test_config_loader(temp_config_file):
    # The file exists only during this test
    assert os.path.exists(temp_config_file)
```

---

## 🎭 Mocking: The DevOps Superpower

You cannot let your tests make real calls to AWS (`boto3`) or external APIs (`requests`). **Mocking** replaces these real systems with fake ones.

### 1. Mocking APIs (unittest.mock)
Standard library tool to replace functions.

```python
from unittest.mock import patch
import my_script

# Context Manager style
def test_api_failure_handling():
    with patch('requests.get') as mock_get:
        # Arrange
        mock_get.return_value.status_code = 500
        
        # Act
        result = my_script.check_site_status("http://example.com")
        
        # Assert
        assert result == "DOWN"
```

### 2. Mocking AWS (Moto)
`moto` is a library that mocks the entire AWS infrastructure in memory.

```python
import boto3
from moto import mock_s3

@mock_s3
def test_s3_bucket_creation():
    # Setup Mock AWS - No credentials needed!
    s3 = boto3.client('s3', region_name='us-east-1')
    
    # Act
    s3.create_bucket(Bucket='my-test-bucket')
    
    # Assert
    response = s3.list_buckets()
    buckets = [b['Name'] for b in response['Buckets']]
    assert 'my-test-bucket' in buckets
```

---

## 🛠️ Real-World Scenario: The "Delete All" Bug

**Scenario**: You have a script `cleanup_users.py` that deletes all IAM users who haven't logged in for 90 days.
**The Bug**: A logic error in the date calculation caused it to return *all* users, regardless of login time.
**The Close Call**: Before running it in production, you wrote a test using `moto`.
1.  Created 3 mock users: Active, Inactive, and Admin.
2.  Ran the function.
3.  Asserted that only the 'Inactive' user was deleted.
**Outcome**: The test FAILED because it deleted everyone. You fixed the bug safely locally, saving the company from a total lockout.

---

## ❓ Interview Questions

1.  **What is a Pytest Fixture and when would you use it?**
    *   *Answer*: A fixture is a function decorated with `@pytest.fixture` that handles the setup of resources (like db connections or files) needed for a test, and optionally cleans them up afterwards using `yield`.
2.  **Why is 'Mocking' critical for Infrastructure-as-Code testing?**
    *   *Answer*: It prevents tests from interacting with real cloud resources, avoiding accidental costs (spinning up EC2s) or destructive actions (deleting production S3 buckets).
3.  **How do you run only a specific test in Pytest?**
    *   *Answer*: Use the `-k` flag (keyword search) or the node ID syntax: `pytest test_file.py::test_function_name`.
4.  **What is `conftest.py`?**
    *   *Answer*: A special file in Pytest used to share fixtures across multiple test files without importing them.

---

## 🛠️ Hands-On Challenges

Master quality assurance by building these automated testing suites.

| Challenge | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- |
| **01. Config Test** | Create unit tests with fixtures to validate configuration loader functions safely. | [Link](./challenges/challenge_01_config_test.py) | [Link](./challenges/solutions/solution_01_config_test.py) |
| **02. API Mocking** | Use `unittest.mock` to simulate Slack API failures and test your code's resilience. | [Link](./challenges/challenge_02_mock_api_test.py) | [Link](./challenges/solutions/solution_02_mock_api_test.py) |
| **03. Moto AWS Test** | Write in-memory AWS tests for S3 file management using the powerful Moto library. | [Link](./challenges/challenge_03_moto_test.py) | [Link](./challenges/solutions/solution_03_moto_test.py) |
| **04. Parameterize** | Efficiently test network validation logic against multiple IP ranges in a single test block. | [Link](./challenges/challenge_04_parameterize_test.py) | [Link](./challenges/solutions/solution_04_parameterize_test.py) |

> **Pro Tip**: Use `pytest --cov=my_script` to check your **Test Coverage**. Aim for 80%+ coverage for critical infrastructure modules.

---

## 🧠 Quiz

1.  **To mark a function as a test in Pytest, you must:**
    *   a) Add `@test` decorator
    *   b) Start the name with `test_` ✅
    *   c) Put it in a `tests/` folder
    *   d) Import `pytest`

2.  **Which library is best for mocking AWS services?**
    *   a) PyMock
    *   b) Boto3-Test
    *   c) Moto ✅
    *   d) Jenkins

3.  **What does the `yield` keyword do in a fixture?**
    *   a) Pauses the test indefinitely
    *   b) Separates Setup code from Teardown code ✅
    *   c) Generating a random number
    *   d) Skips the test

4.  **If `assert 1 == 2` runs, what happens?**
    *   a) It prints "False"
    *   b) It raises an `AssertionError` and fails the test ✅
    *   c) It warns the user but continues
    *   d) nothing

---

**Next Step**: [Capstone Project: S3 Auditor →](../08-Capstone-Project-S3-Auditor/README.md)
