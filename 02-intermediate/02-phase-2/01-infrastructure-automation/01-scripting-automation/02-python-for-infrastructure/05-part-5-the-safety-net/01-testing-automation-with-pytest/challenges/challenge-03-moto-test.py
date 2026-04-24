"""
Challenge: Moto S3 File Count Test
Scenario: You have a script that counts all '.log' files in an S3 bucket. 
To test it, you don't want to use real AWS. You must use `moto`.

TODO: Implement `test_s3_scripts.py`.
1. Decorate the test with `@mock_s3`.
2. Create some files in the mock bucket using `boto3`.
3. Call your `count_logs(bucket_name)` function.
4. Assert the count matches the number of mock files you created.
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

# --- START YOUR TESTS HERE ---
@mock_s3
def test_count_logs():
    # --- START YOUR CODE HERE ---
    pass
