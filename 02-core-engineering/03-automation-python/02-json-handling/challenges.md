# 🎯 JSON Handling: API Language Challenges

> **"Data is the oil of automation, and JSON is the pipeline. These challenges test your ability to refine and transport that data."**

---

## 🏆 Challenge 1: The Infrastructure Snapshot
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that takes a current system "snapshot" and saves it as a valid JSON file.

### Requirements
- Collect: `hostname`, `current_user`, and `disk_usage` (placeholder values are fine).
- Save to `snapshot.json` with 2-space indentation.
- Verification: Print the file size of `snapshot.json`.

---

## 🏆 Challenge 2: The Audit Log Streamer
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Convert a standard JSON list of logs into a high-performance `JSON Lines (.jsonl)` file.

### Requirements
- Start with a standard list of 5 dictionaries (logs).
- Save them to `audit.jsonl` (one JSON object per line).
- **Bonus**: Include a `datetime.now()` object in each log and use a **Custom Encoder** to handle it.

---

## 🏆 Challenge 3: The Production API Guard
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Build a "Validation Layer" that protects your script from malformed API responses.

### Requirements
- Input: A nested JSON string representing an "Inventory Update" (`{"region": "...", "nodes": [...]}`).
- Task: 
    1.  Validate that `region` is one of `['us-east-1', 'us-west-2', 'eu-central-1']`.
    2.  Use a **Schema** (either manual or `jsonschema` library) to ensure every node has an `id` and a `status`.
    3.  If validation fails, print a detailed report of what's missing instead of just crashing.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Infrastructure Snapshot
- [ ] Challenge 2: Audit Log Streamer
- [ ] Challenge 3: Production API Guard
