"""
Solution: S3 Image Metadata Extractor
"""
import json
import boto3
import os

s3 = boto3.client('s3')
# In real life, use environment variables
DEST_BUCKET = os.environ.get("METADATA_BUCKET", "metadata-bucket")

def lambda_handler(event, context):
    try:
        # 1. Parse Event
        record = event['Records'][0]
        src_bucket = record['s3']['bucket']['name']
        src_key = record['s3']['object']['key']
        
        # 2. Get Metadata
        response = s3.head_object(Bucket=src_bucket, Key=src_key)
        
        meta = {
            "source_file": src_key,
            "size_bytes": response['ContentLength'],
            "content_type": response['ContentType'],
            "last_modified": str(response['LastModified'])
        }
        
        # 3. Save to Destination
        dest_key = f"{src_key}.json"
        s3.put_object(
            Bucket=DEST_BUCKET,
            Key=dest_key,
            Body=json.dumps(meta, indent=2),
            ContentType='application/json'
        )
        
        return {
            "statusCode": 200,
            "body": f"Successfully processed {src_key}"
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 500,
            "body": str(e)
        }
