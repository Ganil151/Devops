# CI/CD Interview Questions & Quiz

Master the conceptual and practical aspects of CI/CD pipelines.

---

## 🎤 Top 20 CI/CD Interview Questions

### 🔰 Fundamentals
1. **What is the difference between Continuous Delivery and Continuous Deployment?**
   - *Answer:* Continuous Delivery ensures code is *ready* for production but requires a manual trigger. Continuous Deployment automates the final release to production without human intervention.
2. **What are the benefits of CI/CD?**
   - *Answer:* Faster time-to-market, smaller/more frequent releases, automated testing, reduced risk, and higher code quality.
3. **What is a "Pipeline"?**
   - *Answer:* A set of automated processes (Build, Test, Deploy) that code goes through from a repository to production.
4. **What is "Shifting Left" in CI/CD?**
   - *Answer:* Integrating testing and security as early as possible in the development lifecycle (i.e., immediately after the code commit).
5. **What is a "Build Artifact"?**
   - *Answer:* The output of the build process (e.g., a `.war`, `.zip`, or Docker image) that is promoted through environments.

### ⚙️ Tools (Jenkins, GitLab, SonarQube)
6. **What is a "Jenkinsfile"?**
   - *Answer:* A text file that contains the definition of a Jenkins Pipeline and is checked into source control.
7. **Explain the difference between a Scripted and Declarative Pipeline in Jenkins.**
   - *Answer:* Declarative uses a structured, simpler syntax (`pipeline { ... }`). Scripted uses Groovy-based logic and is more flexible but complex.
8. **What is a "Runner" in GitLab CI?**
   - *Answer:* An isolated environment (like a VM or container) that executes the jobs defined in the `.gitlab-ci.yml` file.
9. **What does SonarQube measure?**
   - *Answer:* Code quality, technical debt, bugs, vulnerabilities, and code smell.
10. **What is a "Quality Gate"?**
    - *Answer:* A set of boolean conditions that a project must meet before it can be promoted (e.g., "Code Coverage > 80%").

### 🚀 Advanced & Troubleshooting
11. **How do you handle secrets in a CI/CD pipeline?**
    - *Answer:* Use environment variables, encrypted credentials (Jenkins Credentials), or external vaults (HashiCorp Vault, AWS Secrets Manager).
12. **What is "Blue-Green Deployment"?**
    - *Answer:* Running two identical production environments. One (Blue) is live, and the other (Green) receives the new deployment. Once verified, traffic is switched to Green.
13. **What is "Canary Deployment"?**
    - *Answer:* Gradually rolling out a change to a small subset of users before deploying it to the entire infrastructure.
14. **What is "Build Toil"?**
    - *Answer:* Manual, repetitive tasks in the build process that should be automated.
15. **How do you optimize pipeline speed?**
    - *Answer:* Parallel execution of tests, caching dependencies, and using lightweight build agents.
16. **What is "Infrastructure as Code" (IaC) integration in CI/CD?**
    - *Answer:* Using pipelines to automatically trigger Terraform or Ansible to provision infrastructure before application deployment.
17. **What is a "Webhook"?**
    - *Answer:* An automated message sent from a Git repository (like GitHub/GitLab) to a CI server to trigger a build whenever code is pushed.
18. **Explain "Rollback" strategy.**
    - *Answer:* The ability to quickly revert a failed deployment to the previous stable version (often by redeploying the previous stable artifact).
19. **What is "Dynamic Inventory" in CD?**
    - *Answer:* Pulling a list of target servers from a cloud provider API during the deployment phase rather than using a static list.
20. **What is "Post-Deployment Testing"?**
    - *Answer:* Running health checks and smoke tests on the live production environment immediately after a release.

---

## 🧠 CI/CD Knowledge Quiz

**1. Which practice focuses on merging code into a shared repository frequently?**
- A) Continuous Integration
- B) Continuous Deployment
- C) Waterfall
- D) Unit Testing
*Answer: A*

**2. In Jenkins, which block is required for a Declarative Pipeline?**
- A) `node { ... }`
- B) `pipeline { ... }`
- C) `job { ... }`
- D) `script { ... }`
*Answer: B*

**3. What is the standard configuration file for GitLab CI?**
- A) `jenkinsfile`
- B) `.gitlab-ci.yml`
- C) `docker-compose.yml`
- D) `sonar-project.properties`
*Answer: B*

**4. Which tool is primarily used for static code analysis?**
- A) Ansible
- B) Jenkins
- C) SonarQube
- D) Terraform
*Answer: C*

**5. What happens when a "Quality Gate" fails?**
- A) The database is deleted
- B) The pipeline is blocked from proceeding
- C) The code is automatically fixed
- D) Nothing
*Answer: B*

**6. Which deployment strategy involves switching traffic between two identical environments?**
- A) Rolling update
- B) Blue-Green
- C) Recreate
- D) Manual
*Answer: B*

**7. "Fail Fast" is a philosophy that encourages:**
- A) Ignoring errors
- B) Detecting errors as early as possible in the pipeline
- C) Giving up quickly
- D) Deleting the repository
*Answer: B*

**8. What is a "Self-hosted Runner"?**
- A) A person who runs fast
- B) A build agent that you manage on your own infrastructure
- C) A cloud service from GitHub
- D) A local machine for coding
*Answer: B*

**9. In a pipeline, the "Artifact" is usually created during which stage?**
- A) Commit
- B) Build
- C) Test
- D) Deploy
*Answer: B*

**10. What is the purpose of a "Webhook"?**
- A) To catch fish
- B) To trigger a CI build automatically on code push
- C) To connect two servers via SSH
- D) To display logs
*Answer: B*

**11. Which Jenkins "Credentials" type is used for SSH keys?**
- A) Secret Text
- B) Username with password
- C) SSH Username with private key
- D) Certificate
*Answer: C*

**12. "Continuous Delivery" requires a manual step for:**
- A) Testing
- B) Building
- C) Production Deployment
- D) Linting
*Answer: C*

**13. What is "Technical Debt"?**
- A) Small loans taken to buy servers
- B) The cost of choosing an easy solution now instead of a better approach that takes longer
- C) Unpaid bills for cloud services
- D) Missing documentation
*Answer: B*

**14. Which metric measures how often code is deployed to production?**
- A) Lead Time
- B) Deployment Frequency
- C) MTTR (Mean Time to Recover)
- D) Change Failure Rate
*Answer: B*

**15. What does the `agent { any }` directive do in Jenkins?**
- A) Runs the pipeline on any available executor
- B) Runs the pipeline on every server in the company
- C) Disables the pipeline
- D) Deletes all data
*Answer: A*

**16. In GitLab CI, which keyword defines the order of job execution?**
- A) `sequence`
- B) `order`
- C) `stages`
- D) `steps`
*Answer: C*

**17. What is a "Sanity Test"?**
- A) A test to see if the developer is okay
- B) A quick, broad test to ensure the major features work after a build
- C) A deep security audit
- D) A unit test for logic
*Answer: B*

**18. Which tool acts as a repository for Docker build artifacts?**
- A) SonarQube
- B) Jenkins
- C) Docker Hub / ECR
- D) Git
*Answer: C*

**19. What is "Orchestration" in the context of CI/CD?**
- A) Playing music during the build
- B) Coordinating multiple automated tasks into a cohesive workflow
- C) Managing many GitHub accounts
- D) Writing Python scripts
*Answer: B*

**20. A "Stage" in a pipeline is:**
- A) A physical place to stand
- B) A logical grouping of related jobs (e.g., 'Build', 'Test')
- C) A single line of code
- D) A backup file
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between CI, CD and Continuous Deployment
