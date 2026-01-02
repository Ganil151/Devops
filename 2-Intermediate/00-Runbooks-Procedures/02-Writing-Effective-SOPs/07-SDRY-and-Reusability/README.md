## Modular Documentation Structure

```mermaid
graph TD
    Common[Base SOPs: VPN, SSO, SSH] --> SOP1[Task SOP: Deploy Cluster]
    Common --> SOP2[Task SOP: DB Migration]
    Common --> SOP3[Task SOP: App Patching]
    
    subgraph "The Source of Truth"
    Common
    end
    
    subgraph "Specific Procedures"
    SOP1
    SOP2
    SOP3
    end
    
    style Common fill:#f9f,stroke:#333
```

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The 100-File Update
**Problem**: A company changes its SSO provider from Okta to Azure AD. Every single SOP (120 files) ends with "Log in using your Okta credentials."
**Outcome**: 5 engineers spend a whole day manually updating 120 files. They inevitably miss 5 files, causing confusion and failed logins during the next on-call rotation.
**Solution**: Refactor the docs. Now, every file links to a single `GBL-AUTH-01: Authentication Guide`.
**Result**: Next year, when they move to another provider, it takes 1 engineer exactly 2 minutes to update the one file.

### Scenario 2: The "Ghost" VPN Server
**Problem**: An internal VPN server was decommissioned and replaced by a new Zero Trust gateway. 50% of the runbooks still had the old IP address because they were "copy-pasted" clones of an original 2018 guide.
**Crisis**: An engineer followed an old guide during a weekend outage and couldn't connect, wasting 30 minutes of critical MTTR.
**Solution**: Adopted **SDRY**. All VPN steps were deleted from specific runbooks and replaced with a link to the central "Access Gateway" guide.
**Result**: When the gateway changed again 6 months later, the single update propagated instantly to all 50 runbooks.

### Scenario 3: The Copy-Paste Corruption
**Problem**: A complex script for "Database Sanitization" was copied into 5 different maintenance SOPs. One copy had a typo in the `DELETE` command introduced during a manual copy-paste event.
**Crisis**: A junior engineer used the "corrupted" SOP and deleted more data than intended.
**Solution**: Centralized the script in a repository and used **Transclusion** (MkDocs snippets) to include the exact file content in the SOPs.
**Result**: No more "human error" during document creation. The code is verified once and reused safely everywhere.

---

## ❓ Interview Questions

1.  **What is the 'SDRY' principle in technical documentation?**
    - *Answer*: It stands for **Single Source of Truth / Don't Repeat Yourself**. It means creating modular documentation where foundational tasks (like authentication or environment setup) are written once in a central location and then referenced or linked by many specific SOPs.
2.  **How do you handle 'Global Prerequisites' in a large documentation portal?**
    - *Answer*: By creating a 'Base' or 'Common' category for fundamental tasks (VPN, SSH, Login, Tool Installation). All specific task-based SOPs reference these guides in their 'Prerequisites' section rather than restating the instructions, ensuring consistency across the board.
3.  **Explain the risks of 'Copy-Paste' documentation.**
    - *Answer*: The primary risks are **Inconsistency** (some docs are updated, others are not), **Staleness** (old information persists in forgotten files), and **Error Injection** (accidental changes made during the paste process). It significantly increases the "maintenance tax" of the documentation system.
4.  **What is 'Transclusion' or 'Snippets' in the context of Docs-as-Code?**
    - *Answer*: It is an advanced SDRY technique where a documentation tool (like MkDocs or Jekyll) pulls the contents of an external file (e.g., a shared YAML config or a bash script) and injects it into the Markdown at build time. This ensures the docs always show the actual, live version of the code.
5.  **How do you balance 'SDRY' with 'Readability' (not making the user click 20 links)?**
    - *Answer*: You follow the "Rule of Three." If a task is small and used in only 1-2 places, it stays in the file. If it's used in 3+ places, it becomes a Base SOP. We also use clear, descriptive links so the user knows exactly what they are clicking.
6.  **Why is SDRY critical for 'Audit and Compliance'?**
    - *Answer*: Auditors want to see that policies (like "Access Control") are applied consistently. With SDRY, you can prove that every engineer is following the exact same approved authentication procedure because they are all referencing the same source file.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. What does SDRY stand for?**
- A) Simple Documentation Rows Yearly
- B) Single Source of Truth / Don't Repeat Yourself
- C) Standard Documentation Rule Yesterday
- D) System Data Retrieval Yield

<details>
<summary>Show Answer</summary>

**Answer: B**（The documentation equivalent of DRY in coding）

</details>

**2. True/False: You should copy-paste instructions to make each document 'Self-Contained' and avoid links.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: B** - This creates a maintenance nightmare. Use links or transclusion.

</details>

**3. 'Modular Documentation' means:**
- A) One giant file for everything
- B) Breaking documentation into small, reusable components or topics
- C) Using many images
- D) writing in code

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. A 'Base SOP' is best used for:**
- A) One-time experiments
- B) Highly specific app features
- C) Fundamental tasks like "Connecting to VPN" or "Setting up AWS CLI"
- D) Marketing materials

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**5. 'Transclusion' refers to:**
- A) Translating docs into other languages
- B) Dynamically including the content of one file inside another at build time
- C) Deleting old docs
- D) Printing docs

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. The "Copy-Paste Trap" lead to:**
- A) Faster writing
- B) Documentation drift and stale instructions
- C) Better security
- D) lower costs

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. Updating a 'Base SOP' once results in:**
- A) No changes elsewhere
- B) All referencing documents being updated automatically (upon build)
- C) The file being deleted
- D) more work

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**8. Which of these is a 'Single Source of Truth'?**
- A) 5 different files with the same login info
- B) One central 'Authentication Guide' linked by 50 files
- C) A Slack message
- D) A sticky note

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. SDRY is the documentation version of which programming principle?**
- A) KISS (Keep It Simple Stupid)
- B) DRY (Don't Repeat Yourself)
- C) YAGNI (You Ain't Gonna Need It)
- D) SOLID

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. True/False: Transclusion ensures that if you update a script, the doc showing that script is automatically updated.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**11. Descriptive Links (e.g., "[Connect to VPN](../base/vpn.md)") are better because:**
- A) They are longer
- B) They tell the user exactly what to expect before they click
- C) They use more characters
- D) they look like code

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. 'Maintenance Debt' in documentation increases when:**
- A) You use SDRY
- B) You copy-paste instructions across multiple files
- C) You use MkDocs
- D) you delete old files

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Global Header/Footer' is an example of:**
- A) A mistake
- B) SDRY (one file defines the menu/links for all pages)
- C) Passive writing
- D) a linter

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. If a task is used in more than __ places, it should probably be centralized.**
- A) 1
- B) 3
- C) 10
- D) 100

<details>
<summary>Show Answer</summary>

**Answer: B** (The 'Rule of Three')

</details>

**15. 'Shared Variables' in MkDocs (e.g., `$VERSION`) allow you to:**
- A) Calculate math
- B) Update a value in one config file and see it change everywhere in the docs
- C) Hide text
- D) share passwords

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: SDRY makes the initial writing phase longer but saves time in the long run.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - Planning modularity takes effort upfront.

</details>

**17. 'Reference Documentation' usually contains:**
- A) Life stories
- B) Static information like API specs or tool configs that change rarely
- C) Daily news
- D) only images

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. A 'Nested List' of instructions is NOT SDRY if:**
- A) It's short
- B) It's 100% identical in 10 other files
- C) It's in color
- D) it's for seniors

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. 'Documentation Health' is measured by:**
- A) The number of pages
- B) The accuracy and consistency of instructions across the portal
- C) The file size
- D) the number of authors

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: It's okay to have "near-duplicate" docs for Dev vs Prod if only 1 line changes.**
- A) False - Use variables or a centralized doc with "If/Then" logic.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Content Fragments' are:**
- A) Broken files
- B) Small pieces of Markdown intended to be transcluded into larger docs
- C) Emails
- D) website titles

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. Which section of an SOP is the best place to link to a Base SOP?**
- A) The Footer
- B) Prerequisites
- C) In the middle of a command
- D) Nowhere

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. 'Centralization' helps with Compliance because:**
- A) It hides files
- B) It's easier to verify and audit one "Authoritative" source
- C) It's faster to read
- D) it's cheaper

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Rule of Three' suggests:**
- A) Read the doc 3 times
- B) Use 3 authors
- C) If you repeat something 3 times, refactor it into a reusable component
- D) delete 3 files a week

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**25. The ultimate enemy of SDRY is:**
- A) Linux
- B) Manual Copy-Pasting and lack of documentation planning
- C) Git
- D) Markdown

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
