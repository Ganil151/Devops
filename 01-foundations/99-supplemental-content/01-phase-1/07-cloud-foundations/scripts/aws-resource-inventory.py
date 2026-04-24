"""
AWS Resource Inventory Tool
Description: Audits and lists AWS resources (EC2, S3, RDS) in a region.
Author: Senior DevOps Engineer
Version: 1.0 (Golden Standard)
Requirements: boto3
"""

import boto3
import json
import csv
import argparse
from datetime import datetime

# Setup arguments
parser = argparse.ArgumentParser(description='AWS Resource Inventory Tool')
parser.add_argument('--region', type=str, default='us-east-1', help='AWS Region')
parser.add_argument('--format', type=str, choices=['json', 'csv', 'console'], default='console', help='Output format')
parser.add_argument('--output', type=str, help='Output file path')
args = parser.parse_args()

def get_ec2_inventory(region):
    ec2 = boto3.client('ec2', region_name=region)
    instances = ec2.describe_instances()
    inventory = []
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            name = 'Unknown'
            if 'Tags' in instance:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        name = tag['Value']
            
            inventory.append({
                'Service': 'EC2',
                'Id': instance['InstanceId'],
                'Name': name,
                'Type': instance['InstanceType'],
                'State': instance['State']['Name'],
                'LaunchTime': str(instance['LaunchTime'])
            })
    return inventory

def get_s3_inventory():
    s3 = boto3.client('s3')
    buckets = s3.list_buckets()
    inventory = []
    
    for bucket in buckets['Buckets']:
        inventory.append({
            'Service': 'S3',
            'Id': bucket['Name'],
            'Name': bucket['Name'],
            'Type': 'Bucket',
            'State': 'Active',
            'LaunchTime': str(bucket['CreationDate'])
        })
    return inventory

def get_rds_inventory(region):
    rds = boto3.client('rds', region_name=region)
    instances = rds.describe_db_instances()
    inventory = []
    
    for db in instances['DBInstances']:
        inventory.append({
            'Service': 'RDS',
            'Id': db['DBInstanceIdentifier'],
            'Name': db['DBInstanceIdentifier'],
            'Type': db['DBInstanceClass'],
            'State': db['DBInstanceStatus'],
            'LaunchTime': str(db['InstanceCreateTime'])
        })
    return inventory

def main():
    try:
        print(f"Collecting inventory for region: {args.region}...")
        
        all_resources = []
        all_resources.extend(get_ec2_inventory(args.region))
        all_resources.extend(get_s3_inventory())
        all_resources.extend(get_rds_inventory(args.region))
        
        # Output handling
        if args.format == 'json':
            output_data = json.dumps(all_resources, indent=4, default=str)
            if args.output:
                with open(args.output, 'w') as f:
                    f.write(output_data)
                print(f"Inventory saved to {args.output}")
            else:
                print(output_data)
                
        elif args.format == 'csv':
            if args.output:
                with open(args.output, 'w', newline='') as f:
                    writer = csv.DictWriter(f, fieldnames=['Service', 'Id', 'Name', 'Type', 'State', 'LaunchTime'])
                    writer.writeheader()
                    writer.writerows(all_resources)
                print(f"Inventory saved to {args.output}")
            else:
                print("Error: CSV format requires --output file.")
                
        else: # Console
            print("\nAWS Resource Inventory")
            print("======================")
            print(f"{'Service':<10} {'Id':<25} {'Name':<25} {'State':<15} {'Type':<15}")
            print("-" * 90)
            for r in all_resources:
                print(f"{r['Service']:<10} {r['Id']:<25} {r['Name']:<25} {r['State']:<15} {r['Type']:<15}")
            print(f"\nTotal Resources: {len(all_resources)}")

    except Exception as e:
        print(f"Error: {str(e)}")
        print("Tip: Ensure you have configured AWS credentials (aws configure)")

if __name__ == '__main__':
    main()
