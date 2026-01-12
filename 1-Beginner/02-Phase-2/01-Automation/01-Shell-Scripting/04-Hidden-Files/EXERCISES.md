# 🎯 Hands-On Exercises: Hidden Files (Dotfiles)

## Exercise 1: Revealing the Invisible (Beginner)
**Objective**: Discover hidden files in your system.

**Tasks**:
1. List files in your home directory normally: `ls ~`
2. List with hidden files: `ls -a ~`
3. List with details: `ls -lah ~`
4. Count how many dotfiles you have: `ls -a ~ | grep "^\." | wc -l`
5. Find the largest dotfile: `ls -lahS ~ | grep "^\." | head -5`

**Questions**:
-What percentage of files in your home are hidden?
- Why are configuration files hidden by default?

---

## Exercise 2: The Bash Profile Investigation (Intermediate)
**Objective**: Understand shell configuration hierarchy.

**Tasks**:
1. Check which profile files exist:
   ```bash
   ls -la ~ | grep -E "bash|profile|zsh"
   ```
2. View contents of `.bashrc`: `cat ~/.bashrc | head -20`
3. View `.bash_profile`: `cat ~/.bash_profile 2>/dev/null || echo "Not found"`
4. Check `.profile`: `cat ~/.profile 2>/dev/null || echo "Not found"`

**Challenge**: Document the order in which these files are loaded.

---

## Exercise 3: Custom Alias Creation (Practical)
**Objective**: Enhance productivity with custom aliases.

**Tasks**:
1. Open `.bashrc`: `nano ~/.bashrc` (or vim)
2. Add these aliases:
   ```bash
   # DevOps aliases
   alias ll='ls -lah'
   alias gs='git status'
   alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
   alias kgp='kubectl get pods'
   alias tf='terraform'
   ```
3. Save and reload: `source ~/.bashrc`
4. Test each alias

**Bonus**: Create an alias that shows your most-used commands:
```bash
alias topcmd='history | awk "{print \$2}" | sort | uniq -c | sort -rn | head -10'
```

---

## Exercise 4: SSH Key Management (Critical)
**Objective**: Secure SSH key storage and permissions.

**Tasks**:
1. Check if `.ssh` directory exists: `ls -la ~/.ssh`
2. If not, create it with correct permissions:
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   ```
3. Generate a test SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "test-key" -f ~/.ssh/test_key -N ""
   ```
4. Verify permissions:
   ```bash
   ls -la ~/.ssh/
   ```
5. Fix any incorrect permissions:
   ```bash
   chmod 600 ~/.ssh/test_key
   chmod 644 ~/.ssh/test_key.pub
   ```

**Security Check**:
What should the permissions be?
- ~/.ssh: `700` (drwx------)
- Private keys: `600` (-rw-------)
- Public keys: `644` (-rw-r--r--)
- authorized_keys: `600`

---

## Exercise 5: Git Configuration Mastery (Essential)
**Objective**: Set up global Git configuration.

**Tasks**:
1. View current config: `cat ~/.gitconfig`
2. Set global identity:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
3. Set default editor:
   ```bash
   git config --global core.editor "vim"
   ```
4. Add useful aliases:
   ```bash
   git config --global alias.st status
   git config --global alias.co checkout
   git config --global alias.br branch
   git config --global alias.last 'log -1 HEAD'
   ```
5. Verify: `cat ~/.gitconfig`

---

## Exercise 6: Environment Variable Export (Advanced)
**Objective**: Manage environment variables via dotfiles.

**Tasks**:
1. Add to `.bashrc`:
   ```bash
   # DevOps Environment Variables
   export EDITOR='vim'
   export VISUAL='vim'
   export AWS_REGION='us-east-1'
   export KUBECONFIG="$HOME/.kube/config"
   export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
   ```
2. Reload shell: `source ~/.bashrc`
3. Verify: `echo $EDITOR && echo $AWS_REGION`
4. Test PATH: `echo $PATH | tr ':' '\n'`

**Challenge**: Create a function in `.bashrc` to quickly switch AWS profiles:
```bash
function awsprofile() {
    export AWS_PROFILE=$1
    echo "Switched to AWS profile: $1"
}
```

---

## Exercise 7: Dotfile Version Control (Professional)
**Objective**: Manage dotfiles with Git for portability.

**Tasks**:
1. Create a dotfiles repository:
   ```bash
   mkdir ~/dotfiles
   cd ~/dotfiles
   git init
   ```
2. Copy important dotfiles:
   ```bash
   cp ~/.bashrc bashrc
   cp ~/.vimrc vimrc 2>/dev/null || touch vimrc
   cp ~/.gitconfig gitconfig
   ```
3. Create installation script `install.sh`:
   ```bash
   #!/bin/bash
   ln -sf ~/dotfiles/bashrc ~/.bashrc
   ln -sf ~/dotfiles/vimrc ~/.vimrc
   ln -sf ~/dotfiles/gitconfig ~/.gitconfig
   echo "Dotfiles installed!"
   ```
4. Make executable: `chmod +x install.sh`
5. Commit: `git add . && git commit -m "Initial dotfiles"`

---

## Exercise 8: Security Audit (Critical)
**Objective**: Find and secure sensitive hidden files.

**Tasks**:
1. Find all dotfiles recursively:
   ```bash
   find ~ -maxdepth 3 -name ".*" -type f 2>/dev/null
   ```
2. Search for potential secrets:
   ```bash
   grep -r "password\|secret\|key\|token" ~/. 2>/dev/null | grep -v ".git"
   ```
3. Check for world-readable sensitive files:
   ```bash
   find ~/.ssh -type f -perm /o+r 2>/dev/null
   ```
4. Audit `.bash_history` for leaked credentials:
   ```bash
   grep -iE "password|token|key|secret" ~/.bash_history
   ```

**Fix**: Clear sensitive history:
```bash
history -c  # Clear current session
> ~/.bash_history  # Clear history file
```

---

## Exercise 9: The Malicious Dotfile Detection (Forensics)
**Objective**: Identify suspicious hidden files.

**Scenario**: Your system has been compromised.

**Investigation Steps**:
1. Find recently modified dotfiles:
   ```bash
   find ~ -maxdepth 1 -name ".*" -type f -mtime -7 -ls
   ```
2. Check for suspicious startup scripts:
   ```bash
   cat ~/.bash_profile ~/.bashrc | grep -E "curl|wget|nc|/tmp"
   ```
3. Look for hidden scripts:
   ```bash
   find ~ -name ".*" -type f -executable
   ```
4. Check for unauthorized SSH keys:
   ```bash
   cat ~/.ssh/authorized_keys
   ```

**Red Flags**:
- Recently modified `.bashrc` you didn't change
- Suspicious commands downloading from internet
- Unknown entries in `authorized_keys`

---

## Exercise 10: Professional Prompt Customization (Productivity)
**Objective**: Create an informative custom prompt.

**Tasks**:
Add to `.bashrc`:
```bash
# DevOps-optimized prompt
parse_git_branch() {
    git branch 2>/dev/null | grep '*' | sed 's/* //'
}

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
```

**Result**: `user@host:/path/to/dir (main)$`

**Advanced**: Add AWS profile and Kubernetes context:
```bash
export PS1='[\[\033[01;33m\]${AWS_PROFILE}\[\033[00m\]] \[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '
```

---

## Verification Checklist
- [ ] Can reveal hidden files with `ls -a`
- [ ] Understand `.bashrc` vs `.bash_profile`
- [ ] Know how to create custom aliases
- [ ] Can set proper SSH key permissions (600/700)
- [ ] Configured global Git settings
- [ ] Know how to export environment variables
- [ ] Can version control dotfiles
- [ ] Understand security implications
- [ ] Can audit for sensitive data
- [ ] Created a custom shell prompt

## Common Dotfiles Reference
| File | Purpose |
|------|---------|
| `.bashrc` | Interactive non-login shell config |
| `.bash_profile` | Login shell initialization |
| `.vimrc` | Vim editor configuration |
| `.gitconfig` | Global Git settings |
| `.ssh/config` | SSH client configuration |
| `.aws/credentials` | AWS API credentials |
| `.kube/config` | Kubernetes cluster config |

## Next Steps
Complete these exercises, then proceed to **[Searching in Files](../05-Searching-in-Files/EXERCISES.md)** →
