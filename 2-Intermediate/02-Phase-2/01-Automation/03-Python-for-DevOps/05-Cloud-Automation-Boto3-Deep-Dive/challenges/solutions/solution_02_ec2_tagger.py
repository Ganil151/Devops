"""
Solution: EC2 Auto-Tagger
"""
import boto3

def tag_untagged_instances(owner_name):
    ec2 = boto3.resource('ec2')
    count = 0
    
    for instance in ec2.instances.all():
        tags = instance.tags or []
        # Extract keys
        keys = [tag['Key'] for tag in tags]
        
        if 'Owner' not in keys:
            instance.create_tags(
                Tags=[{'Key': 'Owner', 'Value': owner_name}]
            )
            count += 1
            print(f"Tagged instance {instance.id}")
            
    return count

if __name__ == "__main__":
    # Test would run here
    pass
