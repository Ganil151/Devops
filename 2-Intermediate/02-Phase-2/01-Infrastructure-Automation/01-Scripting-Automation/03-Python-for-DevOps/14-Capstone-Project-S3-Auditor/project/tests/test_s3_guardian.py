"""
Tests for S3 Guardian
"""
import boto3
import pytest
from moto import mock_s3
from auditor import get_bucket_encryption, get_bucket_versioning

@mock_s3
def test_encryption_check_enabled():
    s3 = boto3.client('s3', region_name='us-east-1')
    bucket = "secure-bucket"
    s3.create_bucket(Bucket=bucket)
    
    # Enable encryption
    s3.put_bucket_encryption(
        Bucket=bucket,
        ServerSideEncryptionConfiguration={
            'Rules': [{'ApplyServerSideEncryptionByDefault': {'SSEAlgorithm': 'AES256'}}]
        }
    )
    
    assert get_bucket_encryption(s3, bucket) is True

@mock_s3
def test_encryption_check_disabled():
    s3 = boto3.client('s3', region_name='us-east-1')
    bucket = "vulnerable-bucket"
    s3.create_bucket(Bucket=bucket)
    
    assert get_bucket_encryption(s3, bucket) is False

@mock_s3
def test_versioning_check():
    s3 = boto3.client('s3', region_name='us-east-1')
    bucket = "versioned-bucket"
    s3.create_bucket(Bucket=bucket)
    
    # Enable versioning
    s3.put_bucket_versioning(
        Bucket=bucket,
        VersioningConfiguration={'Status': 'Enabled'}
    )
    
    assert get_bucket_versioning(s3, bucket) is True
