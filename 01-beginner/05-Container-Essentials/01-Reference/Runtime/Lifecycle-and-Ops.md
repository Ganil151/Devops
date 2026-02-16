# 🐳 Runtime Operations: Managing the Life of a Container

> **"A container is not a destination; it's a journey from `run` to `stop`."**

In this section, we move beyond the blueprint (Dockerfile) and look at how containers behave when they are actually running in the "Wild" (your server). 

---

## 🏗️ The Container Lifecycle
A container is a process. Like any process, it has a birth, a life, and a death.
- **Born**: `docker run` creates and starts the process.
- **Sleeping**: `docker stop` sends a SIGTERM signal, giving the app a chance to shut down gracefully.
- **Killed**: `docker kill` is the hammer; it ends the process immediately.
- **Ghost**: A "stopped" container still exists on disk until you `docker rm` it.

---

## 🩺 The 2:00 AM Toolkit (Debugging)
When your container crashes, you need to be a digital coroner.
1.  **`docker logs -f <id>`**: See the dying words of your application.
2.  **`docker inspect <id>`**: Look at the metadata. Where did it mount the volume? What IP did it get?
3.  **`docker stats`**: Is it eating too much RAM? Use this to find the "Resource Thief."
4.  **`docker exec -it <id> sh`**: Jump inside the running container to see the filesystem.

---

## 🆘 Troubleshooting: "Exited (1)"
- **Observation**: You run the container, it immediately dies.
- **Reason**: The PID 1 process (your app) finished or crashed.
- **Fix**: Check `docker logs`. Usually, it's a missing environment variable or a database it couldn't reach.

---
*Senior Tip: Never use `docker kill` unless you have to. Graceful shutdowns prevent database corruption and lost data.*
