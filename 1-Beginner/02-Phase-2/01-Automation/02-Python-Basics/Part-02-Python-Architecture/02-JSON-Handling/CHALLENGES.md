# 🎯 JSON Handling: API Language Challenges

> **"Data is the oil of automation, and JSON is the pipeline. These challenges test your ability to refine and transport that data."**

---

## 🏆 Challenge 1: The Config Generator
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that converts a Python dictionary into a formatted `config.json` file.

### Requirements
- Create a dictionary representing server settings (port, host, debug_mode).
- Save it to `config.json` with an indentation of 4 spaces.
- Read it back immediately and print the "host" value to verify.

---

## 🏆 Challenge 2: The Log Transmogrifier
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Convert a list of flat strings into a structured JSON log file.

### Requirements
- Input: `["2024-01-01 ERROR DB_FAILED", "2024-01-01 INFO STARTING"]`.
- Output: A JSON file where each entry is an object: `{"date": "...", "level": "...", "message": "..."}`.
- Sort the final list by "level" (alphabetical) before saving.

---

## 🏆 Challenge 3: The API Response Validator
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Simulate an API response and extract nested data safely.

### Requirements
- Use a complex nested JSON string (e.g., a list of users, where each user has a list of 'roles').
- Create a script that finds all users with the role "admin".
- Handle cases where the "roles" key might be missing for some users without the script crashing (use `.get()`).

---

## ✅ Completion Checklist
- [ ] Challenge 1: Config Generator
- [ ] Challenge 2: Log Transmogrifier
- [ ] Challenge 3: API Response Validator
