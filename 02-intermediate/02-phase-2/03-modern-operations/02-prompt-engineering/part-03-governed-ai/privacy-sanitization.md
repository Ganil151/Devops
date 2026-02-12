# 🛡️ Privacy & Sanitization Guardrails

> **"Data is the new oil, and leaks are the new oil spills. In the world of AI, your prompt is the pipeline."**

## 📚 Overview
As an SRE processing millions of lines of logs, you have a massive responsibility to ensure that **Personally Identifiable Information (PII)** and **Secrets** do not leave your production environment. This guide provides the SOP for sanitizing data before using public LLMs.

---

## 🏗️ The "Four Reds" of Data Leakage

| Category | Typical Data | Sanitization Action |
| :--- | :--- | :--- |
| **Secrets** | API Keys, AWS Tokens, SSH Keys | **REDACT** completely. Use `RED_ACT_KEY`. |
| **PII** | Full Names, Email, Phone Numbers | **ANONYMIZE**. Change to `Ganil_1` or `User_A`. |
| **Networking**| Public IPs, Internal VPC CIDRs | **REPLACE** with standard RFC1918 (e.g., `10.0.0.1`). |
| **Identifiers**| Exact Account IDs, Cluster Names | **GENERICIZE**. Use `PROD_CLUSTER` or `AWS_ACCOUNT_ID`. |

---

## 🚀 The Sanitization SOP (Step-by-Step)

### Step 1: Automated Scripting
Use a local Python script or `sed`/`grep` to find common patterns like `192.168.x.x` or `access_key_id`.

```bash
# Example: Sanitizing IPs from a log file locally
sed -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/TARGET_IP/g' logs.txt > sanitized_logs.txt
```

### Step 2: Semantic Redaction
When describing architecture, don't mention your company's actual internal project names. 
- **Incorrect**: "How do I scale the 'Project-Apollo-V2' database on EKS?"
- **Correct**: "How do I scale a high-volume PostgreSQL database on EKS?"

### Step 3: Human Review
Always do a final "Scan" of the prompt before hitting enter. If you see a hardcoded password or a secret token, **STOP**.

---

## 🏆 Real-World DevOps Story: The "Public" Secret
**The Scenario**: A developer pasted a `kubectl logs` output into a public AI tool to find an error.
**The Crisis**: The logs included a "Basic Auth" header that was accidentally printed during an application crash. This token was now part of the AI provider's data pool.
**The Fix**: The company had to rotate every single password for that service and implement a local LLM solution (**Ollama**) for log analysis.
**The Lesson**: AI doesn't know what a secret is. **You are the firewall.**

---

## ❓ Interview Preparation

1. **Q: How do you identify PII in a massive JSON file before prompting?**
   *A: I use automated regex scripts to find emails, IPs, and phone numbers. I also look for 'Metadata' keys like 'Username', 'email', and 'Account_ID' and replace them with generic labels.*

2. **Q: What is 'Shadow AI' and why is it a security risk?**
   *A: Shadow AI is when teams use unapproved or public AI tools for company work. It's a risk because there is no oversight on where the data goes, potentially violating compliance like GDPR or SOC2.*

---
*Next Step: Return to the [Module 02 Hub](../readme.md).*
