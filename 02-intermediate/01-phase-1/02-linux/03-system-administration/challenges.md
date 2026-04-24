# System Administration Mastery Challenges 🐧

Master the core services and observability tools that power Linux distributions.

---

## 🏆 Challenge 01: The Service Architect (Systemd)
**Objective**: Transform a script into a managed system daemon.

1.  **Requirement**: You have a Python app `app.py`.
2.  **Task**: Create a systemd unit file `myapp.service`.
3.  **Specifications**:
    *   Set it to restart automatically on failure.
    *   Run it under a non-root user `appuser`.
    *   Ensure it starts *after* the network is online.
4.  **Action**: Research the `systemctl` commands to enable, start, and check the status of your new service.

---

## 🏆 Challenge 02: Journald & Log Analysis
**Objective**: Find the needle in the digital haystack.

1.  **Scenario**: Your app crashed at 3:15 AM last night.
2.  **Task**: Use `journalctl` to find the exact error.
3.  **Commands**: Research how to:
    *   Filter by Time (`--since`, `--until`).
    *   Filter by Service (`-u`).
    *   View only Error-level logs (`-p err`).
4.  **Goal**: Draft a command that would show all errors for `nginx` from the last 2 hours.

---

## 🏆 Challenge 03: Signal Management
**Objective**: Gracefully shutting down applications.

1.  **Scenario**: You need to update a service without cutting off active user connections.
2.  **Task**: Differentiate between `SIGTERM` and `SIGKILL`.
3.  **Action**: 
    *   Use the `kill` command to send a `SIGTERM` (15) to a process.
    *   Research what `SIGHUP` (1) usually does when sent to a web server like Nginx or Apache.
4.  **Question**: Why should you always try `SIGTERM` before `SIGKILL` in a production environment?

---

## 📁 Solutions
Systemd templates and Signal cheat-sheets are in the `Boilerplates/` directory.
