# 📄 Cheat Sheets & Technical Documentation

This directory serves as the "Instant Recall" center. It contains high-density information designed to be scanned in seconds while you are in the middle of a terminal session.

---

## ⚡ Quick Reference Library

### ☁️ Cloud & Infrastructure
- **[AWS Inventory Master](./aws-inventory-master.md)**: A global scan of resources, services, and identifiers.
- **[AWS Quick Reference](./aws/cheatsheet.md)**: Frequently used CLI commands for EC2, S3, and IAM.
- **[Global Image Inventory](./global-image-inventory.md)**: Metadata library for Docker and VM images.

### 🐚 Operating System & Shell
- **[Bash Customization](./bashcustomization.txt)**: Profiles, aliases, and prompt optimization snippets.
- **[Standard Cheat Sheet](./cheatsheet.md)**: General Linux/Unix command reference.

---

## 💡 The DevOps Why: Reduced Cognitive Load
In a high-pressure production incident (SEV-1), your brain shouldn't be struggling to remember `sed` syntax or `aws ec2` filters.
- **Offload Knowledge**: Use these docs as external memory.
- **Consistency**: Standardized aliases in `bashcustomization.txt` ensure that `ll` or `k` (kubectl) work the same way across all your jump boxes.

---

## 🏗️ Senior Tips: Creating Your Own Cheat Sheets
1.  **Keep it Scannable**: Use tables and code blocks. Minimize paragraphs.
2.  **Use Searchable Keywords**: Add tags at the bottom of files so `grep` can find them easily.
3.  **Audit Regularly**: If a command changes in a new version of a tool, update your sheet immediately.

---
**Tip**: Press `Ctrl+F` in any of these files to find what you need in under 2 seconds.
