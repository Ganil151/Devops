# Docker and Kubernetes SDKs

Managing containers with Python allows for complex orchestration logic that YAML cannot handle (e.g., "Wait for X, then Start Y if Z is true").

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `container_manager.py` (Docker SDK).
- **[CHALLENGES](./CHALLENGES.md)**: Image Pruners, K8s Pod Controllers.

---

## 🔑 Key Concepts

| Library | Use Case |
| :--- | :--- |
| **`docker`** | The Official Python SDK. Manage Images, Containers, Networks. |
| **`kubernetes`** | The Official K8s Client. Manage Pods, Services, Deployments. |

---

## 🏗️ Docker Patterns

### 1. Ephemeral Containers
Run a tool, get output, delete container. Perfect for CI checks.

```python
client.containers.run("python:3.9", "python --version", remove=True)
```

### 2. Event Stream
Listen to Docker events (like start/stop) to trigger automations.

```python
for event in client.events(decode=True):
    print(event)
```

---

## 📖 Real-World Story: The "Stuck Container" Healer

**Problem**: A legacy Java app would occasionally freeze without crashing (Zombie state). Docker healthchecks weren't catching it due to a flawed endpoint.
**Solution**: A Python script ran `docker exec` to query an internal JMX port. If it timed out, the script called `container.restart()`.
**Result**: Uptime improved from 95% to 99.9%.

---

## ❓ Interview Questions

1.  **How does the Docker SDK connect to the daemon?**
    - *Answer*: By default, it uses the Unix Socket `/var/run/docker.sock` (or Named Pipe on Windows).
2.  **Can you manage Kubernetes CRDs with Python?**
    - *Answer*: Yes, using the `CustomObjectsApi` in the requested `kubernetes` client.
3.  **What is the difference between `run()` and `create()`?**
    - *Answer*: `create()` builds the container configuration but doesn't start it. `run()` creates AND starts it.

---

[Next: Web Scraping](../12-Web-Scraping-for-Monitoring/README.md)
