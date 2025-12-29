# 02: Runbook Automation

Intermediate prompt engineering allows you to bridge the gap between "messy reality" (Slack logs, terminal output) and "structured operations" (Runbooks).

## 📝 The "Incident-to-Runbook" Pattern

When a production incident happens, the details are often scattered. You can use LLMs to consolidate this into a repeatable procedure.

### Prompt Strategy:
1. **Define the Persona**: "You are a Lead SRE with 10 years of experience."
2. **Provide the Context**: Paste Slack threads, terminal logs, and error messages.
3. **Specify the Output Format**: Mandatory sections like Symptoms, Steps to Reproduce, and Verification.

---

## 🏗️ Example Template

> "Context: Here are the logs from our Redis outage: [PASTE LOGS].
> Task: Based on these logs, create a concise 'Redis Connection Recovery' Runbook.
> Formatting Requirements:
> - Use standard Markdown.
> - Include exact CLI commands.
> - Add a 'Prevention' section highlighting what automation should be added to avoid this in the future."

---

## 🤖 Automating the Post-Mortem

You can also use LLMs to draft the initial version of a Post-Mortem (Root Cause Analysis).
- **Inputs**: CloudWatch Alarms, Jira Tickets, Slack History.
- **Output**: Timeline of events, Root cause, Action items.
