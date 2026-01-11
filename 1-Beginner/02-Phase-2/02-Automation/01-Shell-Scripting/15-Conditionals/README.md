# 🔀 Conditionals (The Logic of Automation)
> **"A script without conditionals is just a list. A script with conditionals is a decision-maker."**
![Conditional Logic Flow](./conditional_logic_flow.svg)
## 📚 Overview
Conditionals are the "Brain" of your automation. They allow your script to perceive the environment and adapt. Instead of running a deployment blindly, a smart script asks: "Is the database reachable?", "Is this file already backed up?", or "Is the disk nearly full?". In Bash, we primarily use `if` statements and `case` switches to handle these branching paths.
## 🎓 Learning Objectives
By the end of this module, you will:
- ✅ Master the **Triple-Option** <font color="#ffc000">if</font>/<font color="#ffc000">elif</font>/<font color="#ffc000">else</font> anatomy.
- ✅ Understand the **Comparison Partition**: Strings (<font color="#ffc000">==</font>) vs Integers (<font color="#ffc000">-eq</font>).
- ✅ Leverage **File Test Operators** (<font color="#ffc000">-f</font>, <font color="#ffc000">-d</font>, <font color="#ffc000">-s</font>, <font color="#ffc000">-z</font>) for system auditing.
- ✅ Adopt the **Superior `[[ ]]` Syntax** for safer, modern Bash code.
- ✅ Implement **Case Patterns** for complex menu and flag handling.
---
## 🏗️ Logic Architecture: Strings vs. Integers
This is the #1 mistake beginners make. Bash treats numbers and text differently.
| Feature | String Check | Integer Check | Description |
|---------|--------------|---------------|-------------|
| **Equality** | `==` | `-eq` | Match values. |
| **Inequality**| `!=` | `-ne` | Not a match. |
| **Greater** | `>` | `-gt` | Comparative size/order. |
| **Less** | `<` | `-lt` | Comparative size/order. |
### The Power of `[[ ]]`
Always use double brackets. They handle spaces, empty variables, and logical operators (`&&`, `||`) without crashing your script.

---
## 🚀 Practical Examples for Automation
### Example A: The File Integrity Check
Ensure a configuration file exists and has content before trying to use it.
```bash
CONFIG="/etc/app/config.yaml"
if [[ -f "$CONFIG" ]] && [[ -s "$CONFIG" ]]; then
    echo "✅ Config found and valid."
else
    echo "❌ Error: Config missing or empty!"
    exit 1
fi
```
### Example B: Simple Menu (Case)
Handling multiple modes like `start`, `stop`, `restart`.
```bash
case "$1" in
    start) systemctl start nginx ;;
    stop)  systemctl stop nginx ;;
    *)     echo "Usage: $0 {start|stop}" ;;
esac
```
---
## 📑 The Conditionals Cheat Sheet
| Operator | Meaning                       |     |                          |
| -------- | ----------------------------- | --- | ------------------------ |
| -f       | Is it a **File**?             |     |                          |
| -d       | Is it a **Directory**?        |     |                          |
| -z       | Is string **Zero** (empty)?   |     |                          |
| -n       | Is string **Not-Empty**?      |     |                          |
| -e       | Does it **Exist** (any type)? |     |                          |
| &&       | AND (Both must be true)       |     |                          |
| **       |                               | `** | OR (Either must be true) |

---
## 🏆 Real-World DevOps Story
### 💡 **The Empty String Disaster**
**The Scenario**: A script had an optional variable `CLEANUP_TARGET`. The engineer wrote `if [ $CLEANUP_TARGET == "logs" ]`. One day, the variable was empty.
**The Discovery**:
The single bracket `[` tried to evaluate `if [ == "logs" ]`, which is a syntax error that crashed the production script!
**The Fix**:
They switched to `[[ "$CLEANUP_TARGET" == "logs" ]]`. Double brackets handle the empty variable gracefully, treating it as `"" == "logs"` (resulting in False), which safely skips the logic instead of crashing.

---
## 📝 Knowledge Check
1. **Which operator checks if a file exists and is a regular file?**
   - [ ] a) `-d`
   - [x] b) `-f`
   - [ ] c) `-z`
2. **What is the correct way to check if an integer is GREATER than 10?**
   - [ ] a) `[[ $x > 10 ]]`
   - [x] b) `[[ $x -gt 10 ]]`
   - [ ] c) `[[ $x == 10 ]]`
3. **What does `-z` check?**
   - [x] a) If a string is empty
   - [ ] b) If a file is hidden
   - [ ] c) If a number is zero
**Answers**: 1-b, 2-b, 3-a
## 🔗 Next Steps
Continue to: **[Loops](../16-For-Loops/README.md)** →
