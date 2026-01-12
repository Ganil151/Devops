# Automation Real-Life Scenarios: Practical Challenges

Put your scripting skills into practice with these real-world DevOps challenges. Every scenario here is based on a real production crisis.

---

## 🏗️ Scenario 1: The "Recursive Delete" Safety Guard
**Problem**: A cleanup script was designed to run `rm -rf $DIR/*`. However, if the variable `$DIR` was empty due to an upstream failure, the command would evaluate to `rm -rf /*`, deleting the entire OS.
**Crisis**: This almost happened in a staging environment when a config file was corrupted.
**Outcome**: High risk of catastrophic data loss.
**Solution**: Implement protective expansion. Use `${DIR:?Variable not set}` or a check: `[[ -n "$DIR" ]] && rm -rf "$DIR"/*`.
**Result**: The script now fails safely if the target directory is undefined.

---

## 🏗️ Scenario 2: Log Parser for Error Detection
**Problem**: Your application logs are huge (10GB+). You need to find all unique Error messages from the last 24 hours to identify a recurring bug.
**The Command (Bash)**:
```bash
grep "ERROR" /var/log/app.log | awk '{print $5, $6}' | sort | uniq -c | sort -nr
```
**Goal**: Use the "Big Three" of Bash (`grep`, `awk`, `sort`) to turn raw text into actionable data.
**Outcome**: The team identified that 90% of errors were related to a single database timeout.
**Result**: The database was scaled, and error rates dropped by 95%.

---

## 🌩️ Scenario 3: Automated Cloud Cleanup (The Cost Saver)
**Problem**: Developers are launching EC2 instances for testing but forgetting to tag them or turn them off, leading to $2,000/month in waste.
**The Script (Python/Boto3)**:
```python
import boto3
ec2 = boto3.client('ec2')

# Find instances without an 'Environment' tag
instances = ec2.describe_instances()
for reservation in instances['Reservations']:
    for instance in reservation['Instances']:
        has_tag = any(t['Key'] == 'Environment' for t in instance.get('Tags', []))
        if not has_tag:
            print(f"Stopping untagged instance: {instance['InstanceId']}")
            ec2.stop_instances(InstanceIds=[instance['InstanceId']])
```
**Goal**: Use Python to enforce governance and save costs automatically.
**Result**: Monthly AWS costs were reduced by 30% within the first week.

---

## 🏗️ Scenario 4: The "Race Condition" Lock
**Problem**: A file-processing script was running via a high-frequency cron (every 1 minute). Occasionally, a large file would take 90 seconds to process.
**Crisis**: The second script would start while the first was still working, leading to duplicate database entries and file corruption.
**Solution**: Use an **Atomic Lockfile**.
```bash
exec 200>/var/lock/process_files.lock
flock -n 200 || exit 1
# ... main script logic here ...
```
**Result**: Only one script can run at a time; if another starts, it exits immediately.

---

## 🏗️ Scenario 5: The "API Rate Limit" Backoff
**Problem**: A monitoring script was fetching data from a third-party API. During peak hours, the API would return a `429 Too Many Requests` error.
**Crisis**: The script would crash, leaving the team blind to system metrics during high traffic.
**Solution**: Implement exponential backoff in Python using the `requests` library.
**Result**: The script now waits and retries intelligently, maintaining visibility even during API throttling.

---

## 🏗️ Scenario 6: The "Atomic Config Update"
**Problem**: An automation script was updating a critical configuration file on 1,000 servers.
**Crisis**: If the script was interrupted (e.g., network failure) while writing the file, the file would be truncated or corrupted.
**Solution**: The **"Temp-and-Move"** pattern.
```bash
# Write to temp file first
generate_config > config.conf.tmp
# Verify temp file is not empty
[[ -s config.conf.tmp ]] && mv config.conf.tmp config.conf
```
**Result**: The critical config is either completely updated or remains at the old version; it is never "half-baked."

---

## ❓ Interview Questions

1.  **How do you handle 'Recursive Safety' in a destructive shell script?**
    - *Answer*: Use `${VAR:?error message}` which causes the script to exit if VAR is unset, or use explicit directory checks (e.g., `[[ -d "$DIR" ]]`) before running `rm`.
2.  **Explain the 'Temp-and-Move' pattern for atomic file operations.**
    - *Answer*: You write the new content to a temporary file, verify its integrity (e.g., size check), and then use the `mv` command to overwrite the target. Since `mv` is an atomic system call in Linux, the file is never in a partially-written state.
3.  **What is a 'Race Condition' in automation, and how do you solve it?**
    - *Answer*: A race condition occurs when two or more processes try to modify the same resource at the same time. It is solved using locking mechanisms like `flock` or lock-files.
4.  **Why is `jq` better than `grep` for parsing JSON?**
    - *Answer*: JSON is a structured format that can span multiple lines and change its field order. `grep` is line-based and fragile. `jq` parses the entire object structure and queries it logically.
5.  **How do you ensure an automation script is 'Safe to re-run' (Idempotent)?**
    - *Answer*: Always check the state before acting. For example, instead of `mkdir /data`, use `[[ ! -d "/data" ]] && mkdir /data` or simply `mkdir -p /data`.
6.  **What is the benefit of 'Exponential Backoff' in API automation?**
    - *Answer*: It prevents your script from "spamming" an already overloaded API. By waiting longer between each retry, you give the service time to recover and increase the chance of a successful request.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. Which command is used to delete files older than 7 days?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>2. True/False: 'mv' is an atomic operation on most Linux filesystems.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>3. Which operator stores the output of a command into a variable in Bash?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>4. 'flock -n' tells the script to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>5. Which JQ filter selects an object based on a value?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>6. 'set -o pipefail' ensures that:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>7. True/False: You should use 'os.system' for all Python automation.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>8. Which tool is best for column-based log analysis?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>9. In SRE, 'Toil' refers to work that is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>10. A 'Lockfile' is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>11. Which Python library is used to interact with AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>12. 'Pre-flight' checks are performed:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>13. How do you redirect BOTH stdout and stderr to the same file?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>14. True/False: Single quotes allow for variable expansion in Bash.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>15. Which character represents 'Standard Input'?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>16. 'Exponential Backoff' means the wait time:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>17. 'Linter' tools like ShellCheck help you find:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>18. Which Bash loop is best for processing lines from a file?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>19. What does 'pip install -e .' do?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>20. True/False: Automating a bad process just makes a bad process run faster.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>21. Which command shows all currently running background jobs?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>22. 'SIGTERM' (Signal 15) is a request for the process to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>23. How do you capture the output of a command into a Bash array?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>




<b>24. 'Zero-Toil' is a theoretical state where _____ is manual.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>




<b>25. A script is only as good as its _____ coverage.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>



