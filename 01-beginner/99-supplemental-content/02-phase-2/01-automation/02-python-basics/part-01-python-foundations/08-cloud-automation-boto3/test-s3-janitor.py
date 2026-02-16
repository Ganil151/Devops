import pytest
from s3_janitor import manage_s3


def test_manage_s3_creates_new_bucket(s3):
    """
    Test that the function creates a bucket when it doesn't exist.
    's3' argument is the fixture from conftest.py
    """
    bucket_name = "my-test-bucket"

    # Pass the mocked s3 client into the function
    result = manage_s3(bucket_name, client=s3)

    assert result == "created"

    # Verify the state of the mock
    response = s3.list_buckets()
    buckets = [b["Name"] for b in response["Buckets"]]
    assert bucket_name in buckets


def test_manage_s3_handles_existing_bucket(s3):
    """Test that the function handles existing buckets gracefully."""
    bucket_name = "existing-bucket"

    # Pre-create the bucket in the mock environment
    s3.create_bucket(Bucket=bucket_name)

    # Run function
    result = manage_s3(bucket_name, client=s3)

    assert result == "exists"
