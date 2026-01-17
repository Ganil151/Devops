# Advanced Challenges: Custom Tooling & Integration

### Challenge 1: Distributed State Locking
**Scenario**: The current `sync.Mutex` only works for a single instance of the CLI tool. 
-   **Requirement**: Refactor the `Deployer` to use a Distributed Lock (e.g., via Redis or a DynamoDB table) so that multiple engineers across the globe cannot run the tool on the same environment at once.

### Challenge 2: Dynamic Plugin System
**Scenario**: You want to add support for a third tool (e.g., `helm`) without modifying the `Deployer` core logic.
-   **Requirement**: Implement a "Plugin" architecture using Go's `plugin` package or by loading YAML-defined "Provisioner" steps that execute shell commands.

### Challenge 3: Real-Time Secret Masking
**Scenario**: Simple regex masking is often bypassed by multi-line secrets.
-   **Requirement**: Implement a `io.Writer` wrapper that uses a sliding window buffer to detect and mask secrets even if they are split across multiple `Write` calls.
