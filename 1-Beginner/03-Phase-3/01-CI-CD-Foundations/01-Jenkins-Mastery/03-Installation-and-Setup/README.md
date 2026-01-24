# Jenkins Installation and Setup
*Setting Up Your Automation Engine*

Getting Jenkins running correctly involves managing Java dependencies and choosing the right deployment method. For DevOps, Docker is the most efficient and isolated way to start.

---

## 🏗️ Installation Methods

### 1. Docker (Recommended)
The fastest way to get a clean Jenkins environment.
```bash
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

### 2. Standard WAR / Package
Used for on-premise dedicated servers. Requirements:
*   **Java (JDK)**: Jenkins requires Java 11, 17, or 21 (LTS versions).
*   **The WAR**: Run via `java -jar jenkins.war`.

---

## 🛠️ The Initial Setup (The Unlock)

1.  **Unlock Code**: Retrieve the initial password from `/var/jenkins_home/secrets/initialAdminPassword`.
2.  **Plugin Installation**: Choose **"Install Suggested Plugins"** for a standard baseline.
3.  **Admin User**: Create your first permanent administrative account.
4.  **Instance Configuration**: Set the `Jenkins URL` (e.g., `http://jenkins.company.com:8080`).

---

## 💡 Real-World Scenario: Infrastructure as Code
Instead of installing Jenkins manually on an EC2 instance, use **Terraform** to provision the server and a **Post-Install Script** (cloud-init) to pull the Jenkins Docker image and start the service automatically.

---

## 🎤 Interview Preparation

### 1. How do you retrieve the initial admin password?
It is found in the shell logs during startup or at the path: `/var/jenkins_home/secrets/initialAdminPassword`.

### 2. What port does Jenkins use by default?
Web UI: `8080`, Agent Communication (JNLP): `50000`.

### 3. Why use the LTS version instead of the Weekly version?
LTS (Long Term Support) is more stable and receives only bug fixes and critical security updates, making it safer for production environments.

---

## 🎯 Next Steps
*   **[Pipelines as Code](../04-Pipelines-as-Code/README.md)**: Writing your first Jenkinsfile.
