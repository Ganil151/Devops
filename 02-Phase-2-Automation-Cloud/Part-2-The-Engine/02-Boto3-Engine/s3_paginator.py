#!/usr/bin/env python3
"""
Topic: Cloud Automation (Boto3)
Description: Demonstrates high-scale resource discovery using Paginators.
"""

import boto3
from botocore.exceptions import ClientError
import sys

def list_all_buckets_paginated():
    """🚀 Standard: Handle massive fleets using Paginators."""
    s3_client = boto3.client('s3')
    
    # 1. Check: Is the region accessible?
    try:
        # Create a paginator for the list_objects_v2 operation
        # (Though list_buckets isn't paginated, we'll demonstrate with list_objects inside a bucket)
        paginator = s3_client.get_paginator('list_objects_v2')
        
        # This example assumes you have a bucket named 'my-dev-bucket'
        # In a real script, you would loop through all buckets first
        bucket_name = "example-devops-bucket" 
        
        print(f"🔍 Auditing objects in {bucket_name}...")
        
        # 2. Act: Paginate through thousands of objects
        page_iterator = paginator.paginate(Bucket=bucket_name)

        object_count = 0
        for page in page_iterator:
            if "Contents" in page:
                for obj in page["Contents"]:
                    object_count += 1
                    # Only print every 100th for brevity in demo
                    if object_count % 100 == 0:
                        print(f"  - Found {object_count} objects...")

        print(f"✅ Audit Complete. Total Objects: {object_count}")

    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucket':
            print(f"❌ Error: Bucket '{bucket_name}' not found.")
        else:
            print(f"❌ AWS Client Error: {e}")
    except Exception as e:
        print(f"💥 Unexpected Error: {e}")

if __name__ == "__main__":
    # Note: Requires AWS credentials
    print("⚠️  Requires AWS Credentials to run.")
    # list_all_buckets_paginated()
