import os
import logging
from jira import JIRA
from jira.exceptions import JIRAError

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def manage_incident_ticket(project_key: str, summary: str, description: str):
    """
    Creates a Jira ticket if it doesn't already exist, or adds a comment if it does.
    """
    # SECRET MANAGEMENT
    server = os.getenv("JIRA_SERVER") # e.g., "https://your-company.atlassian.net"
    email = os.getenv("JIRA_USER_EMAIL")
    token = os.getenv("JIRA_API_TOKEN")

    if not all([server, email, token]):
        logger.error("🚨 Jira credentials missing in environment variables!")
        return None

    try:
        # Connect to Jira
        jira = JIRA(server=server, basic_auth=(email, token))

        # IDEMPOTENCY: Check if an open ticket with this summary already exists
        jql_query = f'project = "{project_key}" AND summary ~ "{summary}" AND statusCategory != Done'
        existing_issues = jira.search_issues(jql_query)

        if existing_issues:
            issue = existing_issues[0]
            logger.info(f"📍 Existing ticket found: {issue.key}. Adding comment...")
            jira.add_comment(issue, "Update: The incident is still ongoing. Automated re-check failed.")
            return issue.key
        
        # CREATE: If no existing issue, open a new one
        logger.info(f"🆕 Creating new Jira ticket in project {project_key}...")
        issue_dict = {
            'project': {'key': project_key},
            'summary': summary,
            'description': description,
            'issuetype': {'name': 'Incident'},
            'priority': {'name': 'High'},
            'labels': ['automated', 'python-bot']
        }
        
        new_issue = jira.create_issue(fields=issue_dict)
        logger.info(f"✅ Ticket created: {new_issue.key}")
        return new_issue.key

    except JIRAError as e:
        logger.error(f"❌ Jira API Error: {e.text}")
        return None
    except Exception as e:
        logger.error(f"❌ Unexpected error in Jira automation: {e}")
        return None

if __name__ == "__main__":
    # Example usage
    manage_incident_ticket(
        project_key="OPS",
        summary="DB Connection Timeout - us-east-1",
        description="Automated check failed: Unable to connect to RDS 'prod-db' after 3 retries."
    )
