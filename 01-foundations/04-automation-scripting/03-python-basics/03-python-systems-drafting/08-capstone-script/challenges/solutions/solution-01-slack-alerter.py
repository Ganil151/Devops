"""
Solution: Slack Notification Support
"""
import requests

def send_slack_alert(report, webhook_url):
    """Sends Slack notification for unhealthy servers."""
    unhealthy = [r['name'] for r in report['results'] if not r['healthy']]
    
    if not unhealthy:
        return True
        
    message = f"🚨 *Health Check Alert*\nUnhealthy Servers: {', '.join(unhealthy)}"
    
    payload = {"text": message}
    try:
        response = requests.post(webhook_url, json=payload, timeout=5)
        return response.status_code == 200
    except Exception:
        return False

if __name__ == "__main__":
    # Test would require a real webhook
    pass
