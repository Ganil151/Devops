# 🏗️ Jenkins Installation: Building the Factory Floor

> **"A manual install is a one-time event. An automated deployment is a repeatable capability. In DevOps, we don't install Jenkins; we provision it."**

---

## 🧠 The Mental Model: Building the Factory Floor

**The Junior Struggle**: Downloading a `.war` file, installing Java manually, and hoping everything works. When the server crashes, they have to remember every manual step to rebuild it.

**The Engineer Solution**: Use **Infrastructure as Code (IaC)** and **Containers**.

Think of it like **Setting up a Modern Workshop**:
1.  **The Shell (Docker/VM)**: You don't build the foundation from scratch; you buy a pre-fabricated shipping container (Docker Image).
2.  **The Registry (Plugin Store)**: You don't build your own hammers; you subscribe to a service that provides the standard tools (Plugins).
3.  **The Persistence (Volumes)**: You make sure that even if the workshop burns down, your blueprints (Jobs/Configs) are stored in a fire-proof safe outside (External Volume/EFS).

---

### 🎨 Visual: The Setup Workflow

```mermaid
stepper
    direction LR
    Step1(Deploy Container) --> Step2(Unlock Wizard)
    Step2 --> Step3(Install Plugins)
    Step3 --> Step4(Configure URL)
    Step4 --> Step5(Create Admin)
```

*(Note: If your browser doesn't support Mermaid Stepper, this is a linear progression from Deployment to User Creation.)*

---

## 🆚 Junior Way vs. Engineer Way

| Feature | The Junior Way (Problematic) | The Engineer Way (Production-ready) |
|:---|:---|:---|
| **Deployment** | Manual `.deb` or `.rpm` install | Docker Container or Kubernetes Pod |
| **Java Management** | System-wide Java (Conflicts possible) | Isolated Java environment inside Docker |
| **Configuration** | UI-only manual setup | Configuration-as-Code (JCasC) |
| **Persistence** | Data stored on the local disk | Data stored on external persistent volume |
| **Recovery** | "I hope I have a backup" | Whole setup is defined in a Git Repo |
| **Security** | Default admin password stays 12345 | Automated secret rotation & SSO integration |

---

## ⚙️ Installation Methods

### 1. The Pro Way: Docker (Recommended)
This method ensures the environment is identical across all machines.
```bash
docker run -d \
  --name jenkins-production \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkins/jenkins:lts
```
*   **-d**: Runs in the background (detached).
*   **-v**: Creates a persistent volume. If the container is deleted, your data stays safe.

### 2. The Legacy Way: Package/WAR
Used for dedicated servers where Docker is unavailable. Requires manual Java 11/17 installation and service management via `systemd`.

---

## 🔐 The "Unlock" Process (Security First)

1.  **Retrieve Password**: For Docker, run `docker logs [container_id]`. For native, check `/var/lib/jenkins/secrets/initialAdminPassword`.
2.  **Install Suggested Plugins**: Provides Git, Pipeline, and SSH support out of the box.
3.  **Define Jenkins URL**: Crucial for webhooks to send results back from GitHub/Bitbucket.

---

## 🎤 Interview Preparation

### 🎯 Core Concepts
1. **Q: Why is Docker the preferred method for deploying Jenkins in modern DevOps?**
   - *A: Portability and isolation. Using Docker avoids "Dependency Hell" with Java versions and OS libraries. It also makes horizontal scaling and disaster recovery much faster.*

2. **Q: What is the purpose of Port 50000 in Jenkins?**
   - *A: This is the default port for **JNLP (Inbound) Agents** to communicate with the Controller. While Port 8080 is for the Web UI (HTTP), Port 50000 is for dedicated internal agent traffic.*

3. **Q: What is the difference between Jenkins LTS and Weekly releases?**
   - *A: LTS (Long Term Support) is updated every 12 weeks and is the gold standard for production. Weekly releases include the latest features but are prone to plugin compatibility issues.*

### 🚀 Advanced Questions
4. **Q: How do you handle persistence in a Jenkins Docker container?**
   - *A: By mounting a volume to `/var/jenkins_home`. Without this, all plugins, jobs, and build history will be lost the moment the container is restarted or deleted.*

5. **Q: What is Configuration as Code (JCasC) and why do we use it?**
   - *A: JCasC allows you to define Jenkins settings (plugins, security, nodes) in a YAML file. This enables us to version control our Jenkins setup and recreate our entire Jenkins server in seconds.*

---

## 📝 Knowledge Check

1. **Where can you find the initial admin password for a new Jenkins install?**
   - [ ] a) In an email sent to the admin
   - [x] b) In the file `secrets/initialAdminPassword` within the home directory
   - [ ] c) On the Jenkins official website

2. **True/False: You must install Java on your host machine to run Jenkins in Docker.**
   - [ ] True
   - [x] **False**. Java is pre-installed inside the Jenkins Docker image.

3. **Which plugin type is essential for modern "Pipeline" workflows?**
   - [x] The "Pipeline" plugin (part of the suggested plugins).

---

## 🎯 Next Steps
*   **[Pipelines as Code](../04-pipelines-as-code/readme.md)**: Moving from UI clicks to `Jenkinsfile` logic.
