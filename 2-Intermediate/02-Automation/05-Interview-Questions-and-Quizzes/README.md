# Automation Interview Questions & Quiz

Solidify your understanding of automation and prepare for the technical screening.

---

## 🎤 Top 25 Automation Interview Questions

1.  **When should you automate a task?**
    - *Answer*: When a task is repetitive, error-prone when done manually, or needs to happen at a scale that humans cannot handle (Toil reduction).
2.  **What is an Idempotent script?**
    - *Answer*: A script that can be run multiple times on a system and leave it in the same state without causing unintended side effects.
3.  **Bash vs. Python: When to use which?**
    - *Answer*: Use Bash for simple OS tasks, file manipulation, and "glue" logic. Use Python for complex logic, API integrations, and tasks requiring external libraries/SDKs.
4.  **What does `set -e` do in a Bash script?**
    - *Answer*: It causes the script to exit immediately if any command returns a non-zero exit status (Fail-Fast).
5.  **What is a "Shebang" line and why is it important?**
    - *Answer*: The first line (`#!/bin/bash`). It tells the kernel which interpreter to use to execute the script, ensuring portability.
6.  **How do you check if the previous command was successful?**
    - *Answer*: By checking the `$?` variable. A value of `0` indicates success.
7.  **Explain the difference between `>` and `>>`.**
    - *Answer*: `>` overwrites the file; `>>` appends to the file.
8.  **What is the purpose of the `xargs` command?**
    - *Answer*: It builds and executes command lines from standard input, often used to parallelize tasks or handle large file lists.
9.  **What is Boto3?**
    - *Answer*: The official AWS SDK (Software Development Kit) for Python, used for programmatic cloud management.
10. **How do you handle API errors in a Python script?**
    - *Answer*: Using `try/except` blocks to catch specific exceptions from libraries like `requests` or `botocore`.
11. **What is `jq` and why is it essential for DevOps?**
    - *Answer*: `jq` is a command-line JSON processor. It allows for robust parsing of API responses in shell scripts.
12. **What is a "Dry Run"?**
    - *Answer*: A execution mode that reports what changes *would* be made without actually modifying the system state.
13. **How do you prevent a script from running concurrently?**
    - *Answer*: Using "lock files" or the `flock` utility to ensure only one instance of the script runs at a time.
14. **What is "Toil" in SRE terms?**
    - *Answer*: Manual, repetitive, automatable work that provides no long-term value and scales linearly with service size.
15. **What is a "Cron Job"?**
    - *Answer*: A time-based job scheduler in Unix-like systems used to execute scripts at fixed intervals.
16. **Explain 'Environment Variables' and how they are used in automation.**
    - *Answer*: Dynamic values that can affect the behavior of running processes (e.g., `PATH`, `USER`). They are used to pass configurations and secrets to scripts without hardcoding them.
17. **What is 'Standard Error' (stderr) and how do you redirect it to a file?**
    - *Answer*: It is the stream used for error messages (file descriptor 2). Redirected using `2> filename`.
18. **What is 'Standard Input' (stdin) and how do you pipe data?**
    - *Answer*: The stream for input data (file descriptor 0). Data is piped using the `|` symbol.
19. **Explain the 'Fail-Fast' mechanism.**
    - *Answer*: Designing scripts to stop immediately upon encountering an error (`set -e`) to prevent secondary damage or data corruption.
20. **What is 'Atomic' file editing?**
    - *Answer*: Writing to a temporary file first and then moving/renaming it to the target location to ensure the file is never "partially" written if the script crashes.
21. **How do you debug a Bash script?**
    - *Answer*: Run it using `bash -x script.sh` or add `set -x` at the top of the script to see every command as it executes.
22. **What is a 'Virtual Environment' in Python?**
    - *Answer*: An isolated environment that allows you to install specific package versions for a project without affecting the global system.
23. **How do you find and replace text in a file using the CLI?**
    - *Answer*: Using `sed -i 's/old/new/g' filename`.
24. **What is 'Shift-Left' in the context of automation testing?**
    - *Answer*: Moving testing and validation earlier in the development lifecycle (e.g., using unit tests and linters on scripts).
25. **How do you handle 'Secrets' like API keys in automation?**
    - *Answer*: Never hardcode them. Use Secrets Managers, Encrypted Environment Variables (CI/CD), or Vault tools.

---

## 🧠 Automation Knowledge Quiz (25 Questions)

<b>1. What is the exit code of a successful command?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. Which file descriptor represents 'Standard Error'?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>3. In Python, which library is the standard for making HTTP requests?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. What does the `trap` command do in Bash?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which flag is used for 'Check Mode' (Dry Run) in many automation tools?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. To make a script executable, you use:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>7. In Bash, how do you access the Process ID (PID) of the current script?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>8. Which tool is best for parsing JSON in the command line?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>9. 'set -u' helps prevent errors related to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. 'Toil Reduction' is a concept from which discipline?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which Python block ensures resources like files are closed automatically?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>12. What is the Shebang for a Python 3 script using 'env' for portability?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. In Bash, '2>&1' redirects:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. An 'Atomic' operation is one that is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. A `crontab` entry `0 0 * * *` means a script runs:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>16. Which Bash command searches for text patterns within files?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>17. What is the purpose of 'pip'?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. In Bash, `[[ -f "file.txt" ]]` checks if:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. 'Idempotency' is a core pattern in:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. A 'Virtual Environment' in Python is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>21. Which command shows all environment variables?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. How do you append text to a file ('foo.txt') without overwriting?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. 'set -o pipefail' is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. Which Boto3 object is the high-level representation of an AWS service?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>25. 'Dry Run' mode is essential for _____ before large deployments.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>
