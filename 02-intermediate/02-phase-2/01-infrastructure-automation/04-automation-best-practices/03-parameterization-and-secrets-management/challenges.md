# 🛠️ Secrets Challenges

## Challenge 1: The Secure Uploader
**Objective**: Build a script that uploads a file to a dummy API.
1.  Variable: `API_ENDPOINT`.
2.  Variable: `AUTH_TOKEN`.
3.  Load both from environment variables.
4.  Print a usage message if they are missing.
5.  Print the endpoint normally, but mask the token (e.g., `toke***`).

## Challenge 2: .env File Loader
**Objective**: Read config from a local file.
1.  Create a file `.env` with `TIMEOUT=10`.
2.  Write a Python function to parse this file.
3.  Assign the value to a variable.
4.  **Security**: Ensure your script checks if `.env` exists before trying to read it.

## Challenge 3: Pre-flight Permission Check
**Objective**: Ensure the script is running as Root.
1.  In DevOps, we often need root for system changes.
2.  Use `os.getuid()` or `os.geteuid()`.
3.  If uid is not 0 (not root), print "This script must be run as sudo" and exit with code 1.
