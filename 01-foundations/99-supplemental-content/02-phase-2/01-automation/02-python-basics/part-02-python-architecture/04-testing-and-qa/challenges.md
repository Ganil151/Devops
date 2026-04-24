# 🎯 Testing and QA: The Safety Net Challenges

> **"A test is a robot that watches your other robots. These challenges test your ability to build an automated quality gate for your tools."**

---

## 🏆 Challenge 1: The Status Validator Unit Test
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Write a test for a simple function that validates server names.

### Requirements
- Function: `is_valid_hostname(name)` -> Returns True if name is lowercase alphanumeric, False otherwise.
- Test 1: Check `web-01` (Correct).
- Test 2: Check `WEB_01` (Fail).
- Test 3: Check `!admin` (Fail).

### Hints
- Use `assert` statements or `pytest.mark.parametrize`.

---

## 🏆 Challenge 2: The Mock Outage (Simulating 404)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 35 minutes

### Objective
Use `unittest.mock` to test how your script handles a 404 error from an API.

### Requirements
- Create a function `fetch_data()` that uses `requests.get()`.
- Write a test that **mocks** `requests.get`.
- Tell the mock to return a response with `status_code = 404`.
- Verify that your function handles it correctly (e.g., returns `None` or raises a specific error).

---

## 🏆 Challenge 3: The Fixture Workbench (Temp Files)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Use a `pytest` fixture to test a file-processing function.

### Requirements
- Define a fixture `@pytest.fixture` that creates a temporary log file with 10 lines of dummy data.
- Write a test that reads this file and counts the lines.
- Ensure the file is deleted after the test (Teardown).

---

## ✅ Completion Checklist
- [ ] Challenge 1: Status Validator
- [ ] Challenge 2: Mock Outage
- [ ] Challenge 3: Fixture Workbench
