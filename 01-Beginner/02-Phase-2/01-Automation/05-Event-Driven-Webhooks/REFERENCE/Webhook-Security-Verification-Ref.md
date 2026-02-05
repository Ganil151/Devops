# 🔐 Webhook Security & Verification
*Version 1.0 | Hardening Protected Endpoints in the Open Internet*

---

## 📖 Overview
Since webhook endpoints must be publicly accessible, they are vulnerable to "Replay Attacks" and "Spoofing." Security verification ensures that the incoming request actually came from the trusted source (e.g., GitHub) and not a malicious actor.

---

## 🏗️ Technical Pillars of Security

### 1. Signature Verification (HMAC)
The industry standard. The source signs the payload using a **Shared Secret**.
- **Process**:
  1. Source: `hash = HMAC-SHA256(Secret, Payload)`
  2. Source: Sends `X-Hub-Signature` header.
  3. Listener: Regenerates the hash using the same secret and payload.
  4. Listener: Compare hashes using **Constant-Time Comparison** to prevent timing attacks.

### 2. IP Whitelisting
Restricting access at the firewall level to only the source's IP ranges.
- **GitHub Example**: Query `https://api.github.com/meta` for their hook IP ranges.
- **Limit**: Weak on its own (IPs change); use as a secondary layer.

### 3. Replay Attack Prevention
Malicious actors capture a valid request and "replay" it later.
- **Solution**: The source includes a `timestamp` in the signature. The listener rejects requests where the timestamp is more than 5 minutes old.

---

## ⚙️ SRE Implementation Standard (FastAPI/Python)
```python
import hmac
import hashlib

def verify_signature(payload_body, secret_token, signature_header):
    # 'sha256=' prefix is common in GitHub/Stripe
    expected_signature = hmac.new(
        key=secret_token.encode(),
        msg=payload_body,
        digestmod=hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(expected_signature, signature_header)
```

---

## 🚀 Security Checklist
- [ ] **HTTPS Only**: Never receive webhooks over HTTP.
- [ ] **Constant-Time Comparison**: Use `hmac.compare_digest()` to avoid timing leaks.
- [ ] **Secret Rotation**: Implement a way to rotate the shared secret without downtime.
- [ ] **Logging**: Log the `Request-ID` from the source for cross-platform debugging.

---

## ❓ Interview "Deep-Cut" Questions
1. **Describe a "Timing Attack" and how `compare_digest` prevents it.**
2. **What is the difference between SHA-1, SHA-256, and SHA-512 signatures in terms of security for webhooks?**
3. **How does "Payload Tampering" break HMAC signatures?**
4. **Explain how to handle webhook security for a "Server-to-Server" internal service where HMAC might be overkill.**
5. **What is an "OAuth 2.0 Client Credentials Flow" and can it be used as an alternative to shared secrets?**

---
**Next Step**: [Event-Driven Patterns →](./Event-Driven-Patterns-Ref.md)
