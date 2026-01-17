#!/usr/bin/env python3
"""
Name: ec2_enforcer.py
Description: Enforces tagging policies and stops non-compliant instances.
"""

import boto3
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("governance")

def enforce_tagging():
    ec2 = boto3.resource('ec2')
    
    # 1. Find all running instances
    instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    
    for instance in instances:
        # 2. Get Tags
        tags = {tag['Key']: tag['Value'] for tag in (instance.tags or [])}
        
        # 3. Check for specific tag
        if 'Project' not in tags:
            logger.warning(f"VIOLATION: Instance {instance.id} is running without a 'Project' tag!")
            
            # 4. ACT: (In production, you might send a Slack alert or stop the instance)
            # instance.stop()
            # logger.info(f"ACTION: Stopped instance {instance.id}")
        else:
            logger.info(f"COMPLIANT: Instance {instance.id} (Project: {tags['Project']})")

if __name__ == "__main__":
    # Note: Requires AWS credentials configured (AWS_ACCESS_KEY_ID, etc.)
    try:
        enforce_tagging()
    except Exception as e:
        logger.error(f"Failed to connect to AWS: {e}")
