#!/usr/bin/env python3
"""
Lab: The Cloud Zombie Hunter
Task: Identify unattached EBS volumes and tag them for cleanup.
Focus: Boto3, Idempotency, and Cost-Optimization.
"""

import boto3
from datetime import datetime, timedelta
from typing import List, Dict, Any

# --- Professional Standards: Type Hinting & Guard Clauses ---

def get_unattached_volumes(ec2_client: Any) -> List[str]:
    """
    🔍 Check: Find volumes that are 'available' (not attached to any instance).
    """
    response = ec2_client.describe_volumes(
        Filters=[{'Name': 'status', 'Values': ['available']}]
    )
    return [vol['VolumeId'] for vol in response['Volumes']]

def is_protected(ec2_client: Any, volume_id: str) -> bool:
    """
    🛡️ Guard Clause: Check if the volume has a 'Retention: Permanent' tag.
    """
    response = ec2_client.describe_tags(
        Filters=[{'Name': 'resource-id', 'Values': [volume_id]}]
    )
    for tag in response['Tags']:
        if tag['Key'] == 'Retention' and tag['Value'] == 'Permanent':
            return True
    return False

def tag_volume_for_cleanup(ec2_client: Any, volume_id: str) -> bool:
    """
    🚀 Act: Apply tags for cleanup process.
    This operation is Idempotent—running it twice just updates the same tags.
    """
    termination_date = (datetime.utcnow() + timedelta(days=7)).strftime('%Y-%m-%d')
    
    ec2_client.create_tags(
        Resources=[volume_id],
        Tags=[
            {'Key': 'Cleanup-Status', 'Value': 'Candidate'},
            {'Key': 'Termination-Date', 'Value': termination_date},
            {'Key': 'Audit-Source', 'Value': 'Zombie-Hunter-Automation'}
        ]
    )
    return True

def main():
    # In a real scenario, use profiles or env vars
    ec2 = boto3.client('ec2', region_name='us-east-1')
    
    print("🧟 Starting Cloud Zombie Hunter...")
    
    zombies = get_unattached_volumes(ec2)
    
    if not zombies:
        print("✅ No zombie volumes found. System is clean.")
        return

    print(f"👀 Found {len(zombies)} unattached volumes.")

    for vol_id in zombies:
        # Check Guard Clause
        if is_protected(ec2, vol_id):
            print(f"⏭️ Skipping {vol_id} (Protected by Retention policy).")
            continue
        
        # Act
        tag_volume_for_cleanup(ec2, vol_id)
        print(f"🏷️ Tagged {vol_id} for cleanup in 7 days.")

if __name__ == "__main__":
    # Note: Requires AWS credentials configured locally
    try:
        main()
    except Exception as e:
        print(f"❌ Error: {e}")
