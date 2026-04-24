# 📦 APT Cheat Sheet (Debian/Ubuntu)

APT (Advanced Package Tool) is the command-line tool for handling packages on Debian, Ubuntu, and related distributions. It manages the `.deb` ecosystem.

## 📥 Package Operations

| Action | Command |
| :--- | :--- |
| **Update Package Index** | `sudo apt update` (Always run this first!) |
| **Upgrade Installed Packages** | `sudo apt upgrade` |
| **Search for Package** | `apt search <keyword>` |
| **Install Package** | `sudo apt install <package_name>` |
| **Remove Package** | `sudo apt remove <package_name>` |
| **Purge (Remove + Config)** | `sudo apt purge <package_name>` |
| **Show Package Details** | `apt show <package_name>` |
| **List Installed Versions** | `apt list --installed` |
| **Check Dependencies** | `apt-cache depends <package>` |

## 🧹 System Maintenance

| Action | Command |
| :--- | :--- |
| **Remove Unused Deps** | `sudo apt autoremove` |
| **Clean Package Cache** | `sudo apt clean` |
| **Fix Broken Installs** | `sudo apt --fix-broken install` |
| **Update DB from sources**| `sudo apt update` |

## 🔍 PPA Management (Ubuntu)

Personal Package Archives allow you to get software versions not in the standard repo.

| Action | Command |
| :--- | :--- |
| **Add a PPA** | `sudo add-apt-repository ppa:user/ppa-name` |
| **Remove a PPA** | `sudo add-apt-repository --remove ppa:user/ppa-name` |

## 💡 Key Difference: upgrade vs full-upgrade

- `apt upgrade`: Upgrades packages but will **never** remove a package (safe).
- `apt full-upgrade`: Upgrades packages and **may remove** installed packages if necessary to resolve dependencies (use with caution).

## ⚓ Holding Packages (Prevent Updates)

Useful for pinning a specific version of a database or kernel.

| Action | Command |
| :--- | :--- |
| **Hold a package** | `sudo apt-mark hold <package>` |
| **Unhold a package** | `sudo apt-mark unhold <package>` |
| **Show held packages** | `apt-mark showhold` |

## 🏗️ Low-Level DPKG Commands

Sometimes `apt` isn't enough, and you need to work with `.deb` files directly.

| Action | Command |
| :--- | :--- |
| **Install .deb file** | `sudo dpkg -i <file.deb>` |
| **List files in .deb** | `dpkg -c <file.deb>` |
| **List files installed by pkg** | `dpkg -L <package_name>` |
| **Find pkg for a file** | `dpkg -S /path/to/file` |
| **List all installed pkgs** | `dpkg -l` |
