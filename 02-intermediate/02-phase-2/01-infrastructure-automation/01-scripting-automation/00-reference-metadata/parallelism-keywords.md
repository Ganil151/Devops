# ⚡ Reference: Parallelism Keywords

In the fleet-management era, running tasks one-by-one is a bottleneck. Parallelism allows you to scale your script's execution across multiple CPU cores.

---

## 🛠️ Concurrency Tools

### `xargs -P <count>`
*   **Definition**: The "Max Procs" flag. Tells xargs to run up to `<count>` processes concurrently.
*   **Example**: `-P 10` processes tasks in batches of 10.

### `xargs -I { }`
*   **Definition**: The "Replace-String" flag. It allows you to place the incoming argument anywhere in your final command.
*   **Example**: `... | xargs -I {} cp {} /backup/`

### `export -f <function>`
*   **Definition**: Makes a Bash function available to subshells (like those launched by `xargs` or `parallel`).
*   **DevOps Principle**: Small, exported functions are modular and easier to scale than giant monolithic scripts.

---

## 🏗️ Safety & Coordination

### `wait`
*   **Definition**: Pauses the parent script until all background child processes have finished.
*   **DevOps Why**: Prevents the script from generating a final report before the work is actually done.

### `&` (Background)
*   **Definition**: Appending `&` to a command sends it to the background immediately.
*   **Risk**: Without management (like `wait` or a queue), launching too many background jobs can crash a server using an "OOM" (Out of Memory) state.

---

## 🎙️ Staff Interview context
*   **"How do you handle error reporting when 10 tasks are running in parallel?"**
    *   *Answer*: Redirect the stdout/stderr of each worker to a unique log file (`worker-{$ID}.log`). This prevents "Output Interleaving" (garbled text) and allows you to audit each failure individually.
