# 🛠️ Observability Challenges

## Challenge 1: The Dry-Run Switch
**Objective**: Build a script that deletes a file but has a safety switch.
1.  Variable: `DRY_RUN = True`.
2.  If `DRY_RUN` is True, print "[PLAN] Would remove file: {name}".
3.  If `DRY_RUN` is False, actually call `os.remove()`.
4.  Use `argparse` to allow the user to toggle dry run with `--run` or `--force`.

## Challenge 2: Heartbeat Logger
**Objective**: Log a "Success" message to a file every time the script finishes.
1.  Script Name: `heartbeat.py`.
2.  Log format: `TIMESTAMP | SCRIPT_NAME | STATUS`.
3.  Example: `2024-01-01 12:00:00 | heartbeat.py | SUCCESS`.
4.  Ensure the log file is *appended* to, not overwritten.

## Challenge 3: Slack Alert Simulation
**Objective**: Notify on failure.
1.  Wrap your main logic in a `try...except`.
2.  On `except`, call a function `send_alert(error_msg)`.
3.  Inside `send_alert`, print a formatted block with emojis: `🚨 ALERT: Script failed with error {error}`.
4.  In production, this would be a real API call to Slack or PagerDuty.
