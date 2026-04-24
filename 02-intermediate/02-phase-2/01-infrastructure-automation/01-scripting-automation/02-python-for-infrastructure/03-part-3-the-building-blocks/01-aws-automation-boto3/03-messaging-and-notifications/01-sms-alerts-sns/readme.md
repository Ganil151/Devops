# 📱 SMS Alerts with SNS (Simple Notification Service)

Amazon SNS is a managed service that provides message delivery from publishers to subscribers. In this lab, we focus on the most direct way to alert a human: **SMS**.

## 🚀 Key Concept: sns.publish
The `publish` method is the core of SNS. It allows you to send a message to a **Topic** (which alerts all subscribers) or directly to a **Phone Number**.

## ⚠️ Security & Cost Warning
*   **SMS Spend Limits**: AWS has a default monthly spend limit (usually $1.00 for new accounts). If you exceed this, SMS delivery will fail silently. You must request a limit increase for production use.
*   **SNS Sandbox**: New AWS accounts are placed in the "SMS Sandbox." You can only send messages to **verified** phone numbers until you move to production mode. This prevents spam abuse.
*   **Global Pricing**: SMS costs vary wildly by country. Sending a message to the US is cheap; sending to some parts of Europe or Asia can be 10-20x more expensive.

## 🛠️ The Staff Standard Pattern
When writing notification scripts, never hardcode your ARNs. Always use variables and handle API errors gracefully using `botocore.exceptions.ClientError`.

---

## 💻 Lab: Sending a Direct SMS
See `lab.py` for a production-grade implementation.
