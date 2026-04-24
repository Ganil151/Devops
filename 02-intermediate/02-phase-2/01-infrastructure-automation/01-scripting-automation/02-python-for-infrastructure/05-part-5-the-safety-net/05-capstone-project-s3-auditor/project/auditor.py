"""
Auditor Module: Handles S3 security checks.
"""
from botocore.exceptions import ClientError

def get_bucket_encryption(s3_client, bucket_name):
    """Checks if Server-Side Encryption is enabled."""
    try:
        s3_client.get_bucket_encryption(Bucket=bucket_name)
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == 'ServerSideEncryptionConfigurationNotFoundError':
            return False
        raise e

def get_bucket_versioning(s3_client, bucket_name):
    """Checks if Versioning is enabled."""
    try:
        response = s3_client.get_bucket_versioning(Bucket=bucket_name)
        return response.get('Status') == 'Enabled'
    except ClientError:
        return False

def get_public_access_block(s3_client, bucket_name):
    """Checks if Block Public Access is fully enabled."""
    try:
        response = s3_client.get_public_access_block(Bucket=bucket_name)
        config = response['PublicAccessBlockConfiguration']
        return all(config.values())
    except ClientError:
        return False

def audit_bucket(s3_client, bucket_name):
    """Runs a suite of security checks on a bucket."""
    return {
        "Name": bucket_name,
        "Encryption": "✅" if get_bucket_encryption(s3_client, bucket_name) else "❌",
        "Versioning": "✅" if get_bucket_versioning(s3_client, bucket_name) else "❌",
        "PublicBlock": "✅" if get_public_access_block(s3_client, bucket_name) else "❌"
    }
