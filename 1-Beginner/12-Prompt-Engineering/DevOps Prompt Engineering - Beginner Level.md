# DevOps Prompt Engineering - Beginner Level

Prompt Engineering is the practice of crafting effective inputs (prompts) for AI language models to generate desired outputs. In the DevOps context, this skill enables engineers to leverage AI tools for automation, documentation, troubleshooting, and code generation.

---

## 1. Zero-Shot Prompting
Zero-shot prompting is asking the AI to perform a task without providing any examples. This is effective for standard, well-documented tasks like basic scripting or explaining code.

### 📝 Example 1: Script Generation
**Prompt:** "Create a bash script that finds all files in /var/log/nginx/ ending in .log that are older than 7 days and compresses them into a tar.gz file named logs_backup_[date].tar.gz."

**Why it works:** It specifies the location, file extension, condition (age), and the exact desired output format.

### 📝 Example 2: Runbook/SOP Creation
**Prompt:** "Draft a standard operating procedure (SOP) for a junior engineer on how to safely restart a Docker container named 'web-app' and verify its health using curl to localhost:8080/health."

**Why it works:** It defines the audience (junior engineer), the specific target (web-app), and the verification method.

---

## 2. Explanation & Interpretation
AI is excellent at translating complex configuration files into human-readable steps.

### 📝 Example 3: Deciphering a Jenkinsfile
**Prompt:** "Explain what this Jenkinsfile stage does in simple terms: 
```groovy
stage('Build') {
    steps {
        sh './mvnw clean package -DskipTests'
    }
}
```"

**AI Explanation:** "This stage runs a Maven command to clean previous builds and package the application into a JAR/WAR file, while explicitly skipping the execution of unit tests to speed up the process."

---

## Real-World Scenarios

### Scenario 1: The "Legacy Script" Mystery
**Context:** You inherited a 500-line Perl script that rotates database backups but has no comments.
**Task:** Use AI to document it.
**Prompt:** "Act as a Senior DevOps Engineer. Analyze the following Pearl script and add inline comments explaining the logic for each function. Also, create a high-level summary of what the script does."

### Scenario 2: Standardizing Documentation
**Context:** Your team has 50 different ways of writing READMEs for services.
**Task:** Create a template.
**Prompt:** "Generate a markdown template for a DevOps service README. It must include sections for: Prerequisites, Installation, Deployment, Environment Variables, and Troubleshooting."

---

## Interview Questions (Beginner)

1. **What is 'Context' in a prompt?**
   - Background information (e.g., OS version, tools used) that helps the AI understand the environment.
2. **What happens if a prompt is too vague?**
   - The AI might generate "hallucinated" or irrelevant code that doesn't fit your specific setup.
3. **How can AI help with Shell Scripting besides writing the code?**
   - It can explain existing scripts, find bugs, or suggest optimizations for performance and security.
4. **Is it safe to paste production secrets into an AI prompt?**
   - **No.** Never share API keys, passwords, or sensitive PII with public AI models.

---

## Knowledge Quiz

1. **Which prompting technique involves giving NO examples?**
   - A) Few-Shot
   - B) Zero-Shot
   - C) Chain-of-Thought
   - D) Fine-tuning

2. **In the prompt "Write a Python script to check disk space," what is missing to make it more effective?**
   - A) Context (e.g., "for a Linux server")
   - B) Constraints (e.g., "alert if > 80%")
   - C) Output format (e.g., "send an email")
   - D) All of the above

3. **What is a 'Hallucination' in AI?**
   - A) A very fast response
   - B) Generating confident but factually incorrect or non-existent information
   - C) Analyzing logs correctly
   - D) Converting JSON to YAML

4. **AI is best used in DevOps as:**
   - A) A replacement for the whole team
   - B) A 'Co-pilot' to assist with speed and documentation
   - C) A way to avoid learning Linux
   - D) A database backup tool

5. **A good prompt for refactoring should include:**
   - A) Just the code
   - B) The code and the desired outcome (e.g., "make it more readable")
   - C) Random keywords
   - D) Only emojis

<details>
<summary><b>View Answers</b></summary>
1: B, 2: D, 3: B, 4: B, 5: B
</details>

---

## Next Steps
After mastering these single-turn prompts, proceed to the **[Intermediate Level](../../2-Intermediate/12-Prompt-Engineering/README.md)** to learn about multi-step reasoning and template engineering.

