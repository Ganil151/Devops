# Documentation Tooling & SSGs

To build a world-class documentation portal, you need more than just Markdown—you need an infrastructure to build, lint, and serve it.

## 1. Static Site Generators (SSG)
SSGs take your `.md` files and turn them into a fast, searchable website.
- **MkDocs**: (Highly Recommended) Simple, written in Python, and has the industry-standard "Material" theme.
- **Hugo**: (The Speed King) Extremely fast build times for thousands of pages.
- **Docusaurus**: (React-based) Great for complex versioning and interactive components.

## 2. Automated Linters
Don't let humans catch formatting errors—let the machine do it.
- **Markdown-lint**: Checks for heading levels, list formatting, and syntax issues.
- **Vale**: (Advanced) Checks for the "Brand Voice," technical accuracy, and inclusive language.
- **TruffleHog / Gitleaks**: Scans your docs for accidentally committed secrets (passwords).

## 3. Hosting Platforms
- **GitHub/GitLab Pages**: Free and easy to integrate with your Git repo.
- **Netlify / Vercel**: High performance with easy PR previews (see your doc change before you merge it).

---

## 🏗️ Real-Life Scenario: The Broken Link Disaster
**Problem**: An SOP for "Database Scaling" links to an internal tool. The tool URL changes. 
**Crisis**: During an incident, the engineer clicks the link and gets a `404 Not Found`. They waste 15 minutes asking Slack for the new URL while the database is on fire.
**Fix**: Implement a **Link Checker** in the CI pipeline.
**Outcome**: Now, if an engineer tries to merge an SOP with a broken link, the CI pipeline fails. The link *must* be fixed before the documentation can be published.

---

## ❓ Interview Questions
1.  **What is a Static Site Generator and why is it useful for internal documentation?**
    *   *Answer*: It's a tool that converts plain text (Markdown) into a website. It is useful because it allows engineers to write in a simple format (text) while providing users a rich experience (search, navigation, mobile-friendly) without the overhead of a database or CMS.
2.  **How do 'PR Previews' help in a documentation workflow?**
    *   *Answer*: They allow a reviewer to see the "final look" of the changed document in a browser before approving the merge. This helps catch visual errors, broken diagrams, or layout issues that aren't obvious in the raw text.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which SSG is most popular for SRE documentation?** (MkDocs)
2.  **What tool checks for technical accuracy and inclusive language?** (Vale)
3.  **True/False: You should host your docs on a server that depends on the infrastructure they describe.** (False - host externally for 'Out-of-Band' access)
4.  **What does a 'Secret Scanner' do for docs?** (Looks for passwords or API keys in text)
5.  **Which theme is the 'Gold Standard' for MkDocs?** (Material theme)
