# 🐳 Dockerfile Best Practices & 2026 Standards

In 2026, writing a `Dockerfile` is more than just getting an app to run; it's about **Security, Speed, and Size**. This guide covers the professional standards expected in a modern DevOps pipeline.

## 🛠️ Modern Boilerplate: `docker init`
The fastest and safest way to start a project today is using the built-in initialization tool:
```bash
# Run this in your project root
docker init
```
This utility scans your code and generates a professionally audited `Dockerfile`, `.dockerignore`, and `docker-compose.yaml` tailored to your language (Node, Python, Go, etc.).

---

## 🏗️ The "Senior" instruction Guide

### 1. Pinning Versions (The `FROM` Clause)
**Anti-Pattern**: `FROM node:latest` (Unpredictable builds).
**Best Practice**: Use SHA hashes or specific versions.
```dockerfile
# Pinned version for reproducibility
FROM node:20.11.0-alpine3.19
```

### 2. `WORKDIR`: Stop using absolute paths
Always set a `WORKDIR`. Subsequent `RUN`, `CMD`, and `COPY` commands will use this relative path.
```dockerfile
WORKDIR /usr/src/app
```

### 3. `COPY` vs `ADD`: Use the right tool
*   **`COPY`**: 99% of use cases. Moves local files into the image.
*   **`ADD`**: Only use if you need to pull a remote URL or auto-extract a tarball (`.tar.gz`).
```dockerfile
COPY package*.json ./
```

### 4. `CMD` vs `ENTRYPOINT`
*   **`ENTRYPOINT`**: The command that **must** run. Harder to override. Best for utility containers (e.g., a "ping" image).
*   **`CMD`**: The default arguments. Easily overridden by the user at runtime.
```dockerfile
# Senior Pattern: Use ENTRYPOINT for the executable and CMD for default flags
ENTRYPOINT ["node"]
CMD ["index.js"]
```

---

## 🔒 Security: The Non-Root Pattern
By default, Docker containers run as `root`. This is a major security risk. If an attacker escapes the container, they have root access to your host.

> **Senior Tip**: Always create a limited user and switch to it before the `CMD`.
```dockerfile
# Create a system user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set permissions
RUN chown -R appuser:appgroup /usr/src/app

# Switch to the limited user
USER appuser

CMD ["npm", "start"]
```

---

## 🚀 Performance: Multi-Stage builds
The goal is to keep your production image as small as possible by leaving build tools (compilers, git, cache) in a temporary "Build" stage.

<DOCKERFILE_LAYER_VISUAL>

```dockerfile
# Stage 1: Build (The "Heavy" stage)
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production (The "Thin" stage)
FROM nginx:alpine
# Copy ONLY the finished assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## ⚠️ Common Pitfalls

### ❌ The `.dockerignore` Omission
**Pitfall**: Forgetting to add `node_modules` or `.git` to your ignore file.
**Consequence**: You bake 500MB of local trash into your image, slowing down uploads and potentially leaking secrets.
**Fix**: Always include a `.dockerignore` file.

### ❌ Layer Invalidation
**Pitfall**: Copying all files (`COPY . .`) before running `npm install` or `pip install`.
**Consequence**: Every time you change one line of code, Docker re-installs all your dependencies.
**Fix**: Copy dependency manifest files first.

---

## 🧪 Hands-on Exercise
1. Create a simple `index.html`.
2. Generate a Dockerfile using `docker init`.
3. Modify the Dockerfile to use a `non-root` user.
4. Build the image and inspect the size: `docker images`.
