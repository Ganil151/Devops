# Regular Expressions - DevOps Challenges

## Challenge 1: Log Level Extractor
**Scenario**: Extract log levels and messages from unstructured logs.

**Requirements:**
1. Regex to match `[INFO]`, `[ERROR]`, etc.
2. Capture log level and remaining message
3. Handle different bracket styles `[DEBUG]` vs `(DEBUG)`

**Verification:**
```bash
go run log-extractor.go
# Expected: Level: ERROR, Msg: Connection timeout
```

---

## Challenge 2: Terraform Resource Name validator
**Scenario**: Enforce naming conventions for resources.

**Requirements:**
1. Regex for pattern: `[env]-[region]-[service]-[role]`
2. Example: `prod-us-east-1-api-web`
3. Print specific error for non-matching parts

**Verification:**
```bash
go run name-validator.go "my-server-1"
# Expected: Invalid format. Expected: env-region-service-role
```

---

## Challenge 3: Config File Variable Substitution
**Scenario**: Find and replace all `${...}` variables in a file.

**Requirements:**
1. Read file content
2. Find all occurrences of `${VAR_NAME}`
3. Print list of unique variables found

**Verification:**
```bash
go run var-finder.go config.yml
# Expected: Found variables: DATABASE_URL, PORT
```
