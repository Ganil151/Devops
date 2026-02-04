import os
import requests
import json
import logging

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def send_slack_alert(channel_name: str, message_title: str, details: str):
    """
    Sends a rich formatted message to Slack using Incoming Webhooks.
    """
    # SECRET MANAGEMENT: Load from environment variable
    webhook_url = os.getenv("SLACK_WEBHOOK_URL")
    
    if not webhook_url:
        logger.error("🚨 SLACK_WEBHOOK_URL not found in environment variables!")
        return False

    # PAYLOAD FORMATTING: Using Slack Block Kit for rich UI
    payload = {
        "channel": channel_name,
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"🚨 {message_title}"
                }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Source:*\nPython Automation"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Environment:*\nProduction"
                    }
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Details:*\n{details}"
                }
            },
            {
                "type": "divider"
            }
        ]
    }

    try:
        response = requests.post(
            webhook_url, 
            data=json.dumps(payload),
            headers={'Content-Type': 'application/json'}
        )
        
        # Check for HTTP errors
        response.raise_for_status()
        
        logger.info(f"✅ Slack alert sent successfully to {channel_name}")
        return True

    except requests.exceptions.HTTPError as e:
        logger.error(f"❌ Slack API returned an error: {e.response.text}")
        return False
    except Exception as e:
        logger.error(f"❌ Unexpected error sending Slack alert: {e}")
        return False

if __name__ == "__main__":
    # Example usage (Ensure SLACK_WEBHOOK_URL is set in your terminal)
    # export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
    
    send_slack_alert(
        channel_name="#ops-alerts",
        message_title="High CPU Usage Detected",
        details="Microservice 'Auth-Service' is at 94% CPU in us-east-1."
    )
