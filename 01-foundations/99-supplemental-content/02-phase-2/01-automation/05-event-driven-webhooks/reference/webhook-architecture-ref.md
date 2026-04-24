# 🪝 Webhook Architecture & Fundamentals
*Version 1.0 | Mastering the "Push" Model of Automation*

---

## 📖 Overview
A webhook is an HTTP callback: an HTTP POST that occurs when something happens; a simple event-notification via HTTP POST. While standard APIs follow a "Pull" model (Client asks Server), Webhooks follow a "Push" model (Server tells Client).

---

## 🏗️ Core Architecture Components

### 1. The Trigger (The Source)
The event that starts the process (e.g., `git push`, `invoice.paid`, `alert.critical`).
- **Examples**: GitHub, Stripe, PagerDuty, AWS EventBridge.

### 2. The Payload (The Message)
The data sent to the listener, usually in **JSON** format.
- **Key Fields**: Event Type, Timestamp, Resource ID, and Signature Header (for security).

### 3. The Listener (The Target)
A server or serverless function exposed via a public URL that handles the POST request.
- **SRE Target**: AWS Lambda, Google Cloud Run, or a FastAPI listener on EC2.

---

## ⚙️ Push vs. Pull Comparison

| Feature | Pull (Polling) | Push (Webhook) |
| :--- | :--- | :--- |
| **Efficiency** | Low (Empty requests) | High (Only on activity) |
| **Latency** | Variable (Interval based) | Near-Real-Time |
| **Reliability** | Controlled by client | Dependent on source retry logic |
| **Complexity** | Simple | Requires public URL & Security |

---

## 🚀 SRE Safety Standards

### 1. The "Acknowledge First" Pattern
Webhook sources have short timeouts (usually 3-10 seconds).
**Rule**: Receive the request, immediately return a `200 OK`, and then process the logic asynchronously in the background.

### 2. Retry Logic & Idempotency
If your listener is down, the source will retry.
**Rule**: Always ensure your webhook handler is **Idempotent**. Processing the same `payment_intent_succeeded` event twice should not charge the customer twice.

### 3. Endpoint Obfuscation
Never use obvious URLs like `/webhooks/github`. Use a secret path: `/webhooks/v1/a8b2-98c1-f2e3-github`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the benefits of "Asynchronous Processing" in a webhook handler.**
2. **What is a "Thundering Herd" problem in the context of global webhooks?**
3. **Difference between a Webhook and a Web Socket?**
4. **How do you handle "Head of Line Blocking" when receiving thousands of webhooks per second?**
5. **Describe the role of a "Message Queue" (SQS/RabbitMQ) in a robust webhook architecture.**

---
**Next Step**: [Webhook Security & Verification →](./webhook-security-verification-ref.md)
