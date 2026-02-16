# 🎯 Iterative Logic & Loops - Challenges

> **"Loops are the engines of automation. These challenges test your ability to build resilient, non-blocking iteration logic."**

---

## 🏆 Challenge 1: The Health Check Loop
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that pings a list of "Servers" and stops as soon as it finds one that is "DOWN".

### Requirements
- List: `["web-01", "web-02", "db-01", "web-03"]`.
- Manually set `db-01` as DOWN in your logic.
- Use a `for` loop.
- Use `break` once a failure is found.
- Print: `Checking <server>... OK` or `CRITICAL: <server> is DOWN. Terminating scan.`

---

## 🏆 Challenge 2: The Exponential Backoff (While Loop)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Simulate waiting for a Cloud Instance to start using a `while` loop with increasing wait times.

### Requirements
- Start with `wait_time = 1` second.
- Loop until `status == "READY"` (mock this after 4 attempts).
- Each loop: `wait_time = wait_time * 2`.
- Cap the loop at 5 attempts (to prevent infinite hanging).
- Print: `Attempt X: Instance not ready. Waiting Y seconds...`

---

## 🏆 Challenge 3: The Filtered Inventory (Nested Loops)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Process a complex list of dictionaries representing servers across regions.

### Requirements
- Input: A list of dicts. Each dict has `name`, `region`, and `status`.
- Task: Print ONLY the names of servers in the `us-east-1` region that are `active`.
- **Advanced**: Use a list comprehension to achieve the same result in one line.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Health Check Loop
- [ ] Challenge 2: Exponential Backoff
- [ ] Challenge 3: Filtered Inventory
