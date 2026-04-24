"""
Challenge: Unused IAM Key Alert
Scenario: Security policy requires that all IAM access keys older 
than 90 days be rotated. You need a Lambda that runs daily and 
identifies these keys.

TODO: Implement the logic inside `lambda_handler`.
1. Use `boto3.client('iam')`.
2. List all users using `list_users()`.
3. For each user, list their access keys using `list_access_keys(UserName=...)`.
4. Check the `CreateDate` of each key.
5. If `today - CreateDate > 90 days`, add the username and KeyId to a 
   `expired_keys` list.
6. Print the results to the log.
"""
import boto3
from datetime import datetime, timezone, timedelta

iam = boto3.client('iam')

def lambda_handler(event, context):
    """
    Finds IAM access keys older than 90 days.
    """
    # --- START YOUR CODE HERE ---
    pass
