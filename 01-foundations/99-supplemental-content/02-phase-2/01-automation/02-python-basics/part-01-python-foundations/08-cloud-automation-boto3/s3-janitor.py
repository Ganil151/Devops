import boto3
from botocore.exceptions import ClientError


def manage_s3(bucket_name, client=None):
    """
    Creates an S3 bucket if it doesn't exist.

    Args:
        bucket_name (str): Name of the bucket to create.
        client: Boto3 client (optional). If None, creates a new one.
    """
    # Use provided client (for testing) or create a new one (for prod)
    s3 = client if client else boto3.client("s3")

    try:
        s3.create_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' created successfully.")
        return "created"
    except ClientError as e:
        if e.response["Error"]["Code"] == "BucketAlreadyOwnedByYou":
            print(f"Bucket '{bucket_name}' already exists.")
            return "exists"
        else:
            raise e
