# 🧹 06: The Cleanup (System Hygiene)

> **Analogy**: Docker is a **Messy Roommate**. It loves to build things and download "stuff," but it never throws anything away. If you don't clean up once a week, you'll run out of floor space (Disk Space) and trip over your own projects (Kernel crashes).

---

## 🏗️ The Power of `prune` (The Trash Compactor)

Docker keeps everything "Just in case." You have to be the one to tell it when it's time to let go.

[Image of Docker Cleanup Flow]

| Target | Command | Result |
| :--- | :--- | :--- |
| **Containers** | `docker container prune` | Deletes all stopped containers. |
| **Images** | `docker image prune` | Deletes all "Dangling" images (the `<none>:<none>` ones). |
| **Volumes** | `docker volume prune` | **CAUTION**: Deletes all volumes not attached to a running container. |
| **The Nuclear Option** | `docker system prune -a` | Deletes EVERYTHING that isn't currently running. Use once a month. |

---

## 🕵️ Troubleshooting Disk Bloat: The "Hidden" Cache
Sometimes, `docker images` shows only 1GB, but your disk is full.
*   **The Cause**: **BuildKit Cache**. Docker stores intermediate build steps to make your next build faster.
*   **The Pro Fix**: `docker builder prune`. This clears the hidden cache that `system prune` sometimes misses.

---

## 🚀 The DevOps Why: Automated Hygiene
In a production CI/CD pipeline (like Jenkins or GitHub Actions), we run a cleanup script after every deployment.
*   **Script Strategy**:
    1. Deploy new container.
    2. Check health.
    3. `docker image prune -f` to delete the old versions.

---

## 🆘 What to do when this fails: Cleanup Edition

**Issue: "I deleted my database volume by accident!"**
*   **The Cause**: You ran `docker volume prune` without realizing your DB container was stopped.
*   **The Fix**: There is no "Undo" for prune. **This is why we take external backups or snapshots** before doing maintenance!

**Issue: "Disk is still 100% full after a prune"**
*   **The Cause**: Docker logs are growing too large.
*   **The Fix**: Check `/var/lib/docker/containers/` for massive `.log` files. In the future, use **Log Rotation** in your `daemon.json`.

**Issue: "Cannot delete image, it is in use"**
*   **The Cause**: A "dead" container is still referencing the image layers.
*   **The Fix**: Run `docker ps -a` and delete any old containers referencing that image.
