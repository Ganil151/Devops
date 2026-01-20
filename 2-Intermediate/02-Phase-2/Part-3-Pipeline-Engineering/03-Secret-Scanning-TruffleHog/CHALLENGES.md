# 🛠️ Secret Scanning Challenges

## Challenge 1: The "History" Search
**Objective**: Find a secret that was "deleted" but remains in Git history.
1.  Initialize a new git repo.
2.  Commit a file containing a fake API Key (e.g., `AWS_KEY=AKIA1234567890EXAMPLE`).
3.  Delete the file and commit again.
4.  Run `trufflehog git file:///$(pwd)`.
5.  Observe that TruffleHog finds the secret even though it is currently "deleted".

## Challenge 2: GHA Integration
**Objective**: Automate scanning.
1.  Create a `.github/workflows/security.yml` file.
2.  Add a step that uses the `trufflehog` official action.
3.  Ensure the job fails if a secret is found in a Pull Request.

## Challenge 3: Exception Management
**Objective**: Handling False Positives.
1.  Identify a non-sensitive string that TruffleHog flags as a secret.
2.  Research how to use a `.trufflehog-ignore` file to whitelist this string.
3.  Run the scan again and verify the whitelist works.
