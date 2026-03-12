# Hands-on SNS Guide: Console & CLI

This guide provides step-by-step instructions for creating and managing SNS topics and subscriptions using both the AWS Management Console and the AWS CLI.

## 1. Creating an SNS Topic

### Using the Management Console
1. Navigate to the **SNS Console**.
2. Select **Topics** in the left navigation pane.
3. Click **Create topic**.
4. **Type**: Choose **Standard** (default).
5. **Name**: `my-notification-topic`.
6. Click **Create topic**.

### Using the AWS CLI
```bash
# Create a standard topic
aws sns create-topic --name my-notification-topic

# Save the Topic ARN (required for all other operations)
TOPIC_ARN=$(aws sns list-topics --query 'Topics[?contains(TopicArn, `my-notification-topic`)].TopicArn' --output text)
echo "Topic ARN: $TOPIC_ARN"
```

## 2. Managing Subscriptions

### CLI: Subscribe an Email Address
```bash
aws sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol email \
    --notification-endpoint your-email@example.com
```
> [!IMPORTANT]
> You MUST check your email and click the **Confirm Subscription** link before you will receive messages.

### CLI: Subscribe an SQS Queue
```bash
# Get your SQS Queue ARN
QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

aws sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol sqs \
    --notification-endpoint $QUEUE_ARN
```

## 3. Publishing Messages

### CLI: Publishing a Plain Text Message
```bash
aws sns publish \
    --topic-arn $TOPIC_ARN \
    --message "This is a broadcast message to all subscribers." \
    --subject "System Alert"
```

### CLI: Publishing a Message with Message Attributes
Used for subscription filtering.
```bash
aws sns publish \
    --topic-arn $TOPIC_ARN \
    --message "Urgent update" \
    --message-attributes '{"Priority":{"DataType":"String","StringValue":"High"}}'
```

## 4. Subscription Filter Policies

Filter policies allow subscribers to receive only a subset of the messages sent to a topic.

### CLI: Create a Filter Policy
Create a `filter-policy.json` file:
```json
{
  "Priority": ["High", "Critical"]
}
```

```bash
# Replace [SUBSCRIPTION_ARN] with your actual subscription ARN
aws sns set-subscription-attributes \
    --subscription-arn [SUBSCRIPTION_ARN] \
    --attribute-name FilterPolicy \
    --attribute-value file://filter-policy.json
```

## 5. Cleaning Up
Remove resources to avoid unnecessary logs or costs.
```bash
# Delete the topic (this also removes all associated subscriptions)
aws sns delete-topic --topic-arn $TOPIC_ARN
```

---
**Next Step**: Explore [Advanced SNS Patterns & Troubleshooting](../../../../../../../03-advanced/02-phase-2/01-part-1-the-blueprint/01-cloud-architecture/01-enterprise-multi-cloud/11-application-integration/sns-advanced-patterns.md)
