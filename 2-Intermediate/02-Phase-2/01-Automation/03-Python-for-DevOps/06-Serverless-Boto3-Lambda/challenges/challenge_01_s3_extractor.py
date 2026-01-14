"""
Challenge: S3 Image Metadata Extractor
Scenario: Every time a user uploads an image to 'uploads-bucket', 
you need to extract basic metadata (size, content type) and save it 
to 'metadata-bucket'.

TODO: Implement the `lambda_handler(event, context)`.
1. Extract the `bucket` and `key` from the S3 event.
2. Use `s3_client.head_object()` to get the file's metadata.
3. Extract 'ContentLength' and 'ContentType'.
4. Construct a JSON string with this info.
5. Save the JSON string to 'metadata-bucket' with the same key name 
   plus '.json' (e.g., photo.jpg -> photo.jpg.json).
"""
import json
import boto3

s3 = boto3.client('s3')
DEST_BUCKET = "metadata-bucket"

def lambda_handler(event, context):
    """
    Handles S3 Put events and generates metadata JSON.
    """
    # --- START YOUR CODE HERE ---
    pass
