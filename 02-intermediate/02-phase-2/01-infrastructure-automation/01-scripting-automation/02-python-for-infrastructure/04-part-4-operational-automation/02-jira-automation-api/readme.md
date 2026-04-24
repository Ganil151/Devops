# 🎫 Jira Automation: Managing the Registry of Truth

Jira is often the most critical tool in the Enterprise. It tracks budget, compliance, and incident history. Programmatic ticket management ensures that no failure is "lost" in a chat room.

## 🚀 Key Concept: The `jira` Python Library
We use the `jira` library (a wrapper for the Jira REST API) to interact with issues.
*   **Create**: `jira.create_issue()` - Open a new ticket.
*   **Search**: `jira.search_issues()` - Look for existing tickets (Crucial for idempotency!).
*   **Transition**: `jira.transition_issue()` - Move a ticket to "In Progress," "Done," etc.

## 🛠️ The Staff Standard: Idempotency
In a 10-minute outage, a monitoring script might run every 60 seconds. You do **not** want 10 identical Jira tickets.
*   **Pattern**: Before calling `create_issue`, perform a JQL search: `project = OPS AND summary ~ "High CPU" AND status != Closed`.
*   **Logic**: If a result exists, add a comment to the existing ticket instead of creating a new one.

## 🛡️ Authentication: API Tokens
Never use your password.
1.  Go to Atlassian Account Settings.
2.  Create an **API Token**.
3.  Store it in your environment as `JIRA_API_TOKEN`.

---

## 💻 Lab: The Idempotent Ticket Creator
See `lab.py` for a script that checks for existing issues before creating new ones.
