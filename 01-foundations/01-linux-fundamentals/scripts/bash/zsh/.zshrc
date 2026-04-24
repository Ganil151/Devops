# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="bira"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# User configuration

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# =============================================================================
#  🔒 SECURE ZSH CONFIGURATION — Optimized for DevOps Engineers
# =============================================================================
# --- 01. System Security & Hardening ---
# Disable history logging for root
if [ "$UID" -eq 0 ]; then
  unset HISTFILE
  export HISTFILE=/dev/null
  export HISTCONTROL=ignorespace
fi

# Secure SSH
if [ -f "$HOME/.ssh/config" ]; then
  export SSH_CONFIG="$HOME/.ssh/config"
  # Avoid hardcoding SSH_AUTH_SOCK if using an agent, but keep config if needed
  # export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" 
  export SSH_CONNECTIONS="-o ControlMaster=auto -o ControlPath=$HOME/.ssh/ctrl_%r@%h:%p -o ControlPersist=4h"
  export SSH_COMMANDS="-o StrictHostKeyChecking=ask -o UserKnownHostsFile=$HOME/.ssh/known_hosts -o IdentitiesOnly=yes"
fi

# --- 02. PATH Management ---
path_prepend() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then export PATH="$1:$PATH"; fi
}
path_append() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then export PATH="$PATH:$1"; fi
}

# Add custom binaries
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_append "/usr/local/bin"
path_append "/usr/local/go/bin"
path_append "/opt/homebrew/bin"
path_append "$HOME/go/bin"
path_append "$HOME/.local/share/virtualenvs"

unset -f path_prepend path_append

# --- Oh My Zsh Core ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="bira"

# Recommended plugins for DevOps
plugins=(git docker kubectl terraform aws gcloud azure history-substring-search)

# Initialize Oh My Zsh (CRITICAL: Load this BEFORE custom aliases)
source $ZSH/oh-my-zsh.sh

# --- 04. Environment Variables ---
# Set terminal colors to be more readable in dark themes
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS="exfxcxdxbxegedabagacad"
export LESS="-R"

# Set default editor to nano
export EDITOR="nano"

# Enable color for ls
export LS_COLORS='di=1;34:ln=1;36:so=1;32:pi=1;33:ex=1;31:bd=1;34;46:cd=1;34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# ==========================================
#        01. System & Navigation
# ==========================================
alias cls='clear'
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias l='ls -lah --color=auto'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../../'
alias h='history | grep'
alias ports='netstat -tulanp'
alias myip='curl -s https://ifconfig.me; echo'

# ==========================================
#        02. Git Mastery
# ==========================================
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gcm='git checkout main || git checkout master'
alias gd='git diff --staged'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gundo='git reset --soft HEAD~1'

# ==========================================
#        03. Container Ops (Docker & K8s)
# ==========================================
# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a'
alias dstats='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dstop='docker stop $(docker ps -q)'
alias dkill='docker rm -f $(docker ps -aq)'
alias dex='docker exec -it'
alias dimg='docker images'
alias dprune='docker system prune -af --volumes'
alias dclean='docker rmi $(docker images -q -f dangling=true)'

# Docker Compose
alias dco='docker-compose'
alias dcup='docker-compose up -d'
alias dcdn='docker-compose down'
alias dcl='docker-compose logs -f'

# Kubernetes
alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kdelp='kubectl delete pod'
alias kw='watch kubectl get pods'
ksh() { kubectl exec -it "$1" -- /bin/bash || kubectl exec -it "$1" -- /bin/sh; }

# ==========================================
#        04. Infrastructure as Code
# ==========================================
# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfa-auto='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfw='terraform workspace'
alias tff='terraform fmt -recursive'

# ==========================================
#        05. Cloud Platforms
# ==========================================
# --- AWS ---
alias aws-who='aws sts get-caller-identity'
alias aws-ls='aws s3 ls'
alias aws-logs='aws logs tail --follow'
asp() { export AWS_PROFILE=$1; echo "AWS Profile set to: $AWS_PROFILE"; }

# AWS Inventory Suite
alias ec2-ls='aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress,SG:SecurityGroups[0].GroupName}" --output table'
alias ec2-audit='aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,PubIP:PublicIpAddress,PrivIP:PrivateIpAddress,Launched:LaunchTime,SG:SecurityGroups[0].GroupName}" --output table'
alias ec2-cost='aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,State:State.Name}" --output table'
alias ec2-ls-all='aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,State:State.Name,IP:PrivateIpAddress,SG:SecurityGroups[0].GroupName}" --output table'

# Connect via SSM
ec2-connect() {
    echo "Starting SSM Session for $1..."
    aws ssm start-session --target "$1"
}

# --- GCP ---
alias g-who='gcloud auth list'
alias g-list='gcloud projects list'
alias g-compute='gcloud compute instances list'
alias g-ssh='gcloud compute ssh'
g-proj() { gcloud config set project "$1"; }
g-zone() { gcloud config set compute/zone "$1"; }

# --- Azure ---
alias az-who='az account show'
alias az-login='az login'
alias az-list='az account list --output table'
alias az-vm='az vm list --output table'
alias az-rg='az group list --output table'
az-sub() { az account set --subscription "$1"; echo "Switched to Azure Sub: $1"; }
az-res() { az resource list --resource-group "$1" --output table; }

# -----------------------------------------------------------------------------
# 13. POST-INIT VALIDATION — Verify critical tools
# -----------------------------------------------------------------------------
_missing_tools() {
  local tools=("terraform" "kubectl" "docker" "jq" "openssl")
  local missing=()
  for tool in "${tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done
  [[ ${#missing[@]} -gt 0 ]] && \
    echo "⚠️  Missing tools: ${missing[*]}. Install with: sudo dnf install ${missing[*]}"
}
_missing_tools