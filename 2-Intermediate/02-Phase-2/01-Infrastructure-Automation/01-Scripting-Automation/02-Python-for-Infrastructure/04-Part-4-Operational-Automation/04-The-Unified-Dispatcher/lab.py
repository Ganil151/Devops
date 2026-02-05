from notify import DevOpsNotifier
import logging

# Configure professional logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def main():
    # 1. Initialize our unified library
    notifier = DevOpsNotifier()

    # 2. Simulate an event discovery
    logger.info("🕵️ Monitoring script checking RDS status...")
    
    # CASE A: Low priority info
    notifier.dispatch_alert(
        title="Backup Starting",
        description="Routine automated backup for 'prod-db' has started.",
        severity="INFO"
    )

    # CASE B: A production crisis
    logger.warning("🚨 ALERT: Database connection timeout detected!")
    
    notifier.dispatch_alert(
        title="DB-TIMEOUT-01",
        description="Unable to reach 'prod-db' at 10.0.1.5. Application latency increasing.",
        severity="CRITICAL",
        jira_project="OPS" # This will trigger Jira ticket creation!
    )

if __name__ == "__main__":
    main()
