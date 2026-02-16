# 🐧 Linux Fundamentals: Master Index

> **Navigation index — links to every granular file. No content is merged; each file is independent.**

---

## 📂 Core Modules

### 01-introduction/
- [readme.md](./01-introduction/readme.md) — What Linux is and why it matters
- [quiz.md](./01-introduction/quiz.md) — Self-assessment
- [interview-questions.md](./01-introduction/interview-questions.md) — Prep material

### 02-filesystem/
- [readme.md](./02-filesystem/readme.md) — The Filesystem Hierarchy Standard (FHS)
- [quiz.md](./02-filesystem/quiz.md)
- [interview-questions.md](./02-filesystem/interview-questions.md)

### 03-commands/
- [readme.md](./03-commands/readme.md) — Essential Linux commands
- [quiz.md](./03-commands/quiz.md)
- [interview-questions.md](./03-commands/interview-questions.md)

### 04-permissions/
- [readme.md](./04-permissions/readme.md) — Users, groups, chmod, chown
- [quiz.md](./04-permissions/quiz.md)
- [interview-questions.md](./04-permissions/interview-questions.md)

### ssh/
- [readme.md](./ssh/readme.md) — SSH configuration and hardening
- [quiz.md](./ssh/quiz.md)
- [interview-questions.md](./ssh/interview-questions.md)

---

## 📂 Distro Reference (`05-distros/`)

| Distro Family | Cheat Sheet | Deep Dive |
|:---|:---|:---|
| RHEL/Fedora | [dnf-cheat-sheet.md](./05-distros/01-rhel-family/dnf-cheat-sheet.md) | [readme.md](./05-distros/01-rhel-family/readme.md) |
| Debian/Ubuntu | [apt-cheat-sheet.md](./05-distros/02-debian-family/apt-cheat-sheet.md) | [readme.md](./05-distros/02-debian-family/readme.md) |
| SUSE | [zypper-cheat-sheet.md](./05-distros/03-suse-family/zypper-cheat-sheet.md) | [readme.md](./05-distros/03-suse-family/readme.md) |
| Lightweight/Cloud | [apk-cheat-sheet.md](./05-distros/04-lightweight-and-cloud-native/apk-cheat-sheet.md) | [pacman-cheat-sheet.md](./05-distros/04-lightweight-and-cloud-native/pacman-cheat-sheet.md) |

- [distro-comparison-matrix.md](./05-distros/distro-comparison-matrix.md) — Side-by-side comparison

### Fedora Scripts (Exact Names Preserved)
| Script | Path |
|:---|:---|
| `fedora-network.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/fedora-network.sh](./05-distros/01-rhel-family/fedora/scripts/bash/fedora-network.sh) |
| `fedora-security.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/fedora-security.sh](./05-distros/01-rhel-family/fedora/scripts/bash/fedora-security.sh) |
| `fedora-systemaudit.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/fedora-systemaudit.sh](./05-distros/01-rhel-family/fedora/scripts/bash/fedora-systemaudit.sh) |
| `fedora-toolbox.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/fedora-toolbox.sh](./05-distros/01-rhel-family/fedora/scripts/bash/fedora-toolbox.sh) |
| `optimize-fedorafull.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/optimize-fedorafull.sh](./05-distros/01-rhel-family/fedora/scripts/bash/optimize-fedorafull.sh) |
| `optimize-intelgpu.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/optimize-intelgpu.sh](./05-distros/01-rhel-family/fedora/scripts/bash/optimize-intelgpu.sh) |
| `preset-generator.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/preset-generator.sh](./05-distros/01-rhel-family/fedora/scripts/bash/preset-generator.sh) |
| `rollback-fedorafull.sh` | [05-distros/01-rhel-family/fedora/scripts/bash/rollback-fedorafull.sh](./05-distros/01-rhel-family/fedora/scripts/bash/rollback-fedorafull.sh) |
| `input-enhancer-preset.py` | [05-distros/01-rhel-family/fedora/scripts/python/input-enhancer-preset.py](./05-distros/01-rhel-family/fedora/scripts/python/input-enhancer-preset.py) |
| `preseteqgenarator.py` | [05-distros/01-rhel-family/fedora/scripts/python/preseteqgenarator.py](./05-distros/01-rhel-family/fedora/scripts/python/preseteqgenarator.py) |

---

## 📂 Reference Library (`reference/`)
- [linux-best-practices-ref.md](./reference/linux-best-practices-ref.md)
- [linux-essential-commands-ref.md](./reference/linux-essential-commands-ref.md)
- [linux-filesystem-ref.md](./reference/linux-filesystem-ref.md)
- [linux-permissions-ownership-ref.md](./reference/linux-permissions-ownership-ref.md)
- [linux-ssh-security-ref.md](./reference/linux-ssh-security-ref.md)

---

## 📂 Scripts (`scripts/`)

### Bash
- [disk-usage-analyzer.sh](./scripts/bash/disk-usage-analyzer.sh)
- [linux-system-audit.sh](./scripts/bash/linux-system-audit.sh)
- [permission-analyzer.sh](./scripts/bash/permission-analyzer.sh)
- [process-monitor.sh](./scripts/bash/process-monitor.sh)
- [ssh-hardening.sh](./scripts/bash/ssh-hardening.sh)
- [.zshrc](./scripts/bash/zsh/.zshrc)

### Python
- [input-enhancer-generator.py](./scripts/python/input-enhancer-generator.py)
- [preset-eq-generator.py](./scripts/python/preset-eq-generator.py)

---

## 📂 Resources (`resources/`)
- [linuxfilesystems.gif](./resources/linuxfilesystems.gif)
- [linux-bash.pdf](./resources/books/linux-bash.pdf)
- [linux-bash-terminal.pdf](./resources/books/linux-bash-terminal.pdf)
- [linux-for-dummies.pdf](./resources/books/linux-for-dummies.pdf)
- [linux-networking-commands.pdf](./resources/books/linux-networking-commands.pdf)
- [python.pdf](./resources/books/python.pdf)
- [the-linux-command-line-a-complete-introduction.pdf](./resources/books/the-linux-command-line-a-complete-introduction.pdf)
- [xforce-threat-intelligence-2022.pdf](./resources/books/xforce-threat-intelligence-2022.pdf)

---

## 📂 Root Files
- [readme.md](./readme.md) — Pillar overview
- [interview-questions-and-quiz.md](./interview-questions-and-quiz.md) — Combined assessment

---

*This index was auto-generated from tree.txt. All files are independent entities — no content has been merged.*
