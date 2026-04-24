# First CLI Tool - DevOps Challenges

## Challenge 1: System Info Reporter
**Scenario**: Build your first production-ready CLI tool that reports system information.

**Requirements:**
1. Create a CLI tool called `sysinfo` that:
   - Shows hostname, OS, architecture
   - Displays current user and working directory
   - Reports Go version used to build the tool
2. Include `--version` and `--help` flags
3. Use proper exit codes (0 for success, 1 for errors)

**Verification:**
```bash
cd boilerplate
go build -o sysinfo
./sysinfo
./sysinfo --help
./sysinfo --version
```

---

## Challenge 2: File Backup Tool
**Scenario**: Create a CLI tool that backs up files with timestamp rotation.

**Requirements:**
1. Create `filebackup` tool with commands:
   - `backup <file>` - Create timestamped backup
   - `list <file>` - List all backups of a file
   - `restore <file> <backup>` - Restore from backup
2. Store backups in `.backups/` directory
3. Add flags for `--dry-run` and `--verbose`

**Verification:**
```bash
go build -o filebackup
./filebackup backup config.yaml
./filebackup list config.yaml
./filebackup restore config.yaml config.yaml.20240115-143000
```

---

## Challenge 3: Service Health Checker
**Scenario**: Build a tool that checks if services/endpoints are healthy.

**Requirements:**
1. Create `healthcheck` tool that:
   - Accepts multiple URLs as arguments
   - Checks HTTP status codes
   - Reports response time
   - Exits with non-zero code if any service is down
2. Add flags:
   - `--timeout` (request timeout)
   - `--parallel` (check services concurrently)
   - `--json` (output in JSON format)

**Verification:**
```bash
go build -o healthcheck
./healthcheck https://google.com https://github.com --timeout 5s --parallel
# Expected: Status report for each URL
```

---

## Challenge 4 (Advanced): Docker Container Manager
**Scenario**: Create a CLI wrapper around common Docker commands.

**Requirements:**
1. Create `dockman` tool with subcommands:
   - `ps` - List running containers (formatted)
   - `clean` - Remove stopped containers and dangling images
   - `logs <container>` - Stream container logs
   - `stats` - Show resource usage
2. Use `os/exec` to run Docker commands
3. Add colored output for better UX
4. Implement proper error handling

**Verification:**
```bash
go build -o dockman
./dockman ps
./dockman clean --dry-run
./dockman logs myapp
```

---

## Challenge 5 (Expert): Infrastructure Deployment CLI
**Scenario**: Build a comprehensive deployment tool similar to Terraform CLI.

**Requirements:**
1. Create `infractl` tool with:
   - Subcommands: `init`, `plan`, `apply`, `destroy`
   - Configuration file support (YAML/JSON)
   - State management (save deployment state)
   - Rollback capability
2. Features:
   - Interactive confirmation for destructive operations
   - Progress indicators for long-running operations
   - Detailed logging with levels (INFO, WARN, ERROR)
   - `--auto-approve` flag to skip confirmations
3. Use proper Go project structure:
   ```
   infractl/
   ├── cmd/
   │   └── infractl/
   │       └── main.go
   ├── pkg/
   │   ├── config/
   │   ├── state/
   │   └── deploy/
   └── go.mod
   ```

**Verification:**
```bash
cd infractl
go build -o infractl cmd/infractl/main.go
./infractl init
./infractl plan --config infra.yaml
./infractl apply --config infra.yaml
./infractl destroy --auto-approve
```

---

## Final Project: Multi-Tool CLI Suite
**Scenario**: Combine everything you've learned to create a Swiss Army knife CLI tool for DevOps.

**Requirements:**
Create a tool called `devops-toolkit` with these subcommands:
1. **file** - File operations (backup, rotate logs, scan)
2. **service** - Service management (start, stop, restart, status)
3. **health** - Health checks for URLs, databases, services
4. **deploy** - Deployment automation
5. **config** - Configuration management

Each subcommand should have its own flags and help text. The tool should be well-documented and production-ready.

**Bonus Features:**
- Configuration file support (`~/.devops-toolkit.yaml`)
- Plugin system for extending functionality
- Auto-completion for bash/zsh
- Update checker (check for new versions)

**Verification:**
```bash
go build -o devops-toolkit
./devops-toolkit --help
./devops-toolkit file backup --help
./devops-toolkit health check https://myapp.com
./devops-toolkit deploy --environment prod --dry-run
```

---

## Verification Checklist

- [ ] Can build standalone CLI binaries
- [ ] Understand command-line argument parsing
- [ ] Implement subcommands effectively
- [ ] Handle errors with proper exit codes
- [ ] Provide helpful `--help` and `--version` flags
- [ ] Use colored output for better UX
- [ ] Execute external commands with `os/exec`
- [ ] Structure larger projects properly

## Next Steps

🎉 **Congratulations!** You've completed the Go Basics for DevOps curriculum. You now have the skills to build production-ready automation tools in Go.

**Recommended next steps:**
- Build real DevOps tools for your infrastructure
- Explore advanced topics: concurrency, testing, performance optimization
- Study popular Go-based DevOps tools: Docker, Kubernetes, Terraform
- Contribute to open-source DevOps projects
