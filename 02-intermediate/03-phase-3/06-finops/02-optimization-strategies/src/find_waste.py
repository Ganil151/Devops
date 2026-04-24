import boto3

def find_unattached_ebs():
    ec2 = boto3.client('ec2')
    print("--- Searching for Unattached EBS Volumes ---")
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    
    for vol in volumes['Volumes']:
        print(f"ID: {vol['VolumeId']} | Size: {vol['Size']}GB | Created: {vol['CreateTime']}")
    
    if not volumes['Volumes']:
        print("✅ No unattached volumes found.")

def find_idle_eips():
    ec2 = boto3.client('ec2')
    print("\n--- Searching for Idle Elastic IPs ---")
    addresses = ec2.describe_addresses()
    
    idle_count = 0
    for addr in addresses['Addresses']:
        if 'InstanceId' not in addr and 'NetworkInterfaceId' not in addr:
            print(f"Public IP: {addr['PublicIp']} | AllocationId: {addr['AllocationId']}")
            idle_count += 1
            
    if idle_count == 0:
        print("✅ No idle Elastic IPs found.")
    else:
        print(f"⚠️ Found {idle_count} idle IPs costing ~$3.60/month each.")

if __name__ == "__main__":
    try:
        find_unattached_ebs()
        find_idle_eips()
    except Exception as e:
        print(f"Error connecting to AWS: {e}")
        print("Note: Ensure you have AWS credentials configured.")
