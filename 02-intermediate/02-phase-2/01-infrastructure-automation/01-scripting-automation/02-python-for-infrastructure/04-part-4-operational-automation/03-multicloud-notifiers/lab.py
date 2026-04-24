import os
import requests
import logging

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def get_cloud_provider():
    """
    Attempts to detect the current cloud provider using metadata service timeouts.
    Simplified version for the lab.
    """
    # In a real scenario, you'd use a small timeout to poll 169.254.169.254
    # For this lab, we will use an environment variable 'CLOUD_PROVIDER'
    return os.getenv("CLOUD_PROVIDER", "UNKNOWN").upper()

def send_unified_alert(alert_type: str, details: str):
    """
    Sends a Slack alert with cloud-provider branding.
    """
    provider = get_cloud_provider()
    webhook_url = os.getenv("SLACK_WEBHOOK_URL")

    if not webhook_url:
        logger.error("🚨 SLACK_WEBHOOK_URL missing.")
        return

    # Dynamic branding based on provider
    icons = {
        "AWS": "☁️🧡",
        "AZURE": "☁️💙",
        "GCP": "☁️💚",
        "UNKNOWN": "❓"
    }
    
    provider_icon = icons.get(provider, "❓")
    
    payload = {
        "text": f"{provider_icon} *[{provider}] ALERT: {alert_type}*\n_{details}_"
    }

    try:
        response = requests.post(webhook_url, json=payload)
        response.raise_for_status()
        logger.info(f"✅ Unified alert sent for {provider}")
    except Exception as e:
        logger.error(f"❌ Failed to send unified alert: {e}")

if __name__ == "__main__":
    # Simulate running on AWS
    os.environ["CLOUD_PROVIDER"] = "AWS"
    send_unified_alert("Resource Cleanup", "Successfully deleted 14 unattached EBS volumes.")
    
    # Simulate running on Azure
    os.environ["CLOUD_PROVIDER"] = "AZURE"
    send_unified_alert("Storage Alert", "Blob storage 'backup-archive' reached 80% quota.")
