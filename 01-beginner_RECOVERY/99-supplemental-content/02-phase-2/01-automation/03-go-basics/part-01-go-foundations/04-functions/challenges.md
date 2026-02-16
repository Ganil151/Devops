# Functions - DevOps Challenges

## Challenge 1: Retry Logic Function
**Scenario**: Implement retry logic for flaky network operations.

**Requirements:**
1. Create function `retryOperation(fn func() error, maxRetries int) error`
2. Retry the function up to maxRetries times
3. Wait 1 second between retries
4. Return error if all retries fail

**Verification:**
```bash
go run retry.go
# Expected: Attempting call... (retries 3 times before failing)
```

---

## Challenge 2: Deployment Pipeline Builder
**Scenario**: Create a pipeline of deployment steps that can be composed.

**Requirements:**
1. Define a type `DeployStep func(context) error`
2. Create a `Pipeline(steps ...DeployStep)` function
3. Execute steps in order, stopping on first error

**Verification:**
```bash
go run pipeline.go
# Expected: Runs build → test → deploy in sequence
```

---

## Challenge 3: Configuration Validator with Variadic Args
**Scenario**: Validate multiple config values in one function call.

**Requirements:**
1. Create `validateConfigs(configs ...string) (bool, []string)`
2. Return list of invalid configs
3. Config is valid if non-empty and alphanumeric

**Verification:**
```bash
go run validator.go "db-host" "" "port" "user@123"
# Expected: Invalid configs: ["", "user@123"]
```
