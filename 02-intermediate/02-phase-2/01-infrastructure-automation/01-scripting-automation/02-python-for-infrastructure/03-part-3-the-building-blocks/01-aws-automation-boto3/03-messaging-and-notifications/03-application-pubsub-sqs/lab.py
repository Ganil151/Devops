import boto3
import json
import logging
from botocore.exceptions import ClientError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def trigger_fan_out_alert(topic_arn: str, event_id: str, severity: str, region: str = "us-east-1"):
    """
    Publishes a message to an SNS Topic that fans out to both an SQS queue and an Email address.
    
    Args:
        topic_arn (str): The ARN of the SNS Topic.
        event_id (str): A unique ID for the event.
        severity (str): The severity level (INFO, WARNING, CRITICAL).
        region (str): The AWS region.
    """
    sns = boto3.client('sns', region_name=region)
    
    # Create a structured JSON payload for downstream SQS consumers
    message_payload = {
        "event_id": event_id,
        "status": "triggered",
        "severity": severity,
        "timestamp": "2023-10-27T10:00:00Z", # In production, use datetime.now()
        "details": f"System Alert: {severity} level event detected."
    }
    
    try:
        logger.info(f"🔄 Triggering Fan-Out for Topic: {topic_arn}...")
        
        # Publish to the Topic
        response = sns.publish(
            TopicArn=topic_arn,
            Message=json.dumps(message_payload),
            Subject=f"ALERT: {severity} Event {event_id}" # Used by Email subscribers
        )
        
        logger.info(f"✅ Fan-Out successful! SNS Message ID: {response['MessageId']}")
        return response['MessageId']

    except ClientError as e:
        logger.error(f"❌ Fan-Out Failed: {e.response['Error']['Code']}")
        return None

if __name__ == "__main__":
    # PARAMETERIZATION
    # In a real scenario, this Topic would have an SQS queue and an Email address subscribed to it.
    ALARM_TOPIC = "arn:aws:sns:us-east-1:123456789012:SystemAlerts"
    
    trigger_fan_out_alert(
        topic_arn=ALARM_TOPIC,
        event_id="EVT-101",
        severity="CRITICAL"
    )
