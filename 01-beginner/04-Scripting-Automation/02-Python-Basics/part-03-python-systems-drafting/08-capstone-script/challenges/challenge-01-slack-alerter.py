"""
Challenge: Slack Notification Support
Scenario: You want to extend your health monitor to alert the SRE team on Slack 
whenever a server is marked as UNHEALTHY.

TODO: Implement `send_slack_alert(report, webhook_url)`.
1. Extract 'unhealthy' servers from the `report`.
2. Construct a message string listing the names of failed servers.
3. Use `requests.post()` to send the message to the `webhook_url`.
4. Return `True` if the request was successful (status 200).
"""
import requests

def send_slack_alert(report, webhook_url):
    """
    Sends a Slack alert if there are any unhealthy servers.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    sample_report = {
        "summary": {"unhealthy": 1},
        "results": [
            {"name": "web-01", "healthy": True},
            {"name": "db-01", "healthy": False, "status": "Connection Error"}
        ]
    }
    # Mock URL
    # send_slack_alert(sample_report, "https://hooks.slack.com/services/...")
