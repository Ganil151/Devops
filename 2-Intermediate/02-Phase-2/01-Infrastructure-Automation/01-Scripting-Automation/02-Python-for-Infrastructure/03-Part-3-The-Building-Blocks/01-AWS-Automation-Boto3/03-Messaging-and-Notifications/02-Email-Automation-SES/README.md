# 📧 Email Automation with SES (Simple Email Service)

Amazon SES is a cost-effective, flexible, and scalable email service that enables developers to send mail from within any application.

## 🚀 Key Concept: ses.send_email
While there is a `send_raw_email` for complex attachments, **`send_email`** is the standard for transactional messages. It handles the formatting of headers and body so you don't have to worry about the underlying SMTP protocol.

## 🛡️ The Identity Wall (Verification)
You cannot simply spoof an email address (e.g., from `"CEO@company.com"`) using SES. 
*   **Verification**: Before you can send email *from* an address, you must verify it. AWS will send a confirmation email to that address, or you must verify the entire domain via DNS records (DKIM).
*   **The Sandbox**: Like SNS, SES starts in a sandbox. You can only send email **to** verified addresses. You must submit a "Moving out of the Sandbox" request to send to general users.

## 🏗️ Technical Breakdown
*   **Source**: The email address you are sending from (Must be verified).
*   **Destination**: A dictionary containing `ToAddresses`, `CcAddresses`, etc.
*   **Message**: Contains the `Subject` and `Body` (which can be `Text` or `Html`).

---

## 💻 Lab: Automated Email Reports
See `lab.py` for a production-grade implementation.
