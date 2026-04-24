# 🎯 File I/O - Challenges

> **"Data persistence is the memory of automation. These challenges test your ability to read from and write to the system safely."**

---

## 🏆 Challenge 1: The Log Rotator (Simulated)
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Store a list of log messages into a file.

### Requirements
- Create a list: `["[INFO] System Boot", "[INFO] Service Started", "[ERROR] DB Timeout"]`.
- Open a file `app.log` in **write mode**.
- Write each message on a new line.
- Verify the file exists and has 3 lines.

---

## 🏆 Challenge 2: The Audit Log Parser
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 25 minutes

### Objective
Read a log file and extract only the "ERROR" lines to a new "critical.log" file.

### Requirements
- Create a sample `audit.log` with mixed INFO and ERROR levels.
- Read `audit.log` line by line.
- If a line contains "ERROR", append it to `critical.log`.
- Use the `with` statement for both files.

---

## 🏆 Challenge 3: The Config Comparer
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 40 minutes

### Objective
Compare two hostfiles (`hosts_old.txt` and `hosts_new.txt`) and identify which IPs were added.

### Requirements
- File A: `192.168.1.1`, `192.168.1.2`.
- File B: `192.168.1.1`, `192.168.1.2`, `192.168.1.3`.
- Task: Read both files, convert them to `sets`, and find the symmetric difference.
- Print: "New IP detected: 192.168.1.3".

---

## ✅ Completion Checklist
- [ ] Challenge 1: Log Rotator
- [ ] Challenge 2: Audit Log Parser
- [ ] Challenge 3: Config Comparer
