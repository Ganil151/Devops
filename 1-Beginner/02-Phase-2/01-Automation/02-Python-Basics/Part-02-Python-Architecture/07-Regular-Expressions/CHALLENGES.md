# 🎯 Regular Expressions: The Scalpel Challenges

> **"Logs are the messy history of a system. Regex is the light that finds the truth within them. These challenges test your surgical precision with strings."**

---

## 🏆 Challenge 1: The IP Extractor
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Extract all IP addresses from a text-based firewall log.

### Requirements
- Input string: `Attempt from 192.168.1.1 blocked. Success from 10.0.0.5 on port 80.`
- Pattern: Matches 4 sets of numbers separated by dots.
- Output: A list `['192.168.1.1', '10.0.0.5']`.

### Hints
- Use `re.findall()`.
- Pattern hint: `\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`.

---

## 🏆 Challenge 2: The Structured Log Parser
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Convert a raw log line into a Python Dictionary using **Named Capture Groups**.

### Requirements
- Log: `Feb 01 12:00:00 [ERROR] DB-01: Connection Timeout`
- Pattern: Use `(?P<name>...)` to capture Date, Level, Host, and Message.
- Output: `{'date': 'Feb 01 12:00:00', 'level': 'ERROR', 'host': 'DB-01', 'msg': 'Connection Timeout'}`.

---

## 🏆 Challenge 3: PII Masking (Redaction)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 40 minutes

### Objective
Scrub sensitive information (Credit Cards / Passwords) from a log file before it is sent to a monitoring tool.

### Requirements
- Input: `User 1234-5678-1234-5678 with password 'Secret123' changed their email.`
- Action 1: Replace any 16-digit dashed number with `****-****-****-****`.
- Action 2: Replace any string after `password '...'` with `password '********'`.
- Output: `User ****-****-****-**** with password '********' changed their email.`

### Hints
- Use `re.sub()`.

---

## ✅ Completion Checklist
- [ ] Challenge 1: IP Extractor
- [ ] Challenge 2: Log Parser
- [ ] Challenge 3: PII Masking
