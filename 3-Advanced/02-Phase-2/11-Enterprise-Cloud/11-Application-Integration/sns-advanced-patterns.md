# Advanced SNS Patterns & Troubleshooting

A deep dive into complex SNS architectures, security hardening, and production-level troubleshooting.

## 1. Advanced Architectural Patterns

### SNS-to-SQS Fan-out (Enterprise Architecture)
This is the "Golden Path" for decoupling.
- **Reliability**: SQS provides a buffer if the consuming service is down.
- **Scalability**: Each consumer can scale its SQS processing independently.

### Message Archiving & Replay
SNS can now natively archive messages in a topic.
- **Benefit**: You can "replay" (re-publish) archived messages to a specific subscription during a specific time range. Great for disaster recovery or testing new services with old data.
```bash
# Set Archive Policy on a topic
aws sns set-topic-attributes \
    --topic-arn $TOPIC_ARN \
    --attribute-name ArchivePolicy \
    --attribute-value '{"MessageRetentionPeriod": 30}'
```

### Mobile Push Notifications
SNS can send push notifications directly to iOS/Android devices.
- Uses **Platform Application Objects** (GCM/FCM for Android, APNs for iOS).
- Scales to millions of notifications per second.

## 2. Advanced Security & Data Protection

### Encryption at Rest (SSE-KMS)
Protect sensitive data in your messages.
```bash
aws sns set-topic-attributes \
    --topic-arn $TOPIC_ARN \
    --attribute-name KmsMasterKeyId \
    --attribute-value alias/aws/sns
```

### Topic Policies (Cross-Account Access)
Allow a service in another AWS account to publish to your topic.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::OTHER_ACCOUNT_ID:root" },
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:us-east-1:MY_ACCOUNT_ID:my-topic"
    }
  ]
}
```

## 3. Reliability & Dead Letter Queues (DLQ)

Unlike SQS where the *consumer* manages failures, in SNS, the *subscription* manages failures.
- **Retries**: SNS has a default retry policy (exponential backoff).
- **DLQ**: If all retry attempts fail, SNS sends the message to an SQS queue designated as a DLQ for that subscription.

```bash
# Add DLQ to a subscription
aws sns set-subscription-attributes \
    --subscription-arn [SUBSCRIPTION_ARN] \
    --attribute-name RedrivePolicy \
    --attribute-value '{"deadLetterTargetArn": "[QUEUE_ARN]"}'
```

## 4. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Email/SMS not received** | Subscription not confirmed | Check your inbox and click the confirmation link. Check spam. |
| **Messages missing in SQS** | Missing SQS Queue Policy | The SQS queue must have a resource-based policy allowing `sns:SendMessage` from the SNS Topic. |
| **Lambda not triggered** | Inactive trigger | Ensure the SNS Topic is added as a trigger in the Lambda Console. |
| **Access Denied** | IAM Policy insufficient | Ensure the publisher has `sns:Publish` permission for the specific Topic ARN. |

## 5. SNS Hacks & Performance Pro-Tips

### Logging Delivery Status
Enable **CloudWatch Logs** for your delivery status (Success/Failure) to see exactly why a message failed to reach an endpoint.
```bash
# Enable logging for Lambda endpoints
aws sns set-topic-attributes \
    --topic-arn $TOPIC_ARN \
    --attribute-name LambdaSuccessFeedbackSampleRate \
    --attribute-value "100"
```

### The "S3 Extended Client" for SNS
Just like SQS, you can use the S3 Extended Client pattern to send messages larger than **256 KB** by passing an S3 link in the SNS message.

## Summary Checklist
- [ ] Transition critical topics to FIFO for strict ordering and deduplication.
- [ ] Enforce KMS encryption for all sensitive notification topics.
- [ ] Configure DLQs for every production subscription.
- [ ] Use Filter Policies to minimize unnecessary processing in downstream services.
- [ ] Enable Delivery Status logging for audit trails and troubleshooting.
