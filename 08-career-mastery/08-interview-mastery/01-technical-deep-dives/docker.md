# 🐳 Technical Deep Dive: Docker Interview Mastery

Master the container engine that changed everything. Shift from "running images" to architecting secure, optimized container lifecycles.

## 📋 Table of Contents
- [🟢 Junior Tier: The Fundamentals](#-junior-tier-the-fundamentals)
- [🟡 Intermediate Tier: The Professional](#-intermediate-tier-the-professional)
- [🔴 Senior Tier: The Staff Engineer](#-senior-tier-the-staff-engineer)
- [🗝️ Master Key: Interviewer's Secret Summary](#️-master-key-interviewers-secret-summary)

---

## 🟢 Junior Tier: The Fundamentals

#### Q: What is Docker and how does it differ from a VM? [Junior]
**Problem:** Explaining virtualization vs containerization.
**Solution:** Docker is a platform for running applications in **Containers**. 
- **VMs:** Have their own Guest OS, hypervisor, and are heavy. 
- **Containers:** Share the **Host OS Kernel**, making them lightweight, fast to start, and portable.
**Insight (The Interviewer's Secret):** Focus on the **Kernel**. Containers use Linux `cgroups` and `namespaces` to isolate processes on the same host. This is a crucial concept.

#### Q: What is the difference between an Image and a Container? [Junior]
**Problem:** Understanding templates vs running instances.
**Solution:** 
- **Image:** A read-only template with instructions for creating a container (like a Class in OOP).
- **Container:** A runnable instance of an image (like an Object in OOP).
**Insight (The Interviewer's Secret):** Mention **Layers**. A Docker image is built from layers. When you run a container, Docker adds a thin "writable layer" on top.

#### Q: What is a Dockerfile? [Junior]
**Problem:** Defining how to build an image.
**Solution:** A text document containing all the commands to assemble an image.
**Insight (The Interviewer's Secret):** Talk about **Layer Caching**. Mention that you should put the commands that change least (like `FROM` or `RUN apt install`) at the top to speed up subsequent builds.

---

## 🟡 Intermediate Tier: The Professional

#### Q: What is Docker Compose? [Intermediate]
**Problem:** Running multi-container applications.
**Solution:** A tool for defining and running multi-container Docker applications using a `docker-compose.yml` file. It allows you to link services (e.g., App + DB + Redis) with a single command (`docker-compose up`).
**Insight (The Interviewer's Secret):** Mention **Service Discovery**. Docker Compose creates a default network where services can reach each other by their service names.

#### Q: Explain Docker Architecture [Intermediate]
**Problem:** Understanding the Client-Server model.
**Solution:** 
- **Docker Client:** The CLI tool (`docker build`, `docker run`).
- **Docker Host (Daemon):** The `dockerd` process that manages images and containers.
- **Docker Registry:** Where images are stored (e.g., Docker Hub).
**Insight (The Interviewer's Secret):** Mention the **Docker Socket (`/var/run/docker.sock`)**. Discuss the security risks of mounting the socket into a container (it gives the container root-level control over the host).

#### Q: Explain the difference between Docker Swarm and Kubernetes [Intermediate]
**Problem:** Comparing orchestration levels.
**Solution:** 
- **Docker Swarm:** Native to Docker, easier to set up, but less powerful. Good for smaller deployments.
- **Kubernetes:** More complex, battle-tested, handles large-scale auto-scaling and self-healing better. Industry standard for enterprise.
**Insight (The Interviewer's Secret):** It's about **Vendor Lock-in and Ecosystem**. K8s has a much larger ecosystem of tools (Helm, Istio, etc.).

---

## 🔴 Senior Tier: The Staff Engineer

#### Q: How do you optimize a Docker Image for production? [Senior]
**Problem:** Security and image size (bloat).
**Solution:** 
1. **Multi-Stage Builds:** Compile code in one stage, copy only the bin to a tiny final stage (e.g., `alpine` or `scratch`).
2. **Minimize Layers:** Combine `RUN` commands where possible.
3. **Use `.dockerignore`:** Prevent copying unnecessary files (`node_modules`, `.git`).
**Insight (The Interviewer's Secret):** Mention **CVE Scanning**. Use tools like `trivy` or `snyk` to scan your base images for vulnerabilities before pushing.

#### Q: What is the Container Runtime Interface (CRI)? [Senior]
**Problem:** Moving beyond "just Docker."
**Solution:** CRI is a plugin interface which enables Kubernetes to use a wide variety of container runtimes (like `containerd` or `CRI-O`) without needing to rebuild K8s itself.
**Insight (The Interviewer's Secret):** This explains **"Docker-less Kubernetes."** Mention the "Docker deprecation" in K8s—it wasn't about the containers, but about the "dockershim" layer in favor of direct CRI integration via `containerd`.

#### Q: How do you secure containers in production? [Senior]
**Problem:** Limiting the blast radius.
**Solution:** 
- **Non-root user:** Never run applications as `root` inside the container.
- **Read-only Filesystem:** Prevent writing to the image at runtime.
- **Resource Limits:** Set CPU/Memory limits to prevent DOS attacks.
**Insight (The Interviewer's Secret):** Mention **Kernel Capabilities**. Use `--cap-drop=ALL` and only add back the specific permissions the app needs.

---

## 🗝️ Master Key: Interviewer's Secret Summary
| Concept | What they are REALLY looking for |
| :--- | :--- |
| **Volumes** | Do you understand the difference between Bind Mounts and Named Volumes? |
| **Network Modes** | When do you use `bridge` vs `host` vs `none`? |
| **Entrypoint vs CMD** | Do you know which one allows for dynamic arguments? |
| **Orphaned resources** | Do you know how to clean up unused images and volumes (`docker system prune`)? |
