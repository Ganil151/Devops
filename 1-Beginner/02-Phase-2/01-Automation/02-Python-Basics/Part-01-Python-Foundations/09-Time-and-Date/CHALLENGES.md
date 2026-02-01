# 🎯 Time and Date - Challenges

> **"In DevOps, time is the dimension of auditing and availability. These challenges test your ability to coordinate scheduled tasks and monitor durations."**

---

## 🏆 Challenge 1: The Maintenance Window Check
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Determine if the current time falls within a specific maintenance window.

### Requirements
- Define a window: `02:00:00` to `04:00:00`.
- Get the current time.
- Print "System in Maintenance" or "Normal Operations" based on the check.

---

## 🏆 Challenge 2: The S3 Retention Calculator
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Identify files that are older than 90 days for archival.

### Requirements
- Input: A list of filenames and their "Creation Dates" (as strings like `2023-05-20`).
- Convert the strings to `datetime` objects.
- Calculate the "Age in Days" relative to today.
- Print: `file_x.zip is 105 days old. SHIFT TO GLACIER.`

---

## 🏆 Challenge 3: The Execution Timer (Decorator Pattern)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 40 minutes

### Objective
Measure how long a "Deployment Function" takes to run.

### Requirements
- Create a function `deploy_app()` that uses `time.sleep(2)` to simulate work.
- Use `time.perf_counter()` to capture start and end times.
- Print the total duration in seconds (formatted to 2 decimal places).
- **Challenge**: Wrap this logic in a decorator so it can be applied to any function.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Maintenance Window
- [ ] Challenge 2: Retention Calculator
- [ ] Challenge 3: Execution Timer
