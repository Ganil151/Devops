# 🛠️ DNF Cheat Sheet (RHEL Family)

DNF (Dandified YUM) is the next-generation package manager for RPM-based distributions (RHEL 8+, Fedora, Rocky, Alma).

## 📦 Package Management

| Action | Command |
| :--- | :--- |
| **Search for a package** | `dnf search <query>` |
| **Install a package** | `sudo dnf install <package>` |
| **Remove a package** | `sudo dnf remove <package>` |
| **Reinstall a package** | `sudo dnf reinstall <package>` |
| **List installed packages** | `dnf list --installed` |
| **Show package info** | `dnf info <package>` |
| **Check for updates** | `dnf check-update` |
| **Upgrade all packages** | `sudo dnf upgrade` |

## 🧩 Repo & Groups Management

| Action | Command |
| :--- | :--- |
| **List enabled repos** | `dnf repolist` |
| **List all repos** | `dnf repolist all` |
| **Install a group** | `sudo dnf groupinstall "Development Tools"` |
| **List groups** | `dnf group list` |

## 🎞️ History & Rollbacks

One of DNF's most powerful features is its ability to undo changes.

| Action | Command |
| :--- | :--- |
| **List recent actions** | `dnf history` |
| **View specific ID** | `dnf history info <id>` |
| **Undo an action** | `sudo dnf history undo <id>` |
| **Redo an action** | `sudo dnf history redo <id>` |

## 🧪 Modules (AppStreams)

RHEL uses modules to manage different versions of the same software.

| Action | Command |
| :--- | :--- |
| **List modules** | `dnf module list` |
| **List versions of nodejs** | `dnf module list nodejs` |
| **Enable a version** | `sudo dnf module enable nodejs:18` |
| **Install from module** | `sudo dnf install @nodejs:18` |

## 🧹 Maintenance

| Action | Command |
| :--- | :--- |
| **Clean cache** | `sudo dnf clean all` |
| **Remove orphaned deps** | `sudo dnf autoremove` |

---

> [!TIP]
> Use the `-y` flag (e.g., `dnf install nginx -y`) to automatically answer "yes" to all prompts—essential for automation and CI/CD scripts.
