# 🐳 Foundational Containers: Docker Mastery

> **"Learn to walk before you run. Learn to Dockerize before you Orchestrate. Docker is the universal packaging format for the cloud."**

---

## 🗺️ Start Here: The Master Map
For the full curriculum roadmap and architectural overview, start here:
👉 **[Master_Map.md](./Master_Map.md)**

---

## 🏗️ Images vs. Containers: The Golden Rule
Understanding the distinction is the first step toward container zen.

| Component | Analogy | DevOps Why |
| :--- | :--- | :--- |
| **Dockerfile** | The Recipe | Version-controlled instructions for your environment. |
| **Image**| The Frozen Meal | The static, immutable artifact ready for deployment. |
| **Container** | The Cooked Meal | The live, running instance of your application. |

---

## 🚀 The DevOps Why: Immutable Infrastructure
> **Senior Tip**: In the old days, we patched servers (Snowflakes). In the Docker era, we never patch a running container. We update the `Dockerfile`, rebuild the **Image**, and replace the **Container**. This ensures "It works on my machine" translates perfectly to "It works in production."

---

## 📂 Curriculum Modules

1.  **[01-Docker-Basics](./01-docker-basics/01-introduction/readme.md)**: Architecture (Daemon vs. CLI) and Engine internals.
2.  **[02-Dockerfile Best Practices](./02-dockerfile-best-practices.md)**: **[New]** Security, `docker init`, and Multi-stage builds.
3.  **[03-Persistence & Storage](./03-persistence-and-storage.md)**: **[New]** Bind Mounts vs. Managed Volumes.
4.  **[04-Networking](./04-networking-and-connectivity.md)**: **[New]** Bridge networks and Port Mapping.
5.  **[05-Cleanup & Maintenance](./05-cleanup-and-maintenance.md)**: **[New]** The art of the `prune`.
6.  **[06-Advanced Debugging](./01-docker-basics/04-debugging/readme.md)**: SRE Inspection techniques.

---
*Last Updated: 2026 Audit*
