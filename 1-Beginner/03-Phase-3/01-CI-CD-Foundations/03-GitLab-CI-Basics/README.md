# GitLab CI Basics
*The Integrated DevOps Lifecycle Platform*

GitLab CI/CD is a built-in tool for software development using GitLab. It allows you to build, test, and deploy your code without needing third-party integrations like Jenkins.

---

## 🏗️ The .gitlab-ci.yml File
The entire pipeline is defined in a single file at the root of your repository. It uses a very clean and descriptive YAML syntax.

### GitLab Runners
The agents that run your jobs. GitLab provides free shared runners, but most professional DevOps teams use "Private Runners" (on-premise or in the cloud) for security and speed.

---

## 💡 Real-World Scenario: Auto DevOps
GitLab comes with a feature called "Auto DevOps" that can automatically detect your language, build a Docker image, run security scans, and deploy to a Kubernetes cluster just by analyzing your code—no configuration required.

---

## 🎤 Interview Preparation

### 1. What are "Stages" in GitLab CI?
Stages govern the execution order of jobs (e.g., `build`, `test`, `deploy`). All jobs in the same stage run in parallel.

### 2. How do you pass files between stages?
Using **Artifacts**. One job can save a file (like a `.zip` or `.jar`), and the next job can download it automatically.

---

## 🎯 Next Steps
*   **[Runner Configuration Guide](https://docs.gitlab.com/runner/)**: Scale your build power.
