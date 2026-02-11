# ⏱️ Online Screening Strategies (HackerRank & Beyond)

Online Assessment (OA) tests are the first gate. They are often automated and time-bound. Use these tactics to stay in the top 5% of candidates.

---

## 🏗️ Common Platforms
- **HackerRank / Codility**: Standard algorithmic and logic tests.
- **GLIDER.ai**: Often includes live terminal environments for Linux/K8s troubleshooting.
- **CoderPad**: Usually for live paired-coding.

---

## 🚀 The 4-Step Strategy

### 1. The Environment Check
Before starting the timer:
- Ensure you have a stable internet connection.
- Have a local IDE ready (VS Code) to paste and test code if the platform allows it.
- Have your **[DevOps Cheat Sheets](../../../../08-resources/00-cheatsheets/cheatsheet.md)** open.

### 2. Read the "Hidden" Requirements
Platforms often hide edge cases in the description:
- "The input can be null." (Check for nulls!)
- "Memory limit is 128MB." (Avoid loading huge files into memory; use generators/streaming).
- "Execution time limit is 2 seconds." (Use efficient algorithms).

### 3. The "DevOps Twist"
Standard coding tests in DevOps often focus on:
- **String Manipulation**: Parsing logs, extracting IPs, or cleaning JSON data.
- **System Logic**: Calculating uptime, converting bytes to terabytes, or finding high-usage processes.
- **API Interaction**: Using `requests` (Python) or `curl` (Bash) to fetch and filter data.

### 4. Optimize for "Partial Credit"
If you can't solve the perfect solution, solve the "Brute Force" version first. 50% score is better than 0% because you ran out of time trying to be perfect.

---

## 🛡️ Avoiding "Plagiarism Flags"
Platforms detect patterns. **NEVER** copy-paste a solution directly from LLMs into the browser. 
- **The Correct Way**: Use AI to explain the logic → Write the code yourself → Manually type it into the browser window.

---

## 🎯 Pro Tip: The "Linux Terminal" Screener
If the test gives you a real Linux terminal (common in SRE roles):
- **Aliases are your friend**: `alias k=kubectl` saves seconds.
- **Use `grep` and `awk`**: Master these two commands; they solve 90% of log parsing problems in seconds.
- **Check the `history`**: If you get stuck on a command you just ran, but it worked partially, hit `history`.

---
*Back to [Assessment Hub](./readme.md)*
