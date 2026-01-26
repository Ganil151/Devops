# 🏛️ Python Standard Library: The Exhaustive Master Reference
*Version 3.0 | The SRE Automation Engine Room*

---

## 📖 Overview
The Standard Library is the "Batteries Included" philosophy of Python. For DevOps engineers, these modules are the backbone of secure, lightweight automation. This guide follows the exhaustive **Keyword | Definition | Example** standard for the most critical modules and functions used in production infrastructure.

---

## 📂 `os` (Operating System Interface)

### `os.getenv()`
**Definition**: Fetches the value of an environment variable. Returns `None` if the variable does not exist.
**Example**:
```python
# Safely fetch key for CI/CD
API_KEY = os.getenv("VAULT_TOKEN", "default_fallback")
```

### `os.path.exists()`
**Definition**: Returns `True` if a specific path points to an existing file or directory.
**Example**:
```python
if not os.path.exists("/etc/nginx/nginx.conf"):
    print("Webserver not installed.")
```

### `os.makedirs()`
**Definition**: Recursive directory creation function. Similar to `mkdir -p` in Linux.
**Example**:
```python
os.makedirs("/var/log/myapp/backups", exist_ok=True)
```

### `os.environ`
**Definition**: A mapping object representing the current environment variables. Use this to set variables for child processes.
**Example**:
```python
os.environ["DEPLOY_STATUS"] = "SUCCESS"
```

---

## 🧩 `pathlib` (Object-Oriented Pathing)

### `Path.resolve()`
**Definition**: Returns the absolute path, resolving any symlinks and ".." segments.
**Example**:
```python
current_dir = Path(".").resolve()
```

### `Path.read_text()`
**Definition**: Direct method to read the contents of a file as a string without manually opening/closing.
**Example**:
```python
config = Path("config.env").read_text()
```

### `Path.home()`
**Definition**: Returns a new Path object representing the user’s home directory.
**Example**:
```python
ssh_dir = Path.home() / ".ssh"
```

---

## ⚙️ `sys` (System-Specific Parameters)

### `sys.argv`
**Definition**: The list of command-line arguments passed to a Python script.
**Example**:
```python
# python script.py prod us-east-1
env = sys.argv[1] # "prod"
```

### `sys.exit()`
**Definition**: Triggers an exit from Python. Passing an integer (1-255) signals failure to CI/CD pipelines.
**Example**:
```python
if audit_failed:
    sys.exit(1) # Triggers pipeline failure
```

### `sys.path`
**Definition**: A list of strings that specifies the search path for modules.
**Example**:
```python
sys.path.append("/opt/custom_libs")
```

---

## 🧪 `json` (Data Serialization)

### `json.loads()`
**Definition**: Parses a JSON-formatted string into a Python Dictionary.
**Example**:
```python
data = json.loads('{"status": "UP"}')
```

### `json.dumps()`
**Definition**: Converts a Python Dictionary or List into a JSON-formatted string.
**Example**:
```python
payload = json.dumps({"audit": True}, indent=4)
```

### `json.load()`
**Definition**: Reads and parses a JSON file object directly.
**Example**:
```python
with open("config.json") as f:
    conf = json.load(f)
```

---

## ⏳ `datetime` (Time & Date)

### `datetime.now()`
**Definition**: Returns the current local date and time.
**Example**:
```python
start_time = datetime.now()
```

### `datetime.strftime()`
**Definition**: Formats a datetime object into a specific string format (Year, Month, Day, etc.).
**Example**:
```python
# Standard ISO format for logging
timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
```

---

## 🐚 `subprocess` (Command Execution)

### `subprocess.run()`
**Definition**: Runs a system command and waits for it to complete. The most modern way to run shell logic.
**Example**:
```python
result = subprocess.run(["terraform", "apply"], capture_output=True, text=True)
```

### `check=True` (Argument)
**Definition**: An argument for `run()` that automatically raises an exception if the shell command returns a non-zero exit code.
**Example**:
```python
# Crashes the script if kubectl fails
subprocess.run(["kubectl", "get", "pods"], check=True)
```

---

## 📦 `shutil` (High-level File Ops)

### `shutil.copytree()`
**Definition**: Recursively copies an entire directory tree.
**Example**:
```python
shutil.copytree("./build", "/var/www/html", dirs_exist_ok=True)
```

### `shutil.rmtree()`
**Definition**: Recursively deletes an entire directory tree.
**Example**:
```python
shutil.rmtree("/tmp/stale_workspace")
```

### `shutil.which()`
**Definition**: Returns the path to an executable file (like `which` in bash).
**Example**:
```python
if not shutil.which("docker"):
    raise Exception("Docker binary not found")
```

---

## 🏗️ `logging` (Production Observability)

### `logging.basicConfig()`
**Definition**: Configures the root logger (level, format, filename) for the entire script.
**Example**:
```python
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
```

### `logging.error()`
**Definition**: Sends a message with the level `ERROR` to the log destination.
**Example**:
```python
logging.error("Failed to authenticate with Cloud API.")
```

---

## 🛡️ `hashlib` (Security & Integrity)

### `hashlib.sha256()`
**Definition**: Generates a SHA-256 hash object. Essential for verifying file integrity of downloads/artifacts.
**Example**:
```python
file_hash = hashlib.sha256(b"artifact_data").hexdigest()
```

---

## 🌐 `urllib.request` (Basic Networking)

### `urlopen()`
**Definition**: Opens a URL (usually HTTP) for reading. Useful for lightweight metadata fetches without the `requests` library.
**Example**:
```python
from urllib.request import urlopen
response = urlopen("http://169.254.169.254/latest/meta-data/instance-id")
```

---
**Next Step**: [Built-in Functions Reference →](./Built-in-Functions-Ref.md)
