# Hands-on SQS Guide: Console & CLI

This guide provides step-by-step instructions for creating and managing SQS queues using both the AWS Management Console and the AWS CLI.

## 1. Creating a Standard Queue

### Using the Management Console
1. Navigate to the **SQS Console**.
2. Click **Create queue**.
3. Choose **Standard** (default).
4. **Name**: `my-standard-queue`.
5. Configuration: Leave defaults for now (Visibility timeout: 30s, Delivery delay: 0, Receive message wait time: 0).
6. Click **Create queue**.

### Using the AWS CLI
```bash
# Create a standard queue
aws sqs create-queue --queue-name my-standard-queue

# Get the Queue URL (required for most operations)
QUEUE_URL=$(aws sqs get-queue-url --queue-name my-standard-queue --query 'QueueUrl' --output text)
echo "Queue URL: $QUEUE_URL"
```

## 2. Sending and Receiving Messages

### CLI: Send a Message
```bash
aws sqs send-message \
    --queue-url $QUEUE_URL \
    --message-body "Hello from the CLI!"
```

### CLI: Receive a Message
```bash
# Long Polling (wait up to 20 seconds for a message)
aws sqs receive-message \
    --queue-url $QUEUE_URL \
    --wait-time-seconds 20
```

> [!NOTE]
> When you receive a message, SQS returns a **ReceiptHandle**. You MUST use this handle to delete the message after processing.

### CLI: Delete a Message
```bash
# Replace [RECEIPT_HANDLE] with the handle from the previous command
aws sqs delete-message \
    --queue-url $QUEUE_URL \
    --receipt-handle [RECEIPT_HANDLE]
```

## 3. Configuring a Dead Letter Queue (DLQ)

A DLQ helps you isolate messages that fail to process.

### Step 1: Create the DLQ
```bash
aws sqs create-queue --queue-name my-dlq
DLQ_ARN=$(aws sqs get-queue-attributes \
    --queue-url $(aws sqs get-queue-url --queue-name my-dlq --query 'QueueUrl' --output text) \
    --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)
```

### Step 2: Link DLQ to the Source Queue
Create a `redrive-policy.json` file:
```json
{
  "deadLetterTargetArn": "[DLQ_ARN]",
  "maxReceiveCount": "3"
}
```
*(Replace `[DLQ_ARN]` with the actual ARN).*

```bash
aws sqs set-queue-attributes \
    --queue-url $QUEUE_URL \
    --attributes RedrivePolicy='{"deadLetterTargetArn":"'$DLQ_ARN'","maxReceiveCount":"3"}'
```

## 4. Advanced CLI Operations

### Purging a Queue
Remove all messages without deleting the queue itself.
```bash
aws sqs purge-queue --queue-url $QUEUE_URL
```

### Listing Queues
```bash
aws sqs list-queues --queue-name-prefix my-
```

## 5. Cleaning Up
Always delete your testing resources to avoid clutter.
```bash
aws sqs delete-queue --queue-url $QUEUE_URL
aws sqs delete-queue --queue-url $(aws sqs get-queue-url --queue-name my-dlq --query 'QueueUrl' --output text)
```

---
**Next Step**: Explore [Advanced SQS Patterns & Troubleshooting](../../../../../../../03-advanced/02-phase-2/01-part-1-the-blueprint/01-cloud-architecture/01-enterprise-multi-cloud/11-application-integration/sqs-advanced-patterns.md)
