# ⌨️ Command Line Arguments: The User Interface

> **"Bash scripts are for quick fixes, but Python CLIs are for enterprise automation. If you want your tools to be used by fellow engineers, you must build them with a professional interface."**

![Python CLI Architecture](challenges/challenge-06-cli-wrapper.py)

---

## 🧠 The Mental Model: The Cockpit Control Panel

**The Junior Struggle**: "Just edit the variable at the top of the script to change the environment!"

**The Engineer Solution**: Hardcoding inputs is dangerous. Scripts should work like physical machines—the internal logic stays the same, but the **controls** (switches, buttons, knobs) change the behavior.

### 🏗️ The Infrastructure Analogy

Think of your script as a machine and `argparse` as the **Control Panel**:

| Concept | Machine Analogy | Python CLI Equivalent |
|:--------|:----------------|:----------------------|
| **Positional Arg** | Main Power Switch | `python deploy.py production` (Must exist) |
| **Optional Arg** | Fine-tuning Knob | `--replicas 3` (Has a default) |
| **Flag** | Toggle Switch | `--dry-run` (True/False) |
| **Subcommand** | Different Modes | `git commit` vs `git push` |
| **Help Menu** | Instruction Manual | `--help` (Auto-generated) |

**The Key Insight**: A good CLI protects the user from making mistakes by validating input *before* the engine starts.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll use `input()` to ask the user questions" (Blocks automation!)
- "I'll parse `sys.argv` manually" (Fragile and hard to maintain)
- "I'll hardcode values and edit the file every time"

**After this module**, you'll understand:
- **Automation must be non-interactive** (no `input()` calls)
- **Validation prevents disasters** (`--env prod` requires confirmation)
- **Help menus** make your tools self-documenting
- **Flags** control behavior (`--verbose`, `--force`)

**The Difference**: Your script becomes a **Tool** that others can trust and use in CI/CD pipelines.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master `argparse`**: The industry standard library
- ✅ **Implement Positional & Optional** arguments
- ✅ **Create Flags** (`store_true` patterns)
- ✅ **Build Subcommands** (git-style interfaces)
- ✅ **Validate Input** (Types, Choices, and Ranges)
- ✅ **Design Help Menus** that guide the user

---

## 🏗️ Part 1: The CLI Anatomy

### 🧠 The Mental Model: The Parsing Pipeline

**The Process**: Arguments flow from the shell (`sys.argv`) → Parser → Validation → Namespace Object.

### 🔧 Basic Implementation

```python
import argparse
import sys

def main():
    # 1. Initialize the Parser (The "Control Panel")
    parser = argparse.ArgumentParser(
        description="🚀 Deployment Automation Tool",
        epilog="Example: python deploy.py production --replicas 5"
    )

    # 2. Add Arguments (The "Knobs and Switches")
    
    # Positional Argument (Mandatory)
    parser.add_argument(
        "environment", 
        choices=["dev", "staging", "prod"], # Restrict values
        help="Target environment for deployment"
    )

    # Optional Argument with Default (The Knob)
    parser.add_argument(
        "-r", "--replicas", 
        type=int,           # Enforce integer type
        default=1,          # Default value if invalid
        help="Number of container replicas (default: 1)"
    )

    # Flag (The Switch)
    parser.add_argument(
        "--dry-run", 
        action="store_true", # Sets Check=True if present
        help="Simulate deployment without changes"
    )

    # 3. Parse and Validate (The "Safety Check")
    args = parser.parse_args()

    # 4. Use the Values (The "Engine")
    print(f"🔹 Target: {args.environment}")
    print(f"🔹 Replicas: {args.replicas}")
    
    if args.dry_run:
        print("⚠️  DRY RUN MODE: No changes made")
    else:
        print("🚀 Executing deployment...")

if __name__ == "__main__":
    main()
```

### 🏃 Running It
```bash
$ python deploy.py prod --replicas 3 --dry-run
🔹 Target: prod
🔹 Replicas: 3
⚠️  DRY RUN MODE: No changes made
```

---

## 🚀 Part 2: Advanced Patterns (Subcommands)

### 🧠 The Mental Model: The Multi-Tool

**The Use Case**: Tools like `git` or `kubectl` do many different things (`get`, `create`, `delete`). These are **Subcommands**.

### 🔧 Subcommand Architecture

```python
import argparse

parser = argparse.ArgumentParser(prog="cloud-tool")
subparsers = parser.add_subparsers(dest="command", help="Available commands")

# 🔹 Command: 'list'
parser_list = subparsers.add_parser("list", help="List cloud resources")
parser_list.add_argument("--region", default="us-east-1")

# 🔹 Command: 'create'
parser_create = subparsers.add_parser("create", help="Create a new resource")
parser_create.add_argument("name", help="Name of the resource")
parser_create.add_argument("--type", choices=["t2.micro", "m5.large"], required=True)

args = parser.parse_args()

if args.command == "list":
    print(f"Listing resources in {args.region}...")
elif args.command == "create":
    print(f"Creating {args.type} instance named '{args.name}'...")
else:
    parser.print_help()
```

---

## 🛡️ Part 3: Validation and Logic

### 🧠 The Mental Model: The Guard Rails

**The Concept**: Don't let the user crash the script. Validate inputs *before* execution starts.

### 🔧 Custom Validation

```python
def valid_port(value):
    """Custom validator for port numbers."""
    ivalue = int(value)
    if ivalue < 1 or ivalue > 65535:
        raise argparse.ArgumentTypeError(f"{value} is not a valid port (1-65535)")
    return ivalue

parser.add_argument("--port", type=valid_port, default=8080)
```

### 🔧 Mutually Exclusive Groups
Prevent conflicting flags (e.g., cannot be Quiet and Verbose at the same time).

```python
group = parser.add_mutually_exclusive_group()
group.add_argument("-v", "--verbose", action="store_true")
group.add_argument("-q", "--quiet", action="store_true")
```

---

## 🏆 Real-World DevOps Story: The "Prod" Accident

**The Scenario**: A cleanup script used crude parsing: `sys.argv[1]`.
An engineer meant to type `python clean.py staging` but hit `Enter` too early after typing `python clean.py`. The script defaulted to `prod` in the code because of a sloppy `if` check.

**The Incident**: The script deleted production logs instead of staging logs.

**The Fix**: The team switched to `argparse`.
1. **Positional Argument**: `env` became mandatory.
2. **Safety Flag**: Added `--force` flag. If `env == 'prod'` and `--force` is missing, the script Aborts.
3. **Dry Run**: Added a default `--dry-run` that simply printed what *would* happen.

**The Outcome**: Accidents became impossible. The tool required explicit intent (`python clean.py prod --force`) to do damage.

---

## ❓ Interview Preparation (CLI)

### 🎯 Core Concepts

1. **Q: Why use `argparse` instead of `input()`?**
   - *A: `input()` blocks execution and requires human interaction, making the script impossible to automate in CI/CD pipelines. `argparse` allows inputs to be passed as flags at runtime.*

2. **Q: How do you handle a list of items as an argument?**
   - *A: Use `nargs='+'` (one or more) or `nargs='*'` (zero or more). Example: `parser.add_argument('files', nargs='+')` allows `python app.py file1.txt file2.txt`.*

3. **Q: What does `choices` do?**
   - *A: It restricts the argument to a specific list of values. `choices=['json', 'yaml']`. If the user inputs `xml`, argparse raises an error automatically.*

4. **Q: How do you implement a flag (boolean switch)?**
   - *A: Use `action='store_true'`. If the flag is present, the value is True. If absent, False.*

5. **Q: What is a Namespace object?**
   - *A: The result of `parser.parse_args()`. It's a simple object where arguments are accessed as attributes (e.g., `args.verbose`).*

### 🚀 Advanced Questions

6. **Q: How do you make an optional argument required?**
   - *A: `parser.add_argument('--token', required=True)`. This keeps the "flag" syntax (`--token`) but forces the user to provide it.*

7. **Q: How do you create a Git-style CLI with `commit`, `push`, etc.?**
   - *A: Use `parser.add_subparsers()`. Each subparser has its own arguments and can trigger different logic functions.*

8. **Q: How do you hide a dangerous flag from the help menu?**
   - *A: Use `help=argparse.SUPPRESS`. The argument works, but isn't listed in `--help`. Useful for dangerous debug flags.*

9. **Q: Can argparse read environment variables?**
   - *A: Not natively, but you can set the default value using `os.getenv`: `default=os.getenv('API_KEY')`. This is a powerful pattern for 12-Factor Apps.*

10. **Q: What is the exit code if argparse fails validation?**
    - *A: Exit code 2. It also prints the usage guide to stderr.*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which method parses the arguments?**
   - [ ] a) `parser.run()`
   - [x] b) `parser.parse_args()`
   - [ ] c) `parser.get()`

2. **What creates a True/False flag?**
   - [ ] a) `type=bool`
   - [x] b) `action="store_true"`
   - [ ] c) `flag=True`

3. **How do you restrict valid values to 'dev' and 'prod'?**
   - [ ] a) `limit=['dev', 'prod']`
   - [ ] b) `validate=['dev', 'prod']`
   - [x] c) `choices=['dev', 'prod']`

### 🚀 Intermediate Level

4. **What does `nargs='+'` mean?**
   - [ ] a) Optional argument
   - [x] b) One or more values required
   - [ ] c) Zero or more values required

5. **Where are the help messages displayed?**
   - [x] a) Automatically when running with `-h` or `--help`
   - [ ] b) Only in the README
   - [ ] c) When the script crashes

6. **How do you prevent `--quiet` and `--verbose` from being used together?**
   - [ ] a) `if` statements
   - [x] b) `add_mutually_exclusive_group()`
   - [ ] c) It's impossible

### 🏆 Advanced Level

7. **What is the best way to handle secrets in a CLI?**
   - [ ] a) Pass them as plain flags
   - [x] b) Use environment variables as defaults (`default=os.getenv(...)`)
   - [ ] c) Hardcode them

8. **If `type=int` is set and the user passes "abc", what happens?**
   - [x] a) Argparse prints an error and exits (Code 2)
   - [ ] b) Python raises a ValueError
   - [ ] c) The script continues with "abc"

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Control Panel**: Build an interface, not just a script.
2. **Validation**: Check inputs before the engine starts.
3. **Subcommands**: Group related actions (Git style).

### 🛡️ Safety Patterns

1. **Never use `input()`** for automation tools.
2. **Use `choices`** to restrict inputs.
3. **Use 12-Factor Defaults** (Env vars as fallbacks).

### 🚀 Production Rules

1. **Always implement `--help`** (it's automatic!).
2. **Use `--dry-run`** for destructive actions.
3. **Validate types** (`int`, `file`, etc.).

---

## 🔗 Next Steps

You have a professional interface. Now let's explore how to navigate the file system with modern tools.

**Proceed to**: [Pathlib Modern Files →](readme.md)

---

## 📚 Additional Resources

- [Argparse Tutorial](https://docs.python.org/3/howto/argparse.html)
- [Click (Alternative Library)](https://click.palletsprojects.com/)
- [12-Factor App Config](https://12factor.net/config)

---

**🎓 Remember**: A newbie hardcodes values. An engineer parses `sys.argv`. A senior engineer uses `argparse` to build professional, documented, and safe CLI tools.
