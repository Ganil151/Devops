# Git Fundamentals for DevOps Engineers

## What is Git?
Git is a distributed version control system designed to handle everything from small to very large projects with speed and efficiency. Created by Linus Torvalds in 2005, Git has become the de facto standard for version control in software development and DevOps practices.

## Core Concept: The Philosophy of Git
**[REFERENCE: Git Internal Architecture](../../../reference/git-internal-architecture-ref.md)**

Beyond the commands, Git is a **Content-Addressable Filesystem**. 
- **Immutable History**: Every commit is a snapshot, not a delta. SHA-1 hashes ensure that if a single bit changes in history, the commit ID changes.
- **Single Source of Truth**: For IaC (Infrastructure as Code), the repo *is* the infrastructure.


> **⚠️ Missing Image**: *colabo* ('../../../../../../08-Resources/03-Images-Diagrams/git&githubTalk.png')

## Why Git is Critical for DevOps

### 1. Version Control and Change Management

- **Code History**: Complete history of all changes with detailed commit messages
- **Rollback Capability**: Easy rollback to previous versions when issues arise
- **Change Tracking**: Track who made what changes and when
- **Branching Strategy**: Support for complex branching workflows

### 2. Collaboration and Team Coordination

- **Distributed Development**: Multiple developers working on the same code-base
- **Merge Conflict Resolution**: Tools to resolve conflicting changes
- **Code Reviews**: Integration with pull/merge request workflows
- **Team Synchronization**: Keep team members in sync with latest changes

### 3. CI/CD Pipeline Integration
- **Automated Triggers**: Git hooks trigger CI/CD pipelines
- **Branch-based Deployments**: Different branches for different environments
- **Release Management**: Tag-based releases and semantic versioning
- **Infrastructure as Code**: Version control for infrastructure configurations

### 4. DevOps Workflow Enablement
- **GitOps**: Git as single source of truth for infrastructure and applications
- **Configuration Management**: Version control for configuration files
- **Documentation**: Keep documentation in sync with code changes
- **Audit Trail**: Complete audit trail for compliance and security

## Git Architecture and Concepts

### Git Repository Structure

> **⚠️ Missing Image**: *gitRepoStructure* ('../../../../../../08-Resources/03-Images-Diagrams/gitStructure.png')

```bash
.git/
├── HEAD                    # Points to current branch
├── config                  # Repository configuration
├── description            # Repository description
├── hooks/                 # Git hooks (pre-commit, post-receive, etc.)
├── info/                  # Additional repository information
├── objects/               # Git objects (commits, trees, blobs)
│   ├── info/
│   └── pack/
├── refs/                  # References (branches, tags)
│   ├── heads/             # Local branches
│   ├── remotes/           # Remote branches
│   └── tags/              # Tags
├── logs/                  # Reference logs
└── index                  # Staging area (index file)
```
### Git Object Model
```bash
# Git objects hierarchy
Repository
├── Commit Objects         # Snapshots of the repository at specific points
│   ├── Tree Objects      # Directory structures
│   │   └── Blob Objects  # File contents
│   └── Parent Commits    # Previous commits (for history)
├── Branches              # Movable pointers to commits
├── Tags                  # Fixed pointers to specific commits
└── HEAD                  # Pointer to current branch/commit
```
### Git Workflow Areas
```bash
# Three main areas in Git workflow
Working Directory  →  Staging Area (Index)  →  Repository (.git)
     ↓                      ↓                      ↓
  Modified files      Files ready to commit    Committed files
     ↓                      ↓                      ↓
  git add            git commit              git push (to remote)
```
## Essential Git Commands

### Repository Initialization and Cloning
```bash
# Initialize new repository
git init                           # Initialize empty repository
git init --bare                    # Initialize bare repository (for servers)

# Clone existing repository
git clone <repository-url>         # Clone repository
git clone <url> <directory>        # Clone to specific directory
git clone --depth 1 <url>         # Shallow clone (latest commit only)
git clone --branch <branch> <url>  # Clone specific branch

# Remote repository management
git remote -v                      # List remote repositories
git remote add origin <url>        # Add remote repository
git remote set-url origin <new-url> # Change remote URL
git remote remove origin           # Remove remote repository
```
### Basic File Operations
```bash
# Check repository status
git status                         # Show working directory status
git status -s                      # Short status format
git status --porcelain            # Machine-readable status

# Add files to staging area
git add <file>                     # Add specific file
git add .                          # Add all files in current directory
git add -A                         # Add all files in repository
git add -u                         # Add only modified/deleted files
git add -p                         # Interactive staging (patch mode)

# Commit changes
git commit -m "commit message"     # Commit with message
git commit -am "message"           # Add and commit modified files
git commit --amend                 # Amend last commit
git commit --amend -m "new message" # Amend with new message

# Remove and move files
git rm <file>                      # Remove file from repository
git rm --cached <file>             # Remove from repository, keep in working directory
git mv <old-name> <new-name>       # Rename/move file
```
### Viewing History and Changes
```bash
# View commit history
git log                            # Show commit history
git log --oneline                  # Compact one-line format
git log --graph                    # Show branch graph
git log --stat                     # Show file statistics
git log -p                         # Show patch (diff) for each commit
git log --since="2 weeks ago"      # Show commits since specific time
git log --author="John Doe"        # Show commits by specific author
git log --grep="bug fix"           # Search commit messages

# View changes
git diff                           # Show unstaged changes
git diff --staged                  # Show staged changes
git diff HEAD~1                    # Compare with previous commit
git diff <branch1> <branch2>       # Compare branches
git diff <commit1> <commit2>       # Compare commits

# Show specific commit
git show <commit-hash>             # Show specific commit details
git show HEAD                      # Show latest commit
git show HEAD~2                    # Show commit 2 steps back
```
## Branching and Merging

### Branch Management
```bash
# List branches
git branch                         # List local branches
git branch -r                      # List remote branches
git branch -a                      # List all branches (local and remote)
git branch -v                      # List branches with last commit

# Create and switch branches
git branch <branch-name>           # Create new branch
git checkout <branch-name>         # Switch to branch
git checkout -b <branch-name>      # Create and switch to new branch
git switch <branch-name>           # Switch to branch (Git 2.23+)
git switch -c <branch-name>        # Create and switch to new branch (Git 2.23+)

# Delete branches
git branch -d <branch-name>        # Delete merged branch
git branch -D <branch-name>        # Force delete branch
git push origin --delete <branch>  # Delete remote branch

# Rename branches
git branch -m <old-name> <new-name> # Rename branch
git branch -m <new-name>           # Rename current branch
```
### Merging Strategies
```bash
# Merge branches
git merge <branch-name>            # Merge branch into current branch
git merge --no-ff <branch-name>    # Force merge commit (no fast-forward)
git merge --squash <branch-name>   # Squash merge (combine commits)

# Rebase (alternative to merge)
git rebase <branch-name>           # Rebase current branch onto another
git rebase -i HEAD~3               # Interactive rebase (last 3 commits)
git rebase --continue              # Continue rebase after resolving conflicts
git rebase --abort                 # Abort rebase operation

# Cherry-pick specific commits
git cherry-pick <commit-hash>      # Apply specific commit to current branch
git cherry-pick <commit1>..<commit2> # Cherry-pick range of commits
```
### Merge Conflict Resolution
```bash
# When merge conflicts occur
git status                         # Check conflicted files
git diff                           # View conflict details

# Resolve conflicts manually, then:
git add <resolved-file>            # Mark conflict as resolved
git commit                         # Complete the merge

# Merge tools
git mergetool                      # Launch merge tool
git config --global merge.tool vimdiff # Set default merge tool

# Abort merge if needed
git merge --abort                  # Abort current merge
```
## Remote Repository Operations

### Working with Remotes
```bash
# Fetch and pull changes
git fetch                          # Download changes without merging
git fetch origin                   # Fetch from specific remote
git pull                           # Fetch and merge changes
git pull origin main               # Pull from specific remote and branch
git pull --rebase                  # Pull with rebase instead of merge

# Push changes
git push                           # Push to default remote and branch
git push origin main               # Push to specific remote and branch
git push -u origin main            # Push and set upstream branch
git push --force                   # Force push (dangerous!)
git push --force-with-lease        # Safer force push

# Track remote branches
git branch -u origin/main          # Set upstream for current branch
git checkout -b local-branch origin/remote-branch # Track remote branch
```
### Synchronization Strategies
```bash
# Keep fork synchronized (common in open source)
git remote add upstream <original-repo-url>
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Sync all branches
git fetch --all                    # Fetch all remotes
git remote prune origin            # Remove stale remote branches
```
## Advanced Git Operations

### Stashing Changes
```bash
# Stash operations
git stash                          # Stash current changes
git stash save "work in progress"  # Stash with message
git stash list                     # List all stashes
git stash show                     # Show stash contents
git stash apply                    # Apply latest stash
git stash apply stash@{2}          # Apply specific stash
git stash pop                      # Apply and remove latest stash
git stash drop                     # Delete latest stash
git stash clear                    # Delete all stashes
```
### Reset and Revert Operations
```bash
# Reset operations (changes history)
git reset --soft HEAD~1            # Undo last commit, keep changes staged
git reset --mixed HEAD~1           # Undo last commit, unstage changes
git reset --hard HEAD~1            # Undo last commit, discard changes
git reset <file>                   # Unstage file

# Revert operations (creates new commit)
git revert <commit-hash>           # Revert specific commit
git revert HEAD                    # Revert last commit
git revert --no-commit <commit>    # Revert without auto-commit
```
### Tagging and Releases
```bash
# Create tags
git tag                            # List all tags
git tag v1.0.0                     # Create lightweight tag
git tag -a v1.0.0 -m "Release version 1.0.0" # Create annotated tag
git tag -a v1.0.0 <commit-hash>    # Tag specific commit

# Push tags
git push origin v1.0.0             # Push specific tag
git push origin --tags             # Push all tags
git push --follow-tags             # Push commits and associated tags

# Delete tags
git tag -d v1.0.0                  # Delete local tag
git push origin --delete v1.0.0    # Delete remote tag
```
## Git Configuration and Customization

### Global Configuration
```bash
# User configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Editor and diff tool
git config --global core.editor "vim"
git config --global merge.tool "vimdiff"

# Aliases for common commands
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Line ending configuration
git config --global core.autocrlf input    # Linux/Mac
git config --global core.autocrlf true     # Windows

# View configuration
git config --list                  # Show all configuration
git config --global --list         # Show global configuration
git config user.name               # Show specific setting
```

### Repository-specific Configuration

```bash
# Local repository configuration
git config user.email "work.email@company.com" # Override global email
git config core.filemode false     # Ignore file permission changes

# .gitconfig file location
~/.gitconfig                       # Global configuration file
.git/config                        # Repository-specific configuration
```
## Git Hooks for DevOps Automation

### Client-side Hooks
```bash
# Pre-commit hook example
#!/bin/bash
# .git/hooks/pre-commit

# Run linting
npm run lint
if [ $? -ne 0 ]; then
    echo "Linting failed. Commit aborted."
    exit 1
fi

# Run tests
npm test
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

# Check for secrets
if grep -r "password\|secret\|key" --include="*.js" --include="*.py" .; then
    echo "Potential secrets found. Commit aborted."
    exit 1
fi
```
### Server-side Hooks
```bash
# Post-receive hook for deployment
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    
    if [ "$branch" = "main" ]; then
        echo "Deploying to production..."
        cd /var/www/html
        git --git-dir=/var/repo/site.git --work-tree=/var/www/html checkout -f
        
        # Restart services
        systemctl restart nginx
        systemctl restart php-fpm
        
        echo "Deployment completed successfully"
    fi
done
```
### Hook Management
```bash
# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-receive

# Share hooks with team (using templates)
git config --global init.templatedir '~/.git-templates'
mkdir -p ~/.git-templates/hooks
cp hooks/* ~/.git-templates/hooks/
```
## Git Workflows for DevOps

### GitFlow Workflow
```bash
# GitFlow branch structure
main                    # Production-ready code
develop                 # Integration branch for features
feature/feature-name    # Feature development branches
release/version-number  # Release preparation branches
hotfix/issue-name      # Emergency fixes for production

# GitFlow commands (with git-flow extension)
git flow init                      # Initialize GitFlow
git flow feature start new-feature # Start new feature
git flow feature finish new-feature # Finish feature
git flow release start 1.0.0      # Start release
git flow release finish 1.0.0     # Finish release
git flow hotfix start emergency-fix # Start hotfix
git flow hotfix finish emergency-fix # Finish hotfix
```

### GitHub Flow (Simplified)

```bash
# GitHub Flow process
1. Create branch from main
git checkout -b feature/new-feature

2. Make changes and commit
git add .
git commit -m "Add new feature"

3. Push branch and create pull request
git push origin feature/new-feature

4. Review, test, and merge
# Done via GitHub interface

5. Delete branch after merge
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### GitOps Workflow

```bash
# GitOps repository structure
infrastructure/
├── environments/
│   ├── development/
│   ├── staging/
│   └── production/
├── applications/
│   ├── app1/
│   └── app2/
└── shared/
    ├── monitoring/
    └── security/

# GitOps deployment process
1. Developer commits code changes
2. CI pipeline builds and tests
3. CI updates deployment manifests in GitOps repo
4. GitOps operator detects changes
5. GitOps operator applies changes to cluster
```

## Git Best Practices for DevOps

### Commit Message Standards
```bash
# Conventional Commits format
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

# Examples
feat: add user authentication system
fix: resolve memory leak in data processing
docs: update API documentation
style: format code according to style guide
refactor: restructure user service
test: add unit tests for payment module
chore: update dependencies

# Breaking changes
feat!: remove deprecated API endpoints
BREAKING CHANGE: The old API endpoints have been removed
```
### Branch Naming Conventions
```bash
# Branch naming patterns
feature/JIRA-123-user-authentication
bugfix/JIRA-456-memory-leak-fix
hotfix/JIRA-789-security-patch
release/v1.2.0
experiment/new-algorithm-test

# Environment branches
main                    # Production
develop                 # Development integration
staging                 # Staging environment
```
### .gitignore Best Practices
```bash
# .gitignore for different environments

# Operating System
.DS_Store              # macOS
Thumbs.db              # Windows
*.swp                  # Vim swap files

# IDE and Editors
.vscode/
.idea/
*.sublime-*

# Dependencies
node_modules/
vendor/
*.egg-info/

# Build outputs
dist/
build/
*.o
*.so

# Logs and databases
*.log
*.sqlite
*.db

# Environment and secrets
.env
.env.local
config/secrets.yml
*.pem
*.key

# Temporary files
tmp/
temp/
*.tmp

# Language-specific
__pycache__/           # Python
*.pyc
target/                # Java/Maven
bin/                   # Go
```
## Git Security and Compliance

### Signing Commits
```bash
# GPG key setup
gpg --gen-key                      # Generate GPG key
gpg --list-secret-keys --keyid-format LONG # List keys
git config --global user.signingkey <key-id> # Set signing key
git config --global commit.gpgsign true # Auto-sign commits

# Sign commits manually
git commit -S -m "Signed commit"   # Sign specific commit
git log --show-signature           # Verify signatures
```

### Security Scanning

```bash
# Pre-commit security checks
#!/bin/bash
# Check for secrets
git diff --cached --name-only | xargs grep -l "password\|secret\|key\|token" && exit 1

# Check for large files
git diff --cached --name-only | xargs ls -la | awk '$5 > 10485760 {print $9 " is too large"}' && exit 1

# Scan for vulnerabilities (using tools like truffleHog)
trufflehog --regex --entropy=False .
```

### Access Control

```bash
# Repository access patterns
# Read-only access for CI/CD
# Write access for developers
# Admin access for DevOps team

# Branch protection rules
# Require pull request reviews
# Require status checks
# Require up-to-date branches
# Restrict pushes to main branch
```
## Troubleshooting Common Git Issues

### Merge Conflicts
```bash
# Resolve merge conflicts
git status                         # Check conflicted files
git diff                           # View conflicts

# Manual resolution
# Edit files to resolve conflicts
# Remove conflict markers (<<<<<<<, =======, >>>>>>>)

git add <resolved-file>            # Mark as resolved
git commit                         # Complete merge

# Use merge tools
git mergetool                      # Launch configured merge tool
```
### Undoing Changes
```bash
# Undo uncommitted changes
git checkout -- <file>             # Discard changes to file
git reset --hard HEAD              # Discard all uncommitted changes

# Undo committed changes
git revert <commit-hash>           # Create new commit that undoes changes
git reset --soft HEAD~1            # Undo commit, keep changes
git reset --hard HEAD~1            # Undo commit, discard changes

# Recover lost commits
git reflog                         # Show reference log
git checkout <commit-hash>         # Recover lost commit
```

### Repository Maintenance

```bash
# Clean up repository
git gc                             # Garbage collection
git prune                          # Remove unreachable objects
git fsck                           # Check repository integrity

# Reduce repository size
git filter-branch --tree-filter 'rm -rf path/to/large/files' HEAD
git push --force                   # Push cleaned history

# Alternative: BFG Repo-Cleaner
java -jar bfg.jar --delete-files "*.zip" my-repo.git
```

This comprehensive Git fundamentals guide provides DevOps engineers with the essential knowledge needed to effectively use Git in modern development and deployment workflows.
