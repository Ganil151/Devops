# AWS S3 Performance Optimization

Complete guide to optimizing S3 upload/download performance with multipart uploads, Transfer Acceleration, parallelization, and caching strategies.

## Overview

Optimize S3 performance for high-throughput workloads, large files, and global access patterns.

```yaml
Key Strategies:
  Upload Optimization:
    - Multipart uploads for files > 100 MB
    - Parallel uploads
    - Transfer Acceleration
    - Optimal part sizing
  
  Download Optimization:
    - CloudFront CDN
    - Byte-range fetches
    - Parallel downloads
    - Connection pooling
  
  Request Rate:
    - Partition key prefixes
    - Horizontal scaling
    - Request parallelization
    - Avoid sequential keys

Performance Targets:
  Single Request: ~100-200 MB/s
  Multipart Upload: 500+ MB/s
  With Acceleration: 50-500% faster
  Request Rate: 3,500 PUT/COPY/POST/DELETE per prefix/sec
  Request Rate: 5,500 GET/HEAD per prefix/sec
```

## Multipart Upload

For files larger than 100 MB, use multipart uploads:

### AWS CLI Multipart Upload

```bash
# Automatically uses multipart for files > 8 MB
aws s3 cp large-file.zip s3://my-bucket/ \
  --storage-class STANDARD \
  --metadata "uploaded-by=cli"

# Configure multipart threshold and chunk size
aws configure set default.s3.multipart_threshold 64MB
aws configure set default.s3.multipart_chunksize 16MB
aws configure set default.s3.max_concurrent_requests 20

# Upload with progress
aws s3 cp large-file.zip s3://my-bucket/ \
  --no-progress false
```

### Python Boto3 Multipart

```python
import boto3
from boto3.s3.transfer import TransferConfig

# Configure transfer settings
config = TransferConfig(
    multipart_threshold=100 * 1024 * 1024,  # 100 MB
    max_concurrency=10,
    multipart_chunksize=10 * 1024 * 1024,   # 10 MB
    use_threads=True
)

s3 = boto3.client('s3')

# Upload with progress callback
def upload_progress(bytes_transferred):
    print(f"Transferred: {bytes_transferred / (1024*1024):.2f} MB")

s3.upload_file(
    'large-file.zip',
    'my-bucket',
    'uploads/large-file.zip',
    Config=config,
    Callback=upload_progress
)
```

### Manual Multipart Upload

```python
import boto3
import os
import math

s3 = boto3.client('s3')

def multipart_upload(file_path, bucket, key, part_size=10*1024*1024):
    """
    Manual multipart upload for maximum control
    """
    file_size = os.path.getsize(file_path)
    num_parts = math.ceil(file_size / part_size)
    
    print(f"File size: {file_size / (1024*1024):.2f} MB")
    print(f"Uploading in {num_parts} parts...")
    
    # Initiate multipart upload
    response = s3.create_multipart_upload(
        Bucket=bucket,
        Key=key,
        ServerSideEncryption='AES256'
    )
    upload_id = response['UploadId']
    
    parts = []
    
    try:
        with open(file_path, 'rb') as f:
            for part_num in range(1, num_parts + 1):
                # Read part data
                data = f.read(part_size)
                
                # Upload part
                response = s3.upload_part(
                    Bucket=bucket,
                    Key=key,
                    PartNumber=part_num,
                    UploadId=upload_id,
                    Body=data
                )
                
                parts.append({
                    'PartNumber': part_num,
                    'ETag': response['ETag']
                })
                
                progress = (part_num / num_parts) * 100
                print(f"Progress: {progress:.1f}% (Part {part_num}/{num_parts})")
        
        # Complete multipart upload
        s3.complete_multipart_upload(
            Bucket=bucket,
            Key=key,
            UploadId=upload_id,
            MultipartUpload={'Parts': parts}
        )
        
        print("Upload complete!")
        
    except Exception as e:
        # Abort on error
        s3.abort_multipart_upload(
            Bucket=bucket,
            Key=key,
            UploadId=upload_id
        )
        print(f"Upload failed: {e}")
        raise

# Usage
multipart_upload('large-file.zip', 'my-bucket', 'uploads/large-file.zip')
```

### Parallel Multipart Upload

```python
import boto3
from concurrent.futures import ThreadPoolExecutor
import os

s3 = boto3.client('s3')

def upload_part(args):
    """Upload a single part"""
    bucket, key, upload_id, part_num, data = args
    
    response = s3.upload_part(
        Bucket=bucket,
        Key=key,
        PartNumber=part_num,
        UploadId=upload_id,
        Body=data
    )
    
    return {
        'PartNumber': part_num,
        'ETag': response['ETag']
    }

def parallel_multipart_upload(file_path, bucket, key, part_size=10*1024*1024, max_workers=10):
    """
    Parallel multipart upload using thread pool
    """
    file_size = os.path.getsize(file_path)
    
    # Initiate upload
    response = s3.create_multipart_upload(
        Bucket=bucket,
        Key=key,
        ServerSideEncryption='AES256'
    )
    upload_id = response['UploadId']
    
    # Read file and prepare parts
    parts_data = []
    with open(file_path, 'rb') as f:
        part_num = 1
        while True:
            data = f.read(part_size)
            if not data:
                break
            parts_data.append((bucket, key, upload_id, part_num, data))
            part_num += 1
    
    # Upload parts in parallel
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        parts = list(executor.map(upload_part, parts_data))
    
    # Complete upload
    parts.sort(key=lambda x: x['PartNumber'])
    s3.complete_multipart_upload(
        Bucket=bucket,
        Key=key,
        UploadId=upload_id,
        MultipartUpload={'Parts': parts}
    )
    
    print(f"Uploaded {len(parts)} parts successfully")

# Usage
parallel_multipart_upload('large-file.zip', 'my-bucket', 'uploads/large-file.zip')
```

## Transfer Acceleration

Enable faster uploads from distant locations using CloudFront edge locations:

### Enable Transfer Acceleration

```bash
# Enable on bucket
aws s3api put-bucket-accelerate-configuration \
  --bucket my-bucket \
  --accelerate-configuration Status=Enabled

# Verify
aws s3api get-bucket-accelerate-configuration \
  --bucket my-bucket

# Speed test
# Visit: https://s3-accelerate-speedtest.s3-accelerate.amazonaws.com/
```

### Use Accelerated Endpoint

```bash
# AWS CLI with acceleration
aws s3 cp large-file.zip s3://my-bucket/ \
  --endpoint-url https://s3-accelerate.amazonaws.com

# Python Boto3
import boto3

s3 = boto3.client('s3', config=boto3.session.Config(
    s3={'use_accelerate_endpoint': True}
))

s3.upload_file('large-file.zip', 'my-bucket', 'uploads/large-file.zip')
```

### Terraform Configuration

```hcl
resource "aws_s3_bucket" "accelerated" {
  bucket = "my-accelerated-bucket"
}

resource "aws_s3_bucket_accelerate_configuration" "accelerate" {
  bucket = aws_s3_bucket.accelerated.id
  status = "Enabled"
}

# Cost analysis
output "acceleration_cost" {
  value = "Additional $0.04-$0.08/GB depending on region"
  description = "Only charged if faster than standard transfer"
}
```

## Parallel Downloads

### Byte-Range Fetches

```python
import boto3
from concurrent.futures import ThreadPoolExecutor
import os

s3 = boto3.client('s3')

def download_range(args):
    """Download a byte range"""
    bucket, key, start, end, part_file = args
    
    response = s3.get_object(
        Bucket=bucket,
        Key=key,
        Range=f'bytes={start}-{end}'
    )
    
    with open(part_file, 'wb') as f:
        f.write(response['Body'].read())
    
    return part_file

def parallel_download(bucket, key, output_file, chunk_size=10*1024*1024, max_workers=10):
    """
    Download file in parallel chunks
    """
    # Get object size
    response = s3.head_object(Bucket=bucket, Key=key)
    file_size = response['ContentLength']
    
    # Calculate ranges
    ranges = []
    for i, start in enumerate(range(0, file_size, chunk_size)):
        end = min(start + chunk_size - 1, file_size - 1)
        part_file = f"{output_file}.part{i}"
        ranges.append((bucket, key, start, end, part_file))
    
    # Download parts in parallel
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        part_files = list(executor.map(download_range, ranges))
    
    # Combine parts
    with open(output_file, 'wb') as outfile:
        for part_file in sorted(part_files):
            with open(part_file, 'rb') as infile:
                outfile.write(infile.read())
            os.remove(part_file)
    
    print(f"Downloaded {file_size / (1024*1024):.2f} MB successfully")

# Usage
parallel_download('my-bucket', 'large-file.zip', 'downloaded.zip')
```

## CloudFront CDN

### Setup CloudFront Distribution

```hcl
# CloudFront OAI
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for S3 bucket"
}

# Update S3 bucket policy
resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.content.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.content.arn}/*"
      }
    ]
  })
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "S3 CDN"
  price_class     = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.content.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.content.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.content.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400      # 24 hours
    max_ttl     = 31536000   # 1 year
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.main.domain_name
}
```

## Request Rate Optimization

### Partition Key Prefixes

```yaml
Poor Performance (Sequential):
  uploads/file1.jpg
  uploads/file2.jpg
  uploads/file3.jpg
  # All objects share same prefix partition

Good Performance (Random Prefixes):
  a7f3/uploads/file1.jpg
  b2e9/uploads/file2.jpg
  c5d1/uploads/file3.jpg
  # Objects distributed across partitions

Best Performance (Hash-Based):
  {hash(filename)}/uploads/file1.jpg
  # Guaranteed even distribution
```

### Python Example

```python
import hashlib
import boto3

s3 = boto3.client('s3')

def upload_with_hash_prefix(file_path, bucket, key):
    """
    Upload with hash-based prefix for better distribution
    """
    # Generate hash from filename
    hash_obj = hashlib.md5(key.encode())
    hash_prefix = hash_obj.hexdigest()[:4]
    
    # New key with hash prefix
    new_key = f"{hash_prefix}/{key}"
    
    s3.upload_file(file_path, bucket, new_key)
    return new_key

# Usage
for i in range(1000):
    result_key = upload_with_hash_prefix(
        f'file{i}.jpg',
        'my-bucket',
        f'uploads/file{i}.jpg'
    )
    print(f"Uploaded to: {result_key}")
```

## Caching Strategies

### Cache-Control Headers

```python
import boto3

s3 = boto3.client('s3')

# Upload with cache headers
s3.put_object(
    Bucket='my-bucket',
    Key='static/logo.png',
    Body=open('logo.png', 'rb'),
    ContentType='image/png',
    CacheControl='public, max-age=31536000, immutable',  # 1 year
    Metadata={
        'uploaded': '2024-01-20'
    }
)

# Different caching for different content
cache_strategies = {
    'static/': 'public, max-age=31536000, immutable',  # Static assets
    'api/': 'no-cache, no-store, must-revalidate',      # API responses
    'pages/': 'public, max-age=3600, must-revalidate'   # HTML pages
}
```

### S3 Select for Filtering

```python
import boto3

s3 = boto3.client('s3')

# Query CSV without downloading entire file
response = s3.select_object_content(
    Bucket='my-bucket',
    Key='data/large-dataset.csv',
    ExpressionType='SQL',
    Expression="SELECT * FROM s3object s WHERE s.age > 30 LIMIT 100",
    InputSerialization={
        'CSV': {
            'FileHeaderInfo': 'USE',
            'RecordDelimiter': '\n',
            'FieldDelimiter': ','
        }
    },
    OutputSerialization={
        'CSV': {}
    }
)

# Process results
for event in response['Payload']:
    if 'Records' in event:
        records = event['Records']['Payload'].decode('utf-8')
        print(records)
```

## Monitoring Performance

```bash
# S3 request metrics
aws s3api put-bucket-metrics-configuration \
  --bucket my-bucket \
  --id EntireBucket \
  --metrics-configuration '{
    "Id": "EntireBucket",
    "Filter": {
      "Prefix": ""
    }
  }'

# CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name FirstByteLatency \
  --dimensions Name=BucketName,Value=my-bucket \
    Name=FilterId,Value=EntireBucket \
  --statistics Average,Maximum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

## Best Practices

```yaml
Upload Optimization:
  - Use multipart for files > 100 MB
  - Parallelize uploads (10-20 threads)
  - Enable Transfer Acceleration for global uploads
  - Use appropriate part sizes (5-25 MB)
  - Implement retry logic

Download Optimization:
  - Use CloudFront for frequently accessed content
  - Implement byte-range fetches for large files
  - Enable compression (gzip)
  - Use appropriate caching headers
  - Connection pooling

Request Rate:
  - Use random/hash-based prefixes
  - Avoid sequential naming
  - Distribute across partitions
  - Monitor CloudWatch metrics
  - Scale horizontally

Cost vs Performance:
  - Transfer Acceleration: Only when needed
  - CloudFront: For frequently accessed content
  - Storage classes: Match access patterns
  - Request metrics: Enable only when needed
```

## Performance Benchmarks

```python
import boto3
import time
from concurrent.futures import ThreadPoolExecutor

s3 = boto3.client('s3')

def benchmark_upload(method, file_path, bucket, key):
    """Benchmark upload methods"""
    start = time.time()
    
    if method == 'standard':
        with open(file_path, 'rb') as f:
            s3.put_object(Bucket=bucket, Key=key, Body=f)
    
    elif method == 'multipart':
        config = boto3.s3.transfer.TransferConfig(
            multipart_threshold=1024*1024*100,
            max_concurrency=10
        )
        s3.upload_file(file_path, bucket, key, Config=config)
    
    duration = time.time() - start
    file_size = os.path.getsize(file_path) / (1024*1024)  # MB
    speed = file_size / duration
    
    print(f"{method}: {duration:.2f}s ({speed:.2f} MB/s)")

# Run benchmarks
benchmark_upload('standard', 'large.zip', 'my-bucket', 'test/standard.zip')
benchmark_upload('multipart', 'large.zip', 'my-bucket', 'test/multipart.zip')
```

## Additional Resources

- [S3 Advanced README](readme.md)
- [AWS S3 Performance Guidelines](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance.html)
- [Transfer Acceleration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html)
- [Multipart Upload](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html)
