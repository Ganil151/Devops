import os
import json
import logging
import requests
from jira import JIRA
from jira.exceptions import JIRAError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

class DevOpsNotifier:
    """
    A unified notification library for Slack and Jira.
    Designed for use across all DevOps automation scripts.
    """
    def __init__(self):
        # Load variables from environment
        self.slack_webhook = os.getenv("SLACK_WEBHOOK_URL")
        self.jira_server = os.getenv("JIRA_SERVER")
        self.jira_user = os.getenv("JIRA_USER_EMAIL")
        self.jira_token = os.getenv("JIRA_API_TOKEN")
        self._jira_conn = None

    def _get_jira_connection(self):
        """Lazy initialization of Jira connection."""
        if not self._jira_conn:
            if all([self.jira_server, self.jira_user, self.jira_token]):
                try:
                    self._jira_conn = JIRA(
                        server=self.jira_server, 
                        basic_auth=(self.jira_user, self.jira_token)
                    )
                except JIRAError as e:
                    logger.error(f"❌ Failed to connect to Jira: {e}")
            else:
                logger.warning("⚠️ Jira credentials incomplete. Jira tasks will be skipped.")
        return self._jira_conn

    def slack_notify(self, title: str, message: str, severity: str = "INFO"):
        """Sends a formatted alert to Slack."""
        if not self.slack_webhook:
            logger.error("❌ Cannot send Slack alert: SLACK_WEBHOOK_URL is missing.")
            return False

        # Map severity to emojis
        icons = {"INFO": "ℹ️", "WARNING": "⚠️", "CRITICAL": "🚨"}
        icon = icons.get(severity.upper(), "❓")

        payload = {
            "blocks": [
                {"type": "header", "text": {"type": "plain_text", "text": f"{icon} {title}"}},
                {"type": "section", "text": {"type": "mrkdwn", "text": f"*Severity*: {severity}\n*Details*: {message}"}}
            ]
        }

        try:
            res = requests.post(self.slack_webhook, json=payload, timeout=10)
            res.raise_for_status()
            logger.info("✅ Slack notification sent.")
            return True
        except Exception as e:
            logger.error(f"❌ Slack notification failed: {e}")
            return False

    def jira_incident(self, project: str, summary: str, description: str):
        """Idempotently creates a Jira incident ticket."""
        jira = self._get_jira_connection()
        if not jira:
            return None

        try:
            # Check for existing open tickets with similar summary (Idempotency)
            query = f'project = "{project}" AND summary ~ "{summary}" AND statusCategory != Done'
            exists = jira.search_issues(query)
            
            if exists:
                logger.info(f"📍 Mirroring to existing ticket: {exists[0].key}")
                jira.add_comment(exists[0], f"Automatic Update: {description}")
                return exists[0].key

            # Create new issue
            issue_dict = {
                'project': {'key': project},
                'summary': summary,
                'description': description,
                'issuetype': {'name': 'Incident'},
                'priority': {'name': 'High'}
            }
            new_issue = jira.create_issue(fields=issue_dict)
            logger.info(f"✅ Jira ticket created: {new_issue.key}")
            return new_issue.key
        except JIRAError as e:
            logger.error(f"❌ Jira API Error: {e.text}")
            return None

    def dispatch_alert(self, title: str, description: str, severity: str = "INFO", jira_project: str = None):
        """
        Global dispatcher. 
        - Always sends to Slack.
        - Only sends to Jira if severity is CRITICAL or WARNING and jira_project is provided.
        """
        self.slack_notify(title, description, severity)

        if severity.upper() in ["CRITICAL", "WARNING"] and jira_project:
            self.jira_incident(jira_project, title, description)
