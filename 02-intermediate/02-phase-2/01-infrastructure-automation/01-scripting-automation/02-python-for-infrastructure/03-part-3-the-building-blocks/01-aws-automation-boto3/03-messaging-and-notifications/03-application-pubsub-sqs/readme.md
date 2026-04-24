# 🔄 Fan-Out Architecture: SNS to SQS

In high-scale systems, we don't send individual messages to every service. We use the **Fan-Out** pattern.

## 🚀 Key Concept: Decoupling
By publishing a message to an **SNS Topic**, and having an **SQS Queue** subscribe to that topic, you decouple your producer from your consumer. 
*   **SNS** handles the broadcast.
*   **SQS** handles the reliable storage of those messages until they are processed.

## 📡 Why use Fan-Out?
Imagine a "Server Startup" event. You want to:
1. Update an Inventory Database.
2. Send an Email to the SRE team.
3. Trigger a Security Audit Lambda.

Instead of your script calling 3 different APIs, it calls **one** (SNS Publish). The SNS Topic then "fans out" the message to the Database's SQS Queue, the SRE's email, and the Lambda function.

## 🛠️ The Staff Standard Pattern
*   **TopicArn**: Never hardcode the ARN. Pass it as a variable.
*   **JSON Payloads**: For service-to-service communication, send messages as JSON strings so they are easy for SQS consumers to parse.

---

## 💻 Lab: The Fan-Out Implementation
See `lab.py` for a script that triggers a multi-channel alert via a single SNS publish.
