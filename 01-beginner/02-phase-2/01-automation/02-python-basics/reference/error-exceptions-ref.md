# 🛡️ Python Exceptions: The Exhaustive Master Reference
*Version 3.0 | Engineering Fault-Tolerant Automation*

---

## 📖 Overview
This guide provides an exhaustive list of built-in Python exceptions. In DevOps, every unhandled exception is a potential pipeline failure. Mastering this list allows you to catch specific faults, implement retries, and ensure that your automation is both resilient and deterministic.

---

## 🏛️ Base Exceptions

### `Exception`
**Definition**: The base class for all non-exit exceptions. Almost all built-in, non-system-exiting exceptions are derived from this class.
**Example**:
```python
try:
    process_data()
except Exception as e:
    log_to_splunk(f"General failure: {e}")
```

### `ArithmeticError`
**Definition**: The base class for those built-in exceptions that are raised for various arithmetic errors.
**Example**:
```python
try:
    result = compute_metrics()
except ArithmeticError:
    print("Calculation failed due to math error.")
```

### `BufferError`
**Definition**: Raised when a buffer related operation cannot be performed.
**Example**:
```python
# Typically encountered when manipulating low-level memory views or byte arrays
try:
    memoryview(b"abc")[0] = 65
except BufferError:
    print("Cannot modify read-only buffer")
```

### `LookupError`
**Definition**: The base class for the exceptions that are raised when a key or index used on a mapping or sequence is invalid.
**Example**:
```python
try:
    val = target_list[idx]
except LookupError:
    print("Resource not found in collection.")
```

---

## 🛑 Concrete Exceptions (Standard Logic)

### `AssertionError`
**Definition**: Raised when an `assert` statement fails. Used for internal sanity checks.
**Example**:
```python
assert os.path.exists(".env"), "CRITICAL: Environment file missing!"
```

### `AttributeError`
**Definition**: Raised when an attribute reference or assignment fails (e.g., calling a method that doesn't exist on an object).
**Example**:
```python
# Boto3 object might be None if client failed to init
try:
    s3.upload_file(data)
except AttributeError:
    print("S3 Client not initialized correctly.")
```

### `EOFError`
**Definition**: Raised when one of the built-in functions (`input()` or `raw_input()`) hits an end-of-file condition (EOF) without reading any data.
**Example**:
```python
try:
    user_conf = input()
except EOFError:
    print("Input stream closed unexpectedly.")
```

### `FloatingPointError`
**Definition**: Not currently used by most Python versions, but reserved for floating point operation failures.
**Example**:
```python
# In standard CPython, this is rarely seen unless specifically configured
```

### `ImportError`
**Definition**: Raised when the `import` statement has troubles trying to load a module.
**Example**:
```python
try:
    import azure_sdk
except ImportError:
    print("Azure SDK missing. Please run pip install.")
```

### `ModuleNotFoundError`
**Definition**: A subclass of `ImportError` raised when a module could not be located.
**Example**:
```python
try:
    import custom_module
except ModuleNotFoundError:
    print("The requested automation module was not found in sys.path.")
```

### `IndexError`
**Definition**: Raised when a sequence subscript is out of range.
**Example**:
```python
# Accessing sys.argv[1] without checking length
try:
    env = sys.argv[1]
except IndexError:
    env = "development" # Default fallback
```

### `KeyError`
**Definition**: Raised when a mapping (dictionary) key is not found in the set of existing keys.
**Example**:
```python
# Parsing JSON API response
try:
    status = response_json["status"]
except KeyError:
    print("JSON Schema mismatch: 'status' key missing.")
```

### `MemoryError`
**Definition**: Raised when an operation runs out of memory but the condition may still be rescued (e.g. by deleting some objects).
**Example**:
```python
try:
    giant_log = f.read() # Reading 50GB file into RAM
except MemoryError:
    print("System RAM exhausted. Switch to line-by-line processing.")
```

### `NameError`
**Definition**: Raised when a local or global name is not found. Usually a typo in the variable name.
**Example**:
```python
try:
    print(cluster_id)
except NameError:
    print("Variable 'cluster_id' has not been defined yet.")
```

### `NotImplementedError`
**Definition**: In user-defined base classes, abstract methods should raise this exception when they require derived classes to override the method.
**Example**:
```python
class CloudProvider:
    def deploy(self):
        raise NotImplementedError("Subclasses must implement deploy()")
```

### `OSError`
**Definition**: Raised when a system function returns a system-related error, including I/O failures such as “file not found” or “disk full”.
**Example**:
```python
try:
    os.mkdir("/root/secret")
except OSError as e:
    print(f"System Error: {e.strerror}")
```

### `OverflowError`
**Definition**: Raised when the result of an arithmetic operation is too large to be represented.
**Example**:
```python
import math
try:
    res = math.exp(1000)
except OverflowError:
    print("Math result exceeds capacity.")
```

### `RecursionError`
**Definition**: Raised when the interpreter detects that the maximum recursion depth is exceeded.
**Example**:
```python
def infinite_ping():
    return infinite_ping()

try:
    infinite_ping()
except RecursionError:
    print("Infinite recursion detected in logic.")
```

### `RuntimeError`
**Definition**: Raised when an error is detected that doesn't fall in any of the other categories.
**Example**:
```python
raise RuntimeError("Deployment engine reached an illegal state.")
```

### `StopIteration`
**Definition**: Raised by built-in function `next()` and an iterator's `__next__()` method to signal that there are no further items produced by the iterator.
**Example**:
```python
it = iter([1])
next(it)
try:
    next(it)
except StopIteration:
    print("Iterator is empty.")
```

### `StopAsyncIteration`
**Definition**: Must be raised by `__anext__()` method of an asynchronous iterator object to stop the iteration.
**Example**:
```python
# Used internally in async for loops
```

### `SyntaxError`
**Definition**: Raised when the parser encounters a syntax error.
**Example**:
```python
try:
    eval("if x print(x)") # Missing colon
except SyntaxError:
    print("Invalid Python syntax detected.")
```

### `IndentationError`
**Definition**: Base class for syntax errors related to incorrect indentation.
**Example**:
```python
# Usually caught at compile time, but relevant for dynamic code
```

### `TabError`
**Definition**: Raised when indentation contains an inconsistent mix of tabs and spaces.
**Example**:
```python
# Modern IDEs prevent this, but critical for legacy script audit
```

### `SystemError`
**Definition**: Raised when the interpreter finds an internal error.
**Example**:
```python
# Rare: Signals a bug in the Python interpreter itself
```

### `TypeError`
**Definition**: Raised when an operation or function is applied to an object of inappropriate type.
**Example**:
```python
try:
    "Version: " + 2 # Cannot concat str and int
except TypeError:
    print("Data type mismatch in logging logic.")
```

### `UnboundLocalError`
**Definition**: Raised when a reference is made to a local variable in a function or method, but no value has been bound to that variable.
**Example**:
```python
def update():
    count += 1 # count used before assignment

try:
    update()
except UnboundLocalError:
    print("Local variable referenced before assignment.")
```

### `ValueError`
**Definition**: Raised when a built-in operation or function receives an argument that has the right type but an inappropriate value.
**Example**:
```python
try:
    port = int("none")
except ValueError:
    print("Invalid port number specified in config.")
```

### `ZeroDivisionError`
**Definition**: Raised when the second argument of a division or modulo operation is zero.
**Example**:
```python
try:
    uptime_ratio = total_up / total_checks
except ZeroDivisionError:
    uptime_ratio = 0
```

---

## 📂 OS & Filesystem Subclasses (Derived from OSError)

### `FileNotFoundError`
**Definition**: Raised when a file or directory is requested but doesn’t exist.
**Example**:
```python
try:
    with open("config.json") as f: pass
except FileNotFoundError:
    print("Critical config missing from /etc/app/")
```

### `PermissionError`
**Definition**: Raised when trying to run an operation without the adequate access rights (e.g. filesystem permissions).
**Example**:
```python
try:
    os.remove("/etc/shadow")
except PermissionError:
    print("Elevated privileges required for this task.")
```

### `IsADirectoryError`
**Definition**: Raised when a file operation is requested on a directory.
**Example**:
```python
try:
    with open("/var/log/") as f: pass
except IsADirectoryError:
    print("Cannot read a directory as a file.")
```

### `NotADirectoryError`
**Definition**: Raised when a directory operation is requested on something that is not a directory.
**Example**:
```python
try:
    os.listdir("config.yaml")
except NotADirectoryError:
    print("Target is a file, not a directory.")
```

### `ConnectionError`
**Definition**: A base class for network-related issues.
**Example**:
```python
try:
    connect_to_api()
except ConnectionError:
    print("Network link down.")
```

### `TimeoutError`
**Definition**: Raised when a system function timed out at the system level.
**Example**:
```python
try:
    # System level socket timeout
    pass
except TimeoutError:
    print("Remote server failed to respond in time.")
```

---

## 🛠️ Performance Pattern: The Resilience Stack

**Philosophy**: catch specific errors first, then handle the unexpected.

```python
import sys
import subprocess

try:
    # Attempting a high-risk SRE task
    subprocess.run(["vault", "login"], check=True)
except subprocess.CalledProcessError as e:
    # Catch binary-specific failures
    print(f"Vault Error: {e.stderr}")
except FileNotFoundError:
    # Catch missing dependencies
    print("Error: 'vault' binary not found in PATH.")
except Exception as e:
    # Catch the "Unknown Unknowns"
    print(f"Unexpected Crash: {type(e).__name__}")
finally:
    # Ensure cleanup (e.g. deleting temp creds)
    clean_temp_tokens()
```

---
**Next Step**: [PEP 8 Architecture Guide →](./python-pep8-style-guide.md)
