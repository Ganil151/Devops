# =============================================================================
#  🔒 SECURE DEVOPS BASH CONFIGURATION — Fedora 42 / WSL2 Optimized
#  Version: 5.0.1
#  Author: Senior Principal DevSecOps Engineer
#  Last Updated: 2024-01-15
# =============================================================================

# --- 00. Early Exits & Safety ---
# Prevent sourcing issues in non-interactive shells
[[ $- != *i* ]] && return

# --- 01. System Security & Hardening ---
# Disable history logging for root sessions
if [ "$UID" -eq 0 ]; then
  export HISTFILE=/dev/null
  export HISTCONTROL=ignorespace
else
  # Normal user: secure history settings
  export HISTSIZE=10000
  export HISTFILESIZE=20000
  export HISTCONTROL=ignoreboth:erasedups
  shopt -s histappend
  shopt -s cmdhist
fi

# Secure SSH defaults
export SSH_CONNECTIONS="-o ControlMaster=auto -o ControlPath=$HOME/.ssh/ctrl-%r@%h:%p -o ControlPersist=4h"
export SSH_COMMANDS="-o StrictHostKeyChecking=ask -o UserKnownHostsFile=$HOME/.ssh/known_hosts -o IdentitiesOnly=yes"

if [[ ! -f "$HOME/.ssh/config" ]]; then
  mkdir -p "$HOME/.ssh" 2>/dev/null
  cat > "$HOME/.ssh/config" << 'EOF' 2>/dev/null
Host *
  ControlMaster auto
  ControlPath ~/.ssh/ctrl-%r@%h:%p
  ControlPersist 4h
  StrictHostKeyChecking ask
  UserKnownHostsFile ~/.ssh/known_hosts
  IdentitiesOnly yes
  ServerAliveInterval 60
  ServerAliveCountMax 3
EOF
  chmod 600 "$HOME/.ssh/config" 2>/dev/null
fi

# --- 02. PATH Management (Safe, Idempotent) ---
path_prepend() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}
path_append() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$PATH:$1"
}

# Core user paths
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

# DevOps tooling paths
path_append "/usr/local/go/bin"
path_append "$HOME/go/bin"
path_append "/opt/homebrew/bin"
path_append "$HOME/.cargo/bin"
path_append "/opt/sonar-scanner/bin"
path_append "/usr/local/terraform/bin"

# Cloud CLI paths (pip --user installs)
path_append "$HOME/.local/bin"

unset -f path_prepend path_append

# --- 03. Environment Variables ---
export TERM=xterm-256color
export CLICOLOR=1
export LESS="-R -F -X"
export EDITOR="nano"
export PAGER="less -R"
export MANPAGER="less -R"

# Cloud provider defaults
export AWS_CLI_AUTO_PROMPT=on-partial
export AZURE_CORE_COLLECT_TELEMETRY=0
export GCLOUD_CORE_DISABLE_USAGE_REPORTING=true

# Terraform
export TF_IN_AUTOMATION=1
export TF_CLI_ARGS_init="-get-plugins=true"

# Kubernetes
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# --- 04. Bash Shell Options ---
shopt -s checkwinsize
shopt -s histexpand
shopt -s nocaseglob
shopt -s nullglob
shopt -s progcomp_alias
shopt -s direxpand
shopt -s autocd

# Enable programmable completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# --- 05. Color Definitions (PS1-COMPATIBLE WITH \[ \]) ---
# These include bash non-printing markers for proper PS1 rendering
readonly RED='\[\033[0;31m\]'
readonly GREEN='\[\033[0;32m\]'
readonly YELLOW='\[\033[1;33m\]'
readonly BLUE='\[\033[0;34m\]'
readonly MAGENTA='\[\033[0;35m\]'
readonly CYAN='\[\033[0;36m\]'
readonly GRAY='\[\033[0;90m\]'
readonly BOLD='\[\033[1m\]'
readonly NC='\[\033[0m\]'

# --- 06. Autosuggestions Implementation ---
_AUTOSUGGEST_HISTORY=()
_AUTOSUGGEST_INDEX=0
_AUTOSUGGEST_BUFFER=""

__autosuggest_load_history() {
  if [[ -r "$HISTFILE" ]]; then
    mapfile -t _AUTOSUGGEST_HISTORY < <(tail -n 1000 "$HISTFILE" 2>/dev/null | grep -v '^#' | sort -u)
  fi
}

__autosuggest_find_match() {
  local prefix="$1"
  local match=""
  for cmd in "${_AUTOSUGGEST_HISTORY[@]}"; do
    if [[ "$cmd" == "$prefix"* && ${#cmd} -gt ${#prefix} ]]; then
      match="$cmd"
      break
    fi
  done
  echo "$match"
}

__autosuggest_accept() {
  local buffer="${READLINE_LINE:0:$READLINE_POINT}"
  local suggestion
  suggestion=$(__autosuggest_find_match "$buffer")
  if [[ -n "$suggestion" ]]; then
    READLINE_LINE="$suggestion"
    READLINE_POINT=${#suggestion}
  fi
}

# Bind autosuggest to Right Arrow and Ctrl+F
if [[ -n "$BASH_VERSION" ]]; then
  __autosuggest_load_history
  bind '"\e[C": __autosuggest_accept'
  bind '"\C-f": __autosuggest_accept'
  bind '"\C-r": __autosuggest_load_history && builtin history -r'
fi

# Plugin support (if installed)
if [[ -f /usr/share/bash-autosuggestions/bash-autosuggestions.sh ]]; then
  source /usr/share/bash-autosuggestions/bash-autosuggestions.sh
elif [[ -f "$HOME/.bash-autosuggestions/bash-autosuggestions.sh" ]]; then
  source "$HOME/.bash-autosuggestions/bash-autosuggestions.sh"
fi

# --- 07. Syntax Highlighting (Optional) ---
if [[ -n "$BASH_VERSION" && -f /usr/share/bash-preexec/bash-preexec.sh ]]; then
  source /usr/share/bash-preexec/bash-preexec.sh
fi

# --- 08. FZF Integration ---
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline --marker=✦ --prompt='❯ ' --pointer='▶'"
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  fzf-git-branch() {
    git branch -a --color=always | grep -v '/HEAD' | sed 's/^..//' | cut -d' ' -f1 | \
    sed 's#^remotes/##' | fzf --preview 'git log -100 --graph --pretty=format:"%Cred%h%Creset %s %Cgreen(%cr)" --abbrev-commit --date=relative {}' | sed 's#^origin/##'
  }

  fzf-k8s-pod() {
    kubectl get pods --all-namespaces --no-headers -o custom-columns=":metadata.namespace,:metadata.name" | \
    fzf --preview 'kubectl describe pod {2} -n {1}' | awk '{print $2, $1}'
  }

  fzf-aws-profile() {
    grep -E '^\[' ~/.aws/credentials 2>/dev/null | tr -d '[]' | fzf --preview 'aws configure list --profile {}'
  }

  alias gf='fzf-git-branch'
  alias kf='fzf-k8s-pod'
  alias af='fzf-aws-profile'

  export FZF_CTRL_T_COMMAND='find . -type f \( -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "Dockerfile" -o -name "*.sh" \) -not -path "*/\.*" 2>/dev/null'
  export FZF_CTRL_T_OPTS="--preview 'head -100 {}'"
fi

# --- 09. Enhanced Prompt (FIXED: No Subshell Function Calls) ---

# Git info: Returns PLAIN TEXT only (colors applied by caller)
__git_info() {
  [[ ! -d .git ]] && return
  local branch status=""
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  [[ -n $(git status --porcelain 2>/dev/null) ]] && status+="●"
  if git rev-parse --abbrev-ref --symbolic-full-name @{upstream} >/dev/null 2>&1; then
    local ahead behind
    ahead=$(git rev-list --count "@{upstream}..HEAD" 2>/dev/null) || ahead=0
    behind=$(git rev-list --count "HEAD..@{upstream}" 2>/dev/null) || behind=0
    (( ahead > 0 )) && status+="↑${ahead}"
    (( behind > 0 )) && status+="↓${behind}"
  fi
  printf 'git:%s%s' "$branch" "$status"
}

# Kubernetes context: Cached, PLAIN TEXT output
__k8s_info() {
  command -v kubectl >/dev/null 2>&1 || return
  local cache="/tmp/.k8s_ctx_$USER"
  if [[ -f "$cache" && $(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) )) -lt 120 ]]; then
    cat "$cache" 2>/dev/null && return
  fi
  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || { echo -n "" > "$cache"; return; }
  ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null) || ns="default"
  local out="k8s:${ctx}/${ns}"
  echo -n "$out" > "$cache"
  printf '%s' "$out"
}

# AWS profile: PLAIN TEXT
__aws_info() {
  [[ -n "$AWS_PROFILE" ]] && printf 'aws:%s' "$AWS_PROFILE"
}

# Terraform workspace: PLAIN TEXT
__tf_info() {
  [[ -f .terraform/environment ]] || return
  local ws
  ws=$(cat .terraform/environment 2>/dev/null)
  [[ "$ws" != "default" ]] && printf 'tf:%s' "$ws"
}

# Docker context: CACHED + WSL2-SAFE + PLAIN TEXT
__docker_info() {
  command -v docker >/dev/null 2>&1 || return
  local cache="/tmp/.docker_ctx_$USER"
  if [[ -f "$cache" && $(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) )) -lt 300 ]]; then
    cat "$cache" 2>/dev/null && return
  fi
  # Suppress ALL stderr to block WSL2 warning spam
  local ctx
  ctx=$(docker context show 2>&1 | grep -v "could not be found" | grep -v "WSL" | head -1) || {
    echo -n "" > "$cache"
    return
  }
  local out=""
  [[ -n "$ctx" && "$ctx" != "default" ]] && out="docker:${ctx}"
  echo -n "$out" > "$cache"
  printf '%s' "$out"
}

# PROMPT_COMMAND function: Sets PS1 directly in MAIN SHELL (no subshell issues)
__set_prompt() {
  local exit_code=$?
  local git_info k8s_info aws_info tf_info docker_info

  # Gather plain-text context (functions run in main shell via PROMPT_COMMAND)
  git_info=$(__git_info)
  k8s_info=$(__k8s_info)
  aws_info=$(__aws_info)
  tf_info=$(__tf_info)
  docker_info=$(__docker_info)

  # Build PS1 with colors applied directly (colors have \[ \] markers)
  PS1="${GREEN}\u@\h${NC}:${BLUE}\w${NC}"

  # Add context indicators with appropriate colors
  [[ -n "$git_info" ]] && PS1+=" ${BLUE}${git_info}${NC}"
  [[ -n "$k8s_info" ]] && PS1+=" ${CYAN}${k8s_info}${NC}"
  [[ -n "$aws_info" ]] && PS1+=" ${YELLOW}${aws_info}${NC}"
  [[ -n "$tf_info" ]] && PS1+=" ${MAGENTA}${tf_info}${NC}"
  [[ -n "$docker_info" ]] && PS1+=" ${GRAY}${docker_info}${NC}"

  # Exit code indicator
  [[ $exit_code -ne 0 ]] && PS1+=" ${RED}✗${exit_code}${NC}"

  # Newline + prompt symbol
  PS1+=$'\n'"${GREEN}\$ ${NC}"
}

# Apply prompt via PROMPT_COMMAND (runs in main shell, functions available)
PROMPT_COMMAND='__set_prompt'
__set_prompt  # Initial render

# --- 10. System & Navigation Aliases ---
alias cls='clear'
alias reload='source ~/.bashrc && echo "✅ Config reloaded"'
alias path='echo "$PATH" | tr ":" "\n"'
alias l='ls -lah --color=auto --group-directories-first'
alias ll='ls -alF --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias lt='ls -lh --color=auto --sort=time'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias h='history | grep -i'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp 2>/dev/null'
alias myip='curl -s https://ifconfig.me ; echo'
alias df='df -h --total'
alias du='du -h --max-depth=2'
alias free='free -h'
alias top='htop 2>/dev/null || top'

# --- 11. Git Mastery Aliases & Functions ---
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull --rebase'
alias gb='git branch -vv'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main 2>/dev/null || git checkout master'
alias gd='git diff --staged'
alias gds='git diff --staged --stat'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gloga='git log --all --graph --oneline --decorate'
alias gundo='git reset --soft HEAD~1'
alias gclean='git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -r git branch -d'
alias gprune='git remote prune origin'
alias gamend='git commit --amend --no-edit'

gclone() {
  [[ -z "$1" ]] && echo "Usage: gclone <repo-url> [directory]" && return 1
  git clone "$1" "${2:-$(basename "$1" .git)}" && cd "${2:-$(basename "$1" .git)}"
}

gswitch() {
  local branch
  branch=$(git branch -a | grep -v HEAD | sed 's/^..//' | cut -d' ' -f1 | fzf --preview 'git log -10 --oneline {}' 2>/dev/null)
  [[ -n "$branch" ]] && git checkout "$branch"
}

# --- 12. Container Ops (Docker & Kubernetes) ---
# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
alias dstats='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dstop='docker stop $(docker ps -q) 2>/dev/null'
alias dkill='docker rm -f $(docker ps -aq) 2>/dev/null'
alias dex='docker exec -it'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"'
alias dprune='docker system prune -af --volumes'
alias dclean='docker rmi $(docker images -q -f dangling=true) 2>/dev/null'
alias dlogs='docker logs -f --tail=100'
alias dbuild='docker build --progress=plain -t'

# Docker Compose
alias dco='docker compose'
alias dcup='docker compose up -d'
alias dcdn='docker compose down'
alias dcl='docker compose logs -f'
alias dcps='docker compose ps'

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
alias kl='kubectl logs -f --tail=100'
alias kexec='kubectl exec -it'
alias kdelp='kubectl delete pod'
alias kw='watch -n 2 kubectl get pods'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

ksh() {
  [[ -z "$1" ]] && echo "Usage: ksh <pod-name> [-n namespace]" && return 1
  local ns="${3:-default}"
  kubectl exec -it "$1" -n "$ns" -- /bin/bash 2>/dev/null || kubectl exec -it "$1" -n "$ns" -- /bin/sh
}

klogs() {
  [[ -z "$1" ]] && echo "Usage: klogs <pod-name> [-n namespace]" && return 1
  local ns="${3:-default}"
  kubectl logs -f --tail=200 "$1" -n "$ns"
}

kportf() {
  [[ -z "$1" || -z "$2" ]] && echo "Usage: kportf <pod> <local-port>[:<remote-port>] [-n namespace]" && return 1
  local ns="${4:-default}"
  kubectl port-forward "$1" "$2" -n "$ns"
}

# --- 13. Infrastructure as Code (Terraform) ---
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfw='terraform workspace'
alias tff='terraform fmt -recursive'
alias tfs='terraform state list'

tfinit() {
  terraform init -upgrade -reconfigure "$@"
}

tfplan() {
  terraform plan -out=tfplan "$@" && echo "✅ Plan saved to tfplan. Apply with: terraform apply tfplan"
}

# --- 14. Cloud Platform Aliases ---
# AWS
alias aws-who='aws sts get-caller-identity'
alias aws-ls='aws s3 ls'
alias aws-logs='aws logs tail --follow'
alias aws-ec2='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress}" --output table'

asp() {
  export AWS_PROFILE="$1"
  echo "✅ AWS Profile: $AWS_PROFILE"
}

ec2-connect() {
  [[ -z "$1" ]] && echo "Usage: ec2-connect <instance-id>" && return 1
  echo "🔐 Starting SSM Session for $1..."
  aws ssm start-session --target "$1"
}

# GCP
alias g-who='gcloud auth list'
alias g-list='gcloud projects list'
alias g-compute='gcloud compute instances list'
alias g-ssh='gcloud compute ssh'

g-proj() {
  gcloud config set project "$1"
  echo "✅ GCP Project: $1"
}

g-zone() {
  gcloud config set compute/zone "$1"
  echo "✅ GCP Zone: $1"
}

# Azure
alias az-who='az account show'
alias az-login='az login'
alias az-list='az account list --output table'
alias az-vm='az vm list --output table'

az-sub() {
  az account set --subscription "$1"
  echo "✅ Azure Subscription: $1"
}

# --- 15. Utility Functions ---
extract() {
  [[ -f "$1" ]] || { echo "❌ '$1' is not a valid file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.rar)            unrar e -y "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip -q "$1" ;;
    *.7z)             7z x -y "$1" ;;
    *.Z)              uncompress "$1" ;;
    *)                echo "❌ Unknown format: $1"; return 1 ;;
  esac
  echo "✅ Extracted: $1"
}

mkcd() { mkdir -p "$1" && cd "$1"; }

findf() { find . -type f -iname "*$1*" 2>/dev/null | head -20; }

grepf() { grep -rIn --color=always "$@" . 2>/dev/null | head -50; }

serve() {
  local port="${1:-8080}"
  echo "🌐 Serving $(pwd) on http://localhost:${port}"
  python3 -m http.server "$port" 2>/dev/null || python -m SimpleHTTPServer "$port"
}

jp() { jq -C . 2>/dev/null || cat; }
y2j() { yq -o=json 2>/dev/null || cat; }

# --- 16. Performance Optimizations ---
export CDPATH=".:$HOME:$HOME/projects"
export HISTTIMEFORMAT="%F %T "
export FZF_COMPLETION_TRIGGER='**'

# --- 17. Post-Init Validation ---
_check_missing_tools() {
  local tools=("terraform" "kubectl" "docker" "jq" "yq" "fzf")
  local missing=()
  for tool in "${tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "⚠️  Missing optional tools: ${missing[*]}"
    echo "   Install with: sudo dnf install ${missing[*]}"
  fi
}

if [[ -z "$_TOOLS_CHECKED" ]]; then
  _check_missing_tools
  export _TOOLS_CHECKED=1
fi

# --- 18. Welcome Message ---
_welcome_message() {
  echo "✅ DevOps Bash environment loaded"
  echo "   Type 'reload' to refresh config"
  echo "   Type 'help-devops' for command reference"
}

if [[ "$-" == *i* && -t 1 ]]; then
  _welcome_message
fi

# --- 19. Help Function ---
help-devops() {
  cat << 'EOF'
🔧 DevOps Bash Quick Reference

📁 Navigation:
  mkcd <dir>     Create and cd into directory
  findf <name>   Find file by name
  grepf <term>   Search file contents

🐙 Git:
  gs/ga/gc/gp    Status, add, commit, push
  glog           Graphical log
  gswitch        Fuzzy branch switch

🐳 Docker:
  dps/dimg       List containers/images
  dprune         Clean unused resources
  dco up/down    Compose lifecycle

☸️  Kubernetes:
  kgp/kgs        Get pods/services
  ksh <pod>      Shell into pod
  kf             Fuzzy pod selector

🏗️  Terraform:
  tfi/tfp/tfa    Init, plan, apply
  tfplan         Plan + save to file

☁️  Cloud:
  asp <profile>  Switch AWS profile
  g-proj <id>    Switch GCP project
  az-sub <id>    Switch Azure subscription

🔍 Fuzzy Search (FZF):
  Ctrl+T         File selection
  Ctrl+R         History search
  gf/kf/af       Git/K8s/AWS fuzzy find

🎨 Prompt Indicators:
  ● Uncommitted changes    ↑ Unpushed commits
  ↓ Unpulled commits       ✗<code> Last exit code

Type 'reload' to apply config changes.
EOF
}

# --- 20. Source Local Customizations ---
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.bash_functions ]] && source ~/.bash_functions
[[ -d ~/.bashrc.d ]] && for rc in ~/.bashrc.d/*; do [[ -f "$rc" ]] && source "$rc"; done

# --- 21. Environment Variables (Persisted) ---
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-temurin}"
export SONAR_SCANNER_HOME="${SONAR_SCANNER_HOME:-/opt/sonar-scanner}"
export PATH="$SONAR_SCANNER_HOME/bin:$JAVA_HOME/bin:$PATH"

# =============================================================================
#  End of Configuration
# =============================================================================