# 💾 Persistence & Storage: Bind Mounts vs. Volumes

By default, data inside a container is **ephemeral**. When the container is deleted, the data is gone. To build professional stateful applications (Databases, User Uploads, Logs), you must master Docker storage.

## 🏗️ The Storage Landscape

### 1. Named Volumes (The Managed Way)
Volumes are stored in a part of the host filesystem which is *managed by Docker* (`/var/lib/docker/volumes/` on Linux). 
*   **Best for**: Databases and permanent application data.
*   **Advantage**: High performance, easy to back up, and isolated from the host OS.

```bash
# Create a volume
docker volume create my_data

# Use it in a container
docker run -d -v my_data:/var/lib/mysql mysql:8.0
```

### 2. Bind Mounts (The Direct Way)
Bind mounts map a **specific path** on your host machine directly to a path in the container.
*   **Best for**: Development (seeing code changes instantly) and configuration files.
*   **Advantage**: You can edit files with your local VS Code and see changes inside the container immediately.

```bash
# Map current directory to /app inside the container
docker run -d -v "$(pwd)":/app nginx
```

---

## 🆚 Comparison Table

| Feature | Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Storage Location** | Managed by Docker | Anywhere on your host |
| **Performance** | Native (Best) | Depends on Host OS |
| **Flexibility** | Moderate | High (Complete access) |
| **DevOps Why** | Production stability | Local development speed |

---

## 🔒 Senior Tip: Read-Only Mounts
By default, containers can write to your host files if you use a Bind Mount. For safety (e.g., mounting a config file), always use the `:ro` (Read-Only) flag.
```bash
# Mount config as read-only to prevent the container from changing host settings
docker run -v /etc/configs/config.json:/etc/app/config.json:ro my-app
```

---

## ⚠️ Common Pitfalls

### ❌ The "Disappearing Data" Act
**Pitfall**: Running a database container without a volume.
**Consequence**: You lose all production data the moment the container is upgraded or the server reboots.
**Fix**: Always verify volume mounts with `docker inspect <id>`.

### ❌ Permission Mismatch
**Pitfall**: Mounting a host directory that has different UID/GID than the user inside the container.
**Consequence**: "Permission Denied" errors when the app tries to write logs.
**Fix**: Match the host user ID or use Docker Volumes which handle permissions more gracefully.

---

## 🛠️ Essential Monitoring Commands
```bash
# List all managed volumes
docker volume ls

# Cleanup unused volumes (Warning: Deletes orphan data)
docker volume prune

# Inspect a volume's physical location on host
docker volume inspect my_data
```
