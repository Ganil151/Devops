Put your scripting skills into practice with these real-world DevOps challenges.

---

## 🛠️ Scenario 1: Automated Backup Rotation
**Problem:** Your database backup script is filling up the disk. It creates a `.sql` dump every night, but never deletes old ones.

**The Script (Bash):**
```bash
#!/bin/bash
BACKUP_DIR="/backups/db"
RETENTION_DAYS=7

# Delete backups older than 7 days
find $BACKUP_DIR -name "*.sql" -type f -mtime +$RETENTION_DAYS -delete

# Send notification if cleanup failed
if [ $? -ne 0 ]; then
    echo "Cleanup failed!" | mail -s "Backup Alert" admin@myapp.com
fi
```
**Goal**: Implement a safe, automated cleanup process using `find` and exit codes.

---

## 🏗️ Scenario 2: Log Parser for Error Detection
**Problem:** Your application logs are huge. You need to find all unique Error messages from the last 24 hours to identify a recurring bug.

**The Command (Bash):**
```bash
grep "ERROR" /var/log/app.log | awk '{print $5, $6}' | sort | uniq -c | sort -nr
```
**Goal**: Use the "Big Three" of Bash (`grep`, `awk`, `sort`) to turn raw text into actionable data.

---

## 🌩️ Scenario 3: Automated Cloud Cleanup (The Cost Saver)
**Problem:** Developers are launching EC2 instances for testing but forgetting to tag them or turn them off, leading to high monthly costs.

**The Script (Python/Boto3):**
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
**Goal**: Use Python to interact with Cloud APIs to enforce governance and save costs automatically.

---

## 🔄 Scenario 4: Webhook Listener (ChatOps)
**Problem:** Your team wants to trigger an infrastructure status check by typing a command in Slack.

**The Solution:**
1. Write a small Python script (using `Flask`) that listens for an incoming HTTP POST from Slack.
2. The script parses the command (e.g., `/check-db`).
3. The script executes a local bash command (`sh check_db_health.sh`).
4. The script sends the result back to Slack via a webhook.

**Goal**: Move automation from "scripts on a server" to a collaborative interface.

---

## 💡 Key Takeaway
Real-world automation is rarely just one script. It's a combination of **listening** for events (webhooks, cron), **processing** data (awk, Python), and **execuring** changes (Boto3, SSH).
