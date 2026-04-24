# 🧪 Testing and QA: The Automation Safety Net

> **"Untested automation is just a bug waiting to happen in production. If you don't test your backup script, you don't have a backup script—you have a hope and a prayer."**

![Testing Pyramid](../../reference/python-devops-testing-ref.md)

---

## 🧠 The Mental Model: The Vehicle Inspection

**The Junior Struggle**: "I ran it on my laptop and it worked, so I pushed it to production." (Then it crashes 3 hours later).

**The Engineer Solution**: Code is like a car. Before it leaves the factory (your laptop), it must pass a **Safety Inspection** (Unit Tests).
- **Unit Test**: "Does the engine start?" (Test one function in isolation)
- **Integration Test**: "Do the brakes work when the engine is running?" (Test modules working together)
- **Mocking**: "Simulate a crash test without crashing a real car." (Simulate API calls)

### 🏗️ The Infrastructure Analogy

| Concept | Manufacturing Analogy | DevOps Equivalent |
|:--------|:----------------------|:------------------|
| **Unit Test** | Inspecting a bolt | Testing `calculate_disk_space()` |
| **Integration Test** | Starting the engine | Testing `backup_database()` with a real DB |
| **Mocking** | Crash Test Dummy | Simulating AWS S3 response |
| **CI/CD** | Assembly Line | GitHub Actions running `pytest` |
| **Assert** | "Pass/Fail" Sticker | `assert status == 200` |

**The Key Insight**: Tests prove your code works *today* and prevent it from breaking *tomorrow* when you add features.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "Testing takes too much time"
- "I'll just run the script manually to check it"
- "I don't need tests for 'simple' scripts"

**After this module**, you'll understand:
- **Manual testing scales poorly** (you can't manually test 50 functions every time).
- **Refactoring is scary without tests** (you might break something hidden).
- **Mocks save money** (don't spin up real EC2 instances just to test a tagger).

**The Difference**: You sleep soundly at night knowing your cleanup script won't delete the wrong files.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master `pytest`**: The industry standard runner.
- ✅ **Write Unit Tests**: Verify logic in isolation.
- ✅ **Use Fixtures**: Setup/Teardown test infrastructure.
- ✅ **Mock External APIs**: Simulate AWS/Database calls.
- ✅ **Understand TDD**: Test-Driven Development workflow.

---

## 🏗️ Part 1: The First Unit Test

### 🧠 The Mental Model: The Checkup

**The Concept**: Verify that `input A` always produces `output B`.

### 🔧 Writing a Test with `pytest`

**1. The Code (`disk_utils.py`)**
```python
def is_disk_full(used_percent, threshold=90):
    if used_percent < 0 or used_percent > 100:
        raise ValueError("Percent must be 0-100")
    return used_percent >= threshold
```

**2. The Test (`test_disk_utils.py`)**
```python
import pytest
from disk_utils import is_disk_full

def test_disk_is_full():
    assert is_disk_full(95, threshold=90) is True

def test_disk_is_safe():
    assert is_disk_full(50, threshold=90) is False

def test_invalid_percent_raises_error():
    # Verify logical constraints
    with pytest.raises(ValueError):
        is_disk_full(105)
```

**3. The Execution**
```bash
$ pytest
================ test session starts ================
collected 3 items
test_disk_utils.py ...                            [100%]
================ 3 passed in 0.01s =================
```

---

## 🛠️ Part 2: Fixtures (Setup & Teardown)

### 🧠 The Mental Model: The Clean Workbench

**The Concept**: Before every test, you need a clean environment (e.g., a temporary config file). You don't want Test A's garbage to break Test B.

### 🔧 Utilizing `conftest.py`

```python
import pytest
import tempfile
import os

@pytest.fixture
def temp_config_file():
    # 🛫 SETUP: Create temp file
    fd, path = tempfile.mkstemp()
    with os.fdopen(fd, 'w') as f:
        f.write("env=production\ndebug=false")
    
    # Pass path to the test
    yield path
    
    # 🛬 TEARDOWN: Delete file
    os.remove(path)

def test_config_parser(temp_config_file):
    # Test receives the path from the fixture automatically!
    with open(temp_config_file) as f:
        content = f.read()
    assert "env=production" in content
```

**Why it matters**: You can test file operations without polluting your hard drive.

---

## 🎭 Part 3: Mocking (Simulating Reality)

### 🧠 The Mental Model: The Stunt Double

**The Concept**: Your script calls the AWS API. You don't want to actually launch an EC2 instance every time you run a test (Cost + Time). You replace the real AWS library with a **Mock** (Fake).

### 🔧 Mocking External Calls

```python
from unittest.mock import patch, MagicMock
from deployer import check_server_status

# The usage of 'patch' replaces 'requests.get' with our fake version
# for the duration of this specific test.
@patch('requests.get')
def test_check_server_status_success(mock_get):
    # 1. Configure the Stunt Double
    # Create a fake response object
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"status": "ok"}
    
    # Tell the mock to return our fake response
    mock_get.return_value = mock_response

    # 2. Run the Code
    result = check_server_status("http://api.local")

    # 3. Assertions
    assert result is True
    # Verify we actually called the URL
    mock_get.assert_called_once_with("http://api.local")
```

**Why it matters**: You can test edge cases like "Network Timeout" or "500 Error" easily by telling the Mock to simulate them.

---

## 🏆 Real-World DevOps Story: The "RM -RF" Incident That Wasn't

**The Scenario**: A junior engineer wrote a script to clean up old temp logs: `rm -rf /tmp/app_logs/*`.
However, a bug in the path logic made the variable empty, effectively running `rm -rf /*`.

**The Saving Grace**: The team enforced **100% Unit Test Coverage**.
When the engineer pushed the code, the CI pipeline ran the tests.
The test `test_cleanup_path_construction()` detected that the path resolved to `/` in certain conditions.

**The Outcome**: The build failed. The deployment was blocked. The bug **never reached production**.
The engineer fixed the logic, added a guard clause, and re-pushed.

**The Lesson**: Tests act as a **Quality Gate**. They catch disasters before they happen.

---

## ❓ Interview Preparation (Testing)

### 🎯 Core Concepts

1. **Q: What is the difference between `unittest` and `pytest`?**
   - *A: `unittest` is built-in (standard lib) but requires boilerplate classes. `pytest` is a 3rd party standard that allows simple function-based tests, powerful fixtures, and detailed failure reports. DevOps prefers `pytest`.*

2. **Q: What is a "Fixture" in testing?**
   - *A: A function that prepares the environment (setup) before a test runs and cleans it up (teardown) afterward. Example: Creating a temp database or file.*

3. **Q: Why do we Mock API calls?**
   - *A: Speed (no network latency), Cost (no AWS charges), and Reliability (we can force failures like 503 errors to test our error handling).*

4. **Q: What is Code Coverage?**
   - *A: A metric showing what percentage of your code lines were actually executed during tests. High coverage (80%+) implies reliability.*

5. **Q: What is TDD (Test Driven Development)?**
   - *A: Writing the test *before* the code. 1. Write Test (Fail). 2. Write Code (Pass). 3. Refactor.*

### 🚀 Advanced Questions

6. **Q: How do you test a function that prints to stdout?**
   - *A: Use the `capsys` fixture in pytest. `captured = capsys.readouterr(); assert "Success" in captured.out`.*

7. **Q: What is `conftest.py`?**
   - *A: A shared configuration file for pytest where you define fixtures that can be used by any test file in the directory.*

8. **Q: How do you skip a test conditionally?**
   - *A: `@pytest.mark.skipif(sys.platform == "win32", reason="Linux only")`.*

9. **Q: What is "Parametrization"?**
   - *A: Running the same test function multiple times with different inputs. `@pytest.mark.parametrize("input,expected", [(1,2), (2,3)])`.*

10. **Q: Can you mock datetime.now()?**
    - *A: Yes, using libraries like `freezegun`. This is crucial to test time-sensitive logic (e.g., verifying a token expires in 1 hour).*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which command is used to run pytest?**
   - [ ] a) `python test`
   - [x] b) `pytest`
   - [ ] c) `run tests`

2. **What keyword checks if a condition is True?**
   - [ ] a) `check`
   - [x] b) `assert`
   - [ ] c) `ensure`

3. **If a test relies on an API, what should you do?**
   - [ ] a) Use the real API
   - [x] b) Mock the API
   - [ ] c) Skip the test

### 🚀 Intermediate Level

4. **What decorator creates a fixture?**
   - [ ] a) `@pytest.setup`
   - [x] b) `@pytest.fixture`
   - [ ] c) `@mock.patch`

5. **What does `mock_get.assert_called_once()` do?**
   - [x] a) Verifies the function was called exactly one time
   - [ ] b) Calls the function one time
   - [ ] c) Asserts that the return value is 1

6. **Where do you put shared fixtures?**
   - [ ] a) `main.py`
   - [ ] b) `__init__.py`
   - [x] c) `conftest.py`

### 🏆 Advanced Level

7. **How do you verify a function raises an Exception?**
   - [ ] a) `try/except` inside the test
   - [x] b) `with pytest.raises(Error):`
   - [ ] c) `assert Raise Error`

8. **What does `@patch('module.Class')` do?**
   - [x] a) Temporarily replaces `module.Class` with a Mock object
   - [ ] b) Imports the class
   - [ ] c) Deletes the class

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Tests = Safety Net**: Catch bugs before deployment.
2. **Mock = Stunt Double**: Fake the expensive/dangerous stuff.
3. **Fixture = Setup Crew**: Prepare the environment.

### 🛡️ Safety Patterns

1. **Never test against Production APIs** (use Mocks).
2. **Aim for high coverage** on critical logic.
3. **Run tests in CI/CD** on every Pull Request.

### 🚀 Production Rules

1. **Use `pytest`** (it's the industry standard).
2. **Name tests clearly**: `test_function_behavior`.
3. **Keep tests fast**: If it takes 10s, it's an integration test, not a unit test.

---

## 🔗 Next Steps

You have a robust, tested architecture. Now let's organize it into a proper project structure.

**Proceed to**: [Project Structure →](readme.md)

---

## 📚 Additional Resources

- [Pytest Documentation](https://docs.pytest.org/en/7.1.x/)
- [Python Unittest Mock](https://docs.python.org/3/library/unittest.mock.html)
- [Obey the Testing Goat (TDD Book)](https://www.obeythetestinggoat.com/)

---

**🎓 Remember**: A newbie clicks "Run" and prays. An engineer writes `print()` checks. A senior engineer writes **automated tests** that run on every commit.
