# 🏆 Junior DevOps ChatOps Challenges

Apply your knowledge of Webhooks and APIs to bridge the gap between Chat and Tickets.

---

## 🌩️ Challenge 1: The "Auto-Responder"
**Scenario**: Your team is overwhelmed by Slack messages. You want to ensure that any "Urgent" request in the `#ops-support` channel is automatically tracked in Jira.

**Your Task**:
1. Create a script called `slack_to_jira.py`.
2. The script should simulate receiving a Slack message (use a list of strings).
3. If a message contains the word **"Urgent"** or **"Outage"**:
    - Use the `jira` library to open an "Incident" ticket.
    - Include the Slack user's name (simulated) in the Jira description.
4. If a ticket is created, send a message back to Slack (using a webhook) saying: `"Ticket created: [KEY]. An engineer has been notified."`

**Staff Requirements**:
- Implement **idempotency**: Don't create a second Jira ticket if the Slack user posts the same "Urgent" message multiple times within an hour.
- Use `os.getenv()` for all API credentials.

---

## 📧 Challenge 2: The "Health Check Bot"
**Scenario**: You have a mission-critical web endpoint. If it goes down, customers lose money.

**Your Task**:
1. Write a Python script called `health_bot.py`.
2. The script should use `requests.get()` to check a URL (parameterized).
3. **The Failure Flow**: If the site returns a `500` or `404` error:
    - Create a Jira ticket assigned to the "On-Call" user.
    - Send a rich Slack Block notification with a red "CRITICAL" header.
4. **The Resolution Flow**: If the site returns a `200 OK` BUT there is an open Jira ticket for it:
    - Add a comment to the Jira ticket: `"System recovered. Verifying state..."`
    - Transition the ticket to "Resolved."
    - Send a green "RECOVERED" Slack message.

**Staff Requirements**:
- Log Every step: "Checking health...", "Failure detected...", "Jira ticket updated...".
- Use `botocore.exceptions.ClientError` if you decide to integrate AWS Secrets Manager for the tokens (Optional).

---

## 💡 Submission Guidelines
- No hardcoded strings!
- Use a single `config.py` or environment variables for all URLs and Tokens.
- Ensure your code includes professional error handling for network timeouts.
