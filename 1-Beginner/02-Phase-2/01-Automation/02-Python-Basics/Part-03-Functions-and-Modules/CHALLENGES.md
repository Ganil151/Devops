# Functions - DevOps Challenges

## Challenge 1: Connection String Builder
**Scenario**: Create a reusable function to generate database connection URLs.

**Requirements:**
1. Function `build_db_url(user, password, host, port, db_name)`.
2. Use default arguments for port (5432).
3. Return string: `postgresql://user:password@host:port/db_name`.

**Verification:**
```bash
python db_url.py
```

---

## Challenge 2: Service Restarter
**Scenario**: Simulate restarting a service with checks.

**Requirements:**
1. Function `restart_service(service_name, force=False)`.
2. If `force` is True, print "Force killing...".
3. Else, print "Graceful stop...".
4. Finally, print "Starting...".

**Verification:**
```bash
python restarter.py
```

---

## Challenge 3: Env Var Loader (Module)
**Scenario**: Create a separate file `config.py` with a function `load_config()`.

**Requirements:**
1. `config.py`: Returns a dictionary of config values.
2. `main.py`: Imports `config` and prints the values.

**Verification:**
```bash
python main.py
```
