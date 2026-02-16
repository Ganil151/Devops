# ⌨️ DevOps Slash Commands & Prompt Shorthands

## 🚀 Overview
Mastering AI-driven automation requires moving beyond "natural language" into **Shorthand Pattern Matching**. In the DevOps technical workflow, speed and precision are paramount. Use these "Standard Operating Procedures" (SOPs) to instantly configure your AI Pair Programmer for specific infrastructure tasks.

---

## 🛠️ The Technical Command Arsenal

| Command | Action | System Interpretation / Prompt Engineering Logic |
|:--- |:--- |:--- |
| **`/human`** | De-robotize | "Strip AI-isms. Use active voice. Remove 'delve', 'ensure', 'comprehensive'. Write like a Senior SRE in a Slack thread." |
| **`/k8s-audit`** | Manifest Review | "Analyze this YAML for security holes (Privileged mode, missing labels, no resource limits) and provide `kubectl patch` fixes." |
| **`/tf-dry`** | HCL Refactor | "Rewrite this Terraform to be DRY using locals, maps, and for_each. Ensure 0 hardcoded values remain." |
| **`/log-dna`** | Root Cause | "Identify the 'Signature' of the error in this 100-line log. Separate infrastructure noise from application failure signals." |
| **`/bash-safe`** | Script Hardening | "Add `set -euo pipefail`, error traps, and input validation to this script. Ensure it handles non-zero exit codes correctly." |
| **`/doc-md`** | Runbook Gen | "Convert this technical sequence into a production README.md using GitHub Flavored Markdown and Mermaid diagrams for the flow." |
| **`/sec-scan`** | Security Audit | "Act as a Pen-Tester. Scan this code for Hardcoded Secrets, Insecure API configurations, and Injection vulnerabilities." |

---

## 📊 Interaction Codes

| Code | Action | Focus |
|:--- |:--- |:--- |
| **`TLDR`** | Executive Summary | 3 bullets: Context, Blocker, Resolution. |
| **`ELI5`** | Concept Baseline | Simplified mental model for Juniors. |
| **`CODEONLY`** | Dev Mode | 0% conversational filler. 100% executable code. |
| **`LISTIFY`** | Structure | Convert unstructured logs/output into actionable JIRA-style bullets. |
| **`TABULIFY`** | Analysis | Comparison table: (Approach, Pros, Cons, Cost). |
| **`STEPIFY`** | Implementation | Numbered SOP for a production change window. |

---

## 🧠 Advanced Pattern: Command Chaining
You can chain these together for complex, automated workflows.

### Example 1: Security Transformation
> *[Pasted a legacy Deployment.yaml]*  
> **`/k8s-audit`** then **`TABULIFY`** the risks then **`CODEONLY`** the fixed version.

### Example 2: Script Migration
> *[Pasted a Bash script]*  
> **`/human`** explain the flow then **`/bash-safe`** refactor then **`STEPIFY`** the testing plan.

---

## 🎯 Pro-Tips for Phase 2 Workflows

1. **The Infrastructure Template**: When using `TABULIFY`, ask for a "Complexity Score" column to help decide between AWS native vs. Open Source tools.
2. **Hallucination Guard**: Follow any generated command with: *"Verify if the flag `--xyz` actually exists in the latest version of the CLI."*
3. **Context Injection**: Always prefix with: *"Context: We are running on EKS v1.29 using Calico CNI."* before using `/k8s-audit` for accurate networking insights.

---
*This guide is part of Part 2: DevOps Workflows in the Prompt Engineering Curriculum.*
