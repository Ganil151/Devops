# Shell Functions and Modularity

As scripts grow, they become harder to manage. Functions allow you to break your code into reusable, modular blocks, making your automation cleaner and easier to test.

## 🧱 Defining Functions

Functions in Bash are defined using the `function` keyword or simply with `()`.

```bash
# Style 1
function log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Style 2 (More common)
print_usage() {
    echo "Usage: $0 --option"
}
```

### Passing Arguments
Functions do not take named arguments like `function(arg1, arg2)`. Instead, they use positional parameters just like the script itself:
-   `$1`, `$2`, ...: The arguments passed to the function.
-   `$@`: All arguments.
-   `$#`: Number of arguments.

```bash
calculate_sum() {
    local SUM=$(( $1 + $2 ))
    echo "$SUM"
}

TOTAL=$(calculate_sum 5 10)
```

> [!IMPORTANT]
> Always use the `local` keyword inside functions to ensure variables don't bleed into the global script scope.

## 🏁 Exit Codes and Returns

Functions in Bash don't "return" values in the traditional sense (like a string).
-   **Return Statement**: `return` produces an **exit status** (0-255), not data.
-   **Returning Data**: To return data, `echo` it from the function and capture it using command substitution: `RESULT=$(my_func)`.

## 📦 Script Arguments and `shift`

When your script receives many arguments, `shift` is useful for processing them one by one.

```bash
while [ $# -gt 0 ]; do
    case "$1" in
        --help) print_usage; exit 0 ;;
        --user) USERNAME="$2"; shift ;; # Move to next arg
    esac
    shift # Move to next arg
done
```

---

## 📖 Stories from the Field: The Recursive Disaster

**Scenario**: A sysadmin wrote a function to recursively delete "temp" files.
**Problem**: The function had a bug where it accidentally called itself with an empty string as an argument. Because they didn't use `local` variables, the empty argument modified the global "current directory" variable.
**Outcome**: The script started deleting from the root directory instead of the temp folder.
**Resolution**: Added `local` keywords and strict input validation at the start of every function.
**Prevention**: Never pass unvalidated variables to destructive commands like `rm`. Always use `local` to isolate function logic.

---

## ❓ Interview Questions

1.  **What does the `local` keyword do?**
    *   *Answer*: It restricts the scope of a variable to the function where it is defined, preventing it from overwriting variables in the rest of the script.
2.  **How do you return a value from a bash function?**
    *   *Answer*: To return an exit status, use `return N`. To return data (like a string), use `echo "data"` and capture it with `VAR=$(function_name)`.
3.  **What does `shift` do?**
    *   *Answer*: It shifts the positional parameters (e.g., `$2` becomes `$1`, `$3` becomes `$2`). This is often used to parse command-line flags.
4.  **Can a function be exported to other scripts?**
    *   *Answer*: Yes, using `export -f function_name`, provided the sub-script is executed within the same environment (e.g., via `source` or a child bash process).
5.  **How do you find the name of the current function inside itself?**
    *   *Answer*: Use the special array variable `${FUNCNAME[0]}`.

---

## 🧠 Quiz

1.  **Which keyword limits a variable's scope to a function?** `(local)`
2.  **How do you access the second argument passed to a function?** `($2)`
3.  **What is the maximum value a `return` statement can provide?** `(255)`
4.  **T/F: `RESULT=function_name` will capture the output of a function.** `(False - must use substitution: RESULT=$(function_name))`
5.  **What command moves `$2` into the `$1` position?** `(shift)`