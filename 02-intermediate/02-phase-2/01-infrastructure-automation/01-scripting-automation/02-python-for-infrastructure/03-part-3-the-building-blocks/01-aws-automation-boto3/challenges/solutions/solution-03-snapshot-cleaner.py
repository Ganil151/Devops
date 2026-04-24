"""
Solution: Old Snapshot Cleaner
"""
import boto3
from datetime import datetime, timedelta, timezone
from botocore.exceptions import ClientError

def cleanup_old_snapshots(days=30):
    ec2 = boto3.resource('ec2')
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    deleted_count = 0
    
    # Filter snapshots owned by current account
    for snapshot in ec2.snapshots.filter(OwnerIds=['self']):
        # Check date
        if snapshot.start_time < cutoff:
            # Check tags
            tags = snapshot.tags or []
            is_permanent = any(t['Key'] == 'Permanent' for t in tags)
            
            if not is_permanent:
                try:
                    print(f"Deleting old snapshot: {snapshot.id}")
                    snapshot.delete()
                    deleted_count += 1
                except ClientError as e:
                    print(f"Could not delete {snapshot.id}: {e}")
                    
    return deleted_count

if __name__ == "__main__":
    # Test would run here
    pass
