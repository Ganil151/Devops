# 06: Real-Life Scenarios

Explore how Intermediate Prompt Engineering is applied to solve complex DevOps challenges.

## 🛠️ Scenario 1: Automated Security Code Review
**Context**: Your team has 100+ Terraform files. Reviewing every single Pull Request manually for security smells (e.g., world-open ingress, unencrypted buckets) is slowing down the team.
**Challenge**: Use an LLM to pre-screen PRs without manually checking every file.
**Solution**:
1. **Automation**: Integrate an LLM (via API) into your CI pipeline (GitHub Actions).
2. **Prompt**: 
   > "Act as a Senior Cloud Security Engineer. I will provide you with a `git diff` of a Terraform plan. 
   > **Goal**: Identify any high-risk security misconfigurations.
   > **Criteria**: Check for open ports (0.0.0.0/0), unencrypted S3 buckets, and lack of logging.
   > **Output**: If issues are found, list them as 'WARNING' bullet points. If no issues, reply 'NO ISSUES FOUND'."
3. **Outcome**: The AI catches 80% of common errors instantly, allowing the humans to focus on complex architectural risks.

---

## 📈 Scenario 2: Debugging a CI/CD "Zombie Failure"
**Context**: A Jenkins job is failing intermittently with a cryptic error in a 5,000-line console log. Humans have spent hours looking for the pattern.
**Challenge**: Identify the root cause within minutes.
**Solution**:
1. **Context**: Use a script to extract the last 200 lines of the Jenkins log and the error timestamp.
2. **Prompt (CoT)**:
   > "Reasoning Task: Analyze these Jenkins logs: [LOGS]. 
   > Let's think step-by-step. 
   > 1. What is the very first error that appears before the exit?
   > 2. Does this correlate with a disk space issue or a network timeout?
   > 3. Based on your analysis, provide a one-line `bash` command to fix the environment."
3. **Outcome**: The AI identifies that a hidden `/tmp` volume was filling up only during certain parallel builds.

---

## 🔑 Scenario 3: Generating Documentation from CLI Output
**Context**: You just finished setting up a complex private network with several VPCs, VPNs, and peering connections. Your manager needs a detailed technical README by the end of the day.
**Challenge**: How do you document a complex setup without spending 4 hours typing?
**Solution**:
1. **Input**: Run several `aws ec2 describe-...` commands and pipe the output to a text file.
2. **Prompt**:
   > "Task: Convert this JSON output into a structured, technical 'Network Architecture' document.
   > Focus: Group resources by VPC, list all peering connections, and describe the flow of traffic.
   > Include: A Mermaid diagram showing the connectivity."
3. **Outcome**: A high-quality documentation draft is generated in 30 seconds, requiring only minor manual edits.

---

## 🏗️ Scenario 4: Standardizing Legacy Build Scripts
**Context**: You inherited a repository with 50 different `bash` scripts written by 10 different people over 5 years. There is no consistency in error handling or logging.
**Challenge**: Standardize all scripts to follow modern best practices.
**Solution**:
1. **Few-Shot Prompt**:
   > "I will provide a 'Gold Standard' bash template and a 'Legacy' script. 
   > Your task: Rewrite the Legacy script to match the Gold Standard's logic, error handling, and boilerplate.
   > Gold Standard: [TEMPLATE]
   > Legacy Script: [SCRIPT]"
2. **Outcome**: Consistent scripts throughout the repo, making them easier for the whole team to maintain.

---

## ⚡ Scenario 5: Incident Post-Mortem Generation
**Context**: You just resolved a major 4-hour production outage. You have a long Slack thread where multiple engineers shared fragments of information and log snippets.
**Challenge**: Draft an accurate Post-Mortem timeline for the stakeholders.
**Solution**:
1. **Input**: Export the Slack thread as a CSV or text file.
2. **Prompt**:
   > "You are an SRE Manager. Analyze this Slack history to create a 'Production Incident Post-Mortem'.
   > Sections needed:
   > - Detection: When was the first alarm?
   > - Timeline: Key technical observations and actions taken.
   > - Resolution: What fix finally worked?
   > - Action Items: Based on the conversation, what should we automate?"
3. **Outcome**: Provides a coherent narrative out of chaotic chat logs, saving the lead engineer hours of synthesis work.
