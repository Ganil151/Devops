"""
Challenge: GitHub Repo Auditor
Scenario: You want to ensure all open-source repositories in your 
organization have a README.md file.

TODO: Implement `audit_github_repos(username, token=None)`.
1. Use the GitHub REST API: `https://api.github.com/users/{username}/repos`.
2. Fetch the list of repositories.
3. For each repo, check if `has_pages` or simply fetch the repo's content 
   to see if 'README.md' exists in the root.
4. return a list of repo names that are missing a README.
"""
import requests

def audit_github_repos(username, token=None):
    """
    Identifies repos missing a README.md.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test with a public user (e.g., 'octocat')
    missing = audit_github_repos("octocat")
    print(f"Repos missing README: {missing}")
