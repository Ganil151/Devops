# Metaprogramming & Decorators
*Modifying Code Behavior Dynamically*

In DevOps, we often need to add "cross-cutting concerns" to our automation, such as **retries**, **logging**, or **rate limiting**, without modifying the core business logic of every single function. Decorators allow us to "wrap" functions in this extra logic elegantly.

---

## 🏗️ The Decorator Pattern

A decorator is a function that takes another function and extends its behavior.

### Example: The Retry Decorator
```python
import functools
import time

def retry(retries=3):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for i in range(retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print(f"Attempt {i+1} failed. Retrying...")
                    time.sleep(1)
            raise Exception(f"Failed after {retries} attempts.")
        return wrapper
    return decorator

@retry(retries=5)
def call_flaky_api():
    # Attempt network call...
    pass
```

---

## 📊 Logic Flow: The Proxy / Wrapper

```mermaid
graph LR
    Call[Call function: audit_s3] --> Wrap[Decorator Entry]
    Wrap --> Timer[Start Timer]
    Timer --> Exec[Execute core logic]
    Exec --> TimerStop[Stop Timer]
    TimerStop --> Log[Log: 'audit_s3 took 0.5s']
    Log --> Return[Return original result]
```

---

## 🛠️ Hands-On Challenges

Master metaprogramming by building these advanced wrappers.

| Challenge | Topic | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- | :--- |
| **01. Performance Profiler** | Profiling | Build a `@profile` decorator that logs the execution time and memory usage of any function. | [Link](./challenges/challenge-01-profiler.py) | [Link](./challenges/solutions/solution-01-profiler.py) |
| **02. Slack Guardrail** | Alerting | Create a `@slack_on_fail` decorator that automatically sends a notification if a function crashes. | [Link](./challenges/challenge-02-slack-fail.py) | [Link](./challenges/solutions/solution-02-slack-fail.py) |
| **03. Cache Engine** | Memoization | Implement a `@cache_result` decorator that stores results of expensive API calls in memory. | [Link](./challenges/challenge-03-cache.py) | [Link](./challenges/solutions/solution-03-cache.py) |

---

## ❓ Interview Questions

1. **Why use `functools.wraps`?**
   * *Answer*: When you wrap a function in a decorator, the metadata (name, docstring) of the original function is lost. `wraps` copy this metadata back to the wrapper, which is essential for debugging and documentation tools.
2. **What is 'Metaprogramming' in Python?**
   * *Answer*: It is the practice of writing code that manipulates other code at runtime. This includes decorators, metaclasses, and the `getattr`/`setattr` functions.
3. **Can you apply multiple decorators to one function?**
   * *Answer*: Yes. They are applied from bottom to top (the one closest to the function runs first, then the one above it). ✨ `@logging` then `@retry` means the retry logic is wrapped *inside* the logging.

---

**Next Step**: [Professional CLI Frameworks →](../05-cli-frameworks-click-typer/readme.md)
