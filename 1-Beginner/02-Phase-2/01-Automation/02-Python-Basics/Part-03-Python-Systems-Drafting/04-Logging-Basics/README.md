# 📄 Logging Basics: The Automation Flight Recorder

> **"Proper logging separates amateur scripts from production-ready automation. In DevOps, good logs are the difference between a 5-minute fix and a 5-hour blind investigation."**

![Python Logging Architecture](../../assets/logging_architecture.png)

---

## 🧠 The Mental Model: The Cockpit Voice Recorder

**The Junior Struggle**: "My script crashed last night, but I don't know why because I closed the terminal." or "I have 1,000 `print()` statements and I can't find the error."

**The Engineer Solution**: Treat your script like an airplane. You need a **Black Box (Flight Recorder)** that:
1. Records everything important (not everything).
2. Categorizes events (Turbulence vs Engine Failure).
3. Saves data even if the pilot (you) isn't looking.
4. Outputs in a standard format for analysis.

### 🏗️ The Infrastructure Analogy

| Concept | Aviation Analogy | Logging Equivalent |
|:--------|:-----------------|:-------------------|
| **Log Level** | Alert Severity | `DEBUG` (Cockpit chatter), `ERROR` (Engine Fire) |
| **Handler** | Radio Frequency | `StreamHandler` (Air Traffic Control), `FileHandler` (Black Box) |
| **Formatter** | Language/Protocol | `%(asctime)s - %(message)s` (TIMESTAMP - MSG) |
| **Rotation** | Overwriting Old Tape | `RotatingFileHandler` (Keep last 5 days) |
| **Structured Log**| Digital Telemetry | JSON: `{"temp": 400, "status": "FAIL"}` |

**The Key Insight**: `print()` is ephemeral. `logging` is persistent data streams.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just use `print('Error happened')`"
- "Logging is too complicated to set up"
- "I don't need timestamps"

**After this module**, you'll understand:
- **Print is for humans, Logs are for machines.**
- **Log Levels** let you filter noise (turn off DEBUG in production).
- **Handlers** send errors to email/Slack and info to files.
- **Rotation** prevents your server from running out of disk space.
- **Standard Out (stdout)** is the cloud-native way (Docker/K8s).

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Replace `print()`** with the `logging` module
- ✅ **Master Log Levels** (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- ✅ **Configure Handlers** for Console and Files
- ✅ **Implement Log Rotation** to save disk space
- ✅ **Create JSON Logs** for modern observability (ELK/Datadog)
- ✅ **Follow 12-Factor App** principles for containers

---

## 🚦 Part 1: The Severity Hierarchy

### 🧠 The Mental Model: The Awareness Filters

**The Concept**: Not all information is equal. You need to filter noise.

| Level | Value | Usage in DevOps |
|:------|:------|:----------------|
| **DEBUG** | 10 | Detailed variables for troubleshooting (e.g., "Connecting to DB with user 'admin'"). |
| **INFO** | 20 | Normal confirmation (e.g., "Server started", "Backup completed"). |
| **WARNING** | 30 | Unexpected but handled issue (e.g., "Disk 85% full", "Retrying connection"). |
| **ERROR** | 40 | Operation failed (e.g., "Database connection refused", "File not found"). |
| **CRITICAL**| 50 | Heavy failure, program might stop (e.g., "Out of Memory", "Credential Leak"). |

### 🔧 Basic Implementation

```python
import logging

# 1. Configure the logger (Global settings)
logging.basicConfig(
    level=logging.INFO, # Ignore DEBUG
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# 2. Log events
logging.debug("Variable x = 10")      # Won't show (Below INFO)
logging.info("Deployment started")    # Shows
logging.warning("API response slow")  # Shows
logging.error("Database unavailable") # Shows
logging.critical("System Shutdown")   # Shows
```

**Why it matters**: In Production, you set level to `WARNING` to keep logs clean. When a bug appears, you switch to `DEBUG` without changing the code (using env vars).

---

## 📣 Part 2: Handlers and Formatters

### 🧠 The Mental Model: The Router

**The Design**: You want simple messages on the screen, but detailed technical data in the file.

### 🔧 Dual-Logging Pattern

```python
import logging

# Create a custom logger
logger = logging.getLogger("devops-bot")
logger.setLevel(logging.DEBUG) # Determine lowest level captured

# 1. Console Handler (Simple for Humans)
c_handler = logging.StreamHandler()
c_handler.setLevel(logging.INFO)
c_handler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))

# 2. File Handler (Detailed for Audit)
f_handler = logging.FileHandler('automation.log')
f_handler.setLevel(logging.DEBUG)
f_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))

# Attach handlers
logger.addHandler(c_handler)
logger.addHandler(f_handler)

# Usage
logger.debug("Connecting to AWS (Region: us-east-1)...") # Only to File
logger.info("Backup Service Online")                     # To File AND Console
```

---

## 💾 Part 3: Log Rotation (Safeguarding Disk)

### 🧠 The Mental Model: The Loop Tape

**The Risk**: A script logging 1GB/day will crash a 20GB server in 3 weeks.

**The Solution**: Rotate logs. Keep the last 5 files, delete the rest.

### 🔧 RotatingFileHandler

```python
import logging
from logging.handlers import RotatingFileHandler

logger = logging.getLogger("server-mon")
logger.setLevel(logging.INFO)

# Rotate when file hits 5MB. Keep 3 backups.
# Files: app.log, app.log.1, app.log.2, app.log.3
handler = RotatingFileHandler("server.log", maxBytes=5*1024*1024, backupCount=3)

logger.addHandler(handler)

for i in range(10000):
    logger.info(f"Processing record {i}...")
```

**Why this is "DevOps-First"**: This is a production requirement. Unrotated logs are a ticking time bomb.

---

## 📦 Part 4: Structured Data (JSON)

### 🧠 The Mental Model: Machine Reliability

**The Shift**: We used to grep text files. Now we query databases (Splunk, Datadog, Elasticsearch). Simple text logs are hard to query. JSON logs are native.

### 🔧 JSON Logging Pattern

```python
import logging
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "line": record.lineno
        }
        return json.dumps(log_record)

logger = logging.getLogger("json-logger")
handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)

logger.info("User logged in")
# Output: {"timestamp": "2023-10-25 10:00:00", "level": "INFO", "message": "User logged in", ...}
```

**Cloud Native Note**: In Docker/Kubernetes, **always log to stdout (console)**. The container runtime catches it and sends it to the aggregation system. Don't log to files inside containers!

---

## 🏆 Real-World DevOps Story: The Silent Cleanup Failure

**The Scenario**: A cleanup script was designed to delete temporary cloud snapshots every night. It ran via Cron.

**The Discovery**: For 6 months, the script was failing silently because of an API change. It was using `print("Error")`. Since cron jobs have no terminal attached, the output went into the void.

**The Consequence**: The company was billed **$15,000** for storage of 6 months of "deleted" snapshots.

**The Fix**: The team switched to `logging`. They added an `SMTPHandler` (Email) for `CRITICAL` errors.

**The Outcome**: When the API changed again next year, the Ops team got an email within 30 seconds. The issue was fixed before it cost a dime.

---

## ❓ Interview Preparation (Logging)

### 🎯 Core Concepts

1. **Q: Why avoid `print()` in production code?**
   - *A: `print()` writes to stdout without timestamps, levels, or formatting. It cannot be easily toggled off or redirected to files independently of stdout.*

2. **Q: What is the difference between `logger.error(msg)` and `logger.exception(msg)`?**
   - *A: `logger.exception()` prints the message AND the full Stack Trace. Use it inside `except` blocks to debug crashes.*

3. **Q: Explain Log Rotation.**
   - *A: Breaking log files into smaller chunks (by size or time) and deleting the oldest ones to prevent disk saturation.*

4. **Q: How do you log in a Docker container?**
   - *A: Log to `stdout/stderr`. Do NOT log to files inside the container. Let the container runtime (Docker Daemon/Kubelet) handle log shipping.*

5. **Q: What is the logging hierarchy?**
   - *A: Root Logger -> Child Loggers. If a child has no level set, it bubbles up to the parent.*

### 🚀 Advanced Questions

6. **Q: How do logs affect performance?**
   - *A: Logging is I/O. Excessive logging (e.g., DEBUG in a tight loop) can slow down applications significantly. Use `if logger.isEnabledFor(logging.DEBUG):` for expensive log construction.*

7. **Q: Why use JSON logging?**
   - *A: It creates structured data that is easily parsed by aggregation tools (ELK, Datadog), allowing for queries like `level:ERROR AND service:payment`.*

8. **Q: How do you handle sensitive data in logs?**
   - *A: Use output filters or custom formatters to mask PII (Personally Identifiable Information) like passwords or API keys before writing.*

9. **Q: What is `propagate` in Python logging?**
   - *A: A boolean property. If True (default), events logged to this logger are passed to the handlers of higher-level (ancestor) loggers.*

10. **Q: What is the benefit of `logging.getLogger(__name__)`?**
    - *A: It creates a logger named after the module (e.g., `my_app.utils`). This provides context on WHERE the log came from in the application structure.*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which level is used for "System is about to crash"?**
   - [ ] a) WARN
   - [ ] b) ERROR
   - [x] c) CRITICAL

2. **Where does `logging.warning()` send output by default?**
   - [ ] a) File
   - [x] b) Stderr (Console)
   - [ ] c) Email

3. **Does `RotatingFileHandler` delete old logs?**
   - [x] a) Yes, based on `backupCount`
   - [ ] b) No, it archives them forever

### 🚀 Intermediate Level

4. **Which method includes a stack trace?**
   - [ ] a) `logger.error()`
   - [ ] b) `logger.stack()`
   - [x] c) `logger.exception()`

5. **In a Docker container, where is the best place to log?**
   - [x] a) Standard Out (stdout)
   - [ ] b) /var/log/app.log
   - [ ] c) A text file on the desktop

6. **What does `%(asctime)s` do in a formatter?**
   - [x] a) Adds a timestamp string
   - [ ] b) Adds the script name
   - [ ] c) Adds the log level

### 🏆 Advanced Level

7. **If Logger A is a child of Root, and Root has level WARNING, what happens if Logger A logs LOG.INFO? (Assume Logger A has no level set)**
   - [x] a) It is ignored (inherited WARNING > INFO)
   - [ ] b) It is printed
   - [ ] c) It raises an error

8. **Why is JSON better than text for high-scale logging?**
   - [x] a) Indexable and searchable fields
   - [ ] b) Human readablity
   - [ ] c) Smaller file size

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Logs = Flight Recorder**: Always recording, only analyzed when needed.
2. **Levels = Filters**: Control the volume of information.
3. **Structured Logs = Data**: Treat logs as a database stream, not text.

### 🛡️ Safety Patterns

1. **Never use `print`** in scripts.
2. **Always Rotate Logs** on disk.
3. **Use `exception()`** in try/except blocks.

### 🚀 Production Rules

1. **JSON for Cloud**: Structured data wins.
2. **Stdout for Containers**: 12-Factor App.
3. **Alert on ERROR/CRITICAL**: Don't just ignore them.

---

## 🔗 Next Steps

Your script now records its history. Next, let's learn how to verify that your history is correct in advance.

**Proceed to**: [CLI Arguments →](../01-Command-Line-Arguments/README.md)

---

## 📚 Additional Resources

- [Python Logging Cookbook](https://docs.python.org/3/howto/logging-cookbook.html)
- [The 12-Factor App: Logs](https://12factor.net/logs)
- [Structured Logging Guide](https://www.datadoghq.com/blog/structured-logging/)

---

**🎓 Remember**: A newbie prints "Error". An engineer logs `ERROR: Connection Refused`. A senior engineer logs `{"level": "ERROR", "error": "Connection Refused", "service": "payment"}`.
