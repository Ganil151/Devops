"""
Solution: S3 Bucket Policy Auditor
"""
import boto3
from botocore.exceptions import ClientError

def audit_s3_buckets():
    s3_resource = boto3.resource('s3')
    s3_client = boto3.client('s3')
    insecure_buckets = []
    
    for bucket in s3_resource.buckets.all():
        try:
            response = s3_client.get_public_access_block(Bucket=bucket.name)
            config = response['PublicAccessBlockConfiguration']
            
            # If any block is False, it might be insecure depending on policies
            if not all(config.values()):
                insecure_buckets.append(bucket.name)
                
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchPublicAccessBlockConfiguration':
                # No block means it follows default (which might be public)
                insecure_buckets.append(bucket.name)
            else:
                print(f"Error checking {bucket.name}: {e}")
                
    return insecure_buckets

if __name__ == "__main__":
    # Test would run here
    pass
