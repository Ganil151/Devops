# 🎯 Time & Date: Temporal Coordination Challenges

> **"Logs without timestamps are just noise. Deployments without schedules are just accidents. These challenges test your ability to master the fourth dimension of automation."**

---

## 🏆 Challenge 1: The Global Maintenance Guard
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 20 minutes

### Objective
Build a "Gatekeeper" script that checks if the current time in UTC falls within a scheduled maintenance window.

### Requirements
- Maintenance Window: `01:00 UTC` to `03:00 UTC`.
- Use `datetime.now(timezone.utc)` to get the current time.
- Check only the `hour` part of the time.
- Print: `⚠️ MAINTENANCE IN PROGRESS` or `✅ SERVICE OPERATIONAL`.
- **Constraint**: Your script must work correctly regardless of the local timezone of the machine running it.

---

## 🏆 Challenge 2: The S3 Object Expiry Auditor
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Calculate object retirement dates for a mock cloud storage bucket.

### Requirements
- Create a list of dictionaries representing S3 objects:
    ```python
    objects = [
        {"name": "backup_01.zip", "created": "2023-08-01T12:00:00Z"},
        {"name": "logs_july.tar.gz", "created": "2023-07-15T09:30:00Z"}
    ]
    ```
- Use `strptime()` to parse the ISO-8601 strings into timezone-aware datetime objects.
- Calculate the age in days using `(now - created).days`.
- If an object is **older than 30 days**, print: `[EXPIRED] [name] - [age] days old`.
- Otherwise, print: `[KEEP] [name] - [days_left] days until expiry`.

---

## 🏆 Challenge 3: The Deployment Latency Monitor
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Build a high-precision timer to measure the duration of automation tasks.

### Requirements
- Use **`time.perf_counter()`** for high-precision measurement (don't use `time.time()`).
- Simulate a task using `time.sleep(1.5)`.
- Use **`timedelta`** to format the result into `Minutes:Seconds.Milliseconds`.
- **Bonus (Staff Level)**: Write a "Context Manager" (using `__enter__` and `__exit__`) that allows you to time any block of code using:
    ```python
    with Timer() as t:
        run_my_task()
    print(f"Task took {t.duration} seconds")
    ```

---

## ✅ Completion Checklist
- [ ] Challenge 1: Global Maintenance Guard
- [ ] Challenge 2: S3 Expiry Auditor
- [ ] Challenge 3: Latency Monitor
