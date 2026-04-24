import boto3
import logging
from botocore.exceptions import ClientError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def send_automated_report(sender: str, recipient: str, subject: str, body_text: str, region: str = "us-east-1"):
    """
    Sends an email using Amazon SES.
    
    Args:
        sender (str): The verified email address you are sending FROM.
        recipient (str): The email address you are sending TO.
        subject (str): The subject line of the email.
        body_text (str): The plain text content of the email.
        region (str): The AWS region to use.
    """
    # Initialize the SES Client
    ses = boto3.client('ses', region_name=region)
    
    try:
        logger.info(f"📧 Sending report from {sender} to {recipient}...")
        
        # Send the email
        response = ses.send_email(
            Source=sender,
            Destination={
                'ToAddresses': [recipient]
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': body_text,
                        'Charset': 'UTF-8'
                    }
                    # Optional: Add Html body here
                }
            }
        )
        
        message_id = response['MessageId']
        logger.info(f"✅ Email sent! Message ID: {message_id}")
        return message_id

    except ClientError as e:
        error_code = e.response['Error']['Code']
        logger.error(f"❌ SES Failed: {error_code}")
        
        if error_code == 'MessageRejected':
            logger.error("🚨 Account is in Sandbox or identity not verified.")
        elif error_code == 'DailyQuotaExceeded':
            logger.error("🚨 Sending limit reached for the day.")
        else:
            logger.error(f"🚨 Unexpected Error: {e}")
        return None

if __name__ == "__main__":
    # PARAMETERIZATION
    VERIFIED_SENDER = "admin@yourdomain.com" # Must be verified in SES!
    RECIPIENT = "sre-team@yourdomain.com"
    SUBJECT = "Weekly Backup Audit: SUCCESS"
    REPORT = """
    Audit Summary:
    - Region: us-east-1
    - Total Backups: 142
    - Failed Backups: 0
    - Storage Saved: 1.2TB
    """
    
    send_automated_report(VERIFIED_SENDER, RECIPIENT, SUBJECT, REPORT)
