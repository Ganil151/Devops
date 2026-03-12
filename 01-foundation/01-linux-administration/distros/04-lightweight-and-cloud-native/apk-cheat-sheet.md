# 🏔️ APK Cheat Sheet (Alpine Linux)

The **Alpine Package Keeper (apk)** is a fast and simple package manager designed for the minimal Alpine environment.

## 📦 Basic Operations

| Action | Command |
| :--- | :--- |
| **Update Index** | `apk update` |
| **Install Package** | `apk add <package>` |
| **Uninstall Package** | `apk del <package>` |
| **Upgrade All** | `apk upgrade` |
| **Search for Package** | `apk search <keyword>` |
| **Info about Package** | `apk info <package>` |

## 🧪 Container Optimization Tricks

In Dockerfiles, you often want to combine commands and clean up to keep image sizes tiny.

```dockerfile
# Standard pattern:
RUN apk update && \
    apk add --no-cache curl git && \
    rm -rf /var/cache/apk/*
```

> [!TIP]
> The `--no-cache` flag is the preferred way to install packages in Docker without storing the index locally, saving space.

## 🔍 Advanced Queries

| Action | Command |
| :--- | :--- |
| **What pkg owns file?** | `apk info --who-owns /path/to/file` |
| **List installed packages** | `apk info` |
| **List package contents** | `apk info -L <package>` |
| **Dry Run** | `apk add --simulate <package>` |
