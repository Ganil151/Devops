### GIT OPERATION & COMMANDS


> Set Up Repo 
- Git init
- Git Clone
- Git Config
- Git Alias: are used to create shorter commands that map to longer commands
#### Save Changes
- Git Add : to update and save a snapshot
- Git Commit : git commit -m "messages"
- Git Diff : finds the changes between the files or branch
- Git Stash : if you are switching from branch to branch without committing changes, it stashes the changes until you commit then
git stash pop : to add the changes

> Inspect Repo
- Git status : command displays the state of the working directory

- Git Log : all the log's and by whom:
you can also use git --oneline for a shorter version 

- Git Reflog : 
is a reference log file that stores a chronological list of all changes made to the HEAD pointer in your Git repository

- Git Tag : is used to capture(tag) a point in history that is used for a marked version release

- Git Blame : function displays of author metadata attached to specific committed lines in a file.

##### Git Configure file
- git config --global user.name "user_name"
- git config --global user.email "user_email"
- set the code editor: 
git config --global core.editor "code --wait"



> Pull & Push and Remote
- git remote -v: to see if you have a remote running

- git remote add (url)

- git remote add origin https://github.com/Ganil151/DevOps.git

- git remote rename <the oldname> <the newname>
  
- git remote remove name

- git pull : git pull origin main 

- git -u push origin main : to push the files on github repositories 

> Parallel Development

- Git Branch : 
git branch <branch_name>, to create a new branch
To commit the branch: git checkout <branch_name> then: git commit -m "message"
to find which branch; git branch -vv
git branch -d <branch_name> : to delete the branch
git branch -M main : to change the name of the branch 

- Git Switch:
does the same as git branch but you can use
git switch -c <branch_name> (create a branch and move there)

- Git Merge: is one of two utilities that specializes in integrating changes from one branch onto another.
1. checkout to the main branch
2. then merge with the main branch 

- git checkout: to switch branch; 
git checkout -b <branch_name> (create a branch and move it)
use git checkout HEAD~(2):the number you like to head back too.

- Git Rebase:
is one of two utilities that specializes in integrating changes from one branch onto another, it also **Rewrite the History** do not use on main or master branch
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".


> To add files or folders to existing repository:
- git merge --allow-unrelated-histories <branch-name>
- git pull origin <branch-name> --allow-unrelated-histories
- git push origin main


> Side Notes
 
- git config --global init.defaultBranch <name> : To configure the initial branch name to use in all of your new repositories, which will suppress this warning, call:


> Archive your Repository
- git archive master --format=zip - output=../name_of_file.zip

> Bundle your Repository
- git bundle create ../repo.bundler master
____

# Comprehensive Git Commands & Diagnostics Reference

## **Git Configuration**

### Basic Configuration

```bash
# Set user name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "vim"
git config --global core.editor "code --wait"  # VS Code
git config --global core.editor "nano"

# View all configuration
git config --list
git config --global --list
git config --local --list

# View specific config
git config user.name
git config user.email

# Edit config file directly
git config --global --edit

# Unset a config
git config --global --unset user.name

# Set line ending handling
git config --global core.autocrlf true   # Windows
git config --global core.autocrlf input  # Mac/Linux

# Enable color output
git config --global color.ui auto

# Set up credential helper
git config --global credential.helper cache
git config --global credential.helper store
git config --global credential.helper 'cache --timeout=3600'

# Configure merge tool
git config --global merge.tool vimidff
git config --global merge.conflictstyle diff3

# Configure diff tool
git config --global diff.tool vimdiff

# Set default push behavior
git config --global push.default simple

# Enable rebase on pull
git config --global pull.rebase true
```

---

## **Repository Initialization**

```bash
# Initialize new repository
git init

# Initialize with specific branch name
git init -b main

# Clone repository
git clone <url>

# Clone to specific directory
git clone <url> <directory>

# Clone specific branch
git clone -b <branch> <url>

# Shallow clone (limited history)
git clone --depth 1 <url>

# Clone with submodules
git clone --recursive <url>

# Add remote repository
git remote add origin <url>

# Change remote URL
git remote set-url origin <new-url>

# List remotes
git remote -v

# Show remote details
git remote show origin

# Rename remote
git remote rename origin upstream

# Remove remote
git remote remove origin
```

---

## **Basic Operations**

### Staging & Committing

```bash
# Check status
git status
git status -s          # Short format
git status -b          # Show branch info

# Add files to staging
git add <file>
git add .              # Add all files
git add *.js           # Add all JS files
git add -A             # Add all changes
git add -u             # Add modified/deleted only
git add -p             # Interactive staging

# Remove from staging
git reset <file>
git reset              # Unstage all
git restore --staged <file>

# Commit changes
git commit -m "Commit message"
git commit -am "Message"           # Add and commit
git commit --amend                 # Amend last commit
git commit --amend -m "New message"
git commit --amend --no-edit       # Amend without changing message

# Empty commit
git commit --allow-empty -m "Empty commit"

# Commit with detailed message
git commit -m "Title" -m "Description line 1" -m "Description line 2"
```

### Viewing Changes

```bash
# Show differences
git diff                  # Working directory vs staging
git diff --staged         # Staging vs last commit
git diff HEAD             # Working directory vs last commit
git diff <file>           # Specific file
git diff <commit1> <commit2>
git diff <branch1> <branch2>

# Show commit history
git log
git log --oneline         # Compact view
git log --graph           # Graph view
git log --all --graph     # All branches
git log -n 5              # Last 5 commits
git log --since="2 weeks ago"
git log --until="2024-01-01"
git log --author="John"
git log --grep="bug"      # Search commit messages
git log -S "function"     # Search code changes
git log --follow <file>   # History of file (including renames)
git log -p <file>         # Show changes for file

# Pretty log formats
git log --pretty=format:"%h - %an, %ar : %s"
git log --pretty=oneline
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'

# Show specific commit
git show <commit>
git show HEAD
git show HEAD~1           # Previous commit
git show <commit>:<file>  # File at specific commit

# Show commit stats
git log --stat
git log --shortstat
git log --numstat

# Blame (who changed what)
git blame <file>
git blame -L 10,20 <file>  # Specific lines
```

---

## **Branching & Merging**

### Branch Operations

```bash
# List branches
git branch                # Local branches
git branch -r             # Remote branches
git branch -a             # All branches
git branch -v             # With last commit
git branch -vv            # With tracking info

# Create branch
git branch <branch-name>
git checkout -b <branch-name>        # Create and switch
git switch -c <branch-name>          # Create and switch (modern)

# Switch branches
git checkout <branch>
git switch <branch>                  # Modern command

# Rename branch
git branch -m <old-name> <new-name>
git branch -m <new-name>             # Rename current

# Delete branch
git branch -d <branch>               # Safe delete
git branch -D <branch>               # Force delete

# Delete remote branch
git push origin --delete <branch>
git push origin :<branch>

# Track remote branch
git branch --set-upstream-to=origin/<branch>
git branch -u origin/<branch>

# Show merged branches
git branch --merged
git branch --no-merged
```

### Merging

```bash
# Merge branch
git merge <branch>

# Merge with commit message
git merge <branch> -m "Merge message"

# No fast-forward merge
git merge --no-ff <branch>

# Squash merge
git merge --squash <branch>

# Abort merge
git merge --abort

# Continue merge after resolving conflicts
git merge --continue

# Show merge conflicts
git diff --name-only --diff-filter=U

# Accept theirs/ours during conflict
git checkout --theirs <file>
git checkout --ours <file>

# Merge tool
git mergetool
```

---

## **Rebasing**

```bash
# Rebase current branch
git rebase <branch>

# Interactive rebase
git rebase -i HEAD~3      # Last 3 commits
git rebase -i <commit>

# Rebase onto another branch
git rebase --onto <newbase> <oldbase> <branch>

# Continue rebase
git rebase --continue

# Skip commit during rebase
git rebase --skip

# Abort rebase
git rebase --abort

# Rebase and autosquash
git rebase -i --autosquash HEAD~5
```

---

## **Remote Operations**

### Fetching & Pulling

```bash
# Fetch from remote
git fetch
git fetch origin
git fetch --all
git fetch --prune         # Remove deleted remote branches

# Pull changes
git pull
git pull origin main
git pull --rebase         # Rebase instead of merge
git pull --ff-only        # Only fast-forward

# Pull specific branch
git pull origin <branch>
```

### Pushing

```bash
# Push to remote
git push
git push origin main

# Push all branches
git push --all

# Push tags
git push --tags

# Force push (dangerous!)
git push --force
git push --force-with-lease  # Safer force push

# Set upstream while pushing
git push -u origin main
git push --set-upstream origin main

# Push new branch
git push origin <new-branch>

# Delete remote branch
git push origin --delete <branch>

# Push specific tag
git push origin <tag-name>

# Push to all remotes
git remote | xargs -L1 git push --all
```

---

## **Stashing**

```bash
# Stash changes
git stash
git stash save "Message"

# Stash including untracked files
git stash -u
git stash --include-untracked

# Stash including ignored files
git stash -a
git stash --all

# List stashes
git stash list

# Show stash content
git stash show
git stash show -p         # With diff
git stash show stash@{0}

# Apply stash
git stash apply
git stash apply stash@{1}

# Pop stash (apply and remove)
git stash pop

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear

# Create branch from stash
git stash branch <branch-name>
```

---

## **Undoing Changes**

### Reset

```bash
# Soft reset (keep changes staged)
git reset --soft HEAD~1

# Mixed reset (keep changes unstaged) - default
git reset HEAD~1
git reset --mixed HEAD~1

# Hard reset (discard all changes)
git reset --hard HEAD~1
git reset --hard <commit>

# Reset specific file
git reset HEAD <file>

# Reset to remote state
git reset --hard origin/main
```

### Revert

```bash
# Revert commit (creates new commit)
git revert <commit>

# Revert without committing
git revert -n <commit>
git revert --no-commit <commit>

# Revert merge commit
git revert -m 1 <merge-commit>

# Continue revert
git revert --continue

# Abort revert
git revert --abort
```

### Restore

```bash
# Restore file from staging
git restore --staged <file>

# Restore file from commit
git restore --source=HEAD~1 <file>

# Restore all files
git restore .

# Restore and stage
git restore --staged --worktree <file>
```

### Clean

```bash
# Remove untracked files (dry run)
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Remove ignored files too
git clean -fX

# Remove all untracked and ignored
git clean -fdx

# Interactive clean
git clean -i
```

---

## **Tags**

```bash
# List tags
git tag
git tag -l "v1.*"         # Filter tags

# Create lightweight tag
git tag <tag-name>

# Create annotated tag
git tag -a v1.0 -m "Version 1.0"

# Tag specific commit
git tag -a v1.0 <commit> -m "Message"

# Show tag details
git show <tag-name>

# Delete tag
git tag -d <tag-name>

# Delete remote tag
git push origin --delete <tag-name>

# Push tag
git push origin <tag-name>

# Push all tags
git push --tags

# Checkout tag
git checkout <tag-name>

# Create branch from tag
git checkout -b <branch> <tag>
```

---

## **Cherry-picking**

```bash
# Cherry-pick commit
git cherry-pick <commit>

# Cherry-pick multiple commits
git cherry-pick <commit1> <commit2>

# Cherry-pick range
git cherry-pick <commit1>..<commit2>

# Cherry-pick without committing
git cherry-pick -n <commit>
git cherry-pick --no-commit <commit>

# Continue cherry-pick
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort

# Skip cherry-pick
git cherry-pick --skip
```

---

## **Submodules**

```bash
# Add submodule
git submodule add <url> <path>

# Initialize submodules
git submodule init

# Update submodules
git submodule update

# Clone with submodules
git clone --recursive <url>

# Update all submodules
git submodule update --remote

# Update and initialize
git submodule update --init --recursive

# List submodules
git submodule status

# Remove submodule
git submodule deinit <path>
git rm <path>
rm -rf .git/modules/<path>

# Execute command in all submodules
git submodule foreach git pull origin main
```

---

## **Advanced Operations**

### Bisect (Binary Search for Bugs)

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark commit as good
git bisect good <commit>

# Bisect automatically with script
git bisect run <script>

# Reset bisect
git bisect reset

# Skip commit
git bisect skip

# Visualize bisect
git bisect visualize
```

### Reflog (Recovery)

```bash
# Show reflog
git reflog

# Show reflog for specific branch
git reflog show <branch>

# Recover deleted branch/commit
git reflog
git checkout -b <branch> <commit>

# Undo reset using reflog
git reset --hard HEAD@{1}
```

### Worktree (Multiple Working Directories)

```bash
# List worktrees
git worktree list

# Add worktree
git worktree add <path> <branch>

# Create new branch with worktree
git worktree add <path> -b <new-branch>

# Remove worktree
git worktree remove <path>

# Prune worktrees
git worktree prune
```

### Archive

```bash
# Create archive
git archive --format=zip HEAD > archive.zip
git archive --format=tar HEAD | gzip > archive.tar.gz

# Archive specific branch
git archive --format=zip <branch> > archive.zip

# Archive with prefix
git archive --format=zip --prefix=project/ HEAD > archive.zip
```

---

## **Diagnostics & Troubleshooting**

### Repository Health Check

```bash
# Check repository integrity
git fsck
git fsck --full

# Verify connectivity
git fsck --connectivity-only

# Check for corruption
git fsck --lost-found

# Garbage collection
git gc
git gc --aggressive
git gc --prune=now

# Count objects
git count-objects
git count-objects -v

# Verify pack files
git verify-pack -v .git/objects/pack/*.idx

# Show repository size
du -sh .git

# Show largest files in history
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  sed -n 's/^blob //p' | \
  sort --numeric-sort --key=2 | \
  tail -n 10
```

### Network Diagnostics

```bash
git ls-remote <url>

# Check remote branches
git ls-remote --heads origin

# Check remote tags
git ls-remote --tags origin

# Verify remote URL
git remote -v

# Test fetch
git fetch --dry-run

# Show what would be pushed
git push --dry-run

# Verbose operations
git clone -v <url>
git fetch -v
git push -v

# Check SSL certificate
GIT_CURL_VERBOSE=1 git ls-remote <url>
GIT_TRACE=1 git clone <url>
```

### Performance Diagnostics

```bash
# Measure command performance
time git <command>

# Enable Git tracing
GIT_TRACE=1 git <command>
GIT_TRACE_PERFORMANCE=1 git <command>
GIT_TRACE_SETUP=1 git <command>

# Packet tracing
GIT_TRACE_PACKET=1 git <command>

# Show execution time
git <command> --exec-path

# Benchmark operations
git rev-list --all --count
git log --all --oneline | wc -l
```

### Configuration Diagnostics

```bash
# Show effective config
git config --list --show-origin

# Show config for specific scope
git config --system --list
git config --global --list
git config --local --list

# Check specific config
git config --get user.name
git config --get-all user.email

# Verify .gitignore
git check-ignore -v <file>
git check-ignore *

# Check attributes
git check-attr -a <file>
```

### Branch & Commit Diagnostics

```bash
# Show all commits in branch not in main
git log main..<branch>

# Show commits in main not in branch
git log <branch>..main

# Show symmetric difference
git log --left-right main...<branch>

# Find commit by message
git log --all --grep="pattern"

# Find commit by content
git log -S "search_string"
git log -G "regex_pattern"

# Show commits touching file
git log --follow -- <file>

# Show who changed each line
git blame <file>

# Show commit tree
git log --graph --all --oneline

# Find merge commit
git log --merges

# Find non-merge commits
git log --no-merges

# Show branch relationships
git show-branch
git show-branch --all
```

### Conflict Diagnostics

```bash
# Show files with conflicts
git diff --name-only --diff-filter=U

# Show conflict markers
git diff --check

# List merge conflicts
git ls-files -u

# Show three-way diff
git diff --merge

# Show conflict resolution
git log --merge -p <file>
```

### Diff & Comparison

```bash
# Compare branches
git diff <branch1>..<branch2>

# Compare with remote
git diff main origin/main

# Show file changes between commits
git diff <commit1> <commit2> -- <file>

# Diff statistics
git diff --stat
git diff --numstat
git diff --shortstat

# Word diff
git diff --word-diff
git diff --color-words

# Ignore whitespace
git diff -w
git diff --ignore-all-space
```

### Object Inspection

```bash
# Show object type
git cat-file -t <object>

# Show object content
git cat-file -p <object>

# Show object size
git cat-file -s <object>

# List tree objects
git ls-tree HEAD

# List all objects
git rev-list --objects --all

# Show commit parents
git rev-parse HEAD^
git rev-parse HEAD~1
```

---

## **Diagnostic Scripts**

### Repository Diagnostic Script

```bash
#!/bin/bash
# git-diagnostic.sh

echo "=== Git Repository Diagnostics ==="
echo ""

echo "Repository Information:"
echo "Current Branch: $(git branch --show-current)"
echo "Remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
echo ""

echo "Repository Status:"
git status -s
echo ""

echo "Recent Commits:"
git log --oneline -5
echo ""

echo "Branches:"
git branch -vv
echo ""

echo "Remotes:"
git remote -v
echo ""

echo "Stashes:"
git stash list
echo ""

echo "Repository Size:"
du -sh .git
echo ""

echo "Object Count:"
git count-objects -v
echo ""

echo "Configuration:"
git config --list --show-origin | grep -E "user\.|remote\."
echo ""

echo "Checking for issues..."
git fsck --no-progress 2>&1 | grep -v "^Checking"
echo ""

echo "=== Diagnostics Complete ==="
```

### Branch Comparison Script

```bash
#!/bin/bash
# compare-branches.sh

BRANCH1=${1:-main}
BRANCH2=${2:-HEAD}

echo "=== Comparing $BRANCH1 with $BRANCH2 ==="
echo ""

echo "Commits in $BRANCH2 not in $BRANCH1:"
git log --oneline $BRANCH1..$BRANCH2
echo ""

echo "Commits in $BRANCH1 not in $BRANCH2:"
git log --oneline $BRANCH2..$BRANCH1
echo ""

echo "File changes:"
git diff --stat $BRANCH1..$BRANCH2
echo ""
```

---

## **Git Aliases (Productivity)**

Add these to your `.gitconfig`:

```bash
[alias]
    # Short status
    st = status -s
    
    # Commit shortcuts
    cm = commit -m
    cam = commit -am
    
    # Branch operations
    br = branch
    co = checkout
    cob = checkout -b
    
    # Log variations
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
    ls = log --oneline
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    
    # Diff shortcuts
    df = diff
    dfs = diff --staged
    
    # Undo shortcuts
    undo = reset --soft HEAD^
    amend = commit --amend --no-edit
    
    # Stash shortcuts
    sl = stash list
    sa = stash apply
    ss = stash save
    
    # Show contributors
    contributors = shortlog --summary --numbered
    
    # Find files
    find = "!git ls-files | grep -i"
    
    # Clean branches
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d"
```
# How to Remove Git Remote

## **Quick Answer**

```bash
# Remove remote named 'origin'
git remote remove origin

# Alternative command (same result)
git remote rm origin
```

---

## **Step-by-Step Guide**

### **Step 1: List Current Remotes**

```bash
# See all remotes
git remote -v

# Output example:
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)
# upstream  https://github.com/original/repo.git (fetch)
# upstream  https://github.com/original/repo.git (push)
```

### **Step 2: Remove the Remote**

```bash
# Remove by name
git remote remove origin

# Or use 'rm' (same thing)
git remote rm origin
```

### **Step 3: Verify Removal**

```bash
# Check remotes again
git remote -v

# Should show nothing if 'origin' was the only remote
```

---

## **Common Scenarios**

### **Remove Origin and Add New One**

```bash
# Remove old remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/newuser/newrepo.git

# Verify
git remote -v
```

### **Remove Multiple Remotes**

```bash
# Remove origin
git remote remove origin

# Remove upstream
git remote remove upstream

# Remove any other remotes
git remote remove <remote-name>
```

### **Remove Remote and Keep Working Locally**

```bash
# Remove remote
git remote remove origin

# Continue working locally
git add .
git commit -m "Working locally"

# Add remote later when needed
git remote add origin <new-url>
git push -u origin main
```

---

## **Alternative: Change Remote URL Instead**

If you just want to change the URL, you don't need to remove:

```bash
# Change remote URL (better than remove/add)
git remote set-url origin https://github.com/newuser/newrepo.git

# Verify
git remote -v
```

---

## **Troubleshooting**

### **Error: "No such remote 'origin'"**

```bash
# List available remotes first
git remote

# Remove the correct remote name
git remote remove <actual-remote-name>
```

### **Check if Remote Exists Before Removing**

```bash
# Check if remote exists
if git remote | grep -q "^origin$"; then
    git remote remove origin
    echo "Remote 'origin' removed"
else
    echo "Remote 'origin' does not exist"
fi
```

### **Remove All Remotes (Nuclear Option)**

```bash
# List all remotes and remove each
git remote | xargs -n1 git remote remove

# Or manually:
for remote in $(git remote); do
    git remote remove $remote
done
```

---

## **What Happens When You Remove a Remote?**

✅ **Does NOT delete:**

- Your local repository
- Your local branches
- Your commits
- Your files

❌ **Only removes:**

- The connection to the remote server
- Remote tracking branches (origin/main, etc.)

---

## **Remote-Related Commands**

```bash
# List all remotes
git remote
git remote -v                    # With URLs

# Show remote details
git remote show origin

# Add remote
git remote add origin <url>

# Rename remote
git remote rename origin upstream

# Change remote URL
git remote set-url origin <new-url>

# Remove remote
git remote remove origin

# Prune deleted remote branches
git remote prune origin

# Update remote references
git remote update
```

---

## **Complete Example**

```bash
# Scenario: Switch from old GitHub repo to new one

# Step 1: Check current remote
git remote -v
# origin  https://github.com/olduser/oldrepo.git (fetch)
# origin  https://github.com/olduser/oldrepo.git (push)

# Step 2: Remove old remote
git remote remove origin

# Step 3: Verify removal
git remote -v
# (should show nothing)

# Step 4: Add new remote
git remote add origin https://github.com/newuser/newrepo.git

# Step 5: Verify new remote
git remote -v
# origin  https://github.com/newuser/newrepo.git (fetch)
# origin  https://github.com/newuser/newrepo.git (push)

# Step 6: Push to new remote
git push -u origin main
```

---

## **Quick Reference**

|Command|Description|
|---|---|
|`git remote remove origin`|Remove remote named 'origin'|
|`git remote rm origin`|Same as above (shorter)|
|`git remote -v`|List all remotes with URLs|
|`git remote`|List remote names only|
|`git remote add origin <url>`|Add new remote|
|`git remote set-url origin <url>`|Change remote URL|
|`git remote rename origin upstream`|Rename remote|

---

## **Pro Tips**

💡 **Before removing a remote, make sure:**

- You have committed all changes: `git status`
- You have pushed important branches: `git push --all`
- You know the new remote URL (if replacing)

💡 **Use `set-url` instead of remove/add if just changing URL:**

```bash
# Better:
git remote set-url origin <new-url>

# Than:
git remote remove origin
git remote add origin <new-url>
```

💡 **Backup remote URL before removing:**

```bash
# Save URL for later
git remote get-url origin > remote-backup.txt

# Remove remote
git remote remove origin

# Restore later if needed
git remote add origin $(cat remote-backup.txt)
```

That's it! The command is simple: **`git remote remove origin`** (or whatever your remote name is).

---

This comprehensive guide covers all essential Git commands and diagnostics you'll need!

### Introduction to SSH Keys

> SSH: key is an access credential for the secure shell network protocol. This authenticated and encrypted secure network protocol is used for remote communication between machines on an unsecured open network. SSH is used for remote file transfer, network management, and remote operating system access.

- How to create SSH KEY?
create key: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
after filling in all;
add the new SSH key to the ssh-agent: ssh-add -K /Users/you/.ssh/id_rsa








#### Fix Errors while pull & push 
Create Personal Access Token on GitHub
From your GitHub account, go to Settings → Developer Settings → Personal Access Token → Tokens (classic) → Generate New Token (Give your password) → Fill up the form → click Generate token → Copy the generated Token: [REDACTED_TOKEN]

for Linux: git clone https://<tokenhere>@github.com/<user>/<repo>.git







>for DevOps Tutorials:
[Links:](https://youtu.be/a2uh2hA4V3A)
>for Git&GitHub Tutorials:
[Links:](https://youtu.be/zTjRZNkhiEU)
[MoreBooks](https://github.com/jidibinlin/Free-DevOps-Books-1/tree/master/book)


https://youtu.be/zTjRZNkhiEU?t=8164
