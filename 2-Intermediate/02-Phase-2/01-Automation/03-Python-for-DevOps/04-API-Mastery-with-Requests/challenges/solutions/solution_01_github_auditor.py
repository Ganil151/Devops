"""
Solution: GitHub Repo Auditor
"""
import requests

def audit_github_repos(username, token=None):
    base_url = f"https://api.github.com/users/{username}/repos"
    headers = {"Accept": "application/vnd.github.v3+json"}
    if token:
        headers["Authorization"] = f"token {token}"
        
    response = requests.get(base_url, headers=headers)
    response.raise_for_status()
    repos = response.json()
    
    missing_readme = []
    
    for repo in repos:
        repo_name = repo['name']
        # Check for README by attempting to fetch it
        contents_url = f"https://api.github.com/repos/{username}/{repo_name}/contents/README.md"
        res = requests.get(contents_url, headers=headers)
        
        if res.status_code == 404:
            missing_readme.append(repo_name)
            
    return missing_readme

if __name__ == "__main__":
    # Example logic
    pass
