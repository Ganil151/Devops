# Testing Automation with Pytest

"Untested infrastructure code is just a legacy outage waiting to happen." Pytest is the industry standard for testing Python code.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `test_framework.py` (Fixtures, Mocking).
- **[CHALLENGES](./CHALLENGES.md)**: API Mocks, Boto3 Mocks.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Assert** | `assert x == y`. If false, fails the test. |
| **Fixture** | `@pytest.fixture`. Setup/Teardown logic (create DB, delete DB). |
| **Mocking** | Faking external dependencies (APIs, AWS) so tests are fast and free. |
| **Parametrize** | Running the same test with different inputs. |

---

## 🏗️ Mocking Patterns

Don't hit real APIs in unit tests!

```python
from unittest.mock import patch

@patch('requests.get')
def test_api_call(mock_get):
    # Setup the fake response
    mock_get.return_value.status_code = 200
    
    # Run code
    result = my_function()
    
    # Assert requests.get was called
    assert mock_get.called
```

---

## 📖 Real-World Story: The "Boto3 Deleter"

**Problem**: A script intended to delete *old* snapshots had a typo.
**Crisis**: Without testing, the engineer ran it locally. It started deleting *new* snapshots.
**Solution**: Implemented `moto` (Boto3 mocking library).
**Result**: The typo was caught in the test phase because the assertion `assert len(remaining_snaps) == 5` failed.

---

## ❓ Interview Questions

1.  **Difference between Unit Test and Integration Test?**
    - *Answer*: Unit = isolated (mocks everything). Integration = tests interaction (hits real DB or local container).
2.  **What is `conftest.py`?**
    - *Answer*: A global configuration file for Pytest where you define shared fixtures.
3.  **Why use Fixtures instead of `setUp` methods?**
    - *Answer*: Fixtures are modular, can be dependency-injected into specific tests, and support scopes (run once per session vs once per test).

---

[Next: Log Parsing](../08-Log-Parsing-and-Regex/README.md)
