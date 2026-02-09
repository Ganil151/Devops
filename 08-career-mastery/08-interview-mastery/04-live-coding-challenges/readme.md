# 💻 Live Coding & Automated Screeners

DevOps coding interviews aren't about reversing binary trees. They are about **File Manipulation**, **API Interaction**, and **Log Parsing**.

---

## 🐍 Challenge 1: The Log File Analyzer (Python/Bash)
**The Task:** "Write a script that reads an Nginx access log, finds the top 5 most frequent IP addresses, and saves them to a file."

### 🧠 The Solution (Python)
```python
from collections import Counter

def find_top_ips(logfile):
    with open(logfile, 'r') as f:
        ips = [line.split()[0] for line in f if line.strip()]
    
    top_5 = Counter(ips).most_common(5)
    
    with open('top_ips.txt', 'w') as out:
        for ip, count in top_5:
            out.write(f"{ip}: {count}\n")

# Interviewer's Secret: They want to see if you can handle 
# large files (using a generator instead of loading the whole list).
```

---

## ☁️ Challenge 2: The S3 Cleanup Script (Boto3)
**The Task:** "Write a Python script to delete all objects in an S3 bucket that were created more than 30 days ago."

### 🧠 The Solution (Python + Boto3)
```python
import boto3
from datetime import datetime, timedelta, timezone

s3 = boto3.resource('s3')
bucket = s3.Bucket('my-temp-data')

cutoff = datetime.now(timezone.utc) - timedelta(days=30)

for obj in bucket.objects.all():
    if obj.last_modified < cutoff:
        obj.delete()
        print(f"Deleted {obj.key}")

# Interviewer's Secret: They are checking for 'Data Safety'. 
# A Senior candidate would mention 'Dry Run' mode first.
```

---

## 🐧 Challenge 3: Disk Space & SSH Alert (Bash)
**The Task:** "Write a script that checks if disk usage on `/` is over 90% and sends an email if it is."

### 🧠 The Solution (Bash)
```bash
#!/bin/bash
THRESHOLD=90
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "DISK ALERT: Usage is at $USAGE%" | mail -s "Production Alert" admin@company.com
fi

# Interviewer's Secret: They are testing your knowledge of 
# piping and system utilities (df, awk, grep).
```

---

## 🛠️ The "Hiring Manager" Coding Checklist
- **Readability**: Are there comments? Are variables named `i` or `instance_id`?
- **Error Handling**: What happens if the file doesn't exist?
- **Edge Cases**: What if the log file is 100GB? (Hint: Use `readline` or streaming).
- **Tooling Choice**: "I chose Python here because the logic requires complex dictionary grouping; for simple strings, I'd use `awk`."
