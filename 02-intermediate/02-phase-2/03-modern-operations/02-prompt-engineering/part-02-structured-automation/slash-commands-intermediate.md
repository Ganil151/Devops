# 🛠️ Intermediate AI Slash Commands & Performance Codes

## 🚀 Overview
At the Intermediate level, we move beyond basic formatting to **Structured Data Extraction** and **Operational Analysis**. These commands are designed to help you parse complex logs, generate troubleshooting runbooks, and optimize AI output for reliability.

---

## 🛠️ The Operational SOP Library

| Command | Action | AI Reasoning Strategy (Internal Logic) |
|:--- |:--- |:--- |
| **`/debug`** | Error Analysis | "Break down this error log. Identify the failing component, the specific error code, and provide 3 possible causes with verification commands." |
| **`/runbook`** | SOP Generation | "Convert this complex troubleshooting sequence into a step-by-step markdown runbook. Include 'Warning' blocks and 'Verification' steps." |
| **`/json-extract`**| Data Parsing | "Extract all (IPs, Ports, Error Messages) from the provided text and format them as valid JSON. Ensure no conversational filler." |
| **`/refactor`** | Optimization | "Review this script for (Readability, Performance, Error Handling). Suggest improvements and explain the 'Why' behind each." |
| **`/audit-sec`** | Security Scan | "Scan this Kubernetes manifest or Terraform file for common security misconfigurations (Privileged containers, Public S3, etc)." |

---

## 🏗️ Performance Shorthands (Deterministic Codes)

| Code | Action | Focus |
|:--- |:--- |:--- |
| **`TEMP-0`** | Determinism | Forces the AI to use Temperature 0.0 for maximum consistency in code and configuration logic. |
| **`JSON-ONLY`** | Logic | Removes all conversational text. The AI must respond ONLY with a valid JSON block. |
| **`REASON-FIRST`**| Logic Chain | Forces the AI to state its "Thought" or "Reason" before providing the final code/command. |
| **`STRIP-PII`** | Privacy | "Analyze this log but replace all sensitive data (IPs, JWT tokens, Passwords) with generic placeholders." |
| **`STEP-BY-STEP`**| Flow | Breaks down a complex goal into a numbered list of technical tasks. |

---

## 🧠 Example: The Troubleshooting Chain

**Scenario: Pod CrashLoopBackOff**
> *[Pasted `kubectl describe pod` output]*  
> **`/debug`** then **`REASON-FIRST`** then **`TEMP-0`** then **`/runbook`** to fix the issue.

---

## 🎯 Pro-Tips for Intermediate Workflows

1.  **Low Temperature**: For IaC (Terraform/K8s), always use `TEMP-0`. High temperature "hallucinates" CIDR blocks and resource names.
2.  **Explicit Context**: Instead of saying "My pod is failing," say "My pod 'backend-v1' in the 'prod' namespace is failing with 'CrashLoopBackOff' on an EKS 1.28 cluster."
3.  **The "Check" Requirement**: Always end your prompt with: *"Include the exact command I should run to verify the fix worked."*

---
*This guide is part of Part 2: Structured Automation in the Intermediate Prompt Engineering Curriculum.*
