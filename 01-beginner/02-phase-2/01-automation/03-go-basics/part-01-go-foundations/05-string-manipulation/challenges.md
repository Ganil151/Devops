# String Manipulation - DevOps Challenges

## Challenge 1: Log Line Parser
**Scenario**: Extract fields from structured log lines (CLF format).

**Requirements:**
1. Parse log line: `127.0.0.1 - - [15/Jan/2024:10:30:00 +0000] "GET /api/v1/health HTTP/1.1" 200 1234`
2. Extract: IP, Timestamp, Method, Path, Status Code
3. Print structured output

**Verification:**
```bash
go run log-parser.go
# Expected: IP: 127.0.0.1, Method: GET, Status: 200
```

---

## Challenge 2: Environment Variable Template Engine
**Scenario**: Replace `${VAR}` placeholders in config files with env values.

**Requirements:**
1. Read input string with `${VAR_NAME}` syntax
2. Replace with value from `os.Getenv`
3. Leave as-is if env var missing

**Verification:**
```bash
API_URL=http://localhost go run template.go "Connect to ${API_URL}"
# Expected: Connect to http://localhost
```

---

## Challenge 3: Sensitive Data Redactor
**Scenario**: Redact credit cards and email addresses from logs.

**Requirements:**
1. Detect email addresses (simple check)
2. Detect credit card numbers (Luhn check optional, just format)
3. Replace with `[REDACTED]` or `x@x.com`

**Verification:**
```bash
go run redactor.go "User email: bob@example.com"
# Expected: User email: [REDACTED]
```
