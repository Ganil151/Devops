# 🦅 The Unified Dispatcher: Building Your DevOps Library

In the previous labs, you learned how to talk to Slack (using Webhooks) and Jira (using the REST API). Now, it's time to build a **Unified Library**.

## 🚀 The Philosophy: "Write Once, Notify Everywhere"
A Senior DevOps Engineer doesn't rewrite Slack integration code for every script. Instead, they build a `notify.py` module that can be imported into any project. This module acts as the "Dispatcher."

## 🏗️ What's in the Library?
Your notification library should handle:
1.  **Transport Logic**: The "Mechanical" stuff like headers, timeouts, and JSON encoding.
2.  **Environment Logic**: Automatically pulling secrets from the OS environment.
3.  **Routing**: Deciding which alert goes where (e.g., Warnings go to Slack, Criticals go to Jira AND Slack).

## 🛠️ The Staff Standard: Object-Oriented Notifications
By wrapping your logic in a `DevOpsNotifier` class, you can maintain state (like the Jira connection) across multiple calls, making your scripts faster and cleaner.

---

## 💻 Lab: Building and Using the Library
1.  **`notify.py`**: A clean, reusable Python module.
2.  **`app.py`**: A simulation script that imports `notify.py` to handle a production incident.

[Go to the code ->](./notify.py)
