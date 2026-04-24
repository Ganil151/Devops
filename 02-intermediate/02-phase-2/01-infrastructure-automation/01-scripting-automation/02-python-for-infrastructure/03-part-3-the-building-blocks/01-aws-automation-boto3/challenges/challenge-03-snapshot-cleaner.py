"""
Challenge: Old Snapshot Cleaner
Scenario: You have thousands of EBS snapshots. To save costs, you must 
delete any snapshots older than 30 days that aren't tagged as 'Permanent'.

TODO: Implement `cleanup_old_snapshots(days=30)`.
1. Calculate the 'cutoff' date (today - days).
2. Use `boto3.resource('ec2')` to list snapshots 'owned by me'.
3. For each snapshot, check `start_time` and `tags`.
4. If it's older than the cutoff AND doesn't have a 'Permanent' tag, delete it.
5. Handle `ClientError` if the snapshot is in use by an AMI.
"""
import boto3
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

def cleanup_old_snapshots(days=30):
    """
    Deletes old EBS snapshots.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test would run here
    pass
