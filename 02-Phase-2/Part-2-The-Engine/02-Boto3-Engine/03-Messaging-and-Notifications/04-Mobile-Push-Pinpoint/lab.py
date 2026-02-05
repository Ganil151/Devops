import boto3
import logging
from botocore.exceptions import ClientError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def register_mobile_endpoint(app_id: str, device_token: str, platform: str, region: str = "us-east-1"):
    """
    Registers a mobile device token as a Pinpoint endpoint.
    
    Args:
        app_id (str): The Pinpoint Project (Application) ID.
        device_token (str): The token from FCM (Android) or APNs (iOS).
        platform (str): GCM (for Android) or APNS (for iOS).
        region (str): The AWS region.
    """
    pinpoint = boto3.client('pinpoint', region_name=region)
    
    try:
        logger.info(f"📱 Registering {platform} device endpoint...")
        
        response = pinpoint.create_platform_endpoint(
            ApplicationId=app_id,
            Platform=platform,
            Attributes={
                'Token': device_token,
                'Custom': {'UserRole': 'Admin'}
            }
        )
        
        endpoint_arn = response['EndpointArn']
        logger.info(f"✅ Device registered! Endpoint ARN: {endpoint_arn}")
        return endpoint_arn

    except ClientError as e:
        logger.error(f"❌ Pinpoint registration failed: {e.response['Error']['Message']}")
        return None

if __name__ == "__main__":
    # PARAMETERIZATION
    PINPOINT_APP_ID = "0123456789abcdef0123456789abcdef"
    SAMPLE_DEVICE_TOKEN = "APA91bEjU... (Sample FCM Token)"
    
    # Register an Android device
    register_mobile_endpoint(PINPOINT_APP_ID, SAMPLE_DEVICE_TOKEN, "GCM")
