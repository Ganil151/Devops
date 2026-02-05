# 🛠️ Cloud Cost Challenges

## Challenge 1: The Idle Watchdog
**Objective**: Identify idle CPU.
1.  Use CloudWatch metrics.
2.  Find instances where maximum CPU utilization < 2% for 7 days.
3.  Print the IDs of these "Idle" instances.

## Challenge 2: Snapshot Pruner
**Objective**: Delete old data.
1.  List all EBS Snapshots.
2.  Filter for snapshots older than 30 days.
3.  **Safety**: Ensure you do NOT delete snapshots that have a `Protect: True` tag.

## Challenge 3: Public IP Audit
**Objective**: Security and Cost.
1.  Public IPv4 addresses cost money in AWS now.
2.  Find all instances that have a Public IP address but are NOT in the `Public-Subnet`.
3.  Flag these for review.
