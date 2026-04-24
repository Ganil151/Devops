import os
import sys

# ---------------------------------------------------------------------
# PYTHON CRONTAB MANAGER BOILERPLATE
# ---------------------------------------------------------------------
# Requirements: pip install python-crontab
# ---------------------------------------------------------------------

try:
    from crontab import CronTab
except ImportError:
    print("ERROR: 'python-crontab' library not found.")
    print("Install it using: pip install python-crontab")
    sys.exit(1)

def manage_devops_jobs():
    # 1. Access the crontab for the current user
    cron = CronTab(user=True)
    
    # 2. Define a clear comment pattern for our automation
    COMMENT_TAG = "DEVOPS_AUTO_TASK"

    # 3. Add a new job if it doesn't exist
    job_exists = False
    for job in cron.find_comment(COMMENT_TAG):
        job_exists = True
        print(f"Found existing job: {job}")

    if not job_exists:
        # Define command with absolute path
        cmd = "/usr/bin/python3 /Users/Ganil/Documents/Devops/scripts/health_check.py"
        new_job = cron.new(command=cmd, comment=COMMENT_TAG)
        
        # Schedule: Every 30 minutes
        new_job.minute.every(30)
        
        print(f"Adding new job: {cmd}")
        cron.write()
    else:
        print("Job already exists. Skipping.")

if __name__ == "__main__":
    manage_devops_jobs()
