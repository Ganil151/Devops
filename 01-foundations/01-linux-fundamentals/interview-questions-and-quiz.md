# Comprehensive Linux Interview Guide & Quiz

This document aggregates the most important questions and quizzes across all Linux sub-modules. For deep-dives into specific topics, click the links below.

---

## 🎤 Core Interview Questions

| Category | Top Question | Detailed Link |
| :--- | :--- | :--- |
| **Intro** | What is the Linux Kernel? | [Interview Questions](./01-introduction/interview-questions.md) |
| **Filesystem** | What is an Inode? | [Interview Questions](./02-filesystem/interview-questions.md) |
| **Commands** | What is Load Average? | [Interview Questions](./03-commands/interview-questions.md) |
| **Permissions** | What is the Sticky Bit? | [Interview Questions](./04-permissions/interview-questions.md) |
| **SSH** | What is SSH Multiplexing? | [Interview Questions](./ssh/interview-questions.md) |

---

## 🧠 Master Linux Quiz

### 1. Which directory contains system-wide configuration files?
- [ ] A) `/var`
- [x] B) `/etc`
- [ ] C) `/usr`
- [ ] D) `/dev`

### 2. How do you view the last lines of a file in real-time?
- [ ] A) `less`
- [ ] B) `cat`
- [ ] C) `head`
- [x] D) `tail -f`

### 3. Which permission numeric value grants "Read" and "Execute" but not "Write"?
- [ ] A) 4
- [ ] B) 6
- [x] C) 5
- [ ] D) 7

### 4. What is the standard permission for a private SSH key?
- [ ] A) 777
- [x] B) 600
- [ ] C) 644
- [ ] D) 400

### 5. Which special file is used to discard unwanted output?
- [ ] A) `/dev/random`
- [x] B) `/dev/null`
- [ ] C) `/dev/zero`
- [ ] D) `/dev/tty`

### 6. What command is used to change the owner of a file?
- [ ] A) `chmod`
- [x] B) `chown`
- [ ] C) `chgrp`
- [ ] D) `umask`

### 7. Which tool is used to find open network connections?
- [ ] A) `ps`
- [ ] B) `top`
- [x] C) `ss`
- [ ] D) `df`

### 8. What does "Inodes" exhaustion mean?
- [ ] A) RAM is full
- [ ] B) CPU is overloaded
- [x] C) No more files can be created, even if disk space is available
- [ ] D) Network latency is too high

---

## 🚀 Module-Specific Quizzes
- [Intro Quiz](./01-introduction/quiz.md)
- [Filesystem Quiz](./02-filesystem/quiz.md)
- [Commands Quiz](./03-commands/quiz.md)
- [Permissions Quiz](./04-permissions/quiz.md)
- [SSH Quiz](./ssh/quiz.md)

---

## ✅ Knowledge Check
- [ ] Completed all module-specific quizzes.
- [ ] Reviewed advanced SRE troubleshooting scenarios.
- [ ] Practiced command chaining (Pipes/Redirection).
- [ ] Successfully configured an SSH Tunnel.
