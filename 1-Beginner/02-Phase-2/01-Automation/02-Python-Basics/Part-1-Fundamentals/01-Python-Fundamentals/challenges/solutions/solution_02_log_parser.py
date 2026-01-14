"""
Solution: Log Level Parser
"""

log_entry = "2024-01-20 10:00:05 [CRITICAL] Database connection failed "
clean_log = log_entry.strip()

is_db_error = "Database" in clean_log
timestamp = clean_log[:19]  # Slicing

if "[CRITICAL]" in clean_log and is_db_error:
    print(f"Alert! Database Issue at {timestamp}")
else:
    print("Log normal.")
