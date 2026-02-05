"""
Solution: Boto3 Paginator Exercise
"""
import boto3

def calculate_total_bucket_size(bucket_name):
    s3 = boto3.client('s3')
    paginator = s3.get_paginator('list_objects_v2')
    
    total_bytes = 0
    pages = paginator.paginate(Bucket=bucket_name)
    
    for page in pages:
        # 'Contents' key might be missing if bucket is empty
        if 'Contents' in page:
            for obj in page['Contents']:
                total_bytes += obj['Size']
                
    # Convert to GB
    total_gb = total_bytes / (1024 ** 3)
    return round(total_gb, 2)

if __name__ == "__main__":
    # Test would run here
    pass
