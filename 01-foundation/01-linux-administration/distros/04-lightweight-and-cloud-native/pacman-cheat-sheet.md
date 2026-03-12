# 🏹 Pacman Cheat Sheet (Arch Linux)

`pacman` is the package manager for Arch Linux. It combines a simple binary package format with an easy-to-use build system.

## 📦 Core Commands (The "S" Commands)

Pacman uses flags like `-S` (Sync).

| Action | Command |
| :--- | :--- |
| **Sync (Update Index)** | `sudo pacman -Sy` |
| **Upgrade System** | `sudo pacman -Syu` (Always do this!) |
| **Install Package** | `sudo pacman -S <package>` |
| **Remove Package** | `sudo pacman -R <package>` |
| **Remove + Unused Deps**| `sudo pacman -Rs <package>` |
| **Search (Remote)** | `pacman -Ss <keyword>` |
| **Info (Remote)** | `pacman -Si <package>` |

## 🔍 Local Queries (The "Q" Commands)

| Action | Command |
| :--- | :--- |
| **Search (Local)** | `pacman -Qs <keyword>` |
| **Info (Local)** | `pacman -Qi <package>` |
| **List Installed Files** | `pacman -Ql <package>` |
| **Find owner of file** | `pacman -Qo /path/to/file` |
| **List Orphans** | `pacman -Qdt` (Unused dependencies) |

## 🧹 Maintenance

| Action | Command |
| :--- | :--- |
| **Clean Package Cache** | `sudo pacman -Sc` |
| **Deep Clean Cache** | `sudo pacman -Scc` |
| **Remove Orphans** | `sudo pacman -Rs $(pacman -Qdtq)` |

---

## 🏗️ The AUR (Arch User Repository)

The AUR is not managed by `pacman` directly. You usually use an "AUR Helper" like **`yay`**.

| Action | Command |
| :--- | :--- |
| **Install from AUR** | `yay -S <package>` |
| **Upgrade everything**| `yay` (Upgrades both repo and AUR pkgs) |
