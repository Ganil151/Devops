# Production Scenario: "One-Click" Environment Deployer

## Overview
This Go boilerplate demonstrates a **Cross-Tool Orchestrator** that synthesizes Terraform (Infrastructure as Code) and Ansible (Configuration Management) into a single, cohesive deployment pipeline. It uses advanced Go patterns like interfaces, context timeouts, and mutex-based state locking.

### Real-World Use Case
In complex cloud environments, infrastructure provisioning and software configuration often happen in disconnected steps, leading to "state drift." This tool:
1.  **Unified Execution**: Ensures that Ansible only runs if Terraform succeeds.
2.  **Concurrency Control**: Uses a `sync.Mutex` to prevent multiple engineers from deploying to the same environment simultaneously, acting as a local state lock.
3.  **Context-Aware**: Implements `context.Context` to ensure that if a deployment takes longer than 20 minutes, it is automatically cancelled and resources are cleaned up.

## "What happens if the API rate limit is reached?"
When wrapping external CLIs like `terraform`, the orchestrator must handle their failure modes:
-   **Retry Logic**: The `runCommandWithMasking` function can be extended to detect specific exit codes (like AWS Rate Limit errors) and implement an exponential backoff before retrying the `Plan` or `Apply` phases.
-   **Graceful Degradation**: If the `Apply` phase fails halfway, the script can be configured to run a "Rollback" or "Destroy" phase to prevent orphaned resources that incur costs.
-   **Secret Masking**: All stdout/stderr from subprocesses is intercepted to ensure that Terraform sensitive outputs (like RDS passwords) are never logged to the CI/CD pipeline.

## Key Features
-   **Tool Abstraction**: Uses a `Provisioner` interface, allowing you to swap Terraform for Pulumi or Ansible for Chef with minimal code changes.
-   **Global State Lock**: Prevents race conditions during deployments.
-   **Graceful Context Cancellation**: Handles `SIGTERM` and timeouts cleanly.
