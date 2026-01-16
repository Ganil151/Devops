# Logging Basics
*Professional Logging for Production Scripts*

Proper logging separates amateur scripts from production-ready automation. The logging module provides flexible, configurable output for debugging, monitoring, and incident response. In DevOps, good logs are the difference between quick troubleshooting and hours of blind investigation.

---

## 🎯 Learning Objectives

- Configure logging with handlers and formatters
- Use appropriate log levels for different scenarios
- Implement structured logging for searchability
- Set up file rotation and multiple output destinations
- Apply logging best practices in automation scripts

---

## 📊 Logging Architecture

```mermaid
flowchart TD
    A[Application Code] --> B[Logger]
    
    B --> C{Log Level Check}
    C -->|Level >= Threshold| D[Handler 1: Console]
    C -->|Level >= Threshold| E[Handler 2: File]
    C -->|Level >= Threshold| F[Handler 3: Syslog]
    C -->|Level < Threshold| G[Discard Message]
    
    D --> H[Formatter]
    E --> I[Formatter]
    F --> J[Formatter]
    
    H --> K[Terminal Output]
    I --> L[Log File]
    J --> M[Centralized Logging]
    
    style A fill:#306998,stroke:#ffe873,color:#fff
    style B fill:#4b8bbe,stroke:#306998,color:#fff
    style C fill:#9b59b6,stroke:#8e44ad,color:#fff
```

---

## 📈 Logging Levels Hierarchy

```mermaid
flowchart TB
    subgraph "Severity Levels (Low to High)"
        DEBUG["🔍 DEBUG (10)<br>Detailed diagnostic info<br>'Connecting to database...'"]
        INFO["ℹ️ INFO (20)<br>General operational events<br>'Server started on port 8080'"]
        WARNING["⚠️ WARNING (30)<br>Something unexpected<br>'Disk usage at 85%'"]
        ERROR["❌ ERROR (40)<br>Serious problem occurred<br>'Failed to connect to API'"]
        CRITICAL["🔥 CRITICAL (50)<br>System failure<br>'Database server down!'"]
    end
    
    DEBUG --> INFO --> WARNING --> ERROR --> CRITICAL
    
    style DEBUG fill:#3498db,stroke:#2980b9,color:#fff
    style INFO fill:#27ae60,stroke:#2ecc71,color:#fff
    style WARNING fill:#f39c12,stroke:#e67e22,color:#fff
    style ERROR fill:#e74c3c,stroke:#c0392b,color:#fff
    style CRITICAL fill:#8e44ad,stroke:#9b59b6,color:#fff
```

| Level | Value | When to Use | DevOps Example |
|-------|-------|-------------|----------------|
| **DEBUG** | 10 | Detailed diagnostic info | Variable values, loop iterations |
| **INFO** | 20 | General operational events | Server started, deployment complete |
| **WARNING** | 30 | Something unexpected but handled | Retry needed, deprecated feature used |
| **ERROR** | 40 | Serious problem occurred | API call failed, file not found |
| **CRITICAL** | 50 | System failure, needs immediate attention | Database down, out of memory |

---

## 📚 Core Concepts

### 1. Basic Logging Setup

```python
import logging

# Simple configuration - good for scripts
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

# Create a logger for your module
logger = logging.getLogger(__name__)

# Log at different levels
logger.debug("Detailed debugging info - variable x = 42")
logger.info("Starting server health check...")
logger.warning("Disk usage is at 85%, consider cleanup")
logger.error("Failed to connect to database: connection timeout")
logger.critical("System out of memory! Shutting down!")
```

### 2. Logger Hierarchy

```mermaid
flowchart TD
    ROOT["Root Logger<br>(logging)"] --> APP["App Logger<br>(myapp)"]
    APP --> MOD1["Module Logger<br>(myapp.database)"]
    APP --> MOD2["Module Logger<br>(myapp.api)"]
    MOD1 --> SUB1["Sub-module<br>(myapp.database.postgres)"]
    
    style ROOT fill:#306998,stroke:#ffe873,color:#fff
```

```python
import logging

# Logger hierarchy - child inherits from parent
root_logger = logging.getLogger()           # Root logger
app_logger = logging.getLogger("myapp")     # App-level
db_logger = logging.getLogger("myapp.db")   # Module-level

# Setting level on parent affects children
app_logger.setLevel(logging.DEBUG)  # myapp.db also shows DEBUG
```

### 3. Multiple Handlers - Console and File

```python
import logging

def setup_logging(log_file="app.log", console_level=logging.INFO, 
                  file_level=logging.DEBUG):
    """Professional logging setup with multiple handlers."""
    
    # Create logger
    logger = logging.getLogger("automation")
    logger.setLevel(logging.DEBUG)  # Capture all, filter at handler level
    
    # Prevent duplicate handlers on re-run
    logger.handlers.clear()
    
    # Console handler - INFO and above
    console_handler = logging.StreamHandler()
    console_handler.setLevel(console_level)
    console_format = logging.Formatter(
        "%(levelname)-8s | %(message)s"
    )
    console_handler.setFormatter(console_format)
    
    # File handler - DEBUG and above (more detail)
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(file_level)
    file_format = logging.Formatter(
        "%(asctime)s | %(name)s | %(levelname)-8s | %(filename)s:%(lineno)d | %(message)s"
    )
    file_handler.setFormatter(file_format)
    
    # Add handlers
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

# Usage
logger = setup_logging()
logger.info("Starting deployment...")  # Shows in console AND file
logger.debug("Config loaded: {...}")   # Only in file (DEBUG < INFO)
```

### 4. Rotating Log Files

```python
import logging
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler

# Size-based rotation - rotate when file reaches 5MB, keep 3 backups
size_handler = RotatingFileHandler(
    "app.log",
    maxBytes=5*1024*1024,  # 5 MB
    backupCount=3          # Keep app.log.1, app.log.2, app.log.3
)

# Time-based rotation - new file every day at midnight
time_handler = TimedRotatingFileHandler(
    "app.log",
    when="midnight",       # Rotate at midnight
    interval=1,            # Every 1 day
    backupCount=7          # Keep 7 days of logs
)

# When options: 'S' (second), 'M' (minute), 'H' (hour), 
#               'D' (day), 'midnight', 'W0'-'W6' (weekday)
```

### 5. Structured Logging with JSON

```python
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """Output logs as JSON for log aggregation systems."""
    
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        
        # Include exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        
        # Include extra fields
        if hasattr(record, "extra_data"):
            log_data["extra"] = record.extra_data
            
        return json.dumps(log_data)

# Usage
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger = logging.getLogger("structured")
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

logger.info("Deployment started", extra={"extra_data": {"env": "prod", "version": "1.2.3"}})
```

### 6. Contextual Logging with Extra Data

```python
import logging

logger = logging.getLogger("deploy")
logger.setLevel(logging.INFO)

# Create a custom formatter that includes extra fields
class ContextFormatter(logging.Formatter):
    def format(self, record):
        # Add default values for optional fields
        record.server = getattr(record, 'server', 'unknown')
        record.job_id = getattr(record, 'job_id', 'N/A')
        return super().format(record)

handler = logging.StreamHandler()
handler.setFormatter(ContextFormatter(
    "%(asctime)s | [%(job_id)s] %(server)s | %(levelname)s | %(message)s"
))
logger.addHandler(handler)

# Log with context
logger.info("Starting deployment", extra={"server": "web-01", "job_id": "deploy-123"})
logger.info("Checking health", extra={"server": "web-01", "job_id": "deploy-123"})
logger.error("Health check failed", extra={"server": "web-01", "job_id": "deploy-123"})
```

---

## 📋 Format String Reference

| Directive | Description | Example |
|-----------|-------------|---------|
| `%(asctime)s` | Human-readable timestamp | 2026-01-12 17:30:00 |
| `%(name)s` | Logger name | myapp.database |
| `%(levelname)s` | Log level | INFO, ERROR |
| `%(message)s` | The log message | Server started |
| `%(filename)s` | Source file name | deploy.py |
| `%(lineno)d` | Line number | 42 |
| `%(funcName)s` | Function name | check_health |
| `%(process)d` | Process ID | 12345 |
| `%(thread)d` | Thread ID | 67890 |

---

## 🛠️ Hands-On Challenges

Master the `logging` module by building these professional-grade logging systems.

| Challenge | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- |
| **01. Basic Setup** | Configure a logger with dual handlers for console (INFO) and file (DEBUG) output. | [Link](./challenges/challenge_01_basic_setup.py) | [Link](./challenges/solutions/solution_01_basic_setup.py) |
| **02. Rotating Logs** | Implement size-based log rotation to manage disk space automatically. | [Link](./challenges/challenge_02_rotating_logs.py) | [Link](./challenges/solutions/solution_02_rotating_logs.py) |
| **03. JSON Formatter** | Build a custom formatter that outputs logs as structured JSON for central aggregation. | [Link](./challenges/challenge_03_json_formatter.py) | [Link](./challenges/solutions/solution_03_json_formatter.py) |
| **04. Contextual Logs** | Trace requests by including custom metadata (request IDs) in every log entry. | [Link](./challenges/challenge_04_contextual_logging.py) | [Link](./challenges/solutions/solution_04_contextual_logging.py) |

> **Pro Tip**: Use `logger.exception("message")` inside `except` blocks—it automatically captures and logs the full stack trace at the ERROR level.

---

## 📖 Real-World Story: The Silent Failure

**Scenario**: A nightly backup script ran for 3 months without issues. One day, backups stopped working—but nobody noticed for 2 weeks.

**Problem**: The script used `print()` statements that nobody monitored. When an error occurred, it printed to stdout which vanished when the cron job ran.

**Solution**: Implemented proper logging:

```python
import logging
from logging.handlers import SMTPHandler, RotatingFileHandler

# Setup logging
logger = logging.getLogger("backup")
logger.setLevel(logging.INFO)

# File handler with rotation
file_handler = RotatingFileHandler(
    "/var/log/backup.log",
    maxBytes=10*1024*1024,
    backupCount=10
)
file_handler.setFormatter(logging.Formatter(
    "%(asctime)s | %(levelname)s | %(message)s"
))

# Email handler for critical errors
mail_handler = SMTPHandler(
    mailhost="smtp.company.com",
    fromaddr="backup@company.com",
    toaddrs=["oncall@company.com"],
    subject="🚨 Backup Script CRITICAL Error"
)
mail_handler.setLevel(logging.CRITICAL)

logger.addHandler(file_handler)
logger.addHandler(mail_handler)

# Now errors are visible AND actionable
try:
    run_backup()
    logger.info("Backup completed successfully")
except Exception as e:
    logger.critical(f"Backup FAILED: {e}")
    raise
```

**Outcome**: The next failure triggered an immediate email alert, and the issue was fixed within 30 minutes instead of 2 weeks.

---

## ❓ Interview Questions

1. **Why is logging better than print() statements?**
   > Logging provides: configurable output levels, multiple destinations (file, console, network), timestamps, structured metadata, and can be enabled/disabled without code changes. Print statements can't be easily filtered or redirected in production.

2. **Explain the logging hierarchy and how it works.**
   > Loggers form a tree based on dot-separated names (e.g., "app.db.postgres"). Child loggers inherit settings from parents. This allows setting DEBUG on "app" to debug everything, or just on "app.db" to debug database code only.

3. **When would you use WARNING vs ERROR level?**
   > WARNING: Something unexpected happened but the operation can continue (disk at 85%, retry succeeded, deprecated feature used). ERROR: Operation failed and couldn't be completed (API call failed, file not found, database connection lost).

4. **How do you prevent log files from consuming all disk space?**
   > Use `RotatingFileHandler` (size-based rotation) or `TimedRotatingFileHandler` (time-based). Set `backupCount` to limit retained files. Consider log shipping to centralized storage.

5. **What is structured logging and when should you use it?**
   > Structured logging outputs logs in a parsed format like JSON. Use it when: logs are shipped to aggregation systems (ELK, Splunk), you need to search/filter by specific fields, or building dashboards. Human-readable format is better for local debugging.

6. **How do you add context (like request ID or user ID) to all log messages in a request?**
   > Use `logging.LoggerAdapter` or Python's `contextvars` module. Create a filter or formatter that automatically includes context fields. This is essential for tracing requests across microservices.

---

## 🧠 Quiz

1. Which log level is highest severity?
   - a) ERROR
   - b) CRITICAL ✅
   - c) WARNING
   - d) FATAL

2. What is the default logging level when not explicitly set?
   - a) DEBUG
   - b) INFO
   - c) WARNING ✅
   - d) ERROR

3. Which handler rotates logs based on file size?
   - a) FileHandler
   - b) RotatingFileHandler ✅
   - c) TimedRotatingFileHandler
   - d) SizedFileHandler

4. What does `%(lineno)d` show in a format string?
   - a) Logger name
   - b) Line number ✅
   - c) Log level
   - d) Timestamp

5. How do you set different levels for console vs file output?
   - a) Create two loggers
   - b) Use two handlers with different levels ✅
   - c) It's not possible
   - d) Use basicConfig twice

6. What happens if you log at DEBUG level but logger is set to INFO?
   - a) Message is logged anyway
   - b) Message is discarded ✅
   - c) Error is raised
   - d) Message is promoted to INFO

7. Which handler sends log messages via email?
   - a) EmailHandler
   - b) SMTPHandler ✅
   - c) MailHandler
   - d) NotifyHandler

8. What is the numeric value of logging.INFO?
   - a) 10
   - b) 20 ✅
   - c) 30
   - d) 40

---

## 🔗 Related Topics

| Module | Relationship |
|--------|-------------|
| [Error Handling](../../../../../../README.md) | Log exceptions with stack traces |
| [Subprocess Module](../../../../../../README.md) | Log command execution and output |
| [Datetime Operations](../../../../../../README.md) | Timestamp formatting in logs |

---

**Next Step**: [Virtual Environments →](../15-Virtual-Environments/README.md)
