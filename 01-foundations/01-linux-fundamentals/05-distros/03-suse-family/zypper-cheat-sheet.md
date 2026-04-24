# 🦎 Zypper Cheat Sheet (SUSE Family)

Zypper is the command-line package manager for openSUSE and SUSE Linux Enterprise (SLES). It is known for its powerful dependency resolver and integration with the Libzypp library.

## 📦 Package Management

| Action | Command |
| :--- | :--- |
| **Refresh Repositories** | `sudo zypper refresh` (Short: `sudo zypper ref`) |
| **Search for Package** | `zypper search <keyword>` (Short: `zypper se`) |
| **Install Package** | `sudo zypper install <package>` (Short: `sudo zypper in`) |
| **Remove Package** | `sudo zypper remove <package>` (Short: `sudo zypper rm`) |
| **Show Package Info** | `zypper info <package>` (Short: `zypper if`) |
| **Check for Updates** | `zypper list-updates` (Short: `zypper lu`) |
| **Upgrade All Packages** | `sudo zypper update` (Short: `sudo zypper up`) |
| **Distribution Upgrade** | `sudo zypper dup` (Standard for Tumbleweed) |

## 🧩 Repository Management

| Action | Command |
| :--- | :--- |
| **List Repositories** | `zypper repos` (Short: `zypper lr`) |
| **Add Repository** | `sudo zypper addrepo <url> <alias>` (Short: `sudo zypper ar`) |
| **Remove Repository** | `sudo zypper removerepo <alias>` (Short: `sudo zypper rr`) |
| **Enable/Disable Repo** | `sudo zypper modifyrepo -e/-d <alias>` (Short: `sudo zypper mr`) |

## 🎞️ History & Patterns

| Action | Command |
| :--- | :--- |
| **View Transaction Log** | `cat /var/log/zypp/history` |
| **List Patterns** | `zypper patterns` (Groups of software) |
| **Install a Pattern** | `sudo zypper install -t pattern <name>` |

## 🔒 Package Locking

| Action | Command |
| :--- | :--- |
| **Lock a package** | `sudo zypper addlock <package>` (Short: `sudo zypper al`) |
| **List locks** | `zypper locks` (Short: `zypper ll`) |
| **Unlock a package** | `sudo zypper removelock <package>` (Short: `sudo zypper rl`) |

---

> [!TIP]
> SUSE admins often use **YaST** (Yet another Setup Tool) for a TUI/GUI-based approach to the same tasks. Run `sudo yast2` to explore.
