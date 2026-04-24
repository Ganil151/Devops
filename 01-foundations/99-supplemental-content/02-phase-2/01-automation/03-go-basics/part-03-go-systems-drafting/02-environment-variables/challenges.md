# Environment Variables - DevOps Challenges

## Challenge 1: Secrets Manager
**Scenario**: Load secrets from environment with validation.

**Requirements:**
1. Required vars: API_KEY, DB_PASSWORD
2. Exit with error if missing
3. Mask secrets in logs

**Verification:**
```bash
API_KEY=secret123 DB_PASSWORD=pass go run secrets.go
# Expected: Loads secrets, masks in output
```

---

## Challenge 2: Multi-Environment Config
**Scenario**: Load different configs based on ENV variable.

**Requirements:**
1. Support: development, staging, production
2. Different defaults per environment
3. Validate environment-specific requirements

**Verification:**
```bash
ENV=production go run multi-env.go
# Expected: Loads production config
```

---

## Challenge 3: .env File Parser
**Scenario**: Parse .env file and merge with system env vars.

**Requirements:**
1. Read KEY=VALUE pairs from .env
2. System env vars override .env
3. Handle comments and empty lines

**Verification:**
```bash
go run dotenv.go
# Expected: Loads from .env file
```
