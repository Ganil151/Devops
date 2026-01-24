# Artifact Registry Management
*The Warehouse of DevOps Binaries*

Once code is built, it becomes a **Binary Artifact** (a `.jar`, `.war`, `.zip`, or Docker Image). In professional DevOps, we never store these in Git. Instead, we use dedicated Artifact Registries to manage versions, security, and distribution.

---

## 🏗️ The Artifact Lifecycle

In a professional pipeline, the journey of an artifact looks like this:

![Artifact Registry Architecture](../../../../../00-Resources/03-Images-Diagrams/artifact_registry_architecture.png)
1.  **Build**: Script (Shell/Python/Go) compiles the code.
2.  **Package**: Bundles code into a deployable format.
3.  **Scan**: Security checks for vulnerabilities in the dependencies.
4.  **Publish**: Upload to a central registry (Nexus/JFrog/ECR).
5.  **Deploy**: Pull from the registry to production.

---

## ⚖️ Artifact Types vs. Registries

| Artifact Type | Standard Registry | DevOps Tool |
| :--- | :--- | :--- |
| **Java (JAR/WAR)** | Maven Central / Nexus | `mvn deploy` |
| **Python (Wheel)** | PyPI / Artifactory | `twine upload` |
| **Docker Images** | Docker Hub / AWS ECR | `docker push` |
| **Common Files** | Generic Repos | `curl` / `wget` |

---

## 🛠️ Enterprise Solutions

### 1. Sonatype Nexus & JFrog Artifactory
These are the "Big Two." They allow you to host your own private servers for all package types.
*   **Hosted Repos**: Where you upload your own code.
*   **Proxy Repos**: Caches external packages (like PyPI) to speed up builds and work offline.

### 2. Cloud-Native (AWS/Azure/GCP)
*   **AWS ECR**: Deeply integrated with ECS/EKS for container deployments.
*   **GCP Artifact Registry**: Replaces the old Container Registry with multi-format support.

---

## 💡 Real-World Scenario: Traceability & Rollbacks
If a critical bug hits production, the DevOps engineer doesn't re-build the code. They check the **Artifact Registry** for the *previous stable version* (e.g., `app-v1.4.2.jar`) and re-deploy it in seconds. This ensures that Rollbacks are identical to the original working version.

---

## 🎤 Interview Preparation

### 1. Why is "Immutability" important for artifacts?
Once an artifact is published (e.g., `v1.0.0`), it should never be overwritten. If a change is needed, publish `v1.0.1`. This ensures that production environments are predictable and rolls-backs are reliable.

### 2. What is a "Proxy" repository in Nexus/JFrog?
A proxy repository caches packages from external sources (like npmjs.com). It improves build speed (local network) and provides high availability if the external registry goes down.

---

## 🎯 Next Steps
*   **[Hands-on Challenges](./CHALLENGES.md)**: Practice local artifact management.
*   **[Docker Containers](../../01-Container-Orchestration/README.md)**: Learning to registry-tag your images.
