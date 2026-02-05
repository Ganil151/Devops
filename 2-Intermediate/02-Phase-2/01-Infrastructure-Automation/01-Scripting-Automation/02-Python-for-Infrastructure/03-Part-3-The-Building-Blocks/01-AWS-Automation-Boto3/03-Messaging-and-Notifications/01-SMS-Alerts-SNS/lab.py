import boto3
import logging
from botocore.exceptions import ClientError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def send_urgent_sms(phone_number: str, message: str, region: str = "us-east-1"):
    """
    Sends a direct SMS message to a phone number using Amazon SNS.
    
    Args:
        phone_number (str): The destination phone number in E.164 format (e.g., +1234567890).
        message (str): The content of the SMS.
        region (str): The AWS region to use for the SNS client.
    """
    # Initialize the SNS Client
    sns = boto3.client('sns', region_name=region)
    
    try:
        logger.info(f"🚀 Attempting to send SMS to {phone_number}...")
        
        # Publish the message
        response = sns.publish(
            PhoneNumber=phone_number,
            Message=message,
            MessageAttributes={
                'AWS.SNS.SMS.SenderID': {
                    'DataType': 'String',
                    'StringValue': 'DevOpsAlert'
                },
                'AWS.SNS.SMS.SMSType': {
                    'DataType': 'String',
                    'StringValue': 'Transactional' # 'Transactional' for critical, 'Promotional' for non-critical
                }
            }
        )
        
        message_id = response.get('MessageId')
        logger.info(f"✅ SMS sent successfully! Message ID: {message_id}")
        return message_id

    except ClientError as e:
        error_code = e.response['Error']['Code']
        logger.error(f"❌ Failed to send SMS: {error_code}")
        
        if error_code == 'EndpointDisabled':
            logger.error("🚨 The phone number endpoint is disabled.")
        elif error_code == 'AuthorizationError':
            logger.error("🚨 Permission denied. Check your IAM policy.")
        else:
            logger.error(f"🚨 Unexpected API Error: {e}")
        return None

if __name__ == "__main__":
    # PARAMETERIZATION: Avoid hardcoding sensitive info in production
    # Ensure your phone number is verified in the SNS Sandbox!
    TARGET_PHONE = "+10000000000" # Replace with your verified number
    ALERT_MSG = "⚠️ CRITICAL: Production Database reaching 95% capacity!"
    
    send_urgent_sms(TARGET_PHONE, ALERT_MSG)
