# 🧩 Functions (Modularity)

> **"Don't Repeat Yourself (DRY). If you write it twice, make it a function."**

![Functions Banner](../../assets/functions_banner.png)

## 📚 Overview

As scripts grow, they become hard to read and manage. **Functions** allow you to group code into reusable blocks. They look and act like custom commands. Instead of a 500-line script, you can have a 50-line main coordination block calling 10 well-named functions.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Define and call functions in Bash
- ✅ Pass arguments to functions (Scope!)
- ✅ Use `local` variables to prevent bugs
- ✅ Return values (using exit codes or echoes)
- ✅ Organize large scripts into libraries

## 🏗️ Structure: Monolith vs. Modular

```mermaid
graph TD
    subgraph Monolith ["🍝 Spaghetti Code"]
        Start1[Start] --> Code1[100 lines of Logic]
        Code1 --> Code2[Copy-pasted Logic]
        Code2 --> Code3[More Logic]
        Code3 --> End1[End]
    end
    
    subgraph Modular ["🧱 Modular Design"]
        Start2[Main] --> CallA[Call Log()]
        Start2 --> CallB[Call Backup()]
        Start2 --> CallC[Call Deploy()]
        
        CallA -.-> FuncA[Function: Log]
        CallB -.-> FuncB[Function: Backup]
        CallC -.-> FuncC[Function: Deploy]
    end

    style Monolith fill:#e74c3c,stroke:#333
    style Modular fill:#2ecc71,stroke:#333
```

## 🛠️ Defining Functions

Two ways to write them:
```bash
# Style 1 (Preferred)
function my_func() {
    echo "Logic here"
}

# Style 2 (C-style)
my_func() {
    echo "Logic here"
}
```

## 🧪 Function Arguments & Scope

**CRITICAL:** Functions have their own arguments (`$1`, `$2`), separate from the script's arguments!

```bash
function greet() {
    local NAME=$1   # $1 here is the first arg passed TO THE FUNCTION
    echo "Hello, $NAME"
}

# Calling it
greet "Alice"    # "Alice" becomes $1 inside greet
```

### The `local` Keyword
By default, all variables in Bash are **global**. This is a major source of bugs.
Always use `local` inside functions.

```bash
name="Global"

function change() {
    local name="Local"
    echo "Inside: $name"
}

change          # Prints "Inside: Local"
echo "Outside: $name"  # Prints "Outside: Global" (Safe!)
```

## 🏆 Real-World DevOps Story

### 💡 **The Variable Collision**

**Scenario**: A deployment script had two main parts: `build()` and `deploy()`. Both used a variable named `i` for a loop.
Because they didn't use `local`, the `deploy` function accidentally reset the `i` variable of the outer loop that called it.

**The Bug**: The script would only deploy to the first server and then stop, thinking the loop was done.

**The Fix**:
```bash
function deploy() {
    local i   # Fix: Scope the variable
    for i in "${servers[@]}"; do ... done
}
```

## 🎓 Interview Questions

### Q1: How do you return a string from a function?
<details>
<summary>Click to reveal answer</summary>

Bash functions don't "return" data like Python. They only return an **exit status** (0-255).
To return data, `echo` it to stdout and capture it:
```bash
result=$(my_function)
```
</details>

### Q2: Can a function change the environment of the parent script?
<details>
<summary>Click to reveal answer</summary>

Yes, unless you execute the function in a subshell `( my_function )`.
If you change a variable (without `local`) or change directory `cd` inside a function, it affects the whole script.
</details>

### Q3: How do you separate functions into a different file?
<details>
<summary>Click to reveal answer</summary>

Create a file `utils.sh` containing only functions.
Then in your main script:
```bash
source ./utils.sh
# Now you can use the functions
```
This is how "libraries" work in Bash.
</details>

## 📝 Quiz

1. **Which keyword restricts a variable to the function?**
   - [ ] a) `private`
   - [x] b) `local`
   - [ ] c) `scope`
   - [ ] d) `var`

2. **Inside a function, what is `$1`?**
   - [ ] a) Script's first argument
   - [x] b) Function's first argument
   - [ ] c) Function name
   - [ ] d) Return value

3. **How do you call a function named `backup`?**
   - [ ] a) `call backup()`
   - [ ] b) `backup()`
   - [x] c) `backup`
   - [ ] d) `run backup`

4. **What does `return 1` do in a function?**
   - [ ] a) Returns the integer 1
   - [x] b) Sets exit status to 1 (Error)
   - [ ] c) Exits the script
   - [ ] d) Returns to start

5. **Why define functions?**
   - [ ] a) Code reuse
   - [ ] b) Readability
   - [ ] c) Easier maintenance
   - [x] d) All of the above

**Answers**: 1-b, 2-b, 3-c, 4-b, 5-d

## 🔗 Next Steps

Continue to: **[Conditionals](../15-Conditionals/README.md)** →

## 📚 Additional Resources
- [Bash Functions Academy](https://linuxize.com/post/bash-functions/)
- [Google Shell Style Guide (Functions)](https://google.github.io/styleguide/shellguide.html#s4-functions)

---
**📌 Pro Tip**: Define a usage/help function at the top of your script and call it whenever arguments are invalid!
```bash
function usage() {
    echo "Usage: $0 [start|stop]"
    exit 1
}
```
