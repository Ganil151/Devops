---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "On-Call Hero" Crisis
**Problem**: A senior engineer was the only person who knew how to "unstick" the legacy payment gateway. They took a vacation in a remote area with no cell service.
**Crisis**: The gateway stuck on a Friday night. The junior on-call spent 4 hours trying to debug it without documentation, resulting in $50,000 of lost revenue.
**Solution**: Upon return, the senior was mandated to write a "Golden SOP" for the payment gateway using the **Docs-as-Code** workflow.
**Result**: Two weeks later, another stall happened. A new hire followed the SOP and resolved the issue in 12 minutes.

### Scenario 2: The Audit "Secret" Leak
**Problem**: An engineer wrote a helpful "How-to" for the database and included their own temporary API key in a code block `export API_KEY=abc123xyz`.
**Crisis**: During a security audit, the auditor found the key in the Git history of the documentation portal.
**Solution**: Implemented **Markdown Linting** and a **Secret Scanner (Gitleaks)**. The documentation was refactored to point to HashiCorp Vault.
**Result**: The company passed the next SOC2 audit with zero findings on documentation security.

### Scenario 3: The Diagram Drift
**Problem**: A network architecture diagram was an outdated PNG file in a Wiki. An engineer performed a VPC migration but forgot to update the image because they didn't have access to the original Visio file.
**Crisis**: During an outage, a different engineer followed the old diagram and shut down the wrong peering connection.
**Solution**: Adopted **Mermaid.js (Diagrams-as-Code)**. The diagram is now a text block in the Markdown file.
**Result**: Updating the diagram is now as easy as updating a line of text. The network map is now always 100% accurate to reality.

---

## ❓ Interview Questions

1.  **What does 'Docs-as-Code' mean and why is it preferred over a traditional Wiki?**
    - *Answer*: Docs-as-Code means treating documentation with the same tools and workflows as software: Markdown for content, Git for version control, Pull Requests for peer review, and CI/CD for publishing. It's preferred because it ensures accountability, technical accuracy through review, and prevents information from becoming stale in siloed wikis.
2.  **Explain the 'Imperative Mood' in technical writing.**
    - *Answer*: It means using strong, directive verbs (e.g., "Run," "Check," "Validate") rather than passive suggestions ("You might want to"). It reduces ambiguity and tells the operator exactly what action to take under pressure.
3.  **How do you handle 'SDRY' (Don't Repeat Yourself) in large documentation sets?**
    - *Answer*: By creating "Base SOPs" for common tasks (authentication, VPN setup) and linking to them from specific procedures. For advanced setups, we use "Fragments" or "Snippets" that are transcluded into multiple pages at build time.
4.  **What are the essential sections of a professional SRE Runbook?**
    - *Answer*: Metadata (Owner/Impact), Prerequisites (Access/Tools), Alert Verification (Is it a real alarm?), Remediation Steps (The commands), Verification (Proof of fix), and Rollback (The undo plan).
5.  **What is the benefit of 'Diagrams-as-Code' (e.g., Mermaid.js)?**
    - *Answer*: It ensures diagrams are searchable, versionable, and easy to update. Since they are text-based, any engineer can fix a diagram error without needing access to a specialized graphics tool or hunting for a source `.vsd` file.
6.  **How do you measure the 'Health' of your documentation?**
    - *Answer*: Through metrics like **MTTR** (is it decreasing as docs increase?), **Documentation Staleness** (how many docs haven't been reviewed in 6 months?), and **Gameday Success Rate** (can a junior person complete the task using only the doc?).

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. What is the primary format used in Docs-as-Code?**
- A) Microsoft Word
- B) Markdown
- C) PDF
- D) Excel

<details>
<summary>Show Answer</summary>

**Answer: B**（Because it is text-based, portable, and git-friendly）

</details>

**2. True/False: You should use passive language like "The server could be restarted" in an SOP.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: B** - Use the **Imperative Mood**: "Restart the server."

</details>

**3. 'Atomic Steps' in an SOP mean:**
- A) Very small steps
- B) One discrete action per numbered point
- C) Steps involving nuclear power
- D) many steps in one paragraph

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. What is the role of CI/CD in a documentation workflow?**
- A) To write the docs for you
- B) To lint for errors, check for broken links, and build the static site
- C) To delete old files
- D) to send emails

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. Mermaid.js allows you to create:**
- A) Websites
- B) Diagrams-as-Code using text-based definitions
- C) Databases
- D) code compilers

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'SDRY' stands for:**
- A) Some Documents Really Yesterday
- B) Single Source of Truth / Don't Repeat Yourself
- C) Simple Data Retrieval Yield
- D) System Doc Ready Yearly

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. Which section of an SOP identifies 'Who' is responsible for a service?**
- A) Prerequisites
- B) Metadata Header (Owner)
- C) Remediation
- D) Appendix

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**8. True/False: You should include 'Expected Output' for every CLI command in a runbook.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - This is "Outcome-Based" writing; it verifies the operator is on the right track.

</details>

**9. 'Cognitive Load' during an incident is REDUCED by:**
- A) Long paragraphs
- B) Consistent formatting and clear, bolded commands
- C) Complex words
- D) hiding secrets

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. What tool helps track 'Who' changed a document in a Docs-as-Code setup?**
- A) Word Track Changes
- B) Git History / Blame
- C) Slack
- D) printer logs

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. A 'Prerequisite' section should list:**
- A) The history of the app
- B) Required IAM permissions, VPN access, and tools
- C) The author's name
- D) links to YouTube

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. When should you choose documentation in a 'Ticket' over a 'Full SOP'?**
- A) For every task
- B) For non-repetitive, one-off operational tasks
- C) Never
- D) only for juniors

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. 'Transclusion' refers to:**
- A) Hiding text
- B) Dynamically including the content of one file inside another at build time
- C) Changing fonts
- D) translating to Spanish

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What is the benefit of a 'Rollback' section?**
- A) It makes the doc longer
- B) It provides a safe "Undo" path if the remediation steps fail
- C) It's for senior engineers only
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. True/False: Technical writing should prioritize "Speed of Understanding" over "Linguistic Elegance."**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**16. 'Diagram Drift' happens when:**
- A) The diagram moves on the page
- B) The architecture changes but the image file isn't updated
- C) The mouse is broken
- D) the printer is out of ink

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**17. 'Linter' tools like Vale help enforce:**
- A) Code speed
- B) Consistency in style, brand voice, and terminology
- C) Server security
- D) user passwords

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. A 'Static Site Generator' (SSG) like MkDocs is used to:**
- A) Compile Python
- B) Turn Markdown files into a fast, searchable web portal
- C) Host a database
- D) edit videos

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. 'Outcome-Based Steps' tell the reader:**
- A) What to do next
- B) What the system response should look like after an action is taken
- C) Who to call
- D) the price of the server

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: You should never combine two unrelated commands in a single step.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - This preserves "Atomicity."

</details>

**21. 'Tribal Knowledge' is a bottleneck because:**
- A) It's too technical
- B) It only exists in one person's mind and isn't documented for the team
- C) It's wrong
- D) it's ancient

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Gamedays' are used to:**
- A) Have fun
- B) Stress-test documentation and response workflows in a safe environment
- C) Write code
- D) interview people

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Why use 'Bold' for commands in a runbook?**
- A) It looks aggressive
- B) To make the essential actions stand out during a quick "Scan" of the document
- C) To save space
- D) it's a rule

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. 'Metadata' help with:**
- A) Storytelling
- B) Programmatic search, auditing, and ownership tracking
- C) Hiding files
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. The ultimate goal of high-performance documentation is:**
- A) To have 1,000 pages
- B) To reduce MTTR and increase operational reliability
- C) To win an award
- D) to make more work

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
