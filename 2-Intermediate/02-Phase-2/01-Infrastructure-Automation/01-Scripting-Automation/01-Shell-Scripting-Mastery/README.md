# 💻 Shell Scripting Mastery

Bash is the lowest common denominator of infrastructure. If you can ssh into a server, you can run Bash.

## 🏗️ Reorganized Structure
- **[01-Fundamentals](./01-Fundamentals)**: Conditionals, Loops, and Logic.
- **[02-Data-Processing](./02-Data-Processing)**: The power trio: `sed`, `awk`, `jq`.
- **[03-Advanced-Production-Patterns](./03-Advanced-Production-Patterns)**: Robust error handling, logging libraries, and signal traps.

## 🛡️ Production Best Practices
1.  **Shebang**: Always use `#!/bin/bash` (highly portable) or `#!/usr/bin/env bash` (environment aware).
2.  **Linting**: Use `shellcheck` in your IDE or CI pipeline to catch syntax errors and unsafe variable quoting.
3.  **Functions**: Break code into small, reusable functions. Avoid "Spaghetti Script".

### Example: Robust Logging Function
```bash
log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [$level] $*" >&2
}

log INFO "Starting deployment..."
```
