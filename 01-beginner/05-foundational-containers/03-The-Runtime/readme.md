# 🏃 03: The Runtime (Managing Containers)

> **Analogy**: If an Image is a **Recipe**, and a Container is the **Meal**, the Runtime is the **Table Service**. You need to know how to start the meal, check if it's hot, and throw it away when the customer is done.

---

## 🔄 The Lifecycle (Birth to Grave)

Understanding the "Status" of a container is vital for SREs.

| Command | Action | DevOps Why |
| :--- | :--- | :--- |
| `docker run` | Create + Start | Turns your code into a living process. |
| `docker ps` | List running | Your "Dashboard" for current system health. |
| `docker stop` | Graceful exit | Gives the app time to save data and close connections (SIGTERM). |
| `docker kill` | Immediate death | Forced stop (SIGKILL). Use only on "Zombies." |
| `docker rm` | Delete container | Frees up system resources by deleting the container's writable layer. |

---

## 🔍 Inspection & Diagnostics (The Doctor's Toolkit)

When the app crashes, you need to "perform surgery" or read the "medical charts."

### 1. `docker logs -f` (The Heart Rate Monitor)
Streaming logs directly from the application.
*   **DevOps Why**: In container world, we don't log to files. We log to "stdout" so Docker can capture it.

### 2. `docker exec -it <name> sh` (The Endoscopy)
Entering a living container to look around.
*   **DevOps Why**: Great for verifying if environment variables are correct or if a database is reachable.

### 3. `docker inspect` (The X-Ray)
Shows the massive JSON metadata of a container (IP address, Mounts, Env vars).

---

## ⚖️ Resource Limits (The Guardrails)
By default, a container can eat all the RAM and CPU on your host.
*   **Command**: `docker run --memory="512m" --cpus="0.5" my-app`
*   **DevOps Why**: Prevents a single buggy container from crashing your entire server (a "Noisy Neighbor" attack).

---

## 🆘 What to do when this fails: Runtime Edition

**Issue: Container keeps restarting (CrashLoopBackOff)**
*   **The Cause**: Your application is binary-crashing as soon as it starts.
*   **The Fix**: Check `docker logs <id>`. Often, it's a missing environment variable or a database connection that was refused.

**Issue: "Error response from daemon: conflict: unable to remove ... already in use"**
*   **The Cause**: You are trying to delete an image or container that is still "tied" to something running.
*   **The Fix**: Stop the container first: `docker stop <id> && docker rm <id>`.

**Issue: "Exit Code 137"**
*   **The Cause**: **Out Of Memory (OOM)**. The host server killed the container because it used too much RAM.
*   **The Fix**: Increase the memory limit in your `docker run` command or fix the memory leak in your code.
