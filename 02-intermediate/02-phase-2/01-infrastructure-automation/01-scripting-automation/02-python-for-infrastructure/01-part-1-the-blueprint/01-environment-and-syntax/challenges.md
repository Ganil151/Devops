# 🛠️ Python Basics Challenges

## Challenge 1: Multi-Env Config
**Objective**: Build a script that merges a base configuration with environment-specific overrides.
1.  Define a dictionary `base_config` with keys: `app_name`, `version`, `debug` (False).
2.  Define `prod_config` with overrides: `debug` (False), `replicas` (3).
3.  Define `dev_config` with overrides: `debug` (True).
4.  Write a function `merge_config(base, override)` that returns a new dictionary.
5.  Print the final config for both environments.

## Challenge 2: Graceful Shutdown
**Objective**: Implement signal handlers to clean up resources when a script is stopped (Ctrl+C).
1.  Import `signal` and `time`.
2.  Create a `run_forever()` loop that prints "Working..." every second.
3.  Define a `handler(signum, frame)` function that prints "Stopping safely..." and uses `sys.exit(0)`.
4.  Register the handler for `signal.SIGINT`.

## Challenge 3: Conflict Resolver
**Objective**: Audit two lists of dependencies (strings) to find version conflicts.
1.  List A: `["requests==2.0", "numpy==1.0", "pandas==1.0"]`
2.  List B: `["requests==3.0", "numpy==1.0", "scipy==1.0"]`
3.  Parse package names and versions.
4.  Detect that `requests` has different versions defined.
5.  Print the conflicting packages.

## Challenge 4: Secure Secret Loader
**Objective**: Secure your automation by validating file permissions before reading.
1.  Create a dummy secret file `secret.txt`.
2.  Write a script that uses `os.stat` or `pathlib.Path.stat`.
3.  Check the file mode/permissions.
4.  If the file is world-readable (e.g., `777`), print "UNSAFE: File is too open" and exit.
5.  If it is safe (`600`), read and print "Secret loaded".
