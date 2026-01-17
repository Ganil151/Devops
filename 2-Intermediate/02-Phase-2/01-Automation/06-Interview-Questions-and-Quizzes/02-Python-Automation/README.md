# Python for DevOps Interview Prep

Python is the standard for complex automation. You are expected to know `requests`, `boto3`, and exception handling.

## 🎤 Top 10 Questions

1.  **What is a Virtual Environment and why is it mandatory for DevOps?**
    - *Answer*: It isolates dependencies, ensuring your script doesn't break when the system gets a global package update.
2.  **How do you handle API timeouts in Python?**
    - *Answer*: Using the `timeout` parameter in the `requests` library.
3.  **Explain `try...except...finally`.**
    - *Answer*: `try` runs the code; `except` handles errors; `finally` runs cleanup code (like closing a DB connection) no matter what.
4.  **How do you parse a JSON response from an API?**
    - *Answer*: `response.json()`.
5.  **What is the difference between Boto3 'Resource' and 'Client'?**
    - *Answer*: 'Client' is a low-level, 1:1 mapping to AWS APIs. 'Resource' is a high-level, object-oriented abstraction.
6.  **How do you use environment variables in a Python script?**
    - *Answer*: `os.environ.get('VAR_NAME')`.
7.  **What is a Python Decorator?**
    - *Answer*: A function that wraps another function to modify its behavior (commonly used for logging or timing).
8.  **How do you run a shell command from Python?**
    - *Answer*: `subprocess.run()`. Avoid `os.system()`.
9.  **What is a 'List Comprehension'?**
    - *Answer*: A concise way to create lists: `[x for x in list if x > 0]`.
10. **How do you handle secrets securely in Python?**
    - *Answer*: Load them from environment variables or a secret manager (Vault). NEVER hardcode.

---

## 🛠️ Performance Task
**Task**: Build a script that calls the GitHub API and lists all repositories for a given user that haven't been updated in 6 months.

[Check challenges for more tasks.](./CHALLENGES.md)
