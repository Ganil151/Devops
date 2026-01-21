# 📦 Functions and Scope

Functions are the building blocks of maintainable scripts. They allow you to encapsulate logic, re-use code, and isolate variables.

> **⚠️ Missing Image**: *Function Architecture Placeholder* ('./function_scope_architecture.svg')

## 🌎 Global vs. Local Scope

By default, all variables in Bash are **global**, even if defined inside a function. This leads to "variable pollution" where one function accidentally overwrites another's data.

### The `local` Keyword
Always use `local` for variables inside functions.

```bash
my_func() {
    local temp_var="I am local"
    global_var="I am global"
}
```

---

## ↩️ The "Return" Myth: Integers vs. Output

Newcomers often confuse Bash return values with other languages.

### 1. `return` (Status Code)
- Can **only** return an integer (0-255).
- Used for success (0) or failure (!=0).
- Accessed via `$?`.

```bash
check_file() {
    [[ -f "$1" ]] && return 0 || return 1
}
```

### 2. `echo` (Stdout)
- Used to "return" data (strings, lists, complex content).
- Captured via Command Substitution: `VAR=$(my_func)`.

```bash
get_hostname() {
    echo "web-server-01"
}
HOST=$(get_hostname)
```

---

## 🧮 Pattern: Passing Data

Since functions run in the same shell process (unlike subshells), you can also pass data by modifying a known Global Variable, though this is riskier.

### Comparison
| Method            | Pros                                 | Cons                                    |
| :---------------- | :----------------------------------- | :-------------------------------------- |
| Stdout (`$(cmd)`) | Clean, functional, side-effect free. | Spawns a subshell (slower performance). |
| **Global Ref**    | Fast (no subshell).                  | Side-effects, harder to debug.          |

See `Boilerplates/math_functions.sh` for a code comparison.
