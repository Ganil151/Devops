# Advanced Git Techniques for DevOps Engineers

## Advanced Git Operations

### Interactive Rebase

Interactive rebase is a powerful tool for cleaning up commit history before merging or sharing code.

```bash
# Start interactive rebase for last 5 commits
git rebase -i HEAD~5

# Interactive rebase options in editor
pick abc123 Add user authentication
squash def456 Fix typo in auth module
reword ghi789 Implement user registration
edit jkl012 Add password validation
drop mno345 Debug logging (remove this commit)

# Commands available:
# pick (p) = use commit as-is
# reword (r) = use commit, but edit the commit message
# edit (e) = use commit, but stop for amending
# squash (s) = use commit, but meld into previous commit
# fixup (f) = like squash, but discard commit message
# drop (d) = remove commit
# exec (x) = run command (the rest of the line) using shell
```

#### Advanced Rebase Scenarios

```bash
# Rebase onto different branch
git rebase --onto main feature-base feature-branch

# Rebase with strategy options
git rebase -X theirs main                    # Prefer their changes in conflicts
git rebase -X ours main                     # Prefer our changes in conflicts

# Preserve merge commits during rebase
git rebase --preserve-merges main

# Rebase and automatically squash fixup commits
git rebase --autosquash main

# Create fixup commits for automatic squashing
git commit --fixup abc123                   # Creates fixup commit for abc123
git commit --squash abc123                  # Creates squash commit for abc123
```

### Advanced Merge Techniques

```bash
# Merge with custom strategy
git merge -X ours feature-branch            # Prefer our changes in conflicts
git merge -X theirs feature-branch          # Prefer their changes in conflicts
git merge -X ignore-space-change feature-branch  # Ignore whitespace changes

# Octopus merge (multiple branches)
git merge branch1 branch2 branch3           # Merge multiple branches at once

# Subtree merge
git merge -s subtree --no-commit other-repo/main
git commit -m "Merge subtree from other-repo"

# Custom merge driver
git config merge.custom.driver "custom-merge-script %O %A %B %L"
# In .gitattributes:
# *.config merge=custom
```

### Cherry-picking and Patch Management

```bash
# Basic cherry-pick
git cherry-pick abc123                      # Apply specific commit

# Cherry-pick range of commits
git cherry-pick abc123..def456              # Apply range (exclusive of abc123)
git cherry-pick abc123^..def456             # Apply range (inclusive of abc123)

# Cherry-pick with options
git cherry-pick --no-commit abc123          # Apply changes without committing
git cherry-pick -x abc123                   # Add reference to original commit
git cherry-pick --edit abc123               # Edit commit message

# Cherry-pick merge commit
git cherry-pick -m 1 abc123                 # Pick first parent of merge commit
git cherry-pick -m 2 abc123                 # Pick second parent of merge commit

# Handle cherry-pick conflicts
git cherry-pick abc123
# Resolve conflicts
git add resolved-file.txt
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort
```

### Advanced Stashing

```bash
# Stash with specific files
git stash push -m "Work in progress" file1.txt file2.txt

# Stash untracked files
git stash -u                                # Include untracked files
git stash -a                                # Include all files (untracked and ignored)

# Partial stashing (interactive)
git stash -p                                # Interactively choose hunks to stash

# Create branch from stash
git stash branch new-feature stash@{0}      # Create branch and apply stash

# Advanced stash operations
git stash show -p stash@{0}                 # Show stash diff
git stash drop stash@{0}                    # Delete specific stash
git stash clear                             # Delete all stashes

# Stash specific changes
git stash push -m "API changes" -- src/api/
git stash push --keep-index                 # Stash unstaged changes only
```

## Git Hooks and Automation

### Client-side Hooks

#### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

set -e

echo "Running pre-commit checks..."

# Check for merge conflict markers
if grep -r "<<<<<<< \|======= \|>>>>>>> " --include="*.js" --include="*.py" --include="*.java" .; then
    echo "Error: Merge conflict markers found"
    exit 1
fi

# Check for debugging statements
if grep -r "console.log\|debugger\|pdb.set_trace\|System.out.println" --include="*.js" --include="*.py" --include="*.java" .; then
    echo "Error: Debug statements found"
    exit 1
fi

# Check for secrets
if grep -r "password\|secret\|key\|token" --include="*.js" --include="*.py" --include="*.java" . | grep -v ".git"; then
    echo "Error: Potential secrets found"
    exit 1
fi

# Run linting
if command -v eslint >/dev/null 2>&1; then
    echo "Running ESLint..."
    eslint src/
fi

if command -v flake8 >/dev/null 2>&1; then
    echo "Running Flake8..."
    flake8 src/
fi

# Run tests
if [ -f "package.json" ]; then
    echo "Running JavaScript tests..."
    npm test
fi

if [ -f "requirements.txt" ]; then
    echo "Running Python tests..."
    python -m pytest
fi

echo "Pre-commit checks passed!"
```

#### Commit-msg Hook

```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add OAuth2 integration"
    exit 1
fi

# Check commit message length
if [ $(head -n1 "$1" | wc -c) -gt 72 ]; then
    echo "Commit message too long (max 72 characters)"
    exit 1
fi
```

#### Pre-push Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]; then
    echo "Direct push to main branch is not allowed"
    exit 1
fi

# Run additional checks before push
echo "Running pre-push checks..."

# Check if branch is up to date with remote
git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u} 2>/dev/null)
BASE=$(git merge-base @ @{u} 2>/dev/null)

if [ $LOCAL != $REMOTE ] && [ $LOCAL = $BASE ]; then
    echo "Branch is behind remote. Please pull latest changes."
    exit 1
fi

echo "Pre-push checks passed!"
```

### Server-side Hooks

#### Pre-receive Hook

```bash
#!/bin/bash
# hooks/pre-receive

while read oldrev newrev refname; do
    # Check if push is to protected branch
    if [[ $refname == "refs/heads/main" ]]; then
        echo "Checking push to main branch..."
        
        # Ensure push is fast-forward only
        if [ "$oldrev" != "0000000000000000000000000000000000000000" ]; then
            if ! git merge-base --is-ancestor "$oldrev" "$newrev"; then
                echo "Non-fast-forward pushes to main are not allowed"
                exit 1
            fi
        fi
        
        # Check commit messages
        for commit in $(git rev-list "$oldrev".."$newrev"); do
            message=$(git log --format=%s -n 1 "$commit")
            if ! echo "$message" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+'; then
                echo "Invalid commit message format in $commit: $message"
                exit 1
            fi
        done
    fi
done

echo "Pre-receive checks passed"
```

#### Post-receive Hook

```bash
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    
    case $branch in
        main)
            echo "Deploying to production..."
            deploy_to_production "$newrev"
            ;;
        develop)
            echo "Deploying to staging..."
            deploy_to_staging "$newrev"
            ;;
        feature/*)
            echo "Deploying to feature environment..."
            deploy_to_feature "$branch" "$newrev"
            ;;
    esac
done

deploy_to_production() {
    local commit=$1
    
    # Update production code
    cd /var/www/production
    git fetch origin
    git reset --hard "$commit"
    
    # Run deployment tasks
    npm install --production
    npm run build
    
    # Restart services
    systemctl restart nginx
    systemctl restart app
    
    # Send notification
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"Production deployment completed: '"$commit"'"}' \
        "$SLACK_WEBHOOK_URL"
}

deploy_to_staging() {
    local commit=$1
    
    # Similar deployment process for staging
    cd /var/www/staging
    git fetch origin
    git reset --hard "$commit"
    
    # Run tests in staging
    npm install
    npm run test:integration
    
    # Restart staging services
    systemctl restart staging-app
}
```

## Advanced Git Configuration

### Global Git Configuration

```bash
# ~/.gitconfig
[user]
    name = Your Name
    email = your.email@company.com
    signingkey = GPG_KEY_ID

[core]
    editor = vim
    autocrlf = input
    filemode = false
    precomposeunicode = true

[init]
    defaultBranch = main

[push]
    default = simple
    followTags = true

[pull]
    rebase = true

[merge]
    tool = vimdiff
    conflictstyle = diff3

[diff]
    tool = vimdiff
    algorithm = patience

[rerere]
    enabled = true

[commit]
    gpgsign = true
    template = ~/.gitmessage

[alias]
    # Shortcuts
    co = checkout
    br = branch
    ci = commit
    st = status
    
    # Advanced aliases
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    
    # Log aliases
    lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    lol = log --graph --decorate --pretty=oneline --abbrev-commit
    lola = log --graph --decorate --pretty=oneline --abbrev-commit --all
    
    # Diff aliases
    dt = difftool
    mt = mergetool
    
    # Branch management
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d"
    
    # Stash aliases
    sl = stash list
    sa = stash apply
    ss = stash save

[url "git@github.com:"]
    insteadOf = https://github.com/

[credential]
    helper = cache --timeout=3600
```

### Repository-specific Configuration

```bash
# .git/config (repository-specific)
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true

[remote "origin"]
    url = git@github.com:company/project.git
    fetch = +refs/heads/*:refs/remotes/origin/*

[branch "main"]
    remote = origin
    merge = refs/heads/main

[branch "develop"]
    remote = origin
    merge = refs/heads/develop

# Custom configuration for this project
[user]
    email = project-specific@company.com

[commit]
    template = .gitmessage-project
```

## Git Performance Optimization

### Repository Maintenance

```bash
# Garbage collection
git gc                                      # Basic garbage collection
git gc --aggressive                         # Aggressive garbage collection
git gc --prune=now                         # Prune unreachable objects immediately

# Repository statistics
git count-objects -v                       # Show repository statistics
git rev-list --objects --all | sort -k 2 > allfileshas.txt
git gc && git verify-pack -v .git/objects/pack/pack-*.idx | egrep "^\w+ blob\W+[0-9]+ [0-9]+ [0-9]+$" | sort -k 3 -n -r > bigobjects.txt

# Find large files
git rev-list --objects --all | \
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
    sed -n 's/^blob //p' | \
    sort --numeric-sort --key=2 | \
    tail -20

# Clean up repository
git remote prune origin                     # Remove stale remote branches
git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d
```

### Large File Management

```bash
# Git LFS (Large File Storage) setup
git lfs install                             # Install LFS in repository
git lfs track "*.zip"                       # Track zip files with LFS
git lfs track "*.pdf"                       # Track PDF files with LFS
git lfs track "assets/**"                   # Track entire directory

# .gitattributes file for LFS
*.zip filter=lfs diff=lfs merge=lfs -text
*.pdf filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text

# LFS operations
git lfs ls-files                            # List LFS files
git lfs migrate import --include="*.zip"    # Migrate existing files to LFS
git lfs pull                                # Download LFS files
git lfs push origin main                    # Push LFS files
```

### Shallow Clones and Partial Clones

```bash
# Shallow clone (limited history)
git clone --depth 1 https://github.com/user/repo.git     # Only latest commit
git clone --depth 50 https://github.com/user/repo.git    # Last 50 commits

# Deepen shallow clone
git fetch --unshallow                       # Fetch complete history
git fetch --depth=100                       # Fetch more commits

# Partial clone (Git 2.19+)
git clone --filter=blob:none https://github.com/user/repo.git    # No blobs
git clone --filter=tree:0 https://github.com/user/repo.git       # No trees
git clone --filter=blob:limit=1m https://github.com/user/repo.git # Blobs < 1MB

# Sparse checkout
git config core.sparseCheckout true
echo "src/" > .git/info/sparse-checkout
echo "docs/" >> .git/info/sparse-checkout
git read-tree -m -u HEAD
```

## Git Security and Signing

### GPG Commit Signing

```bash
# Generate GPG key
gpg --gen-key

# List GPG keys
gpg --list-secret-keys --keyid-format LONG

# Configure Git to use GPG key
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true

# Sign commits manually
git commit -S -m "Signed commit message"

# Verify signatures
git log --show-signature
git verify-commit HEAD
```

### SSH Commit Signing (Git 2.34+)

```bash
# Configure SSH signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

# Sign with SSH
git commit -S -m "SSH signed commit"

# Configure allowed signers file
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

# allowed_signers file format
your.email@company.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
```

## Advanced Git Workflows

### Worktrees

Git worktrees allow you to have multiple working directories for the same repository.

```bash
# Create new worktree
git worktree add ../feature-branch feature/new-feature
git worktree add -b hotfix/urgent-fix ../hotfix-branch

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../feature-branch
git worktree prune                          # Clean up worktree references

# Use cases for worktrees
# 1. Work on multiple features simultaneously
# 2. Compare different branches side by side
# 3. Run tests on one branch while developing on another
# 4. Maintain separate build environments
```

### Submodules and Subtrees

#### Git Submodules

```bash
# Add submodule
git submodule add https://github.com/user/library.git lib/library

# Clone repository with submodules
git clone --recursive https://github.com/user/main-project.git

# Initialize submodules in existing clone
git submodule init
git submodule update

# Update submodules
git submodule update --remote
git submodule foreach git pull origin main

# Remove submodule
git submodule deinit lib/library
git rm lib/library
rm -rf .git/modules/lib/library
```

#### Git Subtrees

```bash
# Add subtree
git subtree add --prefix=lib/library https://github.com/user/library.git main --squash

# Update subtree
git subtree pull --prefix=lib/library https://github.com/user/library.git main --squash

# Push changes back to subtree
git subtree push --prefix=lib/library https://github.com/user/library.git main

# Extract subtree to separate repository
git subtree split --prefix=lib/library -b library-branch
```

## Troubleshooting and Recovery

### Advanced Recovery Techniques

```bash
# Recover deleted branch
git reflog                                  # Find commit hash
git checkout -b recovered-branch abc123     # Recreate branch

# Recover deleted commits
git fsck --lost-found                       # Find dangling commits
git show abc123                             # Examine dangling commit
git cherry-pick abc123                      # Recover commit

# Recover from corrupted repository
git fsck --full                             # Check repository integrity
git gc --prune=now                          # Clean up corruption

# Reset repository to specific state
git reset --hard abc123                     # Reset to specific commit
git clean -fd                               # Remove untracked files and directories

# Undo various operations
git reset --soft HEAD~1                     # Undo last commit, keep changes staged
git reset --mixed HEAD~1                    # Undo last commit, unstage changes
git reset --hard HEAD~1                     # Undo last commit, discard changes
```

### Repository Analysis and Debugging

```bash
# Analyze repository history
git log --stat                              # Show file changes in commits
git log --follow filename                   # Follow file renames
git blame filename                          # Show line-by-line authorship
git bisect start                            # Start binary search for bugs

# Debug merge issues
git log --merge                             # Show commits involved in merge conflict
git diff --name-only --diff-filter=U       # Show conflicted files
git checkout --theirs filename              # Accept their version
git checkout --ours filename                # Accept our version

# Performance analysis
git log --oneline | wc -l                   # Count commits
git shortlog -sn                            # Contributor statistics
git log --since="1 month ago" --oneline | wc -l  # Recent activity
```

This comprehensive guide provides DevOps engineers with advanced Git techniques essential for managing complex development workflows, maintaining repository health, and implementing robust version control practices in production environments.