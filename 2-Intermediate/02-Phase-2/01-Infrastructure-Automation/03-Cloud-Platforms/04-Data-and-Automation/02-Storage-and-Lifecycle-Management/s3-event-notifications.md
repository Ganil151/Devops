# AWS S3 Event Notifications

Complete guide to building event-driven architectures with S3 event notifications, triggering Lambda functions, SNS topics, and SQS queues.

## Overview

S3 Event Notifications enable you to respond automatically when objects are created, deleted, or modified in your buckets.

```yaml
Supported Events:
  Object Created:
    - s3:ObjectCreated:* (all create events)
    - s3:ObjectCreated:Put
    - s3:ObjectCreated:Post
    - s3:ObjectCreated:Copy
    - s3:ObjectCreated:CompleteMultipartUpload
  
  Object Removed:
    - s3:ObjectRemoved:* (all delete events)
    - s3:ObjectRemoved:Delete
    - s3:ObjectRemoved:DeleteMarkerCreated
  
  Object Restore:
    - s3:ObjectRestore:Post
    - s3:ObjectRestore:Completed
  
  Replication:
    - s3:Replication:OperationFailedReplication
    - s3:Replication:OperationMissedThreshold
    - s3:Replication:OperationReplicatedAfterThreshold

Destinations:
  - AWS Lambda functions
  - Amazon SNS topics
  - Amazon SQS queues
  - Amazon EventBridge
```

## Use Cases

```yaml
Automated Processing:
  - Image thumbnail generation
  - Video transcoding
  - Document conversion
  - Data validation
  
Workflow Triggers:
  - Start ETL pipelines
  - Trigger AWS Step Functions
  - Initiate batch jobs
  - Update databases

Notifications:
  - Email on file upload
  - Slack notifications
  - Audit logging
  - Compliance alerts

Data Integration:
  - Index in Elasticsearch
  - Update search catalog
  - Sync to data warehouse
  - Replicate to external systems
```

## Lambda Function Trigger

### Setup Steps

#### 1. Create Lambda Function

```python
# lambda_function.py
import json
import boto3
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Process S3 event notification
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Get bucket and key from event
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        size = record['s3']['object']['size']
        event_name = record['eventName']
        
        print(f"Event: {event_name}")
        print(f"Bucket: {bucket}")
        print(f"Key: {key}")
        print(f"Size: {size} bytes")
        
        # Process based on event type
        if 'ObjectCreated' in event_name:
            process_created_object(bucket, key, size)
        elif 'ObjectRemoved' in event_name:
            process_removed_object(bucket, key)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }

def process_created_object(bucket, key, size):
    """Handle object creation"""
    print(f"Processing new object: {key}")
    
    # Example: Get object metadata
    try:
        response = s3.head_object(Bucket=bucket, Key=key)
        content_type = response.get('ContentType')
        
        # Process based on file type
        if content_type and content_type.startswith('image/'):
            print(f"Image file detected: {key}")
            # Call image processing function
            
        elif key.endswith('.csv'):
            print(f"CSV file detected: {key}")
            # Trigger data processing pipeline
            
    except Exception as e:
        print(f"Error processing object: {e}")
        raise

def process_removed_object(bucket, key):
    """Handle object deletion"""
    print(f"Object deleted: {key}")
    # Cleanup related resources, update indexes, etc.
```

#### 2. Create IAM Role

```bash
# Trust policy for Lambda
cat > lambda-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name S3EventLambdaRole \
  --assume-role-policy-document file://lambda-trust-policy.json

# Attach basic execution policy
aws iam attach-role-policy \
  --role-name S3EventLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Attach S3 read only policy
aws iam attach-role-policy \
  --role-name S3EventLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

#### 3. Deploy Lambda Function

```bash
# Package function
zip lambda_function.zip lambda_function.py

# Create Lambda function
aws lambda create-function \
  --function-name S3EventProcessor \
  --runtime python3.11 \
  --role arn:aws:iam::123456789012:role/S3EventLambdaRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --timeout 60 \
  --memory-size 256

# Grant S3 permission to invoke Lambda
aws lambda add-permission \
  --function-name S3EventProcessor \
  --statement-id S3InvokeLambda \
  --action lambda:InvokeFunction \
  --principal s3.amazonaws.com \
  --source-arn arn:aws:s3:::my-bucket \
  --source-account 123456789012
```

#### 4. Configure S3 Event Notification

```bash
cat > event-notification.json << 'EOF'
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "ProcessNewFiles",
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:123456789012:function:S3EventProcessor",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "prefix",
              "Value": "uploads/"
            },
            {
              "Name": "suffix",
              "Value": ".jpg"
            }
          ]
        }
      }
    }
  ]
}
EOF

# Apply configuration
aws s3api put-bucket-notification-configuration \
  --bucket my-bucket \
  --notification-configuration file://event-notification.json
```

## Terraform Configuration

### Lambda with S3 Trigger

```hcl
# Lambda function
resource "aws_lambda_function" "s3_processor" {
  filename      = "lambda_function.zip"
  function_name = "S3EventProcessor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 256

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.processed.id
    }
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "S3EventLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Lambda basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 access policy
resource "aws_iam_role_policy" "lambda_s3" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.source.arn}/*",
          "${aws_s3_bucket.processed.arn}/*"
        ]
      }
    ]
  })
}

# S3 bucket
resource "aws_s3_bucket" "source" {
  bucket = "my-source-bucket"
}

# Lambda permission for S3
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

# S3 event notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    id                  = "ProcessImages"
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    id                  = "ProcessDocuments"
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "documents/"
    filter_suffix       = ".pdf"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
```

## SNS Topic Notification

```hcl
# SNS topic
resource "aws_sns_topic" "s3_events" {
  name = "s3-events-topic"
}

# SNS topic policy
resource "aws_sns_topic_policy" "s3_events" {
  arn = aws_sns_topic.s3_events.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.s3_events.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.source.arn
          }
        }
      }
    ]
  })
}

# Email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.s3_events.arn
  protocol  = "email"
  endpoint  = "admin@example.com"
}

# S3 notification to SNS
resource "aws_s3_bucket_notification" "sns_notification" {
  bucket = aws_s3_bucket.source.id

  topic {
    id            = "SendToSNS"
    topic_arn     = aws_sns_topic.s3_events.arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix = "important/"
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}
```

## SQS Queue Notification

```hcl
# SQS queue
resource "aws_sqs_queue" "s3_events" {
  name                       = "s3-events-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10

  # Dead letter queue for failed messages
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# Dead letter queue
resource "aws_sqs_queue" "dlq" {
  name = "s3-events-dlq"
}

# SQS queue policy
resource "aws_sqs_queue_policy" "s3_events" {
  queue_url = aws_sqs_queue.s3_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.s3_events.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.source.arn
          }
        }
      }
    ]
  })
}

# S3 notification to SQS
resource "aws_s3_bucket_notification" "sqs_notification" {
  bucket = aws_s3_bucket.source.id

  queue {
    id            = "SendToSQS"
    queue_arn     = aws_sqs_queue.s3_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "queue-processing/"
  }

  depends_on = [aws_sqs_queue_policy.s3_events]
}
```

## EventBridge Integration

```hcl
# Enable EventBridge notifications
resource "aws_s3_bucket_notification" "eventbridge" {
  bucket      = aws_s3_bucket.source.id
  eventbridge = true
}

# EventBridge rule
resource "aws_cloudwatch_event_rule" "s3_events" {
  name        = "s3-object-created"
  description = "Trigger on S3 object creation"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.source.id]
      }
      object = {
        key = [{
          prefix = "data/"
        }]
      }
    }
  })
}

# EventBridge target (Lambda)
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.s3_events.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.s3_processor.arn
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_events.arn
}
```

## Event Message Structure

```json
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventTime": "2024-01-20T10:30:00.000Z",
      "eventName": "ObjectCreated:Put",
      "userIdentity": {
        "principalId": "AWS:AIDAI..."
      },
      "requestParameters": {
        "sourceIPAddress": "203.0.113.1"
      },
      "responseElements": {
        "x-amz-request-id": "C3D13FE58DE4C810",
        "x-amz-id-2": "FMyUVU..."
      },
      "s3": {
        "s3SchemaVersion": "1.0",
        "configurationId": "testConfigRule",
        "bucket": {
          "name": "my-bucket",
          "ownerIdentity": {
            "principalId": "A3NL..."
          },
          "arn": "arn:aws:s3:::my-bucket"
        },
        "object": {
          "key": "uploads/image.jpg",
          "size": 1024,
          "eTag": "0123456789abcdef",
          "versionId": "null",
          "sequencer": "0055AED6DCD90281E5"
        }
      }
    }
  ]
}
```

## Advanced Lambda Example: Image Processing

```python
import json
import boto3
import os
from PIL import Image
from io import BytesIO

s3 = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Skip if already a thumbnail
        if 'thumbnails/' in key:
            continue
        
        try:
            # Download image
            response = s3.get_object(Bucket=bucket, Key=key)
            image_data = response['Body'].read()
            
            # Create thumbnail
            image = Image.open(BytesIO(image_data))
            image.thumbnail((200, 200))
            
            # Save to buffer
            buffer = BytesIO()
            image.save(buffer, format=image.format)
            buffer.seek(0)
            
            # Upload thumbnail
            thumbnail_key = f"thumbnails/{os.path.basename(key)}"
            s3.put_object(
                Bucket=bucket,
                Key=thumbnail_key,
                Body=buffer,
                ContentType=response['ContentType']
            )
            
            print(f"Created thumbnail: {thumbnail_key}")
            
        except Exception as e:
            print(f"Error processing {key}: {e}")
            raise
    
    return {'statusCode': 200, 'body': 'Success'}
```

## Best Practices

```yaml
Performance:
  - Use async processing
  - Batch small files
  - Set appropriate Lambda timeout
  - Monitor execution duration
  - Use SQS for high volume

Reliability:
  - Implement idempotency
  - Use dead letter queues
  - Handle retries gracefully
  - Log all processing
  - Monitor failures

Cost:
  - Filter events precisely
  - Use SQS for batching
  - Optimize Lambda memory/timeout
  - Clean up test notifications
  - Monitor request counts

Security:
  - Validate event source
  - Use least privilege IAM
  - Encrypt SNS/SQS
  - Enable CloudTrail
  - Implement error handling
```

## Monitoring & Debugging

```bash
# View Lambda logs
aws logs tail /aws/lambda/S3EventProcessor --follow

# Test event
aws lambda invoke \
  --function-name S3EventProcessor \
  --payload file://test-event.json \
  --cli-binary-format raw-in-base64-out \
  output.json

# Check SQS queue
aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/123456789012/s3-events-queue \
  --max-number-of-messages 10

# CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=S3EventProcessor \
  --statistics Sum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

## Troubleshooting

```yaml
Events Not Triggering:
  - Check notification configuration
  - Verify IAM permissions
  - Test with manual upload
  - Check event filters
  - Review CloudTrail logs

Lambda Timeouts:
  - Increase timeout setting
  - Optimize code
  - Use async processing
  - Monitor execution time

Duplicate Events:
  - Implement idempotency keys
  - Use SQS FIFO queues
  - Check for multiple triggers
  - Deduplicate in code

Permission Errors:
  - Verify Lambda permission
  - Check bucket policy
  - Review IAM roles
  - Use policy simulator
```

## Additional Resources

- [S3 Advanced README](README.md)
- [AWS S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- [Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html)
- [EventBridge with S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/EventBridge.html)
