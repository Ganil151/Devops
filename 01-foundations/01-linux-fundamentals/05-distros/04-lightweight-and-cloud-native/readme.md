# ☁️ Lightweight & Cloud-Native: Alpine & Arch

In the DevOps world, "size matters." Smaller OS footprints mean faster pull times in CI/CD, less disk usage, and a smaller attack surface.

## 🏔️ Alpine Linux (The Docker King)

Alpine Linux is the powerhouse behind the smallest Docker images in the world. It is built around **musl libc** and **busybox**.

### 🧬 Distinct DNA
1.  **Tiny Footprint:** A base Alpine container is only ~5MB.
2.  **Musl vs Glibc:** Alpine uses `musl` instead of `glibc`. This is the most common cause of "Binary not found" errors when running pre-compiled C/Go binaries.
3.  **Security by Design:** Minimal packages mean fewer vulnerabilities.

- [APK Cheat Sheet (Alpine)](./apk-cheat-sheet.md)

---

## 🏹 Arch Linux (The Learning Powerhouse)

Arch is a rolling-release distribution that follows the **KISS (Keep It Simple, Stupid)** principle. It provides very little by default, forcing the user to build their system themselves.

### 🧬 Distinct DNA
1.  **Rolling Release:** There are no "versions" (e.g., 22.04). You just update, and you always have the latest kernel and software.
2.  **Arch Wiki:** Arguably the best Linux documentation in existence.
3.  **AUR (Arch User Repository):** A community-driven repository containing almost every piece of Linux software imaginable.

- [Pacman Cheat Sheet (Arch)](./pacman-cheat-sheet.md)

---

## ⚖️ When to Choose Which?

| Feature | Alpine Linux | Arch Linux |
| :--- | :--- | :--- |
| **Primary Use** | Production Containers | Developer Workstations / Learning |
| **Package Manager**| APK | Pacman |
| **C Library** | musl | glibc |
| **Init System** | OpenRC | systemd |
| **Complexity** | Low (if staying in Docker) | High (Manual setup) |
