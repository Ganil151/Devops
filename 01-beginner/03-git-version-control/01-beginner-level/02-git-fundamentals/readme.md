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

### [Concept] Project Initialization
Before you can version control your code, you must define the environment. This is where the `.git` directory is born.

<GIT_STAGING_ARCHITECTURE_DIAGRAM>

```bash
# Initialize new repository
git init                           # Initialize empty repository
git init -b main                   # Initialize with specific branch name
git init --bare                    # Initialize bare repository (for servers)

# Clone existing repository
git clone <repository-url>         # Clone repository
git clone <url> <directory>        # Clone to specific directory
git clone --depth 1 <url>          # Shallow clone (latest commit only - SRE Tip: Best for CI)
git clone --branch <branch> <url>  # Clone specific branch
git clone --recursive <url>        # Clone with submodules
```

> **Senior Tip**: When initializing for a professional project, always use `git config --global init.defaultBranch main` to avoid the "master" legacy warning and align with modern industry standards.

### [Concept] The Three States: Staging and Workflow
Understanding how files move between your physical disk and the Git database is the most critical hurdle for beginners.

| Area | Purpose | State |
| :--- | :--- | :--- |
| **Working Directory** | Your actual files on disk. | **Modified** |
| **Staging Area (Index)** | The "loading dock" for your next snapshot. | **Staged** |
| **Repository (.git)** | The permanent database. | **Committed** |

#### Commands for State Management:
```bash
# Check repository status (The heartbeat of Git)
git status                         # Show working directory status
git status -s                      # Short format (Easy for scanning)
git status -b                      # Show branch info

# Add files to staging (Recording changes)
git add <file>                     # Add specific file
git add .                          # Add all changes in current dir
git add -p                         # Interactive staging (Patch mode - Senior Tip: Use this to review code before committing)

# Commit changes (Capturing the snapshot)
git commit -m "feat: add user login" # Commit with message (Use Conventional Commits!)
git commit -am "fix: typo"           # Add and commit modified files (Skips staging area)
git commit --amend                   # Edit the last commit (Warning: Do not amend if already pushed)
```

### [Concept] Branching & Merging: Parallel Development
Branches allow teams to work on features, bugfixes, and experiments without breaking the production code (main).

#### Command Toolkit:
```bash
# Branch Management
git branch                         # List local branches
git checkout -b <branch-name>      # Create and switch to new branch
git switch -c <branch-name>        # Modern alternative to "checkout -b"
git branch -m <old> <new>          # Rename branch
git branch -d <branch-name>        # Delete merged branch (Safe)
git branch -D <branch-name>        # Force delete branch (Caution)

# Merging & Integration
git merge <branch-name>            # Integrate changes into current branch
git merge --no-ff <branch-name>    # Force merge commit (Preserves history)
git merge --squash <branch-name>   # Combine all branch commits into one

# Rebase (The "Clean History" Alternative)
git rebase <branch-name>           # Move your work on top of another branch
git rebase -i HEAD~3               # Interactive rebase (Squash/Edit history)
```

> **⚠️ Common Pitfall**: Do **NOT** rebase branches that have been shared with other people. It rewrites history and will cause massive merge conflicts for your team.

---

## Remote Repository Operations

### Working with Remotes
```bash
# Remote repository management
git remote -v                      # List remote repositories
git remote add origin <url>        # Add remote repository
git remote set-url origin <new-url> # Change remote URL
git remote remove origin           # Remove remote link (SRE Tip: Use git remote rm)

# Fetch and pull changes
git fetch                          # Download changes without merging
git pull                           # Fetch and merge changes
git pull --rebase                  # Pull with rebase (Keeps history linear)

# Push changes
git push -u origin main            # Push and set upstream
git push --force-with-lease        # Safer alternative to --force
```

## Advanced Git Operations & Diagnostics

### Stashing Changes
```bash
git stash                          # Save uncommitted work for later
git stash list                     # View your stashes
git stash pop                      # Apply and delete latest stash
git stash apply stash@{1}          # Apply specific stash
```

### Undoing Changes
```bash
git restore <file>                 # Discard changes in working directory
git restore --staged <file>        # Unstage a file
git reset --soft HEAD~1            # Undo last commit, keep code in staging
git reset --hard HEAD~1            # Undo last commit, delete all changes (Caution!)
git revert <commit-hash>           # Create a NEW commit that undoes a PREVIOUS one (Safe for team)
```

### [New Section] SRE Diagnostics & Troubleshooting
When Git behaves unexpectedly, use these tools to inspect the metadata and health of your repository.

```bash
# Repository Health
git fsck                           # Check for corruption
git count-objects -v               # Show object count and size
git gc --aggressive                # Optimize repository size

# History Forensics
git reflog                         # Show every move of the HEAD (The "Undo" list)
git blame <file>                   # See who changed which line last
git show <commit-hash>             # Inspect specific commit details
git log -S "secret_key"            # Search for specific strings in code history

# Conflict Diagnostics
git diff --name-only --diff-filter=U # List files with merge conflicts
git ls-files -u                    # List unmerged files in the index
```

---

## Git Hooks for DevOps Automation

### Client-side Hooks
```bash
#!/bin/bash
# .git/hooks/pre-commit example
# Run linting before allowing a commit
npm run lint || { echo "Linting failed"; exit 1; }
```

### Hook Management
```bash
chmod +x .git/hooks/pre-commit
```

## Git Workflows for DevOps

### GitHub Flow (Industry Standard)
1. Create branch: `git checkout -b feat/task`
2. Commit changes: `git commit -m "feat: description"`
3. Push & PR: `git push origin feat/task`
4. Merge: Delete branch locally and remotely.

## Git Best Practices for DevOps

### Commit Message Standards
Use **Conventional Commits**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `chore`: Maintenance

### .gitignore Best Practices
Always ignore local environment files (`.env`), OS-specific files (`.DS_Store`), and large build artifacts (`node_modules/`, `dist/`).

---

## Git Security and Compliance
- **GPG Signing**: `git commit -S` to verify authenticity.
- **Secret Scanning**: Use `git secrets` or `trufflehog` to scan your history.
- **Access Control**: Use Branch Protection rules in GitHub/GitLab.

This comprehensive Git guide provides DevOps engineers with the essential knowledge needed to effectively use Git in modern development and deployment workflows.
