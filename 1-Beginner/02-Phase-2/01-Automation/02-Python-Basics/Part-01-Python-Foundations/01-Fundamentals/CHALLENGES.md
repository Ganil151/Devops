# Python Fundamentals - DevOps Challenges

## Challenge 1: Log Formatter
**Scenario**: Create a script that acts as a consistent logging interface.

**Requirements:**
1. Accept a message and a level (INFO, ERROR, WARN) as arguments.
2. Print the message with a timestamp and ISO format.
3. Use f-strings for formatting.

**Verification:**
```bash
python log_formatter.py "Service started" INFO
# Expected: [2024-01-15T10:00:00] [INFO] Service started
```

**Reference Implementation:** [log_formatter.py](../../Scripts/log_formatter.py)

---

## Challenge 2: Environment Health Check
**Scenario**: Simple script to verify if critical environment variables are set.

**Requirements:**
1. Check for `APP_ENV`, `DB_HOST`, `DB_PORT`.
2. Print "OK" for found variables, "MISSING" for missing ones.
3. Exit with status code 1 if any are missing.

**Verification:**
```bash
python health_check.py
# If missing: Exits with 1
```

**Reference Implementation:** [health_check.py](../../Scripts/health_check.py)

---

## Challenge 3: Disk Space Calculator (Simple)
**Scenario**: Calculate generic percentage.

**Requirements:**
1. Accept `used` and `total` (in GB) as input.
2. Calculate percentage.
3. Print warning if usage > 80%.

**Verification:**
```bash
python disk_calc.py 90 100
# Expected: Usage: 90.0%. WARNING: High disk usage!
```

**Reference Implementation:** [disk_calc.py](../../Scripts/disk_calc.py)
