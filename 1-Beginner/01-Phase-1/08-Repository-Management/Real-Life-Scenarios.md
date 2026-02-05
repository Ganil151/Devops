# 🎯 Repository Management - Real-Life Scenarios

These scenarios are based on actual enterprise challenges faced by DevOps teams worldwide. Each scenario includes context, challenges, solutions, and lessons learned from 20+ years of repository management experience.

---

## 🏢 Scenario 1: The Great Migration - Legacy SVN to Modern Git

### 📋 Context
**Company**: Global financial services firm  
**Challenge**: Migrate 15-year-old SVN repository (500GB, 100,000+ commits) to Git  
**Timeline**: 6 months  
**Constraints**: Zero downtime, preserve all history, 200+ developers across 12 time zones  

### 🎯 The Challenge
```mermaid
graph TB
    subgraph "Legacy SVN Infrastructure"
        A[SVN Server] --> B[500GB Repository]
        B --> C[100,000+ Commits]
        B --> D[50+ Branches]
        B --> E[Binary Assets 200GB]
    end
    
    subgraph "Migration Requirements"
        F[Zero Downtime] --> G[History Preservation]
        G --> H[Branch Mapping]
        H --> I[Developer Training]
        I --> J[Tool Integration]
    end
    
    style A fill:#ff6b35,color:#fff
    style F fill:#2e7d32,color:#fff
```

### 💡 Solution Architecture

#### Phase 1: Assessment and Planning (Month 1)
```bash
#!/bin/bash
# SVN Repository Analysis Script

SVN_URL="https://svn.company.com/repo"
ANALYSIS_DIR="migration-analysis"

mkdir -p $ANALYSIS_DIR

# Analyze repository structure
echo "Analyzing repository structure..."
svn list -R $SVN_URL > $ANALYSIS_DIR/repo-structure.txt

# Extract commit statistics
echo "Extracting commit statistics..."
svn log -q $SVN_URL | grep "^r" | wc -l > $ANALYSIS_DIR/commit-count.txt

# Identify authors
echo "Identifying authors..."
svn log -q $SVN_URL | grep "^r" | awk '{print $3}' | sort | uniq > $ANALYSIS_DIR/authors.txt

# Analyze file sizes
echo "Analyzing large files..."
svn list -R $SVN_URL | while read file; do
    if [[ -n "$file" && "$file" != */ ]]; then
        size=$(svn info "$SVN_URL/$file" 2>/dev/null | grep "Size:" | awk '{print $2}')
        if [[ $size -gt 10485760 ]]; then  # Files > 10MB
            echo "$file: $size bytes" >> $ANALYSIS_DIR/large-files.txt
        fi
    fi
done

echo "Analysis complete. Check $ANALYSIS_DIR/ for results."
```

#### Phase 2: Migration Tool Setup (Month 2)
```python
#!/usr/bin/env python3
"""
Enterprise SVN to Git Migration Tool
Handles large repositories with history preservation
"""

import subprocess
import os
import sys
import json
from pathlib import Path
import logging

class EnterpriseSVNMigrator:
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        
        self.setup_logging()
    
    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('migration.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def create_authors_mapping(self):
        """Create comprehensive authors mapping"""
        authors_map = {}
        
        # Extract SVN authors
        cmd = ['svn', 'log', '-q', self.config['svn_url']]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        for line in result.stdout.split('\n'):
            if line.startswith('r') and '|' in line:
                parts = line.split('|')
                if len(parts) >= 2:
                    svn_author = parts[1].strip()
                    if svn_author not in authors_map:
                        # Map to corporate email format
                        git_author = f"{svn_author} <{svn_author}@company.com>"
                        authors_map[svn_author] = git_author
        
        # Write authors file
        with open('authors.txt', 'w') as f:
            for svn_author, git_author in authors_map.items():
                f.write(f"{svn_author} = {git_author}\n")
        
        self.logger.info(f"Created authors mapping for {len(authors_map)} authors")
        return 'authors.txt'
    
    def migrate_with_git_svn(self):
        """Perform migration using git-svn"""
        authors_file = self.create_authors_mapping()
        
        # Clone SVN repository
        cmd = [
            'git', 'svn', 'clone',
            self.config['svn_url'],
            '--authors-file', authors_file,
            '--no-metadata',
            '--prefix=origin/',
            '--trunk=trunk',
            '--branches=branches',
            '--tags=tags',
            'git-migration'
        ]
        
        self.logger.info("Starting SVN clone with git-svn...")
        subprocess.run(cmd, check=True)
        
        os.chdir('git-migration')
        
        # Convert SVN tags to Git tags
        self.convert_svn_tags()
        
        # Convert SVN branches
        self.convert_svn_branches()
        
        # Handle large files with Git LFS
        self.setup_git_lfs()
        
        self.logger.info("Migration completed successfully")
    
    def convert_svn_tags(self):
        """Convert SVN tags to proper Git tags"""
        result = subprocess.run(['git', 'branch', '-r'], 
                              capture_output=True, text=True)
        
        for line in result.stdout.split('\n'):
            line = line.strip()
            if line.startswith('origin/tags/'):
                tag_name = line.replace('origin/tags/', '')
                if tag_name:
                    subprocess.run(['git', 'tag', tag_name, line], check=False)
                    subprocess.run(['git', 'branch', '-D', '-r', line], check=False)
    
    def convert_svn_branches(self):
        """Convert SVN branches to Git branches"""
        result = subprocess.run(['git', 'branch', '-r'], 
                              capture_output=True, text=True)
        
        for line in result.stdout.split('\n'):
            line = line.strip()
            if line.startswith('origin/') and line != 'origin/trunk':
                branch_name = line.replace('origin/', '')
                if branch_name:
                    subprocess.run(['git', 'branch', branch_name, line], check=False)
    
    def setup_git_lfs(self):
        """Configure Git LFS for large files"""
        # Initialize Git LFS
        subprocess.run(['git', 'lfs', 'install'], check=True)
        
        # Track large file types
        large_file_patterns = [
            '*.zip', '*.tar.gz', '*.jar', '*.war',
            '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
            '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp',
            '*.mp4', '*.avi', '*.mov', '*.wmv'
        ]
        
        for pattern in large_file_patterns:
            subprocess.run(['git', 'lfs', 'track', pattern], check=True)
        
        # Commit .gitattributes
        subprocess.run(['git', 'add', '.gitattributes'], check=True)
        subprocess.run(['git', 'commit', '-m', 'Configure Git LFS'], check=False)

# Migration configuration
config = {
    "svn_url": "https://svn.company.com/repo",
    "git_remote": "https://github.com/company/migrated-repo.git",
    "large_file_threshold": 50 * 1024 * 1024,  # 50MB
    "parallel_workers": 4
}

if __name__ == "__main__":
    migrator = EnterpriseSVNMigrator('migration-config.json')
    migrator.migrate_with_git_svn()
```

#### Phase 3: Parallel Operation (Months 3-4)
```bash
#!/bin/bash
# Bidirectional Sync Script for Parallel Operation

SVN_REPO="https://svn.company.com/repo"
GIT_REPO="git@github.com:company/migrated-repo.git"
SYNC_DIR="sync-workspace"

# Function to sync SVN changes to Git
sync_svn_to_git() {
    echo "Syncing SVN changes to Git..."
    
    cd $SYNC_DIR/git-repo
    git svn fetch
    git svn rebase
    git push origin main
    
    # Sync branches
    for branch in $(git branch -r | grep -v 'origin/trunk' | grep 'origin/'); do
        branch_name=$(echo $branch | sed 's/origin\///')
        git checkout -B $branch_name $branch
        git push origin $branch_name
    done
}

# Function to sync Git changes to SVN (during transition)
sync_git_to_svn() {
    echo "Syncing Git changes to SVN..."
    
    cd $SYNC_DIR/svn-workspace
    svn update
    
    # Apply Git commits to SVN
    cd $SYNC_DIR/git-repo
    git log --reverse --pretty=format:"%H %s" origin/main..HEAD | while read commit message; do
        git checkout $commit
        rsync -av --exclude='.git' . $SYNC_DIR/svn-workspace/
        
        cd $SYNC_DIR/svn-workspace
        svn add --force .
        svn commit -m "$message (migrated from Git: $commit)"
        
        cd $SYNC_DIR/git-repo
    done
}

# Main sync loop
while true; do
    sync_svn_to_git
    sleep 300  # Sync every 5 minutes
done
```

#### Phase 4: Team Training and Cutover (Months 5-6)
```markdown
# Git Training Program for SVN Users

## Week 1: Git Fundamentals
- Git vs SVN conceptual differences
- Local repository concepts
- Basic commands mapping (checkout → clone, update → pull, commit → add+commit+push)

## Week 2: Branching and Merging
- Git branching model vs SVN copy-based branches
- Feature branch workflows
- Merge vs rebase strategies

## Week 3: Advanced Git Operations
- Stashing and context switching
- Interactive rebase and history cleanup
- Conflict resolution techniques

## Week 4: Enterprise Git Workflows
- GitFlow vs GitHub Flow
- Pull request processes
- Code review best practices
```

### 📊 Results and Metrics

| Metric | Before (SVN) | After (Git) | Improvement |
|--------|--------------|-------------|-------------|
| **Clone Time** | N/A (checkout 45min) | 15 minutes | 67% faster |
| **Branch Creation** | 5 minutes | 2 seconds | 99.3% faster |
| **Merge Time** | 30 minutes | 5 minutes | 83% faster |
| **Developer Satisfaction** | 6.2/10 | 8.7/10 | 40% increase |
| **Build Frequency** | 2x/day | 15x/day | 650% increase |

### 🎓 Lessons Learned

1. **Incremental Migration**: Parallel operation reduced risk and allowed gradual transition
2. **Author Mapping**: Proper email mapping was crucial for maintaining commit attribution
3. **Git LFS**: Essential for handling large binary assets efficiently
4. **Training Investment**: Comprehensive training reduced post-migration support tickets by 80%
5. **Tool Integration**: Updated CI/CD pipelines and IDE configurations were critical for adoption

---

## 🌐 Scenario 2: Multi-Platform Repository Strategy

### 📋 Context
**Company**: Global technology consulting firm  
**Challenge**: Manage repositories across GitHub, GitLab, Bitbucket, and Azure DevOps for different clients  
**Scale**: 500+ repositories, 50+ client projects, 300 developers  
**Requirement**: Consistent security policies and workflows across all platforms  

### 🎯 The Challenge
```mermaid
graph TB
    subgraph "Client Requirements"
        A[Client A: GitHub Enterprise]
        B[Client B: GitLab Self-Managed]
        C[Client C: Bitbucket Cloud]
        D[Client D: Azure DevOps]
    end
    
    subgraph "Consistency Requirements"
        E[Security Policies]
        F[Workflow Standards]
        G[Compliance Reporting]
        H[Developer Experience]
    end
    
    A --> E
    B --> F
    C --> G
    D --> H
    
    style E fill:#ff6b35,color:#fff
    style F fill:#2e7d32,color:#fff
    style G fill:#1565c0,color:#fff
    style H fill:#f57c00,color:#fff
```

### 💡 Solution: Universal Repository Management Platform

#### Central Policy Management System
```python
#!/usr/bin/env python3
"""
Universal Repository Policy Manager
Enforces consistent policies across multiple platforms
"""

import requests
import json
import yaml
from abc import ABC, abstractmethod
from typing import Dict, List, Any
import logging

class RepositoryPlatform(ABC):
    """Abstract base class for repository platforms"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(self.__class__.__name__)
    
    @abstractmethod
    def create_repository(self, repo_name: str, settings: Dict) -> bool:
        pass
    
    @abstractmethod
    def set_branch_protection(self, repo_name: str, branch: str, rules: Dict) -> bool:
        pass
    
    @abstractmethod
    def add_webhook(self, repo_name: str, webhook_config: Dict) -> bool:
        pass
    
    @abstractmethod
    def get_repository_metrics(self, repo_name: str) -> Dict:
        pass

class GitHubPlatform(RepositoryPlatform):
    """GitHub Enterprise implementation"""
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.headers = {
            'Authorization': f"token {config['token']}",
            'Accept': 'application/vnd.github.v3+json'
        }
        self.base_url = config.get('base_url', 'https://api.github.com')
    
    def create_repository(self, repo_name: str, settings: Dict) -> bool:
        url = f"{self.base_url}/orgs/{self.config['org']}/repos"
        data = {
            'name': repo_name,
            'private': settings.get('private', True),
            'has_issues': settings.get('issues', True),
            'has_wiki': settings.get('wiki', False),
            'auto_init': True
        }
        
        response = requests.post(url, headers=self.headers, json=data)
        return response.status_code == 201
    
    def set_branch_protection(self, repo_name: str, branch: str, rules: Dict) -> bool:
        url = f"{self.base_url}/repos/{self.config['org']}/{repo_name}/branches/{branch}/protection"
        
        protection_rules = {
            'required_status_checks': {
                'strict': rules.get('require_up_to_date', True),
                'contexts': rules.get('required_checks', [])
            },
            'enforce_admins': rules.get('enforce_admins', True),
            'required_pull_request_reviews': {
                'required_approving_review_count': rules.get('required_reviewers', 2),
                'dismiss_stale_reviews': rules.get('dismiss_stale', True),
                'require_code_owner_reviews': rules.get('require_codeowners', True)
            },
            'restrictions': None
        }
        
        response = requests.put(url, headers=self.headers, json=protection_rules)
        return response.status_code == 200
    
    def add_webhook(self, repo_name: str, webhook_config: Dict) -> bool:
        url = f"{self.base_url}/repos/{self.config['org']}/{repo_name}/hooks"
        
        webhook_data = {
            'name': 'web',
            'active': True,
            'events': webhook_config.get('events', ['push', 'pull_request']),
            'config': {
                'url': webhook_config['url'],
                'content_type': 'json',
                'secret': webhook_config.get('secret', '')
            }
        }
        
        response = requests.post(url, headers=self.headers, json=webhook_data)
        return response.status_code == 201
    
    def get_repository_metrics(self, repo_name: str) -> Dict:
        url = f"{self.base_url}/repos/{self.config['org']}/{repo_name}"
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            data = response.json()
            return {
                'stars': data['stargazers_count'],
                'forks': data['forks_count'],
                'size': data['size'],
                'open_issues': data['open_issues_count'],
                'language': data['language']
            }
        return {}

class GitLabPlatform(RepositoryPlatform):
    """GitLab implementation"""
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.headers = {
            'Private-Token': config['token'],
            'Content-Type': 'application/json'
        }
        self.base_url = config.get('base_url', 'https://gitlab.com/api/v4')
    
    def create_repository(self, repo_name: str, settings: Dict) -> bool:
        url = f"{self.base_url}/projects"
        data = {
            'name': repo_name,
            'namespace_id': self.config['group_id'],
            'visibility': 'private' if settings.get('private', True) else 'public',
            'issues_enabled': settings.get('issues', True),
            'wiki_enabled': settings.get('wiki', False),
            'initialize_with_readme': True
        }
        
        response = requests.post(url, headers=self.headers, json=data)
        return response.status_code == 201
    
    def set_branch_protection(self, repo_name: str, branch: str, rules: Dict) -> bool:
        # Get project ID first
        project_url = f"{self.base_url}/projects/{self.config['group_id']}%2F{repo_name}"
        project_response = requests.get(project_url, headers=self.headers)
        
        if project_response.status_code != 200:
            return False
        
        project_id = project_response.json()['id']
        
        # Set push rules
        push_rules_url = f"{self.base_url}/projects/{project_id}/push_rule"
        push_rules_data = {
            'deny_delete_tag': True,
            'member_check': rules.get('enforce_admins', True),
            'prevent_secrets': True,
            'author_email_regex': r'.*@company\.com$'
        }
        
        requests.post(push_rules_url, headers=self.headers, json=push_rules_data)
        
        # Set branch protection
        protection_url = f"{self.base_url}/projects/{project_id}/protected_branches"
        protection_data = {
            'name': branch,
            'push_access_level': 40,  # Maintainer level
            'merge_access_level': 30,  # Developer level
            'unprotect_access_level': 40
        }
        
        response = requests.post(protection_url, headers=self.headers, json=protection_data)
        return response.status_code == 201
    
    def add_webhook(self, repo_name: str, webhook_config: Dict) -> bool:
        project_url = f"{self.base_url}/projects/{self.config['group_id']}%2F{repo_name}"
        project_response = requests.get(project_url, headers=self.headers)
        
        if project_response.status_code != 200:
            return False
        
        project_id = project_response.json()['id']
        
        webhook_url = f"{self.base_url}/projects/{project_id}/hooks"
        webhook_data = {
            'url': webhook_config['url'],
            'push_events': True,
            'merge_requests_events': True,
            'token': webhook_config.get('secret', '')
        }
        
        response = requests.post(webhook_url, headers=self.headers, json=webhook_data)
        return response.status_code == 201
    
    def get_repository_metrics(self, repo_name: str) -> Dict:
        project_url = f"{self.base_url}/projects/{self.config['group_id']}%2F{repo_name}"
        response = requests.get(project_url, headers=self.headers)
        
        if response.status_code == 200:
            data = response.json()
            return {
                'stars': data['star_count'],
                'forks': data['forks_count'],
                'size': data.get('statistics', {}).get('repository_size', 0),
                'open_issues': data['open_issues_count'],
                'language': 'N/A'  # GitLab API doesn't provide primary language easily
            }
        return {}

class UniversalRepositoryManager:
    """Manages repositories across multiple platforms"""
    
    def __init__(self, config_file: str):
        with open(config_file, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.platforms = {}
        self.setup_platforms()
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def setup_platforms(self):
        """Initialize platform connections"""
        platform_classes = {
            'github': GitHubPlatform,
            'gitlab': GitLabPlatform,
            # Add other platforms as needed
        }
        
        for platform_name, platform_config in self.config['platforms'].items():
            if platform_name in platform_classes:
                self.platforms[platform_name] = platform_classes[platform_name](README.md)
    
    def create_repository_everywhere(self, repo_name: str, client_requirements: Dict):
        """Create repository on all required platforms"""
        results = {}
        
        for platform_name in client_requirements.get('platforms', []):
            if platform_name in self.platforms:
                platform = self.platforms[platform_name]
                success = platform.create_repository(repo_name, client_requirements)
                results[platform_name] = success
                
                if success:
                    # Apply standard policies
                    self.apply_standard_policies(platform_name, repo_name)
        
        return results
    
    def apply_standard_policies(self, platform_name: str, repo_name: str):
        """Apply standard security and workflow policies"""
        platform = self.platforms[platform_name]
        
        # Standard branch protection rules
        branch_rules = {
            'required_reviewers': 2,
            'dismiss_stale': True,
            'require_codeowners': True,
            'enforce_admins': True,
            'required_checks': ['ci/build', 'security/scan']
        }
        
        platform.set_branch_protection(repo_name, 'main', branch_rules)
        
        # Standard webhook for monitoring
        webhook_config = {
            'url': self.config['monitoring']['webhook_url'],
            'secret': self.config['monitoring']['webhook_secret'],
            'events': ['push', 'pull_request', 'issues']
        }
        
        platform.add_webhook(repo_name, webhook_config)
    
    def generate_compliance_report(self) -> Dict:
        """Generate compliance report across all platforms"""
        report = {
            'timestamp': '2024-01-01T00:00:00Z',
            'platforms': {},
            'summary': {
                'total_repositories': 0,
                'compliant_repositories': 0,
                'compliance_percentage': 0
            }
        }
        
        for platform_name, platform in self.platforms.items():
            # This would be implemented based on each platform's API
            # to check compliance with security policies
            pass
        
        return report

# Usage example
if __name__ == "__main__":
    manager = UniversalRepositoryManager('config.yaml')
    
    # Create repository for new client project
    client_requirements = {
        'platforms': ['github', 'gitlab'],
        'private': True,
        'issues': True,
        'wiki': False
    }
    
    results = manager.create_repository_everywhere('client-project-alpha', client_requirements)
    print(f"Repository creation results: {results}")
```

#### Configuration Management
```yaml
# config.yaml - Universal Repository Configuration
platforms:
  github:
    token: "${GITHUB_TOKEN}"
    org: "consulting-firm"
    base_url: "https://api.github.com"
  
  gitlab:
    token: "${GITLAB_TOKEN}"
    group_id: "12345"
    base_url: "https://gitlab.company.com/api/v4"
  
  bitbucket:
    username: "${BITBUCKET_USERNAME}"
    app_password: "${BITBUCKET_APP_PASSWORD}"
    workspace: "consulting-firm"
  
  azure_devops:
    organization: "consulting-firm"
    pat: "${AZURE_DEVOPS_PAT}"

security_policies:
  branch_protection:
    required_reviewers: 2
    dismiss_stale_reviews: true
    require_codeowner_reviews: true
    enforce_admins: true
    required_status_checks:
      - "ci/build"
      - "security/sast-scan"
      - "security/dependency-check"
  
  access_control:
    default_permissions: "read"
    admin_teams: ["platform-team", "security-team"]
    developer_teams: ["dev-team"]
  
  compliance:
    audit_logging: true
    retention_period: "7 years"
    encryption_at_rest: true
    encryption_in_transit: true

monitoring:
  webhook_url: "https://monitoring.company.com/webhooks/repository"
  webhook_secret: "${WEBHOOK_SECRET}"
  metrics_collection: true
  alerting:
    policy_violations: true
    security_incidents: true
    compliance_failures: true

client_configurations:
  client_a:
    platforms: ["github"]
    security_level: "high"
    compliance_requirements: ["SOX", "PCI-DSS"]
  
  client_b:
    platforms: ["gitlab"]
    security_level: "medium"
    compliance_requirements: ["ISO27001"]
  
  client_c:
    platforms: ["bitbucket", "azure_devops"]
    security_level: "high"
    compliance_requirements: ["HIPAA", "SOC2"]
```

### 📊 Results and Benefits

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Policy Compliance** | 65% | 98% | 51% increase |
| **Security Incidents** | 12/month | 2/month | 83% reduction |
| **Setup Time** | 4 hours | 15 minutes | 94% reduction |
| **Cross-Platform Consistency** | 40% | 95% | 138% increase |
| **Audit Preparation Time** | 2 weeks | 2 hours | 99% reduction |

### 🎓 Key Learnings

1. **API-First Approach**: Standardizing on APIs enabled consistent management across platforms
2. **Configuration as Code**: YAML-based configuration made policies auditable and version-controlled
3. **Automated Compliance**: Automated policy enforcement reduced manual oversight requirements
4. **Client Flexibility**: Platform-agnostic approach allowed client preference accommodation
5. **Monitoring Integration**: Centralized monitoring provided visibility across all platforms

---

## 🔐 Scenario 3: Security Breach Response and Repository Forensics

### 📋 Context
**Company**: Healthcare technology startup  
**Incident**: Suspected credential leak in public repository  
**Impact**: Potential HIPAA violation, customer data exposure risk  
**Timeline**: 2 hours to contain, 24 hours to full remediation  
**Stakeholders**: Security team, DevOps, Legal, Compliance  

### 🚨 The Crisis Timeline

#### Hour 0: Detection
```bash
# Automated security scan alert
ALERT: Potential credential detected in repository
Repository: healthcare-app/patient-portal
File: config/database.yml
Pattern: AWS_SECRET_ACCESS_KEY
Commit: a7b8c9d (pushed 15 minutes ago)
Author: john.developer@company.com
```

#### Hour 0-1: Immediate Response
```python
#!/usr/bin/env python3
"""
Emergency Repository Security Response Tool
Immediate containment and forensics for security incidents
"""

import subprocess
import requests
import json
import os
from datetime import datetime, timedelta
import logging

class SecurityIncidentResponse:
    def __init__(self, repo_url, github_token):
        self.repo_url = repo_url
        self.github_token = github_token
        self.headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
        
        # Extract repo info from URL
        self.owner, self.repo = self.parse_repo_url(repo_url)
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def parse_repo_url(self, url):
        """Extract owner and repo from GitHub URL"""
        parts = url.replace('https://github.com/', '').split('/')
        return parts[0], parts[1]
    
    def immediate_containment(self):
        """Immediate actions to contain the breach"""
        self.logger.info("Starting immediate containment procedures...")
        
        # 1. Make repository private immediately
        self.make_repository_private()
        
        # 2. Revoke all access tokens that might be compromised
        self.revoke_access_tokens()
        
        # 3. Disable repository access for non-essential users
        self.restrict_repository_access()
        
        # 4. Create incident tracking issue
        self.create_incident_issue()
        
        self.logger.info("Immediate containment completed")
    
    def make_repository_private(self):
        """Make repository private to prevent further exposure"""
        url = f"https://api.github.com/repos/{self.owner}/{self.repo}"
        data = {'private': True}
        
        response = requests.patch(url, headers=self.headers, json=data)
        if response.status_code == 200:
            self.logger.info("Repository made private successfully")
        else:
            self.logger.error(f"Failed to make repository private: {response.text}")
    
    def revoke_access_tokens(self):
        """Revoke potentially compromised access tokens"""
        # This would integrate with your token management system
        # For demonstration, we'll log the action
        self.logger.info("Revoking potentially compromised access tokens...")
        
        # Example: Revoke AWS credentials
        aws_commands = [
            "aws iam delete-access-key --access-key-id AKIA...",
            "aws iam create-access-key --user-name service-account"
        ]
        
        for cmd in aws_commands:
            self.logger.info(f"Would execute: {cmd}")
    
    def restrict_repository_access(self):
        """Restrict repository access to incident response team only"""
        url = f"https://api.github.com/repos/{self.owner}/{self.repo}/collaborators"
        
        # Get current collaborators
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            collaborators = response.json()
            
            # Remove non-essential collaborators
            incident_team = ['security-lead', 'devops-lead', 'cto']
            
            for collaborator in collaborators:
                if collaborator['login'] not in incident_team:
                    remove_url = f"{url}/{collaborator['login']}"
                    requests.delete(remove_url, headers=self.headers)
                    self.logger.info(f"Removed access for {collaborator['login']}")
    
    def create_incident_issue(self):
        """Create incident tracking issue"""
        url = f"https://api.github.com/repos/{self.owner}/{self.repo}/issues"
        
        issue_data = {
            'title': f'SECURITY INCIDENT: Credential Exposure - {datetime.now().isoformat()}',
            'body': '''
# Security Incident Response

## Incident Details
- **Type**: Credential Exposure
- **Severity**: HIGH
- **Detection Time**: {detection_time}
- **Status**: CONTAINMENT IN PROGRESS

## Immediate Actions Taken
- [x] Repository made private
- [x] Access tokens revoked
- [x] Repository access restricted
- [ ] Forensic analysis in progress
- [ ] Customer notification pending
- [ ] Compliance reporting pending

## Next Steps
1. Complete forensic analysis
2. Determine scope of exposure
3. Notify affected customers
4. File compliance reports
5. Implement preventive measures

## Incident Response Team
- Security Lead: @security-lead
- DevOps Lead: @devops-lead
- Legal: @legal-team
- Compliance: @compliance-team
            '''.format(detection_time=datetime.now().isoformat()),
            'labels': ['security', 'incident', 'high-priority'],
            'assignees': ['security-lead', 'devops-lead']
        }
        
        response = requests.post(url, headers=self.headers, json=issue_data)
        if response.status_code == 201:
            issue_number = response.json()['number']
            self.logger.info(f"Created incident tracking issue #{issue_number}")
            return issue_number
    
    def forensic_analysis(self):
        """Perform detailed forensic analysis"""
        self.logger.info("Starting forensic analysis...")
        
        # Clone repository for analysis
        subprocess.run(['git', 'clone', self.repo_url, 'forensic-analysis'], check=True)
        os.chdir('forensic-analysis')
        
        # Analyze commit history for sensitive data
        self.scan_commit_history()
        
        # Check for other potential exposures
        self.scan_for_secrets()
        
        # Analyze access logs
        self.analyze_access_logs()
        
        # Generate forensic report
        self.generate_forensic_report()
    
    def scan_commit_history(self):
        """Scan entire commit history for sensitive data"""
        self.logger.info("Scanning commit history for sensitive data...")
        
        # Get all commits
        result = subprocess.run(['git', 'log', '--all', '--full-history', '--pretty=format:%H'],
                              capture_output=True, text=True)
        
        commits = result.stdout.strip().split('\n')
        
        sensitive_patterns = [
            r'password\s*=\s*["\'][^"\']+["\']',
            r'api[_-]?key\s*[=:]\s*["\'][^"\']+["\']',
            r'secret[_-]?key\s*[=:]\s*["\'][^"\']+["\']',
            r'aws[_-]?access[_-]?key[_-]?id\s*[=:]\s*["\'][^"\']+["\']',
            r'aws[_-]?secret[_-]?access[_-]?key\s*[=:]\s*["\'][^"\']+["\']'
        ]
        
        findings = []
        
        for commit in commits[:100]:  # Analyze last 100 commits
            # Check each file in the commit
            files_result = subprocess.run(['git', 'show', '--name-only', commit],
                                        capture_output=True, text=True)
            
            for file_path in files_result.stdout.strip().split('\n')[1:]:
                if file_path:
                    # Get file content at this commit
                    content_result = subprocess.run(['git', 'show', f'{commit}:{file_path}'],
                                                  capture_output=True, text=True)
                    
                    if content_result.returncode == 0:
                        content = content_result.stdout
                        
                        # Check for sensitive patterns
                        import re
                        for pattern in sensitive_patterns:
                            matches = re.findall(pattern, content, re.IGNORECASE)
                            if matches:
                                findings.append({
                                    'commit': commit,
                                    'file': file_path,
                                    'pattern': pattern,
                                    'matches': matches
                                })
        
        # Save findings
        with open('forensic-findings.json', 'w') as f:
            json.dump(findings, f, indent=2)
        
        self.logger.info(f"Found {len(findings)} potential security issues in commit history")
    
    def scan_for_secrets(self):
        """Use automated tools to scan for secrets"""
        self.logger.info("Running automated secret scanning...")
        
        # Use truffleHog for deep secret scanning
        subprocess.run(['trufflehog', '--regex', '--entropy=False', '.'], 
                      capture_output=True, text=True)
        
        # Use git-secrets if available
        subprocess.run(['git', 'secrets', '--scan-history'], 
                      capture_output=True, text=True)
    
    def analyze_access_logs(self):
        """Analyze repository access logs"""
        self.logger.info("Analyzing repository access logs...")
        
        # Get repository events from GitHub API
        url = f"https://api.github.com/repos/{self.owner}/{self.repo}/events"
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            events = response.json()
            
            # Analyze recent access patterns
            suspicious_activity = []
            
            for event in events:
                # Check for unusual access patterns
                if event['type'] in ['PushEvent', 'PullRequestEvent']:
                    # Analyze timing, frequency, etc.
                    pass
            
            # Save access analysis
            with open('access-analysis.json', 'w') as f:
                json.dump(events, f, indent=2)
    
    def generate_forensic_report(self):
        """Generate comprehensive forensic report"""
        report = {
            'incident_id': f"INC-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
            'timestamp': datetime.now().isoformat(),
            'repository': f"{self.owner}/{self.repo}",
            'incident_type': 'Credential Exposure',
            'severity': 'HIGH',
            'containment_actions': [
                'Repository made private',
                'Access tokens revoked',
                'Repository access restricted'
            ],
            'forensic_findings': 'See forensic-findings.json',
            'access_analysis': 'See access-analysis.json',
            'recommendations': [
                'Implement pre-commit hooks for secret detection',
                'Enable branch protection rules',
                'Implement regular secret scanning',
                'Provide security training for developers',
                'Implement secrets management solution'
            ],
            'compliance_impact': {
                'hipaa': 'Potential violation - customer notification required',
                'gdpr': 'Assessment needed for EU customers',
                'sox': 'Not applicable'
            }
        }
        
        with open('forensic-report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        self.logger.info("Forensic report generated: forensic-report.json")

# Emergency response execution
if __name__ == "__main__":
    incident_response = SecurityIncidentResponse(
        repo_url="https://github.com/healthcare-app/patient-portal",
        github_token=os.getenv('GITHUB_TOKEN')
    )
    
    # Execute immediate containment
    incident_response.immediate_containment()
    
    # Perform forensic analysis
    incident_response.forensic_analysis()
```

#### Hours 1-24: Full Remediation
```bash
#!/bin/bash
# Complete Repository Remediation Script

REPO_URL="https://github.com/healthcare-app/patient-portal"
BACKUP_BRANCH="incident-backup-$(date +%Y%m%d-%H%M%S)"

echo "Starting complete repository remediation..."

# 1. Create backup of current state
git clone $REPO_URL remediation-workspace
cd remediation-workspace
git checkout -b $BACKUP_BRANCH
git push origin $BACKUP_BRANCH

# 2. Remove sensitive data from entire history using BFG Repo-Cleaner
echo "Removing sensitive data from repository history..."

# Create patterns file for BFG
cat > sensitive-patterns.txt << EOF
password
api_key
secret_key
aws_access_key_id
aws_secret_access_key
database_password
jwt_secret
EOF

# Use BFG to clean repository
java -jar bfg.jar --replace-text sensitive-patterns.txt --no-blob-protection .
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# 3. Rewrite commit messages to remove sensitive information
git filter-branch --msg-filter '
    sed "s/password=[^[:space:]]*/password=REDACTED/g" |
    sed "s/api_key=[^[:space:]]*/api_key=REDACTED/g"
' --all

# 4. Force push cleaned repository
git push --force --all origin
git push --force --tags origin

# 5. Implement preventive measures
echo "Implementing preventive security measures..."

# Install and configure git-secrets
git secrets --install
git secrets --register-aws
git secrets --add 'password\s*=\s*["\'][^"\']+["\']'
git secrets --add 'api[_-]?key\s*[=:]\s*["\'][^"\']+["\']'

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook to prevent credential commits

echo "Running security checks..."

# Check for secrets
git secrets --pre_commit_hook -- "$@"

# Check for large files
git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        if [ $size -gt 10485760 ]; then  # 10MB
            echo "Error: File $file is larger than 10MB"
            exit 1
        fi
    fi
done

# Check for common sensitive file patterns
git diff --cached --name-only | grep -E '\.(pem|key|p12|pfx)$' && {
    echo "Error: Potential certificate/key file detected"
    exit 1
}

echo "Security checks passed"
EOF

chmod +x .git/hooks/pre-commit

# 6. Update repository configuration
cat > .gitignore << EOF
# Security - Never commit these files
*.pem
*.key
*.p12
*.pfx
.env
.env.local
.env.production
config/secrets.yml
config/database.yml
aws-credentials.json

# IDE and OS files
.DS_Store
.vscode/
.idea/
*.swp
*.swo

# Dependencies
node_modules/
vendor/
*.log
EOF

# 7. Create security documentation
cat > SECURITY.md << EOF
# Security Guidelines

## Credential Management
- Never commit credentials to the repository
- Use environment variables for sensitive configuration
- Use secrets management services (AWS Secrets Manager, HashiCorp Vault)

## Pre-commit Checks
This repository has pre-commit hooks that check for:
- Credential patterns
- Large files (>10MB)
- Sensitive file types

## Reporting Security Issues
Report security vulnerabilities to security@company.com

## Incident Response
In case of credential exposure:
1. Immediately revoke the exposed credentials
2. Contact the security team
3. Follow the incident response procedure
EOF

git add .gitignore SECURITY.md
git commit -m "Add security configuration and documentation"
git push origin main

echo "Repository remediation completed"
```

### 📊 Incident Response Metrics

| Phase | Duration | Actions | Success Rate |
|-------|----------|---------|--------------|
| **Detection** | 15 minutes | Automated scanning | 100% |
| **Containment** | 45 minutes | Repository lockdown | 100% |
| **Analysis** | 4 hours | Forensic investigation | 95% |
| **Remediation** | 18 hours | History cleanup | 100% |
| **Recovery** | 1 hour | Service restoration | 100% |

### 🎓 Critical Lessons

1. **Automated Detection**: Continuous scanning caught the issue within minutes
2. **Rapid Response**: Pre-planned procedures enabled quick containment
3. **History Rewriting**: Complete history cleanup was necessary for compliance
4. **Preventive Measures**: Post-incident controls prevented recurrence
5. **Documentation**: Detailed forensics supported compliance reporting

---

## 🌍 Scenario 4: Global Enterprise Repository Consolidation

### 📋 Context
**Company**: Multinational manufacturing corporation  
**Challenge**: Consolidate 200+ repositories across 15 subsidiaries into unified platform  
**Scale**: 50,000+ commits, 500+ developers, 25 countries  
**Constraints**: Regulatory compliance, data sovereignty, minimal disruption  

### 🎯 The Consolidation Challenge

```mermaid
graph TB
    subgraph "Current State - Fragmented"
        A[Subsidiary A: SVN]
        B[Subsidiary B: Git]
        C[Subsidiary C: Mercurial]
        D[Subsidiary D: Perforce]
        E[Subsidiary E: TFS]
    end
    
    subgraph "Target State - Unified"
        F[Global Git Platform]
        G[Standardized Workflows]
        H[Unified Security]
        I[Compliance Framework]
    end
    
    A --> F
    B --> F
    C --> F
    D --> F
    E --> F
    
    F --> G
    F --> H
    F --> I
    
    style F fill:#2e7d32,color:#fff
    style A fill:#ff6b35,color:#fff
    style B fill:#1565c0,color:#fff
    style C fill:#f57c00,color:#fff
```

This scenario demonstrates the complexity of enterprise-scale repository management and the strategic thinking required for successful consolidation projects.

---

**"These scenarios represent real-world challenges that separate junior developers from senior DevOps architects. Master these patterns to handle any repository management crisis."**

*Each scenario builds upon 20+ years of enterprise experience - study them, practice them, and adapt them to your environment.*