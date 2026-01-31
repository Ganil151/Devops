# 🧪 Reference: Testing & Observability Keywords

Professional automation requires verification and logging. This reference covers how to ensure your scripts are working as intended.

---

## 🛠️ Testing (Pytest)

### `@pytest.fixture`
*   **Definition**: A function that sets up data or an environment for a test (e.g., creating a mock S3 bucket).
*   **DevOps Why**: Allows you to test your logic without actually touching or paying for real Cloud resources.

### `Mocking / Patching`
*   **Definition**: Replacing real functions or objects with "mocks" during testing.
*   **DevOps Why**: Use `unittest.mock` to simulate an API failure and verify that your script's error handling correctly notifies the team.

---

## 📊 Observability (Logging & Regex)

### `logging` levels
*   **DEBUG**: Diagnostic info.
*   **INFO**: Confirming things are working as expected.
*   **WARNING**: Something unexpected happened, but the script can continue.
*   **ERROR**: A serious problem; the script could not perform a task.
*   **CRITICAL**: The script itself may be unable to continue running.

### `re.compile()`
*   **Definition**: Pre-compiles a Regex pattern into an object for faster reuse.
*   **DevOps Why**: Critical when parsing gigabytes of server logs where performance is paramount.

---

## 🎙️ Staff Interview context
*   **"Why is print() not a substitute for logging?"**
    *   *Answer*: `print` goes only to stdout and has no concept of severity levels or structured formats. The `logging` module allows you to send data to multiple destinations (stdout, files, Datadog) and filter output based on severity without changing the code.
*   **"What is the 'Fail-Fast' principle in Python testing?"**
    *   *Answer*: It means designing tests to catch the most critical failures first (e.g., Auth failure) before running long-running logic tests.
