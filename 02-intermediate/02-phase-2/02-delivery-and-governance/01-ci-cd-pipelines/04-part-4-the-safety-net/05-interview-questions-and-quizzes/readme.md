# CI/CD Interview Questions & Quiz

Master the conceptual and practical aspects of CI/CD pipelines.

---

## 🎤 Top 20 CI/CD Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * Continuous Delivery ensures code is *ready* for production but requires a manual trigger. Continuous Deployment automates the final release to production without human intervention.
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * Faster time-to-market, smaller/more frequent releases, automated testing, reduced risk, and higher code quality.
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * A set of automated processes (Build, Test, Deploy) that code goes through from a repository to production.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * Integrating testing and security as early as possible in the development lifecycle (i.e., immediately after the code commit).
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * The output of the build process (e.g., a `.war`, `.zip`, or Docker image) that is promoted through environments.
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * A text file that contains the definition of a Jenkins Pipeline and is checked into source control.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * Declarative uses a structured, simpler syntax (`pipeline { ... }`). Scripted uses Groovy-based logic and is more flexible but complex.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * An isolated environment (like a VM or container) that executes the jobs defined in the `.gitlab-ci.yml` file.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * Code quality, technical debt, bugs, vulnerabilities, and code smell.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * A set of boolean conditions that a project must meet before it can be promoted (e.g., "Code Coverage > 80%").
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use environment variables, encrypted credentials (Jenkins Credentials), or external vaults (HashiCorp Vault, AWS Secrets Manager).
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Running two identical production environments. One (Blue) is live, and the other (Green) receives the new deployment. Once verified, traffic is switched to Green.
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * Gradually rolling out a change to a small subset of users before deploying it to the entire infrastructure.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * Manual, repetitive tasks in the build process that should be automated.
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * Parallel execution of tests, caching dependencies, and using lightweight build agents.
</details>


<b>16. </b>
<details>
<summary>Show Answer</summary>
Answer: * Using pipelines to automatically trigger Terraform or Ansible to provision infrastructure before application deployment.
</details>


<b>17. </b>
<details>
<summary>Show Answer</summary>
Answer: * An automated message sent from a Git repository (like GitHub/GitLab) to a CI server to trigger a build whenever code is pushed.
</details>


<b>18. </b>
<details>
<summary>Show Answer</summary>
Answer: * The ability to quickly revert a failed deployment to the previous stable version (often by redeploying the previous stable artifact).
</details>


<b>19. </b>
<details>
<summary>Show Answer</summary>
Answer: * Pulling a list of target servers from a cloud provider API during the deployment phase rather than using a static list.
</details>


<b>20. </b>
<details>
<summary>Show Answer</summary>
Answer: * Running health checks and smoke tests on the live production environment immediately after a release.
</details>


---

## 🧠 CI/CD Knowledge Quiz

<b>1. Which practice focuses on merging code into a shared repository frequently?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>2. In Jenkins, which block is required for a Declarative Pipeline?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>3. What is the standard configuration file for GitLab CI?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. Which tool is primarily used for static code analysis?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>5. What happens when a "Quality Gate" fails?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. Which deployment strategy involves switching traffic between two identical environments?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. "Fail Fast" is a philosophy that encourages:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>8. What is a "Self-hosted Runner"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. In a pipeline, the "Artifact" is usually created during which stage?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. What is the purpose of a "Webhook"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which Jenkins "Credentials" type is used for SSH keys?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>12. "Continuous Delivery" requires a manual step for:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>13. What is "Technical Debt"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. Which metric measures how often code is deployed to production?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. What does the `agent { any }` directive do in Jenkins?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>16. In GitLab CI, which keyword defines the order of job execution?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>17. What is a "Sanity Test"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Which tool acts as a repository for Docker build artifacts?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>19. What is "Orchestration" in the context of CI/CD?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. A "Stage" in a pipeline is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between CI, CD and Continuous Deployment

---
## 🧭 Additional Modules
- [02 Jenkins](02-jenkins/readme.md)
