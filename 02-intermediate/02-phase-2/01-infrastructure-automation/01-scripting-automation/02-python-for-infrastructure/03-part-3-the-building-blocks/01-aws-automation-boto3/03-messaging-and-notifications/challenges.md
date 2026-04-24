# 🏆 Junior DevOps Messaging Challenges

Put your knowledge of SNS and SES into practice with these real-world scenarios.

---

## 🌩️ Challenge 1: The "Disk-Space Alert"
**Scenario**: You have a mission-critical log folder on a local server. If this folder exceeds 90% of its disk capacity, it can cause the application to crash.

**Your Task**:
1. Write a Python script called `disk_monitor.py`.
2. The script should check the disk usage of a specific path (use the `shutil` module).
3. If usage is **> 90%**, the script must send an **SMS via SNS** to the on-call engineer.
4. If usage is **< 90%**, it should just log "Disk Healthy" and exit.

**Staff Requirements**:
- Parameterize the `THRESHOLD` and `PHONE_NUMBER`.
- Use `logging` to record the check outcome.
- Handle `ClientError` for any Boto3 API calls.

---

## 📧 Challenge 2: The "Welcome Email"
**Scenario**: Your company is growing fast! The HR team is tired of manually emailing new DevOps engineers their "Welcome" packet.

**Your Task**:
1. Write a Python script called `bulk_welcome.py`.
2. The script should take a list of email addresses: `['new-hire1@example.com', 'new-hire2@example.com']`.
3. For each email in the list, send a professional "Welcome to the DevOps Team!" email via **SES**.
4. The email body must be personalized (e.g., "Hello, [Email Address], welcome to the team!").

**Staff Requirements**:
- Use a **verified sender** email address.
- Ensure the script doesn't crash if one email address fails (use a loop with `try/except`).
- Log a summary at the end: "Total emails sent: X, Total failures: Y."

---

## 💡 Submission Guidelines
- No hardcoded strings! (Use variables or environment variables).
- Include comments explaining *why* you are using `ClientError`.
- Ensure your code is PEP 8 compliant.
