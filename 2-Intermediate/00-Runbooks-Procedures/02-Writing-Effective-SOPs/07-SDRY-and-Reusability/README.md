# SDRY and Reusability

**SDRY** stands for **Single source of TRUTH / Don't Repeat Yourself**. It is the "DRY" principle of programming applied to documentation.

## The Problem: The "Copy-Paste" Trap
If you copy the "How to connect to the AWS VPN" steps into 50 different SOPs, you have created a Maintenance Nightmare. When the VPN endpoint changes, you must find and update 50 different files. You will inevitably miss one.

## The Solution: Modular Documentation
1.  **Base SOPs**: Create a dedicated document for foundational tasks (e.g., `BASE-01: Connecting to VPN`).
2.  **Linking**: Instead of copy-pasting, just link to the Base SOP: "Prerequisite: Follow [BASE-01](../base/vpn.md) to connect to the network."
3.  **Transclusion**: (Advanced) Use tools like MkDocs snippets to "mount" one file's content into another at build time.

## Benefits
- **Consistency**: High quality is maintained everywhere.
- **Speed**: Updating one file fixes the entire portal.
- **Clarity**: Documents stay short and focused on the *specific* task at hand.

---

## 🏗️ Real-Life Scenario: The 100-File Update
**Problem**: A company changes its SSO provider from Okta to Azure AD. Every single SOP (120 files) ends with "Log in using your Okta credentials."
**Outcome**: 5 engineers spend a whole day manually updating 120 files. 
**The SDRY Fix**: They refactor the docs. Now, every file links to a single `GBL-AUTH-01: Authentication Guide`.
**Result**: Next year, when they move to another provider, it takes 1 engineer exactly 2 minutes to update the one file.

---

## ❓ Interview Questions
1.  **What is the SDRY principle in technical documentation?**
    *   *Answer*: Single Source of Truth / Don't Repeat Yourself. It means creating modular documentation where common tasks are written once and referenced/linked many times, simplifying maintenance and ensuring consistency.
2.  **How do you handle 'Global Prerequisites' in a large documentation portal?**
    *   *Answer*: By creating a 'Base' or 'Foundational' category for common tasks (VPN, SSH, Login). All specific SOPs reference these base guides in their 'Prerequisites' section rather than restating the steps.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What does SDRY stand for?** (Single Source of Truth / Don't Repeat Yourself)
2.  **True/False: You should copy-paste instructions to make each doc 'Stand Alone'.** (False - use links)
3.  **What is 'Modular Documentation'?** (Breaking docs into small, reusable pieces)
4.  **What is a 'Base SOP'?** (A document covering a fundamental task used by many other procedures)
5.  **What is the main benefit of SDRY?** (Ease of maintenance and consistency)
