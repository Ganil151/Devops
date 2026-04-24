# Jenkins & Pipeline Interview Mastery

Prepare for CI/CD engineering roles with these targeted Jenkins questions and performance tasks.

---

## 🔝 Top 10 Questions

1.  **How do you migrate a Freestyle job to a Pipeline?**
    - *Answer*: You translate the build steps, post-build actions, and triggers into a `Jenkinsfile` using Declarative syntax. Use the "Snippet Generator" if unsure of the specific DSL syntax.
2.  **What is the 'Groovy Sandbox' and why is it important?**
    - *Answer*: It is a security feature that restricts the execution of certain high-risk Groovy methods to prevent malicious scripts from compromising the Jenkins server.
3.  **Explain the Jenkins 'Master-Slave' (Controller-Agent) security model.**
    - *Answer*: The Controller stores configuration; the Agent executes code. You should never run builds on the master to protect its SSH keys and configurations from being leaked by a malicious build script.
4.  **What is a 'Multi-branch Pipeline'?**
    - *Answer*: A project type that automatically creates a separate pipeline for every branch in your Git repo that contains a `Jenkinsfile`.
5.  **How do you handle secrets (e.g., API keys) in a Jenkinsfile?**
    - *Answer*: Use the `withCredentials` block or the `credentials()` function in the `environment` section. Never echo or print these variables.
6.  **What is 'Declarative' vs 'Scripted' syntax?**
    - *Answer*: Declarative is structured (JSON-like) and recommended for 90% of use cases. Scripted uses full Groovy power and is used for complex, logic-heavy dynamic pipelines.
7.  **How do you restart a pipeline from a specific stage?**
    - *Answer*: Jenkins allows you to "Restart from Stage" using the UI, provided the build haven't been deleted from the workspace.
8.  **What is the purpose of the 'Safe Restart' plugin?**
    - *Answer*: It queues the restart until all currently running builds have finished, preventing data loss or failed releases.
9.  **How do you scale Jenkins to handle 1,000 builds an hour?**
    - *Answer*: Move the controller to a high-memory instance and use the **Kubernetes Plugin** to dynamically spin up ephemeral agents in a K8s cluster.
10. **Explain 'Blue Ocean' and its status in current Jenkins.**
    - *Answer*: Blue Ocean was a UI redesign for pipelines. While popular for its visual stage view, it is now in maintenance mode, and users are encouraged to use the modern "Pipeline Graph View" plugin.

---

## 🛠️ Performance Task
**Objective**: Build a multi-stage Jenkinsfile with safe credentials.
1. Create a Jenkinsfile that defines two stages: `Build` and `Deploy`.
2. In the `Deploy` stage, use a `when { branch 'production' }` block.
3. Inject a secret named `PROD_DB_PASS` and use it to run a shell command (masking is mandatory).
4. Add a `post` section to send a simulated email on failure.
