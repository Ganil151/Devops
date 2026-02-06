# 🤖 Prompt Engineering Hands-On Challenges

Master the art of AI communication by completing these 10 progressive challenges. 

## 🟢 Level: Beginner (Foundation & Logic)

### Challenge 01: The Identity Shift

- **Task**: Write a "System Prompt" that turns an AI into a **Senior Linux Administrator**.
- **Goal**: Ask the AI to explain the `chown` command.
- **Success Criteria**: Compare the explanation with one from a "General AI" persona. The Senior Admin version should include safety tips and real-world context.

### Challenge 02: Scripting the Basics

- **Task**: Use the **CIRO Framework** to prompt for a Bash script that backups `/var/log` to `/opt/backup`.
- **Goal**: Ensure the script includes error handling and a "Success" message.
- **Success Criteria**: The script runs in a terminal without syntax errors.

### Challenge 03: The Deconstructor

- **Task**: Find a complex one-liner command online (e.g., a regex `sed` command) and ask the AI to "Deconstruct it for a junior engineer."
- **Goal**: Understand every flag and pipe in the command.
- **Success Criteria**: You can explain the command to a friend without using the AI.

---

## 🟡 Level: Intermediate (Context & Structure)

### Challenge 04: The "Sanitized" Debugger

- **Task**: Take a "Fake" error log (provided in the [Debugging Module](readme.md)) that contains specific IP addresses.
- **Goal**: Create a prompt that sanitizes those IPs into placeholders and asks for a root cause analysis.
- **Success Criteria**: The AI identifies the error correctly without ever seeing the real IP data.

### Challenge 05: Few-Shot YAML

- **Task**: You need to generate a Kubernetes `Secret` manifest.
- **Goal**: Use **Few-Shot prompting** (provide 1 example of a correctly formatted Secret) to ask for a Secret for an application named `db-creds`.
- **Success Criteria**: The output matches your example's formatting exactly and includes the correct base64 requirements.

### Challenge 06: The Translator

- **Task**: Take a basic 10-line Bash loop and prompt the AI to "Convert this to idiomatic Python 3 using the `pathlib` library."
- **Goal**: Compare the two.
- **Success Criteria**: The Python script achieves the exact same result as the Bash script.

---

## 🔴 Level: Advanced (Production & Security)

### Challenge 07: The Terraform Architect

- **Task**: Prompt for a **Terraform Module** that creates a VPC with 2 Private and 2 Public subnets on AWS.
- **Goal**: Use the **CIRO Framework** and specify constraints: "Do not use default tags" and "Must be compatible with Terraform 1.5+."
- **Success Criteria**: Running `terraform validate` on the output shows no errors.

### Challenge 08: The Security Auditor

- **Task**: Paste a script that has a "Hidden" security flaw (e.g., a hardcoded token or an insecure `chmod 777`).
- **Goal**: Prompt the AI: *"Act as a Security Auditor. Analyze this script for the Top 3 security risks and provide the corrected version."*
- **Success Criteria**: The AI identifies the specific flaw and removes it.

### Challenge 09: The Post-Mortem Drafter

- **Task**: Create a "Scenario" of a 15-minute outage involving a database crash.
- **Goal**: Ask the AI to: *"Draft a professional SRE Post-Mortem including Timeline, Root Cause, and 5 Action Items for prevention."*
- **Success Criteria**: The report is structured professionally (Industry standard: Google SRE style).

### Challenge 10: The Final Boss - The AI-Driven CI Pipeline

- **Task**: Create a prompt that generates a **GitHub Actions Workflow** that:
    1. Triggers on pull requests.
    2. Runs a Linter.
    3. Runs a Security Scan.
    4. Automatically comments a "Summary" of the changes on the PR using an AI-style persona.
- **Goal**: Automate the automation.
- **Success Criteria**: A working `.yml` file that correctly implements all 4 features without logic conflicts.

---

## 💡 Stuck?
- Review the [Mental Models](readme.md) to understand AI limits.
- Use **Context Tags** (e.g., `<logs> ... </logs>`) if the AI gets confused.
- Ask the AI: *"Why did you give me that specific answer?"* to learn its logic.

**Good luck, AI Architect!**
