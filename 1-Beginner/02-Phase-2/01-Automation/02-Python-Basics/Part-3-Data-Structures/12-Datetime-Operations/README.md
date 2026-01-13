# Datetime Operations
*Handling Time in Automation Scripts*

Time handling is critical for DevOps—scheduling tasks, parsing logs, calculating durations, managing backups, and working across global time zones. Mastering datetime operations is essential for any production automation.

---

## 🎯 Learning Objectives

- Work with dates, times, and timestamps accurately
- Parse and format datetime strings for logs and APIs
- Calculate time differences and durations
- Handle time zones correctly (the #1 cause of production bugs)
- Convert between timestamps, datetime objects, and strings

---

## 📊 Datetime Module Components

```mermaid
flowchart TD
    subgraph datetime["datetime Module"]
        A[datetime.datetime] --> B[datetime.date]
        A --> C[datetime.time]
        D[datetime.timedelta] --> A
        E[datetime.timezone] --> A
    end
    
    subgraph "Real Usage"
        A --> F["Full timestamp<br>2024-01-15 10:30:00"]
        B --> G["Date only<br>2024-01-15"]
        C --> H["Time only<br>10:30:00"]
        D --> I["Duration<br>3 days, 2 hours"]
        E --> J["Timezone<br>UTC, EST, PST"]
    end
    
    style A fill:#306998,stroke:#ffe873,color:#fff
    style D fill:#4b8bbe,stroke:#306998,color:#fff
    style E fill:#4b8bbe,stroke:#306998,color:#fff
```

---

## 📊 Timestamp Conversion Flow

```mermaid
flowchart LR
    A["Unix Timestamp<br>1704067200"] --> B["datetime Object<br>2024-01-01 00:00:00"]
    B --> C["ISO String<br>2024-01-01T00:00:00"]
    B --> D["Custom Format<br>01/01/2024"]
    B --> A
    
    style B fill:#306998,stroke:#ffe873,color:#fff
```

---

## 📚 Core Concepts

### 1. Creating Datetime Objects

```python
from datetime import datetime, date, time, timedelta, timezone

# Current date and time
now = datetime.now()              # Local time
utc_now = datetime.utcnow()       # UTC (deprecated, use below)
utc_now = datetime.now(timezone.utc)  # Better: timezone-aware

# Current date only
today = date.today()

# Specific datetime
meeting = datetime(2026, 1, 15, 10, 30, 0)
print(meeting)  # 2026-01-15 10:30:00

# Date and time separately
birthday = date(1990, 5, 15)
alarm = time(7, 30, 0)       # 07:30:00

# Combine date and time
start_time = datetime.combine(birthday, alarm)
```

### 2. From Timestamps (Unix Epoch)

```python
from datetime import datetime, timezone

# Unix timestamp (seconds since Jan 1, 1970 UTC)
timestamp = 1704067200

# Convert to datetime
dt = datetime.fromtimestamp(timestamp)          # Local timezone
dt_utc = datetime.fromtimestamp(timestamp, tz=timezone.utc)  # UTC

# Get timestamp from datetime
now = datetime.now()
ts = now.timestamp()
print(f"Current timestamp: {ts}")  # 1704067200.123456

# Millisecond timestamps (common in APIs)
ms_timestamp = 1704067200000
dt = datetime.fromtimestamp(ms_timestamp / 1000)
```

### 3. Formatting Dates (to String)

```python
from datetime import datetime

now = datetime.now()

# strftime - "string format time"
formatted = now.strftime("%Y-%m-%d %H:%M:%S")
print(formatted)  # "2026-01-12 17:30:00"

# ISO format (standard for APIs and logs)
iso = now.isoformat()
print(iso)  # "2026-01-12T17:30:00.123456"

# Common formats for DevOps
log_format = now.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # 2026-01-12 17:30:00.123
file_safe = now.strftime("%Y%m%d_%H%M%S")               # 20260112_173000
human = now.strftime("%B %d, %Y at %I:%M %p")           # January 12, 2026 at 05:30 PM
aws_format = now.strftime("%Y-%m-%dT%H:%M:%SZ")         # 2026-01-12T17:30:00Z
```

### 4. Format Codes Reference

| Code | Meaning | Example |
|------|---------|---------|
| `%Y` | 4-digit year | 2026 |
| `%m` | Month (01-12) | 01 |
| `%d` | Day (01-31) | 12 |
| `%H` | Hour 24h (00-23) | 17 |
| `%I` | Hour 12h (01-12) | 05 |
| `%M` | Minute (00-59) | 30 |
| `%S` | Second (00-59) | 00 |
| `%f` | Microsecond | 123456 |
| `%p` | AM/PM | PM |
| `%j` | Day of year | 012 |
| `%W` | Week number | 02 |
| `%A` | Weekday name | Sunday |
| `%B` | Month name | January |
| `%Z` | Timezone name | UTC |
| `%z` | Timezone offset | +0000 |

### 5. Parsing Dates (from String)

```python
from datetime import datetime

# strptime - "string parse time"
date_str = "2026-01-12 17:30:00"
dt = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")

# Parse ISO format
iso_str = "2026-01-12T17:30:00"
dt = datetime.fromisoformat(iso_str)

# Parse common log formats
apache_log = "12/Jan/2026:17:30:00 -0500"
dt = datetime.strptime(apache_log, "%d/%b/%Y:%H:%M:%S %z")

# Handle timestamps from APIs
api_response = "2026-01-12T17:30:00.123Z"  # ISO with Z suffix
dt = datetime.fromisoformat(api_response.replace("Z", "+00:00"))
```

### 6. Time Calculations with timedelta

```python
from datetime import datetime, timedelta

now = datetime.now()

# Add/subtract time
tomorrow = now + timedelta(days=1)
next_week = now + timedelta(weeks=1)
an_hour_ago = now - timedelta(hours=1)
in_90_mins = now + timedelta(minutes=90)
next_month = now + timedelta(days=30)

# Complex timedeltas
backup_retention = timedelta(days=7, hours=12)
meeting_duration = timedelta(hours=1, minutes=30)

# Calculate duration between datetimes
start = datetime(2026, 1, 1)
end = datetime(2026, 1, 15)
duration = end - start  # timedelta object

print(f"Days: {duration.days}")              # 14
print(f"Total seconds: {duration.total_seconds()}")  # 1209600.0
print(f"Total hours: {duration.total_seconds() / 3600}")  # 336.0
```

### 7. Timezone Handling (Critical for Production!)

```python
from datetime import datetime, timezone, timedelta

# Create timezone-aware datetime
utc_now = datetime.now(timezone.utc)
print(utc_now)  # 2026-01-12 22:30:00+00:00

# Define custom timezones
est = timezone(timedelta(hours=-5))
pst = timezone(timedelta(hours=-8))

# Convert between timezones
utc_time = datetime.now(timezone.utc)
est_time = utc_time.astimezone(est)
pst_time = utc_time.astimezone(pst)

print(f"UTC: {utc_time}")   # 2026-01-12 22:30:00+00:00
print(f"EST: {est_time}")   # 2026-01-12 17:30:00-05:00
print(f"PST: {pst_time}")   # 2026-01-12 14:30:00-08:00

# For real-world timezone handling, use pytz or zoneinfo (Python 3.9+)
from zoneinfo import ZoneInfo  # Python 3.9+

ny_tz = ZoneInfo("America/New_York")
tokyo_tz = ZoneInfo("Asia/Tokyo")

ny_time = datetime.now(ny_tz)
tokyo_time = ny_time.astimezone(tokyo_tz)
```

### 8. Comparing Datetimes

```python
from datetime import datetime, timezone, timedelta

# Compare datetimes
start = datetime(2026, 1, 1)
end = datetime(2026, 1, 15)
now = datetime.now()

if now > start:
    print("We're past the start date")

if start < now < end:
    print("We're in the date range")

# Check if datetime is within threshold
last_backup = datetime(2026, 1, 10)
threshold = timedelta(days=7)

if datetime.now() - last_backup > threshold:
    print("⚠️ Backup is too old!")
else:
    print("✅ Backup is recent")
```

---

## 🛠️ Hands-On Exercises

### Exercise 1: Backup Age Checker

```python
from datetime import datetime, timedelta

def check_backup_ages(backups, max_age_days=30):
    """Check if backups are within acceptable age.
    
    TODO: Implement to:
    1. Parse each backup's date
    2. Calculate age in days
    3. Flag old backups
    4. Return report dict
    """
    pass

# Test data
backups = [
    {"name": "backup_20260101.tar.gz", "date": "2026-01-01"},
    {"name": "backup_20260110.tar.gz", "date": "2026-01-10"},
    {"name": "backup_20260112.tar.gz", "date": "2026-01-12"},
]
```

<details>
<summary>💡 Solution</summary>

```python
from datetime import datetime, timedelta

def check_backup_ages(backups, max_age_days=30):
    """Check if backups are within acceptable age."""
    now = datetime.now()
    max_age = timedelta(days=max_age_days)
    
    report = {
        "checked_at": now.isoformat(),
        "max_age_days": max_age_days,
        "total": len(backups),
        "healthy": 0,
        "expired": 0,
        "details": []
    }
    
    for backup in backups:
        backup_date = datetime.strptime(backup["date"], "%Y-%m-%d")
        age = now - backup_date
        age_days = age.days
        
        is_expired = age > max_age
        
        if is_expired:
            report["expired"] += 1
            status = "❌ EXPIRED"
        else:
            report["healthy"] += 1
            status = "✅ OK"
        
        report["details"].append({
            "name": backup["name"],
            "age_days": age_days,
            "status": status
        })
    
    return report

# Test
backups = [
    {"name": "backup_20260101.tar.gz", "date": "2026-01-01"},
    {"name": "backup_20260110.tar.gz", "date": "2026-01-10"},
    {"name": "backup_20260112.tar.gz", "date": "2026-01-12"},
]

report = check_backup_ages(backups, max_age_days=7)
print(f"Healthy: {report['healthy']}, Expired: {report['expired']}")
for detail in report["details"]:
    print(f"  {detail['status']} {detail['name']} ({detail['age_days']} days)")
```
</details>

### Exercise 2: Log Timestamp Parser

```python
from datetime import datetime

def parse_log_timestamps(log_lines):
    """Parse timestamps from various log formats.
    
    TODO: Handle multiple formats:
    - Apache: "12/Jan/2026:17:30:00 -0500"
    - Syslog: "Jan 12 17:30:00"
    - ISO: "2026-01-12T17:30:00.123Z"
    """
    pass

# Test data
logs = [
    '12/Jan/2026:17:30:00 -0500 "GET /api/health"',
    'Jan 12 17:30:05 server1 sshd[12345]: Connection attempt',
    '2026-01-12T17:30:10.123Z INFO Starting service',
]
```

<details>
<summary>💡 Solution</summary>

```python
from datetime import datetime
import re

def parse_log_timestamps(log_lines):
    """Parse timestamps from various log formats."""
    
    formats = [
        # Apache/nginx combined log
        (r'(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2} [+-]\d{4})', 
         '%d/%b/%Y:%H:%M:%S %z'),
        # Syslog (no year, assume current)
        (r'(\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})', 
         '%b %d %H:%M:%S'),
        # ISO format with Z
        (r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?)', 
         'iso'),
    ]
    
    results = []
    current_year = datetime.now().year
    
    for line in log_lines:
        parsed = None
        
        for pattern, fmt in formats:
            match = re.search(pattern, line)
            if match:
                ts_str = match.group(1)
                try:
                    if fmt == 'iso':
                        # Handle ISO format
                        ts_str = ts_str.replace('Z', '+00:00')
                        parsed = datetime.fromisoformat(ts_str)
                    else:
                        parsed = datetime.strptime(ts_str, fmt)
                        # Add year for syslog format
                        if parsed.year == 1900:
                            parsed = parsed.replace(year=current_year)
                    break
                except ValueError:
                    continue
        
        results.append({
            "original": line[:50] + "..." if len(line) > 50 else line,
            "timestamp": parsed.isoformat() if parsed else "PARSE_FAILED",
            "parsed": parsed
        })
    
    return results

# Test
logs = [
    '12/Jan/2026:17:30:00 -0500 "GET /api/health"',
    'Jan 12 17:30:05 server1 sshd[12345]: Connection attempt',
    '2026-01-12T17:30:10.123Z INFO Starting service',
]

for result in parse_log_timestamps(logs):
    print(f"✅ {result['timestamp']}")
```
</details>

### Exercise 3: SLA Duration Calculator

```python
from datetime import datetime, timedelta

def calculate_sla_metrics(incidents):
    """Calculate SLA compliance metrics.
    
    TODO: For each incident:
    1. Calculate time to resolve
    2. Determine if within SLA (4 hours)
    3. Calculate overall SLA compliance percentage
    """
    pass

incidents = [
    {"id": "INC001", "start": "2026-01-12 10:00:00", "end": "2026-01-12 12:30:00"},
    {"id": "INC002", "start": "2026-01-12 14:00:00", "end": "2026-01-12 19:30:00"},
    {"id": "INC003", "start": "2026-01-12 20:00:00", "end": "2026-01-12 21:15:00"},
]
```

<details>
<summary>💡 Solution</summary>

```python
from datetime import datetime, timedelta

def calculate_sla_metrics(incidents, sla_hours=4):
    """Calculate SLA compliance metrics."""
    sla_threshold = timedelta(hours=sla_hours)
    
    metrics = {
        "total_incidents": len(incidents),
        "within_sla": 0,
        "breached_sla": 0,
        "compliance_rate": 0.0,
        "average_resolution_mins": 0,
        "details": []
    }
    
    total_resolution_time = timedelta()
    
    for incident in incidents:
        start = datetime.strptime(incident["start"], "%Y-%m-%d %H:%M:%S")
        end = datetime.strptime(incident["end"], "%Y-%m-%d %H:%M:%S")
        
        resolution_time = end - start
        total_resolution_time += resolution_time
        
        within_sla = resolution_time <= sla_threshold
        if within_sla:
            metrics["within_sla"] += 1
            status = "✅ WITHIN SLA"
        else:
            metrics["breached_sla"] += 1
            status = "❌ SLA BREACHED"
        
        metrics["details"].append({
            "id": incident["id"],
            "resolution_mins": resolution_time.total_seconds() / 60,
            "status": status
        })
    
    # Calculate averages
    if len(incidents) > 0:
        metrics["compliance_rate"] = (metrics["within_sla"] / len(incidents)) * 100
        metrics["average_resolution_mins"] = (
            total_resolution_time.total_seconds() / 60 / len(incidents)
        )
    
    return metrics

# Test
incidents = [
    {"id": "INC001", "start": "2026-01-12 10:00:00", "end": "2026-01-12 12:30:00"},
    {"id": "INC002", "start": "2026-01-12 14:00:00", "end": "2026-01-12 19:30:00"},
    {"id": "INC003", "start": "2026-01-12 20:00:00", "end": "2026-01-12 21:15:00"},
]

report = calculate_sla_metrics(incidents, sla_hours=4)
print(f"📊 SLA Compliance: {report['compliance_rate']:.1f}%")
print(f"⏱️ Average Resolution: {report['average_resolution_mins']:.0f} minutes")
for detail in report["details"]:
    print(f"  {detail['status']} {detail['id']}: {detail['resolution_mins']:.0f} min")
```
</details>

### Exercise 4: Maintenance Window Scheduler

```python
from datetime import datetime, timedelta

def schedule_maintenance(start_time, duration_hours, excluded_days=None):
    """Calculate maintenance window details.
    
    TODO: 
    1. Determine start/end times
    2. Check if falls on excluded days
    3. Calculate next valid window if excluded
    4. Format for display and notifications
    """
    pass
```

<details>
<summary>💡 Solution</summary>

```python
from datetime import datetime, timedelta

def schedule_maintenance(start_time, duration_hours, excluded_days=None):
    """Calculate maintenance window details."""
    
    if excluded_days is None:
        excluded_days = [5, 6]  # Saturday=5, Sunday=6
    
    if isinstance(start_time, str):
        start = datetime.fromisoformat(start_time)
    else:
        start = start_time
    
    duration = timedelta(hours=duration_hours)
    
    # Check if start falls on excluded day
    max_attempts = 7
    original_start = start
    
    while start.weekday() in excluded_days and max_attempts > 0:
        start = start + timedelta(days=1)
        max_attempts -= 1
    
    was_rescheduled = start != original_start
    end = start + duration
    
    # Format for different uses
    window = {
        "start": start,
        "end": end,
        "duration_hours": duration_hours,
        "day_name": start.strftime("%A"),
        "rescheduled": was_rescheduled,
        "formats": {
            "display": f"{start.strftime('%A, %B %d, %Y')} "
                      f"{start.strftime('%I:%M %p')} - {end.strftime('%I:%M %p')}",
            "slack": f"🔧 Maintenance: {start.strftime('%m/%d %H:%M')} - "
                    f"{end.strftime('%H:%M')} ({duration_hours}h)",
            "email_subject": f"[Maintenance] {start.strftime('%b %d')} - "
                           f"{duration_hours} Hour Window",
            "ical": f"DTSTART:{start.strftime('%Y%m%dT%H%M%S')}\n"
                   f"DTEND:{end.strftime('%Y%m%dT%H%M%S')}"
        }
    }
    
    if was_rescheduled:
        window["original_date"] = original_start
        window["reschedule_reason"] = "Fell on excluded day"
    
    return window

# Test
window = schedule_maintenance("2026-01-11T02:00:00", 4)  # Saturday
print(f"📅 {window['formats']['display']}")
print(f"💬 {window['formats']['slack']}")
if window["rescheduled"]:
    print(f"⚠️ Rescheduled from {window['original_date'].strftime('%A')}")
```
</details>

---

## 📖 Real-World Story: The Timezone Bug

**Scenario**: A global team's deployment automation would randomly fail. Sometimes deployments worked, sometimes they didn't—with no pattern.

**Problem**: The script used `datetime.now()` to compare against a maintenance window stored in UTC:

```python
# ❌ Bug: Comparing local time to UTC time
maintenance_start = datetime(2026, 1, 12, 2, 0, 0)  # Stored as UTC
if datetime.now() < maintenance_start:  # now() is local time!
    deploy()
```

For the UK team (UTC+0), it worked. For the US team (UTC-5), it failed because `now()` was 5 hours behind UTC.

**Solution**: Always use timezone-aware datetimes:

```python
from datetime import datetime, timezone

# ✅ Fixed: Both are UTC
maintenance_start = datetime(2026, 1, 12, 2, 0, 0, tzinfo=timezone.utc)
if datetime.now(timezone.utc) < maintenance_start:
    deploy()
```

**Outcome**: Zero timezone-related deployment failures since the fix.

---

## ❓ Interview Questions

1. **What's the difference between `datetime.now()` and `datetime.utcnow()`?**
   > `now()` returns local system time, `utcnow()` returns UTC time. However, both return "naive" (non-timezone-aware) objects. Best practice is `datetime.now(timezone.utc)` for timezone-aware UTC time.

2. **How do you parse a date string like "2026-01-12T17:30:00Z"?**
   > Replace the 'Z' with '+00:00' and use `fromisoformat()`: `datetime.fromisoformat("2026-01-12T17:30:00Z".replace("Z", "+00:00"))`. The 'Z' means UTC (Zulu time).

3. **What is a "naive" vs "aware" datetime object?**
   > "Naive" datetimes have no timezone info (`tzinfo=None`) and should be avoided in production. "Aware" datetimes include timezone information and can be safely compared and converted across timezones.

4. **How do you calculate the difference between two datetimes?**
   > Subtract them: `diff = end_time - start_time` returns a `timedelta` object. Use `diff.days`, `diff.seconds`, or `diff.total_seconds()` to get numeric values.

5. **What's the purpose of timedelta?**
   > `timedelta` represents a duration/difference between two dates. Use it for adding/subtracting time (`now + timedelta(days=7)`) and representing durations like "30 days" for comparisons.

6. **How do you handle timestamps in milliseconds (common in JavaScript/APIs)?**
   > Divide by 1000: `datetime.fromtimestamp(ms_timestamp / 1000)`. JavaScript's `Date.now()` returns milliseconds, while Python's `timestamp()` uses seconds.

---

## 🧠 Quiz

1. What method formats datetime to string?
   - a) `format()`
   - b) `strftime()` ✅
   - c) `to_string()`
   - d) `stringify()`

2. What represents duration between datetimes?
   - a) `duration`
   - b) `timedelta` ✅
   - c) `span`
   - d) `interval`

3. What does `%Y-%m-%d` format look like?
   - a) 26-01-12
   - b) 2026-01-12 ✅
   - c) 01/12/2026
   - d) Jan-12-2026

4. How do you get current UTC time (timezone-aware)?
   - a) `datetime.utcnow()`
   - b) `datetime.now(timezone.utc)` ✅
   - c) `datetime.now().utc()`
   - d) `datetime.utc()`

5. What does `datetime.fromisoformat()` parse?
   - a) Unix timestamp
   - b) ISO 8601 format string ✅
   - c) Any date string
   - d) JSON date

6. How do you add 7 days to a datetime?
   - a) `dt.add_days(7)`
   - b) `dt + timedelta(days=7)` ✅
   - c) `dt + 7`
   - d) `dt.plus(days=7)`

7. What's the format code for 12-hour time with AM/PM?
   - a) `%H:%M %p`
   - b) `%I:%M %p` ✅
   - c) `%T %p`
   - d) `%h:%m %a`

8. What does `strptime` stand for?
   - a) String print time
   - b) String parse time ✅
   - c) Standard parse time
   - d) System parse time

---

## 🔗 Related Topics

| Module | Relationship |
|--------|-------------|
| [Logging Basics](../14-Logging-Basics/README.md) | Timestamps in log messages |
| [Working with JSON](../06-Working-with-JSON/README.md) | Serialize/deserialize dates |
| [Regular Expressions](../13-Regular-Expressions/README.md) | Parse timestamps from logs |

---

**Next Step**: [Regular Expressions →](../13-Regular-Expressions/README.md)
