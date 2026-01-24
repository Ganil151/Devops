"""
Solution: Moto S3 File Count Test
"""
import boto3
import pytest
from moto import mock_s3

def count_logs(bucket_name):
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=bucket_name)
    count = 0
    if 'Contents' in response:
        for obj in response['Contents']:
            if obj['Key'].endswith('.log'):
                count += 1
    return count

@mock_s3
def test_count_logs():
    # 1. Setup Mock
    bucket_name = "test-bucket"
    s3 = boto3.client('s3', region_name='us-east-1')
    s3.create_bucket(Bucket=bucket_name)
    
    # 2. Upload dummy files
    s3.put_object(Bucket=bucket_name, Key="app.log", Body="data")
    s3.put_object(Bucket=bucket_name, Key="error.log", Body="data")
    s3.put_object(Bucket=bucket_name, Key="image.png", Body="data") # Should be ignored
    
    # 3. Act
    result = count_logs(bucket_name)
    
    # 4. Assert
    assert result == 2
