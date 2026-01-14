"""
Challenge: Boto3 Paginator Exercise
Scenario: You need to calculate the total size of all objects in a very 
large S3 bucket (potentially millions of objects). Using a normal 
`list_objects_v2` call will only return the first 1,000 items.

TODO: Implement `calculate_total_bucket_size(bucket_name)`.
1. Use `boto3.client('s3')`.
2. Get the `list_objects_v2` paginator.
3. Iterate through all pages using `.paginate(Bucket=bucket_name)`.
4. Sum the `Size` of every item in every page.
5. Return the total size in Gigabytes (Total Bytes / 1024^3).
"""
import boto3

def calculate_total_bucket_size(bucket_name):
    """
    Calculates total size of all objects in a bucket using paginators.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test would run here
    pass
