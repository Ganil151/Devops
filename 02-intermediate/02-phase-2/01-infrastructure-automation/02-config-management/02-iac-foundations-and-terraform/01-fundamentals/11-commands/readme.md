# Terraform CLI Commands Reference

This directory contains comprehensive documentation for all essential Terraform CLI commands, organized by function and workflow stage.

## 📚 Directory Structure

### Core Workflow Commands
1. **[01-Init.md](01-init.md)** - `terraform init` - Initialize working directory
2. **[02-Validate.md](02-validate.md)** - `terraform validate` - Validate configuration syntax
3. **[03-Plan.md](03-plan.md)** - `terraform plan` - Preview infrastructure changes
4. **[04-Apply.md](04-apply.md)** - `terraform apply` - Create/update infrastructure
5. **[05-Destroy.md](05-destroy.md)** - `terraform destroy` - Destroy infrastructure

### State Management Commands
6. **[06-State.md](06-state.md)** - `terraform state` - Advanced state manipulation
7. **[07-Import.md](07-import.md)** - `terraform import` - Import existing resources
8. **[08-Taint.md](08-taint.md)** - `terraform taint/untaint` - Mark resources for recreation

### Formatting & Documentation
9. **[09-Fmt.md](09-fmt.md)** - `terraform fmt` - Format Terraform code
10. **[10-Show.md](10-show.md)** - `terraform show` - Display state or plan details
11. **[11-Output.md](11-output.md)** - `terraform output` - Extract output values

### Workspace Management
12. **[12-Workspace.md](12-workspace.md)** - `terraform workspace` - Manage workspaces

### Advanced Commands
13. **[13-Graph.md](13-graph.md)** - `terraform graph` - Generate dependency graph
14. **[14-Console.md](14-console.md)** - `terraform console` - Interactive console
15. **[15-Providers.md](../06-providers/providers.md)** - `terraform providers` - Manage providers
16. **[16-Refresh.md](16-refresh.md)** - `terraform refresh` - Sync state with reality

### Utility Commands
17. **[17-Version.md](../18-version-control-integration/version-control-integration.md)** - `terraform version` - Show version information
18. **[18-Get.md](../../../../05-system-administration/04-log-management-and-auditing/get-taskaudit.ps1)** - `terraform get` - Download modules
19. **[19-Login-Logout.md](19-login-logout.md)** - `terraform login/logout` - Terraform Cloud auth

### Advanced Topics
20. **[20-Force-Unlock.md](20-force-unlock.md)** - `terraform force-unlock` - Release state locks
21. **[21-Quick-Reference.md](21-quick-reference.md)** - Cheat sheet of all commands

---

## 🎯 Command Categories by Use Case

### Daily Development Workflow
```bash
terraform init        # First time setup
terraform fmt         # Format code
terraform validate    # Check syntax
terraform plan        # Preview changes
terraform apply       # Apply changes
```

### State Management
```bash
terraform state list              # List resources
terraform state show <resource>   # Show resource details
terraform state mv               # Move resource
terraform state rm               # Remove from state
terraform import                 # Import existing resource
```

### Debugging & Troubleshooting
```bash
terraform console     # Test expressions
terraform show        # Inspect state/plan
terraform graph       # Visualize dependencies
terraform output      # View outputs
terraform refresh     # Sync state
```

### Team Collaboration
```bash
terraform workspace new <name>    # Create workspace
terraform workspace select <name> # Switch workspace
terraform workspace list          # List workspaces
```

---

## 📖 Learning Path

### Beginner (Essential Commands)
1. `terraform init` - Understand initialization
2. `terraform plan` - Learn to preview changes
3. `terraform apply` - Create infrastructure
4. `terraform destroy` - Clean up resources
5. `terraform fmt` - Format your code

### Intermediate (State & Workspace)
6. `terraform state` - Manipulate state safely
7. `terraform import` - Bring existing resources
8. `terraform workspace` - Manage multiple environments
9. `terraform output` - Extract values
10. `terraform validate` - Ensure correctness

### Advanced (Debugging & Optimization)
11. `terraform console` - Interactive testing
12. `terraform graph` - Visualize dependencies
13. `terraform show` - Deep dive into state
14. `terraform refresh` - State synchronization
15. `terraform force-unlock` - Handle locks

---

## 🔍 Quick Command Lookup

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `init` | Initialize directory | First time, after adding providers/modules |
| `validate` | Check syntax | Before committing code |
| `fmt` | Format code | Before committing code |
| `plan` | Preview changes | Before applying changes |
| `apply` | Create/update infrastructure | When ready to deploy |
| `destroy` | Delete infrastructure | Cleanup, testing |
| `state` | Manage state | Renaming, moving resources |
| `import` | Add existing resources | Adopting existing infrastructure |
| `output` | Show output values | Getting resource information |
| `workspace` | Manage workspaces | Multiple environments |
| `console` | Interactive REPL | Testing expressions, debugging |
| `show` | Display state/plan | Understanding current state |
| `graph` | Dependency visualization | Understanding relationships |

---

## 🛡️ Best Practices

### Always Run Before Apply
```bash
terraform fmt -check      # Ensure formatting
terraform validate        # Check syntax
terraform plan -out=plan  # Save plan
terraform apply plan      # Apply saved plan
```

### State Management Safety
```bash
# Always backup before state operations
terraform state pull > backup.tfstate

# Use targeted operations when possible
terraform state rm -dry-run <resource>
terraform apply -target=<resource>
```

### Environment-Specific Commands
```bash
# Development
terraform plan -var-file=dev.tfvars

# Staging
terraform plan -var-file=staging.tfvars

# Production
terraform plan -var-file=prod.tfvars -out=prod.plan
terraform apply prod.plan
```

---

## 🎓 Command Flags Reference

### Global Flags (Work with most commands)
- `-chdir=<path>` - Change working directory
- `-no-color` - Disable colored output
- `-json` - Output in JSON format (where supported)

### Common Plan/Apply Flags
- `-var="key=value"` - Set a variable
- `-var-file=<file>` - Load variables from file
- `-target=<resource>` - Target specific resources
- `-parallelism=<n>` - Set parallel operations (default: 10)
- `-refresh=false` - Skip refresh phase

### State Command Flags
- `-state=<path>` - Path to state file
- `-state-out=<path>` - Write state to path
- `-lock=false` - Don't hold state lock
- `-backup=<path>` - Path to backup file

---

## 📝 Command Output Symbols

Understanding Terraform's plan output:

| Symbol | Meaning |
|--------|---------|
| `+` | Resource will be created |
| `-` | Resource will be destroyed |
| `~` | Resource will be modified in-place |
| `-/+` | Resource will be destroyed and recreated |
| `<=` | Data source will be read |
| `#` | Comment or informational message |

---

## 🔗 Related Resources

- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [Terraform Command Line Interface](https://www.terraform.io/docs/cli/index.html)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

---

**Last Updated**: 2026-01-07
**Terraform Version**: 1.6+

> **Note**: All examples in this directory are compatible with Terraform 1.0+ unless otherwise specified.
