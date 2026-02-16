# 🧪 Container Operations Lab

> **"A Docker container is a sandbox. Let's play in the sand without getting it in our eyes."**

Today's mission: Build, Run, and Troubleshoot a small web stack.

---

## 🚩 Task 1: The Blueprint
Write a Dockerfile for a simple Nginx index page. Try to use a non-root USER for security points.

## 🚩 Task 2: The Runtime
Start the container with a **Memory Limit** of 50MB. What happens if you try to run a heavy process inside it?
- *Command Tip*: `docker run -m 50m ...`

## 🚩 Task 3: The Persistence
Map a **Local Volume** to the Nginx html folder. Change the folder's file on your laptop and see it change instantly in the browser.
- *Command Tip*: `docker run -v $(pwd):/usr/share/nginx/html ...`

## 🚩 Task 4: The Network
Create a custom network and run two containers inside it. Can they `ping` each other by name?

---

## 🏗️ Cleanup Command
When you are done, clean your environment!
`docker system prune -a --volumes`

---
*Success Metric: A running, persistent, name-reachable web server.*
