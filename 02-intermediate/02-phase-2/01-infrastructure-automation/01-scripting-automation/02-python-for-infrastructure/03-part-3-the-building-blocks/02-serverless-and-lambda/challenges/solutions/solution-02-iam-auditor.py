"""
Solution: Unused IAM Key Alert
"""
import boto3
from datetime import datetime, timezone, timedelta

iam = boto3.client('iam')

def lambda_handler(event, context):
    threshold_days = 90
    cutoff_date = datetime.now(timezone.utc) - timedelta(days=threshold_days)
    
    expired_keys = []
    
    # 1. Get all users
    users_resp = iam.list_users()
    
    for user in users_resp['Users']:
        user_name = user['UserName']
        
        # 2. Get keys for user
        keys_resp = iam.list_access_keys(UserName=user_name)
        
        for key in keys_resp['AccessKeyMetadata']:
            create_date = key['CreateDate']
            
            # 3. Compare dates
            if create_date < cutoff_date:
                expired_keys.append({
                    "user": user_name,
                    "key_id": key['AccessKeyId'],
                    "age_days": (datetime.now(timezone.utc) - create_date).days
                })
                
    # 4. Report
    if expired_keys:
        print(f"⚠️ Found {len(expired_keys)} expired keys!")
        for k in expired_keys:
            print(f"User: {k['user']} | Key: {k['key_id']} | Age: {k['age_days']} days")
    else:
        print("✅ No expired keys found.")
        
    return {"expired_count": len(expired_keys)}
