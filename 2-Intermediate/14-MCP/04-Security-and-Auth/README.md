# 04: Security and Authorization

Giving an AI model access to your infrastructure via MCP is powerful, but it requires a robust security model.

## 🛡️ The "Human-in-the-Loop" Model

The most critical security layer in MCP is the **Host Application**.
- The AI **proposes** a tool call.
- The Host **notifies** the user.
- The User **approves** or **rejects** the action.

> [!IMPORTANT]
> Never configure an MCP server to auto-approve destructive actions (like `rm -rf` or `terraform destroy`) without explicit user consent.

---

## 🔑 Least Privilege for AI

Just as you wouldn't give a junior engineer `root` access, you should limit the AI's MCP credentials.

1.  **Scoped Service Accounts**: Use restricted K8s ServiceAccounts or IAM Roles for the MCP server.
2.  **Read-Only by Default**: Start with read-only MCP servers. Only add "write" tools as needed.
3.  **Network Isolation**: Run MCP servers in private subnets, only allowing connections from authorized AI hosts.

---

## 📝 Audit Logging

Every interaction through MCP should be logged:
- Who initiated the request (The AI model and the User).
- Which tool was called.
- What arguments were passed.
- What the result was.

This ensures accountability and allows for "Replay" analysis if the AI makes a mistake.
