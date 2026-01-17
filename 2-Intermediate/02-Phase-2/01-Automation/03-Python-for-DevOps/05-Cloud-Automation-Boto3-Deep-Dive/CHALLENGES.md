# 🛠️ Cloud Automation Challenges

## Challenge 1: The S3 Cleaner
**Objective**: Find and delete old files.
1.  Connect to S3 using Boto3.
2.  List objects in a specific bucket.
3.  Check `LastModified` date.
4.  If older than 30 days, print "Deleting..." (use `--dry-run` logic).
5.  **Bonus**: Use Paginators for buckets with >1000 items.

## Challenge 2: EC2 Stopper
**Objective**: Stop Dev instances at night.
1.  Connect to EC2 resource (`boto3.resource("ec2")`).
2.  Filter instances with tag `Environment=Dev` AND state `running`.
3.  Print their Instance IDs.
4.  Call `.stop()` on them.
5.  Handle exceptions (e.g., instance changes state during script).

## Challenge 3: Snapshot Auditor
**Objective**: Find unencrypted snapshots.
1.  List all EBS snapshots owned by `self`.
2.  Check the `Encrypted` boolean field.
3.  If `False`, add to a list `risk_snapshots`.
4.  Generate a JSON report of ID and Volume Size.
