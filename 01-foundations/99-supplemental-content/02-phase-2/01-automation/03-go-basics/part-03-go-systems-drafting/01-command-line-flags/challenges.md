# Command-Line Flags - DevOps Challenges

## Challenge 1: Basic Service Controller
**Scenario**: Create a simple service control tool with start/stop/status commands.

**Requirements:**
1. Create a Go program with flags for:
   - `--service` (name of service)
   - `--action` (start, stop, status)
   - `--verbose` (boolean for detailed output)
2. Simulate the service action with appropriate messages

**Verification:**
```bash
cd boilerplate
go run main.go --service nginx --action start --verbose
# Expected: Detailed output about starting nginx
```

---

## Challenge 2: Deployment Configuration Tool
**Scenario**: Build a deployment tool that accepts multiple configuration options.

**Requirements:**
1. Accept flags for:
   - `--environment` (dev, staging, prod)
   - `--replicas` (number of instances, default: 3)
   - `--image` (Docker image name)
   - `--dry-run` (boolean, simulate only)
2. Validate that environment is one of the allowed values
3. Print deployment configuration

**Verification:**
```bash
go run deploy.go --environment prod --replicas 5 --image myapp:v1.2.3
# Expected: Deployment configuration output
```

---

## Challenge 3: Log Analyzer with Options
**Scenario**: Create a log analysis tool with various filtering options.

**Requirements:**
1. Accept flags for:
   - `--file` (log file path)
   - `--level` (ERROR, WARN, INFO, DEBUG)
   - `--since` (time duration, e.g., "1h", "24h")
   - `--count` (show count only, boolean)
2. Parse and filter log entries based on criteria
3. Support `-h` or `--help` for usage information

**Verification:**
```bash
go run log_analyzer.go --file app.log --level ERROR --since 24h
# Expected: Filtered log entries from last 24 hours
```

---

## Challenge 4 (Advanced): Multi-Cloud Configuration Tool
**Scenario**: Build a tool that manages configurations across different cloud providers.

**Requirements:**
1. Accept flags for:
   - `--provider` (aws, gcp, azure)
   - `--region` (cloud region)
   - `--config-file` (path to config file)
   - `--output-format` (json, yaml, table)
   - `--validate-only` (boolean)
2. Use `flag.FlagSet` for subcommands (init, apply, destroy)
3. Implement proper flag parsing with validation

**Verification:**
```bash
go run cloud_config.go apply --provider aws --region us-east-1 --config-file config.yaml
# Expected: Configuration applied message
```

---

## Challenge 5 (Expert): Custom Flag Types
**Scenario**: Create a deployment tool with custom flag types for complex configurations.

**Requirements:**
1. Implement custom flag types for:
   - StringSlice (for multiple tags: `--tag v1 --tag v2`)
   - KeyValue (for environment variables: `--env KEY=VALUE`)
   - Duration (for timeout periods)
2. Create a deployment command that uses these custom types
3. Implement `flag.Value` interface for each custom type

**Example Usage:**
```bash
go run deploy.go \
  --tag backend --tag api --tag v1.0 \
  --env DATABASE_URL=postgres://... \
  --env REDIS_URL=redis://... \
  --timeout 5m
```

**Verification:**
```bash
# Should parse all flags correctly and display deployment plan
```

**Next Step**: [Environment Variables →](challenges.md)
