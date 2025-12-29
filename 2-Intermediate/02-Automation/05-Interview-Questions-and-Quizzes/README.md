# Automation Interview Questions & Quiz

Solidify your understanding of automation and prepare for the technical screening.

---

## 🎤 Top 15 Automation Interview Questions

### 🔰 General Questions
1. **When should you automate a task?**
   - *Answer:* When a task is repetitive, error-prone when done manually, or needs to happen at a scale that humans cannot handle.
2. **What is an Idempotent script?**
   - *Answer:* A script that can be run multiple times on a system and leave it in the same state without causing side effects.
3. **Bash vs. Python: When to use which?**
   - *Answer:* Use Bash for simple OS tasks, file manipulation, and "glue" logic. Use Python for complex logic, API integrations, and tasks requiring external libraries.

### ⚙️ Shell Scripting Questions
4. **What does `set -e` do in a Bash script?**
   - *Answer:* It causes the script to exit immediately if any command returns a non-zero exit status.
5. **What is a "Shebang" line and why is it important?**
   - *Answer:* The first line (`#!/bin/bash`). It tells the kernel which interpreter to use to execute the script.
6. **How do you check if the previous command was successful?**
   - *Answer:* By checking the `$?` variable. A value of `0` indicates success.
7. **Explain the difference between `>` and `>>`.**
   - *Answer:* `>` overwrites the file; `>>` appends to the file.
8. **What is the purpose of the `xargs` command?**
   - *Answer:* It builds and executes command lines from standard input (useful for processing lists of files or results from `find`).

### 🚀 Python & Advanced Questions
9. **What is Boto3?**
   - *Answer:* The official AWS SDK (Software Development Kit) for Python.
10. **How do you handle API errors in a Python script?**
    - *Answer:* Using `try/except` blocks to catch specific exceptions from the AWS SDK or the `requests` library.
11. **What is `jq` and why is it essential for DevOps?**
    - *Answer:* `jq` is a lightweight command-line JSON processor. It's essential for parsing the output of many cloud CLIs and APIs.
12. **What is a "Dry Run"?**
    - *Answer:* A mode where the script reports what changes it *would* make without actually applying them.
13. **How do you prevent a script from running concurrently?**
    - *Answer:* Using "lock files" or specific tools like `flock`.
14. **What is "Toil" in SRE/DevOps terms?**
    - *Answer:* Manual, repetitive, automatable work that provides no long-term value.
15. **What is a "Cron Job"?**
    - *Answer:* A time-based job scheduler in Unix-like operating systems used to run scripts at specific intervals.

---

## 🧠 Automation Knowledge Quiz

**1. What is the exit code of a successful command?**
- A) 1
- B) 0
- C) -1
- D) 200
*Answer: B*

**2. Which character represents "Standard Error"?**
- A) 1
- B) 0
- C) 2
- D) &
*Answer: C*

**3. In Python, which library is the standard for making HTTP requests?**
- A) `curl`
- B) `urlib`
- C) `requests`
- D) `http-lib`
*Answer: C*

**4. What does the `trap` command do in Bash?**
- A) It catches security threats
- B) It executes a command when the script receives a signal (like a crash or interrupt)
- C) It keeps the script running forever
- D) It encrypts the script
*Answer: B*

**5. Which flag is used to run an Ansible playbook in "Check Mode"?**
- A) `--verify`
- B) `--dry-run`
- C) `--check`
- D) `--test`
*Answer: C (Note: Related to general automation best practices)*

**6. To make a script executable, you use:**
- A) `chmod +x script.sh`
- B) `run script.sh`
- C) `edit +x script.sh`
- D) `sh +x script.sh`
*Answer: A*

**7. In Bash, how do you access the second argument passed to a script?**
- A) `$0`
- B) `$1`
- C) `$2`
- D) `$arg2`
*Answer: C*

**8. Which tool is best for parsing JSON in the command line?**
- A) `grep`
- B) `sed`
- C) `jq`
- D) `cut`
*Answer: C*

**9. What is a "Static Inventory"?**
- A) A list of servers stored in a text file
- B) A list of servers pulled from an API
- C) A server that never reboots
- D) An IP address that changes
*Answer: A*

**10. "Toil Reduction" is a primary goal of:**
- A) Marketing
- B) SRE (Site Reliability Engineering)
- C) Accounting
- D) HR
*Answer: B*

**11. Which Python block is used to manage resources like files (ensuring they close)?**
- A) `while`
- B) `with`
- C) `for`
- D) `global`
*Answer: B*

**12. What is the Shebang for a Python 3 script?**
- A) `#!/bin/python`
- B) `#!/usr/bin/env python3`
- C) `#!python`
- D) `#!3`
*Answer: B*

**13. In Bash, `2>&1` means:**
- A) Multiply 2 by 1
- B) Redirect standard error to standard output
- C) Redirect standard output to standard error
- D) Exit the script
*Answer: B*

**14. What does "Agentless" mean?**
- A) It doesn't use agents/spies
- B) It requires no software to be installed on the managed node
- C) It only works on Windows
- D) It's free
*Answer: B*

**15. A `crontab` entry `* * * * *` means a script runs:**
- A) Once a month
- B) Every hour
- C) Every minute
- D) Every day at midnight
*Answer: C*

**16. Which Bash command lets you search for text within files?**
- A) `find`
- B) `grep`
- C) `locate`
- D) `ls`
*Answer: B*

**17. What is the purpose of `pip`?**
- A) Running Python scripts
- B) Managing Python packages/libraries
- C) Compiling code
- D) Debugging
*Answer: B*

**18. In Bash, `[[ -d "/tmp" ]]` checks if:**
- A) `/tmp` is a file
- B) `/tmp` is a directory
- C) `/tmp` exists
- D) `/tmp` is empty
*Answer: B*

**19. What is "Human Toil"?**
- A) Working long hours
- B) Repetitive, manual tasks with no lasting value
- C) Learning new skills
- D) Design work
*Answer: B*

**20. A "Virtual Environment" in Python is used to:**
- A) Run code in the cloud
- B) Isolate project dependencies
- C) Speed up the CPU
- D) Secure the internet
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 15 Interview Questions
- [x] Understand the difference between Bash and Python use cases
