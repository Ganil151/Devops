# 🎯 Regular Expressions: The Precision Scalpel Challenges

> **"Infrastructure logs are a chaotic sea of unstructured text. These challenges test your ability to surgically extract the signal from the noise."**

---

## 🏆 Challenge 1: The Multi-IP & Port Extractor
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Extract both IP addresses and Port numbers from a firewall log string.

### Requirements
- Input: `Allow 192.168.1.1:80 from 10.0.0.5:443 (TCP ACK)`
- Pattern: Use a single regex with two capture groups (one for IP, one for Port).
- Output: A list of tuples `[('192.168.1.1', '80'), ('10.0.0.5', '443')]`.
- **Constraint**: Use `re.findall()` with a pattern like `([\d\.]+):(\d+)`.

---

## 🏆 Challenge 2: The High-Performance Log Parser
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Parse 100+ raw log lines into a list of structured dictionaries using a **Compiled Regex**.

### Requirements
- Log Format: `[2026-02-01 12:00:00] [LEVEL] <SERVICE> Message`
- Create a **Compiled Regex Object** (`re.compile`) with Named Groups: `timestamp`, `level`, `service`, `message`.
- Loop through a provided list of lines and append each `match.groupdict()` to a results list.
- **Verification**: Ensure the `level` matches even if it's lowercase (use `re.IGNORECASE`).

---

## 🏆 Challenge 3: The API Secret Scrubber
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Build a "Pre-processing" function that redacts multi-type secrets (Passwords, API Keys, and SSH Keys).

### Requirements
- Input:
    ```
    api_key='sk_test_12345'
    password="my-secure-pass"
    ssh-rsa AAAAB3Nza...[long key]... user@host
    ```
- Write a function `scrub_secrets(text)` that:
    1. Replaces values inside quotes after `api_key=` or `password=` with `[REDACTED]`.
    2. Replaces any string starting with `ssh-rsa` and ending with more than 50 characters with `[SSH-KEY-REMOVED]`.
- **Constraint**: Must use a **Non-Greedy** match (`.*?`) to avoid deleting the entire line if multiple secrets exist.

---

## ✅ Completion Checklist
- [ ] Challenge 1: IP & Port Extractor
- [ ] Challenge 2: High-Performance Parser
- [ ] Challenge 3: API Secret Scrubber
