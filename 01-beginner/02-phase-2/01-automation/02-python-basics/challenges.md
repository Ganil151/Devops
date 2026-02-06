# 🏆 Python for DevOps: Graduation Challenges

These labs are designed to test your ability to bridge theoretical Python with real-world infrastructure orchestration. Solve these to prove your readiness for **Phase 3: Systems Drafting**.

---

## 🛠️ Challenge 1: The Multi-Server Health Validator
**Module**: Control Flow & Logic
**Scenario**: You are managing a fleet of bare-metal servers. Some have high CPU, some have low disk, and some are perfectly healthy.

**Task**:
1. Create a list of dictionaries representing 5 servers with `name`, `cpu_usage` (int), and `disk_free` (int).
2. Use a **For Loop** to iterate through them.
3. Apply **Guard Clauses**:
    - If `cpu_usage > 90`, print: `[CRITICAL] {name}: High CPU Load!`
    - If `disk_free < 10`, print: `[WARNING] {name}: Low Disk Space!`
    - Otherwise, print: `[CLEAN] {name}: Healthy.`

---

## 📄 Challenge 2: The Automated Log Scraper
**Module**: File I/O & Error Handling
**Scenario**: An application is producing a large `app.log` file. You need to extract only the `CRITICAL` errors and save them to a new file `incidents.txt` for the SRE team.

**Task**:
1. Create a mock `app.log` file with at least 10 lines, including some with the word `CRITICAL`.
2. Use a **Context Manager** to read the file line-by-line.
3. Use **Error Handling**: Wrap the file opening in a `try/except` block to handle a missing log file.
4. Save the results into `incidents.txt` with a timestamp.

---

## 🏎️ Challenge 3: The Drift Detector
**Module**: Data Structures & Sets
**Scenario**: You have the "Desired State" for your cloud security groups and the "Current State" fetched from an API.

**Task**:
1. `desired_rules = {"SSH", "HTTP", "HTTPS", "ICMP"}`
2. `current_rules = {"SSH", "HTTP", "TELNET"}`
3. Use **Set Operations** to output:
    - **Missing Rules**: Rules that need to be added.
    - **Forbidden Rules**: Rules that need to be removed (e.g., TELNET).
    - **Valid Rules**: Rules that are already correctly configured.

---

## 🏁 Submission
Once complete, ensure all your scripts follow **PEP 8** standards and include **Type Hints**. Your final tools should be ready to be integrated into a Jenkins pipeline!
