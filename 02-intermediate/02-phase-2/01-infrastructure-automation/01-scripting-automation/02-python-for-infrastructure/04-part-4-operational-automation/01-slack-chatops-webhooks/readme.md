# 💬 Slack ChatOps: Mastering Webhooks

The easiest way to start with ChatOps is the **Incoming Webhook**. It allows you to "Push" data from your Python scripts directly into a Slack channel.

## 🚀 Key Concept: Webhooks vs. APIs
*   **Incoming Webhooks (Push)**: AWS/Python tells Slack what happened. Simple, requires a unique URL, and is one-way (Send only). Perfect for alerts.
*   **Slack Web API (Pull/Interactivity)**: Python asks Slack for info or handles button clicks. Two-way, complex, requires an OAuth token.

## 🧱 Slack Block Kit
Don't just send plain text like `"Server down"`. Use **Slack Blocks** to send rich, actionable messages with headers, bold text, and images.

## 🛠️ The Staff Standard: Secret Management
Your Webhook URL is a **secret**. If leaked, anyone can post to your channel. 
*   **Pattern**: Use `SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")`.
*   **Fail Fast**: If the environment variable is missing, the script should exit with a clear error.

---

## 💻 Lab: The Rich Notifier
See `lab.py` for an implementation that sends a formatted Slack Block for a system alert.
