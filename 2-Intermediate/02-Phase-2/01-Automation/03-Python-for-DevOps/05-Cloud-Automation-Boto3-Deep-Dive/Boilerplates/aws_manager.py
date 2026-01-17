#!/usr/bin/env python3
"""
Name: aws_manager.py
Description: Safe Boto3 usage patterns.
"""

import boto3
import logging
import sys
from botocore.exceptions import ClientError, NoCredentialsError

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("aws_manager")

def get_s3_client(profile: str = "default"):
    """Creates a Boto3 client using a specific profile."""
    try:
        session = boto3.Session(profile_name=profile)
        return session.client("s3")
    except Exception as e:
        logger.error(f"Failed to create session: {e}")
        return None

def list_buckets(client) -> None:
    """Lists all S3 buckets safely."""
    try:
        logger.info("Listing S3 Buckets...")
        response = client.list_buckets()
        
        for bucket in response.get("Buckets", []):
            logger.info(f"- {bucket['Name']} (Created: {bucket['CreationDate']})")
            
    except ClientError as e:
        logger.error(f"AWS API Error: {e}")
    except NoCredentialsError:
        logger.error("No AWS Credentials found! content ~/.aws/credentials")

def upload_file(client, file_name, bucket, object_name=None):
    """Uploads a file to an S3 bucket."""
    if object_name is None:
        object_name = file_name

    try:
        client.upload_file(file_name, bucket, object_name)
        logger.info(f"File {file_name} uploaded to {bucket}/{object_name}")
        return True
    except FileNotFoundError:
        logger.error(f"The file was not found: {file_name}")
        return False
    except ClientError as e:
        logger.error(f"Upload failed: {e}")
        return False

if __name__ == "__main__":
    # Note: Requires AWS credentials configured
    s3 = get_s3_client()
    
    if s3:
        list_buckets(s3)
        # upload_file(s3, "test.txt", "my-bucket")
