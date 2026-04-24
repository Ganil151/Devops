# 🏆 Automation Challenges

## 🟢 Level 1: The Bootstrapper (Bash)
**Task**: Write a user-data script for an EC2 instance that:
1.  Updates all packages.
2.  Installs Docker and Git.
3.  Clones a repository.
4.  Starts a docker container.
**Constraint**: Script must include `set -euo pipefail` and log all output to `/var/log/user-data.log`.

---

## 🟡 Level 2: The Log Parser (Bash/Awk)
**Task**: Parsing a massive Nginx access log.
1.  Identify the Top 10 IP addresses by request count.
2.  Identify the number of 500 errors.
**Constraint**: Use `awk` and `sort`. No Python allowed.

---

## 🟠 Level 3: The Cleaner (Python/Boto3)
**Task**: EBS Snapshot cleanup.
1.  List all EBS snapshots owned by your account.
2.  Check if the snapshot is associated with an AMI.
3.  If not associated and older than 30 days, delete it.
4.  Dry Run mode by default; require `--force` flag to delete.

---

## 🔴 Level 4: The Auto-Remediator (Python Lambda)
**Task**: Security Group Watchdog.
1.  Trigger on CloudWatch Event "Security Group Change".
2.  Check if port 22 (SSH) is open to 0.0.0.0/0.
3.  If found, revoke that specific rule via Boto3.
4.  Send an SNS notification to the admin.
