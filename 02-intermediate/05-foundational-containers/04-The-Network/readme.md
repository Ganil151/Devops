# 🌐 04: The Network (Crossing the Bridge)

> **Analogy**: A Docker container is like a **House in a Gated Community**. It has its own internal address, but nobody from the outside world can visit unless you "Grant Access" at the guard shack (the Host Port).

---

## 🏗️ The Bridge Network (The Default)

When you run a container, Docker automatically puts it on a virtual bridge (usually called `bridge`).

[Image of Docker Bridge Network]

### 1. Port Mapping (`-p HOST:CONTAINER`)
This is the "Bridge" between your physical laptop and the isolated container.
*   **Example**: `docker run -p 8080:80 nginx`
*   **DevOps Why**: It allows you to run multiple Nginx web servers on the same machine by using different host ports (8081, 8082, etc.) while they all listen on port 80 internally.

### 2. DNS & Internal Communication
If you create a **Custom Network**, containers can talk to each other using their names instead of IP addresses.
*   **DevOps Why**: Container IPs change every time they restart. Using a name like `db` or `api` ensures your app never loses connection.

---

## 🚦 Network Drivers

| Driver | When to use it | The "Why" |
| :--- | :--- | :--- |
| **Bridge** | 90% of the time | Provides isolation + flexibility. |
| **Host** | High performance | Removes the bridge. Container uses the host's IP directly. |
| **None** | Super Secure | Disables all networking. Good for secret "Vault" or batch jobs. |

---

## 🆘 What to do when this fails: Network Edition

**Issue: "Bind for 0.0.0.0:8080 failed: port is already allocated"**
*   **The Cause**: Another app (or another Docker container) is already using port 8080.
*   **The Fix**: Use a different host port: `docker run -p 9000:8080 ...`.

**Issue: "Connection Refused" when app tries to reach the Database**
*   **The Cause**: 
    1. The containers are on different networks.
    2. The app is trying to connect to `localhost` inside its own container (where no DB exists).
*   **The Fix**: 
    1. Create a network: `docker network create my-net`
    2. Launch both with `--network my-net`.
    3. Update the app to connect to `db_container_name` instead of `localhost`.

**Issue: "pings reach the container, but I can't see the website."**
*   **The Cause**: The application inside the container is listening on `127.0.0.1`.
*   **The Fix**: Configure your app (Flask, Node, etc.) to listen on **`0.0.0.0`**.
