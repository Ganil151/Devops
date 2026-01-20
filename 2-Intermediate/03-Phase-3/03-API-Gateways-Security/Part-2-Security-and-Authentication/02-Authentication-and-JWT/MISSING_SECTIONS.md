# 🔑 Authentication & JWT: High-Fidelity Security

Authentication is about **Who** you are; Authorization is about **What** you can do. In this section, we dive into the technical implementation of these concepts at scale.

---

## 🎫 1. JWT Implementation Patterns

### Stateless vs. Stateful Auth
*   **Stateful (Sessions)**: The server stores a session ID in a database/Redis. Every request requires a database lookup.
*   **Stateless (JWT)**: The token contains all the data needed for authorization. The server only needs to verify the **Signature**. No database lookup is required for every request.

### Nested Tokens (Gateway Pattern)
In a secure microservice architecture, the Gateway might perform "Token Exchange."
1.  **Incoming**: Request with a 3rd party token (e.g., Google OAuth).
2.  **Gateway Action**: Validate the Google token.
3.  **Outgoing**: Gateway issues an internal, short-lived "Microservice JWT" containing specific internal roles and passes it to the backend.

---

## 🔒 2. OAuth2 Flow Selection Guide

| Use Case | Recommended Flow | Why? |
| :--- | :--- | :--- |
| **Web App (React/Vue)** | Auth Code + PKCE | Most secure; hides secret from the browser. |
| **Server-to-Server** | Client Credentials | Simplified; no human user involved. |
| **Native Mobile App** | Auth Code + PKCE | Securely handles redirect URIs. |

---

## 📖 Real-World DevOps Story: "The Infinite Expiration Glitch"

**The Scenario:** A startup launched a successful SaaS platform. For "better user experience," they set the JWT expiration (`exp`) to 10 years.

**The Incident:** An employee left the company under bad terms. They had a valid JWT on their personal laptop. Even after the company disabled their account in the local DB, the employee's token remained valid because the **API Gateway only checked the signature**, not the user status in the database.

**The Result:** The ex-employee deleted several production databases over the weekend using their "eternally valid" token.

**The Fix:** 
1.  Immediate move to 15-minute **Access Tokens**.
2.  Implementation of a **Refresh Token** flow.
3.  Added a "Revocation Check" at the gateway for sensitive operations.

**The Lesson:** Stateless doesn't mean "unmanaged." Always use short-lived tokens and have a plan for revocation.

---

## 👔 Interview Preparation

1. **Q: How can you revoke a JWT if they are stateless?**
   *   *A: You can't truly revoke a stateless token until it expires. To handle revocation, you can either: 1) Keep a "blacklist" in Redis of revoked token IDs (JTI), or 2) Use very short-lived tokens (5-15 mins) and force users to use a Refresh Token to get a new one.*

2. **Q: What is the purpose of the "Signature" in a JWT?**
   *   *A: The signature ensures that the payload has not been tampered with. If an attacker changes the `user_id` from 101 to 1 (Admin), the signature will no longer match the payload, and the gateway will reject the token.*

3. **Q: What is PKCE (Proof Key for Code Exchange) and why is it used?**
   *   *A: PKCE is an extension to the Authorization Code flow that prevents "Authorization Code Injection" attacks. It is essential for public clients like single-page apps (SPAs) and mobile apps where a client secret cannot be securely stored.*

---

## 🧠 Knowledge Check

1. Which part of the JWT contains the expiration time (`exp`)? (The Payload)
2. What is the standard HTTP header for sending a JWT? (`Authorization: Bearer <token>`)
3. True or False: You should store sensitive data like passwords inside a JWT payload. (False—Payload is only Base64 encoded, anyone can read it).

---

## 🔗 Internal Navigation
- [Next: Traffic Control and Rate Limiting](../../Part-3-Traffic-Management-and-Docs/03-Traffic-Control-and-Rate-Limiting/README.md)
- [Back: Security & Authentication Overview](../README.md)
