# Scaling Bash: Multiplexing and Parallelism

Sequential scripts are too slow for cloud scale. Master `xargs` and `wait`.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `parallel_scanner.sh`
- **[CHALLENGES](./challenges.md)**: Ping Sweepers and Image Resizers.

---

## ⚡ Parallel Execution with `xargs`

The `-P` flag is the secret weapon.

```bash
# Run 5 SSH connections in parallel
cat hosts.txt | xargs -P 5 -I {} ssh {} "uptime"
```

---

## 🧵 Job Control (`&` and `wait`)

```bash
for SERVER in $(cat hosts.txt); do
    ssh "$SERVER" "yum update -y" &  # Run in background
done
wait  # Block until all finish
```

---

## 🔌 SSH Multiplexing

Reuse connections to speed up Ansible/Bash loops.

`~/.ssh/config`:
```ssh
Host *
    ControlMaster auto
    ControlPath /tmp/ssh-%r@%h:%p
    ControlPersist 10m
```

---

## 📖 Real-World Story: The 4-Hour Deployment

**Problem**: Sequential deployment to 200 servers took 3+ hours (1 min per server).
**Resolution**: `xargs -P 20`.
**Outcome**: Deployment dropped to 10 minutes.

---

## ❓ Interview Questions

1. **Difference between `xargs -P` and GNU Parallel?**
   - *Answer*: `xargs` is standard but basic (outputs mix together). GNU Parallel is advanced (handles output cleanly, supports remote servers).
2. **What does `wait` do?**
   - *Answer*: Waits for all background jobs (`&`) of the current shell to finish.
3. **What is Interlacing?**
   - *Answer*: When two parallel processes print to screen at the same time, scrambling the text.

---

[⬅️ Back to Advanced Bash](readme.md)