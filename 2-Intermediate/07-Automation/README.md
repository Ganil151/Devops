# Automation & Scripting for DevOps

Automation is the multiplier that allows one DevOps engineer to manage thousands of servers. This module focuses on using scripting languages to eliminate toil and build intelligent workflows.

---

## 1. The Automation-First Mindset

If you have to do a task more than twice, automate it.
- **Toil Reduction**: Freeing up time from repetitive manual tasks.
- **Consistency**: Code doesn't make typos or forget steps.
- **Speed**: Automations run at CPU speed, not human speed.

---

## 2. Core Scripting Languages

### [Python for DevOps](./Python$DevOps/README.md)
The versatile standard for DevOps. Use Python to:
- Interact with Cloud APIs (Boto3 for AWS, SDKs for Azure/GCP).
- Build complex data processing logic.
- Integrate different tools via their APIs.

### [Advanced Shell Scripting](./Script-Files/README.md)
The "Glue" of the DevOps world. Use Bash for:
- OS-level configurations.
- Custom container entrypoint scripts.
- Quick CLI-based automation loops.

---

## 3. Learning Path
1.  **Fundamental Logic**: Variables, Loops, and Conditionals in the shell.
2.  **API Interaction**: Learning `curl`, `jq`, and eventually Python SDKs.
3.  **Error Handling**: Building "resilient" scripts that don't just crash when a network call fails.
4.  **Logging**: Writing scripts that tell you *exactly* what they are doing and where they failed.

---

## 4. Best Practices
- **Idempotency**: Ensure your scripts can run multiple times safely.
- **Parameterization**: Never hardcode values; use environment variables or command-line arguments.
- **Documentation**: Comment your code so other engineers (or future-you) know what it does.
- **Modularization**: Break large scripts into smaller, reusable functions.

---
**Enterprise IaC**: Move beyond scripting to declarative management with [Terraform](../04-Terraform/README.md).
