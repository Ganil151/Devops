"""
Solution: Instance Auto-Stop Scheduler
"""
import boto3
from datetime import datetime, timezone

ec2 = boto3.resource('ec2')

def lambda_handler(event, context):
    current_hour = datetime.now(timezone.utc).hour
    print(f"Current UTC Hour: {current_hour}")
    
    # Office hours: 9 AM to 6 PM (9 to 18)
    if current_hour < 9 or current_hour >= 18:
        print("Outside office hours. Checking for Dev instances to stop...")
        
        # Filter: Env=Dev AND state=running
        instances = ec2.instances.filter(
            Filters=[
                {'Name': 'tag:Env', 'Values': ['Dev']},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )
        
        stop_ids = [i.id for i in instances]
        
        if stop_ids:
            print(f"Stopping instances: {stop_ids}")
            ec2.instances.filter(InstanceIds=stop_ids).stop()
            return {"status": "success", "stopped": stop_ids}
        else:
            return {"status": "active", "message": "No running Dev instances found"}
            
    return {"status": "active", "message": "Inside office hours"}
