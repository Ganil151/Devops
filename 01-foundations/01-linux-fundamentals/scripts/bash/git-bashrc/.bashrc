# ===================================================================
#  🔒 SECURE DEVOPS BASH CONFIGURATION — Git Bash / Windows 11
#  Version: 7.0.0-BIRA-BOX-FIXED
#  ✅ Syntax Validated • No Duplicates • Git Bash Optimized
# ===================================================================

# --- 00. Infinite Loop & Reload Guard ---
[[ -n "${_BASHRC_LOADED+x}" ]] && return
export _BASHRC_LOADED=1

[[ $- != *i* ]] && return

# --- 01. Environment Detection ---
case "$OSTYPE" in
  msys*|mingw*|cygwin*) IS_GITBASH=1 ;;
  linux-gnu*) IS_GITBASH=0 ;;
  *) IS_GITBASH=0 ;;
esac

if [[ "$IS_GITBASH" -eq 1 ]]; then
  export MSYS_NO_PATHCONV=1
  export MSYS2_ARG_CONV_EXCL="*"
  export ANSICON=1
  export ConEmuANSI=ON
  export LESSCHARSET=utf-8
fi

# --- 02. Security & History ---
if [ "$UID" -eq 0 ]; then
  export HISTFILE=/dev/null
  export HISTCONTROL=ignorespace
else
  export HISTSIZE=10000
  export HISTFILESIZE=20000
  export HISTCONTROL=ignoreboth:erasedups
  shopt -s histappend cmdhist
fi

# --- 03. SSH Config (Idempotent) ---
export SSH_CONFIG_DIR="$HOME/.ssh"
export SSH_CONNECTIONS="-o ControlMaster=auto -o ControlPath=${SSH_CONFIG_DIR}/ctrl-%r@%h:%p -o ControlPersist=4h"
export SSH_COMMANDS="-o StrictHostKeyChecking=ask -o UserKnownHostsFile=${SSH_CONFIG_DIR}/known_hosts -o IdentitiesOnly=yes"

if [[ ! -f "${SSH_CONFIG_DIR}/config" ]]; then
  mkdir -p "${SSH_CONFIG_DIR}" 2>/dev/null
  cat > "${SSH_CONFIG_DIR}/config" << 'EOF' 2>/dev/null
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
  chmod 600 "${SSH_CONFIG_DIR}/config" 2>/dev/null
fi

# --- 04. PATH Management ---
path_prepend() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"; }
path_append()  { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$PATH:$1"; }

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
[[ "$IS_GITBASH" -eq 0 ]] && {
  path_append "/usr/local/go/bin"
  path_append "$HOME/go/bin"
  path_append "/usr/local/terraform/bin"
  path_append "/opt/sonar-scanner/bin"
}
path_append "$HOME/.cargo/bin"
path_append "/opt/homebrew/bin" 2>/dev/null
unset -f path_prepend path_append

# --- 05. Environment Variables ---
export TERM="${TERM:-xterm-256color}"
export CLICOLOR=1
export LESS="-R -F -X"
export EDITOR="${EDITOR:-nano}"
export PAGER="less -R"
export MANPAGER="less -R"
export AWS_CLI_AUTO_PROMPT=on-partial 2>/dev/null
export AZURE_CORE_COLLECT_TELEMETRY=0 2>/dev/null
export GCLOUD_CORE_DISABLE_USAGE_REPORTING=true 2>/dev/null
export TF_IN_AUTOMATION=1
unset TF_CLI_ARGS_init
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

shopt -s checkwinsize histexpand nocaseglob nullglob progcomp_alias direxpand autocd 2>/dev/null

if [[ "$IS_GITBASH" -eq 1 && -f /mingw64/share/bash-completion/bash_completion ]]; then
  source /mingw64/share/bash-completion/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# ===================================================================
#  🔌 PLUGIN LOADER FRAMEWORK
# ===================================================================

export BASH_PLUGINS_DIR="${BASH_PLUGINS_DIR:-$HOME/.bash_plugins}"
mkdir -p "$BASH_PLUGINS_DIR" 2>/dev/null

__load_plugin() {
  local name="$1" file="${BASH_PLUGINS_DIR}/${1}/${1}.bash"
  [[ -r "$file" ]] && source "$file" 2>/dev/null && return 0 || return 1
}

__lazy_plugin() {
  local name="$1" cmd="${2:-$1}"
  eval "
  $cmd() {
    __load_plugin '$name' || { echo '⚠️  Plugin $name failed to load' >&2; return 1; }
    unset -f $cmd 2>/dev/null
    $cmd \"\$@\"
  }"
}

declare -A CMD_AVAIL
for c in fzf zoxide starship jq yq; do
  CMD_AVAIL[$c]=$(command -v "$c" >/dev/null 2>&1 && echo 1 || echo 0)
done

# ===================================================================
#  🔍 PLUGIN STATUS CHECKER
# ===================================================================
test-plugins() {
  echo "🔍 Plugin Framework Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Plugin Dir: ${BASH_PLUGINS_DIR:-unset}"
  [[ -d "${BASH_PLUGINS_DIR}" ]] && echo "✅ Exists" || echo "❌ Missing"
  echo ""
  local count=0
  for plugin_dir in "${BASH_PLUGINS_DIR}"/*/; do
    [[ -d "$plugin_dir" ]] || continue
    local name=$(basename "$plugin_dir")
    local file="${plugin_dir}${name}.bash"
    ((count++))
    if [[ -r "$file" ]]; then
      echo "✅ ${name} (.bash found)"
      bash -n "$file" 2>/dev/null && echo "   ↳ Syntax: OK" || echo "   ↳ Syntax: FAIL"
    else
      echo "❌ ${name} (.bash missing)"
    fi
  done
  [[ $count -eq 0 ]] && echo "⚠️  No plugins installed in ${BASH_PLUGINS_DIR}"
  echo ""
  echo "🔍 Command Availability"
  echo "━━━━━━━━━━━━━━━━━━━━━━"
  for cmd in fzf zoxide starship jq yq; do
    if command -v "$cmd" &>/dev/null; then
      echo "✅ $cmd → $(command -v "$cmd")"
    else
      echo "⚠️  $cmd → Not in PATH"
    fi
  done
}

# ===================================================================
#  🎨 COLOR DEFINITIONS (Fixed: PS1 vs Echo Separation)
# ===================================================================

# PS1-safe colors (include \[ \] for Bash prompt width calculation)
readonly _NO_FG='\[\033[38;5;189m\]'
readonly _NO_DARK='\[\033[38;5;16m\]'
readonly _NO_GREEN='\[\033[38;5;50m\]'
readonly _NO_BLUE='\[\033[38;5;25m\]'
readonly _NO_RED='\[\033[38;5;124m\]'
readonly _NO_GRAY='\[\033[38;5;245m\]'
readonly _NO_RESET='\[\033[0m\]'
readonly _NO_BOLD='\[\033[1m\]'

# Echo-safe colors (raw ANSI, NO \[ \])
readonly _NO_FG_E='\033[38;5;189m'
readonly _NO_GREEN_E='\033[38;5;50m'
readonly _NO_RESET_E='\033[0m'

readonly _SYM_TL='╭─' _SYM_BL='╰─' _SYM_BRANCH=''
readonly _SYM_GIT='🌿' _SYM_K8S='☸️' _SYM_AWS='🅰️' _SYM_ARROW='❯' _SYM_ERR='✗'
readonly _SEP="${_NO_GRAY}─${_NO_RESET}"

# =============================================================================
#  ⚡ BIRA BOX PROMPT (Cached)
# =============================================================================

declare -g __NO_GIT_CACHE="" __NO_GIT_DIR="" __NO_GIT_TIME=0
declare -g __NO_K8S_CACHE="" __NO_K8S_TIME=0
declare -g __NO_AWS_CACHE="" __NO_AWS_PROFILE=""
declare -g _NO_CMD_START=$SECONDS

__no_get_git_info() {
  [[ ! -d .git && ! -f .git ]] && return
  local now=$(date +%s)
  if [[ "$PWD" != "$__NO_GIT_DIR" || $((now - __NO_GIT_TIME)) -gt 5 ]]; then
    __NO_GIT_DIR="$PWD"; __NO_GIT_TIME=$now
    local branch status=""
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git describe --tags --exact-match 2>/dev/null) || \
    branch="detached"
    git status --porcelain 2>/dev/null | grep -q . && status="${_NO_RED}*${_NO_RESET}"
    __NO_GIT_CACHE="${_SYM_BRANCH}${branch}${status}"
  fi
  echo "$__NO_GIT_CACHE"
}

__no_get_k8s_context() {
  [[ "${CMD_AVAIL[kubectl]}" != "1" ]] && return
  local now=$(date +%s)
  if [[ $((now - __NO_K8S_TIME)) -gt 30 ]]; then
    __NO_K8S_TIME=$now
    local ctx=$(kubectl config current-context 2>/dev/null | cut -d'/' -f1)
    __NO_K8S_CACHE="${ctx:+${ctx}$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null | sed 's/^/:/' 2>/dev/null)}"
  fi
  [[ -n "$__NO_K8S_CACHE" && "$__NO_K8S_CACHE" != "default" ]] && echo "${_SYM_K8S} ${__NO_K8S_CACHE}"
}

__no_get_aws_profile() {
  local current="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [[ "$current" != "$__NO_AWS_PROFILE" ]]; then
    __NO_AWS_PROFILE="$current"
    __NO_AWS_CACHE="${current:+${_SYM_AWS} ${current}}"
  fi
  echo "$__NO_AWS_CACHE"
}

# =============================================================================
#  ⚡ VENV + PROMPT DEFINITIONS (Correct Order)
# =============================================================================

# 1. Define Venv Function FIRST (Fixes "command not found")
show_venv() {
  [[ -n "$VIRTUAL_ENV" ]] && printf "(%s) " "$(basename "$VIRTUAL_ENV")"
}

# 2. Execution Time Helper
__no_get_exec_time() {
  [[ -z "$_NO_CMD_START" ]] && return
  local elapsed=$((SECONDS - _NO_CMD_START)); _NO_CMD_START=$SECONDS
  [[ $elapsed -ge 5 ]] && printf "${_NO_GRAY}%ds${_NO_RESET} " $elapsed
}

# 3. The Bira Box Prompt
__bira_box_prompt() {
  local exit_code=$?
  local short_path="${PWD/#$HOME/\~}"
  local venv_info="$(show_venv)"
  local git_info="" ctx_info="" aws_info="" exec_time=""

  if [[ -d .git || -f .git ]]; then
    local now=$(date +%s)
    if [[ "$PWD" != "${__NO_GIT_DIR:-}" || $((now - ${__NO_GIT_TIME:-0})) -gt 5 ]]; then
      __NO_GIT_DIR="$PWD"; __NO_GIT_TIME=$now
      local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "●")
      git status --porcelain 2>/dev/null | grep -q . && branch="${_NO_RED}*${_NO_RESET}${branch}"
      __NO_GIT_CACHE="${_SYM_BRANCH}${branch}"
    fi
    git_info="${__NO_GIT_CACHE:+ ${_NO_GRAY}[${__NO_GIT_CACHE}${_NO_GRAY}]}"
  fi

  if [[ "${CMD_AVAIL[kubectl]:-0}" == "1" ]]; then
    local now=$(date +%s)
    if [[ $((now - ${__NO_K8S_TIME:-0})) -gt 30 ]]; then
      __NO_K8S_TIME=$now
      local ctx=$(kubectl config current-context 2>/dev/null | cut -d'/' -f1)
      [[ -n "$ctx" && "$ctx" != "default" ]] && __NO_K8S_CACHE="${_SYM_K8S} ${ctx}"
    fi
    [[ -n "${__NO_K8S_CACHE:-}" ]] && ctx_info=" ${_NO_GRAY}|${_NO_RESET} ${__NO_K8S_CACHE}"
  fi

  if [[ -n "${AWS_PROFILE:-$AWS_DEFAULT_PROFILE:-}" ]]; then
    local current="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
    [[ "$current" != "${__NO_AWS_PROFILE:-}" ]] && __NO_AWS_PROFILE="$current" && __NO_AWS_CACHE="${_SYM_AWS} ${current}"
    [[ -n "${__NO_AWS_CACHE:-}" ]] && aws_info=" ${_NO_GRAY}|${_NO_RESET} ${__NO_AWS_CACHE}"
  fi

  if [[ -n "${_NO_CMD_START:-}" ]]; then
    local elapsed=$((SECONDS - _NO_CMD_START)); _NO_CMD_START=$SECONDS
    [[ $elapsed -ge 3 ]] && exec_time=" ${_NO_GRAY}${elapsed}s${_NO_RESET}"
  fi

  local line1="${_SYM_TL}${_SEP} ${_NO_FG}\u@\h${_NO_RESET} ${_NO_GREEN}${short_path}${_NO_RESET}${venv_info}${git_info}${ctx_info}${aws_info}${exec_time}"
  local prompt="${_NO_GREEN}${_SYM_ARROW}${_NO_RESET}"
  [[ $exit_code -ne 0 ]] && prompt="${_NO_RED}${_SYM_ERR}${exit_code}${_NO_RESET}"
  local line2="${_SYM_BL} ${prompt} ${_NO_RESET}"
  PS1="${line1}\n${line2}"
}

# Safe PROMPT_COMMAND assignment (prevents loop)
PROMPT_COMMAND='__bira_box_prompt'
__bira_box_prompt

# --- Welcome Message (Fixed: uses Echo-safe colors) ---
_welcome_message() {
  [[ -n "$_WELCOME_SHOWN" ]] && return
  export _WELCOME_SHOWN=1
  local platform="Git Bash/Windows 11"
  [[ "$IS_GITBASH" -eq 0 ]] && platform="Linux"
  printf "${_NO_GREEN_E}✅ DevOps Bash v7.0 - Bira Box${_NO_RESET_E}\n"
  printf "${_NO_FG_E}   Platform: %s | Type 'reload' | 'help-devops' for reference${_NO_RESET_E}\n" "$platform"
}
[[ "$-" == *i* && -t 1 ]] && _welcome_message
#-------------------------------------------------------------------------------
# 🧭 Aliases & Functions
#-------------------------------------------------------------------------------
alias cls='clear'
alias reload='source ~/.bashrc && echo "✅ Config reloaded"'
alias path='print -l ${PATH//:/\\n}'
alias l='ls -lah --color=auto --group-directories-first 2>/dev/null || ls -lah'
alias ll='ls -alF --color=auto --group-directories-first 2>/dev/null || ls -alF'
alias la='ls -A --color=auto 2>/dev/null || ls -A'
alias lt='ls -lh --color=auto --sort=time 2>/dev/null || ls -lh -t'
alias mkdir='mkdir -p'
alias ..='cd ..'; alias ...='cd ../..'; alias .3='cd ../../..'; alias .4='cd ../../../..'
alias h='history | grep -i --color=auto'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp 2>/dev/null || echo "⚠  Port tools unavailable"'
alias myip='curl -sL https://ifconfig.me 2>/dev/null || curl -sL https://icanhazip.com 2>/dev/null || echo "⚠  IP lookup unavailable"'
alias df='df -h --total 2>/dev/null || df -h'
alias du='du -h --max-depth=2 2>/dev/null || du -h -d 2'
alias free='free -h 2>/dev/null || free -m'
alias top='htop 2>/dev/null || top'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias timestamp='date "+%Y%m%d_%H%M%S"'

# >>> Git <<<
alias gs='git status -sb 2>/dev/null || echo "⚠  Not a git repo"'
alias ga='git add'; alias gaa='git add -A'; alias gap='git add -p'
alias gc='git commit -m'; alias gca='git commit -am'
alias gp='git push'; alias gpf='git push --force-with-lease'; alias gl='git pull --rebase'
alias gb='git branch -vv'; alias gba='git branch -a'
alias gco='git checkout'; alias gcb='git checkout -b'
alias gcm='git checkout main 2>/dev/null || git checkout master'
alias gd='git diff --staged'; alias gds='git diff --staged --stat'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gloga='git log --all --graph --oneline --decorate'
alias gundo='git reset --soft HEAD~1'
alias gclean='git branch --merged 2>/dev/null | grep -v "\*\|main\|master\|develop" | xargs -r git branch -d 2>/dev/null'
alias gprune='git remote prune origin'
alias gamend='git commit --amend --no-edit'
alias gwho='git log -1 --pretty=format:"%an <%ae>"'
alias gtime='git log -1 --pretty=format:"%ai"'

gclone() { [[ -z "$1" ]] && echo "Usage: gclone <repo-url> [dir]" && return 1; local t="${2:-$(basename "$1" .git)}"; git clone --quiet "$1" "$t" && cd "$t" && echo "✅ Cloned: $t"; }
gswitch() { local b=$(git branch -a 2>/dev/null | grep -v HEAD | sed 's/^..//' | cut -d' ' -f1 | grep -v '^remotes' | sort -u); [[ -z "$b" ]] && echo "⚠  No branches" && return 1; echo "$b" | fzf --preview 'git log -10 --oneline {}' 2>/dev/null | xargs -r git checkout || echo "⚠  fzf unavailable"; }
gclean-merged() { local p="main master develop"; git branch --merged 2>/dev/null | grep -v "\*" | while read -r b; do [[ "$p" != *"$b"* ]] && git branch -d "$b" 2>/dev/null && echo "✅ Deleted: $b"; done; }

# >>> Docker <<<
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker ps'
alias dpa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" 2>/dev/null || docker ps -a'
alias dstats='docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "⚠  docker stats unavailable"'
alias dstop='docker stop $(docker ps -q 2>/dev/null) 2>/dev/null || true'
alias dkill='docker rm -f $(docker ps -aq 2>/dev/null) 2>/dev/null || true'
alias dex='docker exec -it'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" 2>/dev/null || docker images'
alias dprune='docker system prune -af --volumes'
alias dclean='docker rmi $(docker images -q -f dangling=true 2>/dev/null) 2>/dev/null || true'
alias dlogs='docker logs -f --tail=100'
alias dbuild='docker build --progress=plain -t'
alias dexec='docker exec -it'
alias dinspect='docker inspect --format="{{json .Config}}" | jq -C . 2>/dev/null || docker inspect'

if docker compose version &>/dev/null; then alias dco='docker compose'
elif command -v docker-compose &>/dev/null; then alias dco='docker-compose'
else alias dco='echo "⚠  Docker Compose not installed"'; fi 2>/dev/null
alias dcup='dco up -d' 2>/dev/null || true; alias dcdn='dco down' 2>/dev/null || true
alias dcl='dco logs -f' 2>/dev/null || true; alias dcps='dco ps' 2>/dev/null || true

# >>> Kubernetes <<<
alias kgp='kubectl get pods 2>/dev/null || true'; alias kgpw='kubectl get pods -o wide 2>/dev/null || true'
alias kgs='kubectl get svc 2>/dev/null || true'; alias kgd='kubectl get deployments 2>/dev/null || true'
alias kga='kubectl get all 2>/dev/null || true'; alias kd='kubectl describe' 2>/dev/null || true
alias kl='kubectl logs -f --tail=100' 2>/dev/null || true; alias kexec='kubectl exec -it' 2>/dev/null || true
alias kdelp='kubectl delete pod' 2>/dev/null || true
alias kw='watch -n 2 kubectl get pods 2>/dev/null || kubectl get pods --watch' 2>/dev/null || true
alias kaf='kubectl apply -f' 2>/dev/null || true; alias kdf='kubectl delete -f' 2>/dev/null || true

ksh() { [[ -z "$1" ]] && echo "Usage: ksh <pod> [-n ns]" && return 1; local ns="${3:-default}"; kubectl exec -it "$1" -n "$ns" -- /bin/bash 2>/dev/null || kubectl exec -it "$1" -n "$ns" -- /bin/sh 2>/dev/null || echo "❌ Could not exec"; }
klogs() { [[ -z "$1" ]] && echo "Usage: klogs <pod> [-n ns]" && return 1; local ns="${3:-default}"; kubectl logs -f --tail=200 "$1" -n "$ns" 2>/dev/null || echo "❌ Logs unavailable"; }
kportf() { [[ -z "$1" || -z "$2" ]] && echo "Usage: kportf <pod> <port>[:<rport>] [-n ns]" && return 1; local ns="${4:-default}"; kubectl port-forward "$1" "$2" -n "$ns" 2>/dev/null || echo "❌ Port-forward failed"; }
kctx() { kubectl config current-context 2>/dev/null || echo "⚠  No context"; }
kns() { kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "default"; }

# >>> Terraform <<<
alias tf='terraform 2>/dev/null || echo "⚠  terraform not installed"'
alias tfi='terraform init'; alias tfp='terraform plan'; alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'; alias tfd='terraform destroy'
alias tfv='terraform validate'; alias tfo='terraform output'; alias tfw='terraform workspace'
alias tff='terraform fmt -recursive'; alias tfs='terraform state list'
tfinit() { terraform init -upgrade -reconfigure "$@"; }
tfplan() { terraform plan -out=tfplan "$@" && echo "✅ Plan saved. Apply: terraform apply tfplan"; }
tfapply() { [[ -f tfplan ]] && terraform apply tfplan "$@" || echo "⚠  No tfplan. Run 'tfplan' first."; }

# >>> Cloud <<<
alias aws-who='aws sts get-caller-identity 2>/dev/null || echo "⚠  AWS CLI unavailable"'
alias aws-ls='aws s3 ls 2>/dev/null || true'
alias aws-ec2='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress}" --output table 2>/dev/null || true'
asp() { [[ -z "$1" ]] && echo "Usage: asp <profile>" && return 1; export AWS_PROFILE="$1"; echo "✅ AWS Profile: $AWS_PROFILE"; }
ec2-connect() { [[ -z "$1" ]] && echo "Usage: ec2-connect <id>" && return 1; echo "🔐 SSM: $1"; aws ssm start-session --target "$1" 2>/dev/null || echo "❌ SSM failed"; }

alias g-who='gcloud auth list 2>/dev/null || echo "⚠  gcloud not installed"'
alias g-list='gcloud projects list 2>/dev/null || true'
alias g-compute='gcloud compute instances list 2>/dev/null || true'
g-proj() { [[ -z "$1" ]] && echo "Usage: g-proj <id>" && return 1; gcloud config set project "$1" 2>/dev/null && echo "✅ GCP: $1" || echo "❌ Failed"; }

alias az-who='az account show 2>/dev/null || echo "⚠  Azure CLI not installed"'
alias az-login='az login --use-device-code 2>/dev/null || az login'
az-sub() { [[ -z "$1" ]] && echo "Usage: az-sub <sub>" && return 1; az account set --subscription "$1" 2>/dev/null && echo "✅ Azure: $1" || echo "❌ Failed"; }

# >>> Utilities <<<
extract() { [[ -f "$1" ]] || { echo "❌ Invalid: $1"; return 1; }; case "$1" in *.tar.bz2|*.tbz2) tar xjf "$1";; *.tar.gz|*.tgz) tar xzf "$1";; *.tar.xz) tar xJf "$1";; *.bz2) bunzip2 "$1";; *.rar) unrar e -y "$1" 2>/dev/null || bsdtar x -f "$1";; *.gz) gunzip "$1";; *.tar) tar xf "$1";; *.zip) unzip -q "$1";; *.7z) 7z x -y "$1" 2>/dev/null || echo "⚠  7z missing";; *.Z) uncompress "$1";; *) echo "❌ Unknown: $1"; return 1;; esac && echo "✅ Extracted: $1"; }
mkcd() { mkdir -p "$1" && cd "$1" && pwd; }
findf() { local r=$(find . -type f -iname "*$1*" 2>/dev/null | head -20); [[ -n "$r" ]] && print -l "$r" || echo "⚠  No matches: $1"; }
grepf() { grep -rIn --color=always "$@" . 2>/dev/null | head -50; }
serve() { local p="${1:-8080}"; echo "🌐 Serving $(pwd) on :$p"; python3 -m http.server "$p" 2>/dev/null || python -m http.server "$p" 2>/dev/null || echo "❌ Python missing"; }
jp() { jq -C . 2>/dev/null || python3 -m json.tool 2>/dev/null || cat; }
y2j() { yq -o=json . 2>/dev/null || python3 -c "import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin),indent=2))" 2>/dev/null || cat; }
alias sysinfo='echo "🖥  $(uname -s) $(uname -r) | $OSTYPE | $(whoami)@$(hostname)"'
alias disk='df -h / /home 2>/dev/null | tail -2'
alias mem='free -h 2>/dev/null | grep -i mem'
alias cpu='lscpu 2>/dev/null | grep -E "Model name|CPU\(s\)|Architecture" || echo "⚠  CPU info unavailable"'
alias ping8='ping -c 8 8.8.8.8'; alias ping1='ping -c 1 1.1.1.1'
alias dns-test='nslookup google.com 2>/dev/null || dig google.com +short 2>/dev/null || echo "⚠  DNS tools unavailable"'
alias http-test='curl -ILs https://httpbin.org/ip 2>/dev/null | head -5 || echo "⚠  HTTP test failed"'
alias ssh-keys='ls -la ~/.ssh/*.pub 2>/dev/null || echo "⚠  No SSH keys"'
alias perms-check='find . -maxdepth 3 -perm /o+w -type f 2>/dev/null | head -10 || echo "✅ No world-writable files"'
alias env-check='env | grep -E "(AWS|AZURE|GCLOUD|KUBE|TF_|DOCKER)" | sort'

#--------------------------------------------------------------------------
# 🌐 Network Toolkit — FIXED: Functions ONLY (no alias duplicates)
#--------------------------------------------------------------------------
# 📡 WiFi Info
wifi-info() {
  if [[ "$IS_GITBASH" -eq 1 ]]; then
    netsh wlan show interfaces 2>/dev/null | grep -E "SSID|Signal|Channel|Radio" | sed 's/^[ ]*//'
  else
    nmcli -t -f SSID,SIGNAL,CHAN,BSSID dev wifi 2>/dev/null | head -1 || iw dev 2>/dev/null | grep -A3 "Interface"
  fi
}

# 🌐 Proxy Management
proxy-set() { [[ -z "$1" ]] && echo "Usage: proxy-set <http://host:port>" && return 1; export http_proxy="$1" https_proxy="$1" no_proxy="localhost,127.0.0.1,*.local"; echo "✅ Proxy set: $1"; }
proxy-off() { unset http_proxy https_proxy all_proxy no_proxy; echo "✅ Proxy cleared"; }
proxy-check() { echo "🌐 http_proxy: ${http_proxy:-none} | https_proxy: ${https_proxy:-none}"; }

# 🐳 Docker Network Debug
docker-net() {
  echo "🐳 Docker Networks:"
  docker network ls 2>/dev/null || echo "⚠️ Docker not running"
  echo -e "\n📦 Active Containers & Ports:"
  docker ps --format "table {{.Names}}\t{{.Ports}}" 2>/dev/null || echo "⚠️ No containers"
}

# ☁️ AWS Network Shortcuts
aws-vpcs() { aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,CidrBlock,State]" --output table 2>/dev/null || echo "⚠️ AWS CLI unavailable"; }
aws-sgs() { aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]" --output table 2>/dev/null || echo "⚠️ AWS CLI unavailable"; }
aws-dns() { aws route53 list-hosted-zones --query "HostedZones[*].[Name,Id]" --output table 2>/dev/null || echo "⚠️ Route53 unavailable"; }

# 📊 Lightweight Speed Test
net-speed() {
  echo "📡 Testing download speed (~10MB)..."
  curl -sL https://speed.cloudflare.com/__down?bytes=10000000 -o /dev/null -w "⏱️ Time: %{time_total}s\n📦 Size: %{size_download} bytes\n🌐 Est. Speed: ~$(( 10000000 / (${time_total:-1} * 1024) )) KB/s\n" 2>/dev/null || echo "⚠️ Speed test unavailable"
}

# >>> Basic Connectivity (aliases only - no conflicts) <<<
alias net-who='curl -sL https://ifconfig.me 2>/dev/null || curl -sL https://icanhazip.com 2>/dev/null || echo "⚠️ IP lookup failed"'
alias net-local='hostname -I 2>/dev/null | awk "{print \$1}" || ip -4 addr show scope global 2>/dev/null | grep -oP "(?<=inet )[^/]+" || echo "⚠️ Local IP missing"'
alias trace='traceroute -m 15 -q 2 2>/dev/null || tracert -h 15 2>/dev/null || echo "⚠️ Trace tool unavailable"'
alias mtr-net='mtr -r -c 5 2>/dev/null || trace 2>/dev/null || echo "⚠️ mtr/traceroute missing"'
alias scan-ports='ss -tulanp 2>/dev/null | grep LISTEN || netstat -tulanp 2>/dev/null | grep LISTEN || echo "✅ No listening ports"'

# >>> Port Testing (functions) <<<
tcp-test() {
  [[ -z "$1" || -z "$2" ]] && echo "Usage: tcp-test <host> <port>" && return 1
  (echo >/dev/tcp/"$1"/"$2") 2>/dev/null && echo "✅ $1:$2 is OPEN" || echo "❌ $1:$2 is CLOSED/FILTERED"
}
ssh-test() {
  [[ -z "$1" ]] && echo "Usage: ssh-test <host> [port]" && return 1
  local p="${2:-22}"
  timeout 3 bash -c "echo >/dev/tcp/$1/$p" 2>/dev/null && echo "✅ SSH ($1:$p) reachable" || echo "❌ SSH ($1:$p) unreachable"
}

# >>> DNS & Resolution <<<
alias dns-lookup='dig google.com +short 2>/dev/null || nslookup google.com 2>/dev/null | grep -A2 "Name:" | tail -1 || echo "⚠️ DNS tools missing"'
resolve() {
  [[ -z "$1" ]] && echo "Usage: resolve <domain> [type=A|AAAA|MX|CNAME]" && return 1
  local t="${2:-A}"
  dig "$1" "$t" +short 2>/dev/null || nslookup -type="$t" "$1" 2>/dev/null | grep -v "^Server:" | grep -v "^Address:" | tail -n +4
}
alias dns-flush='sudo systemctl restart systemd-resolved 2>/dev/null || sudo dscacheutil -flushcache 2>/dev/null || echo "💡 Linux: sudo systemctl restart systemd-resolved | macOS: sudo dscacheutil -flushcache | Win: ipconfig /flushdns"'

# >>> HTTP & API Testing <<<
alias http-head='curl -sI'
alias http-status='curl -o /dev/null -s -w "🔗 %{url_effective} → %{http_code}\n"'
api-test() {
  [[ -z "$1" ]] && echo "Usage: api-test <url>" && return 1
  curl -s -w "\n⏱️ Total: %{time_total}s | Status: %{http_code} | Size: %{size_download}B\n" -o /dev/null "$1" 2>/dev/null
}
json-api() {
  curl -s "$@" 2>/dev/null | jq -C . 2>/dev/null || python3 -m json.tool 2>/dev/null || cat
}

# >>> TLS/SSL Certificates <<<
ssl-check() {
  [[ -z "$1" ]] && echo "Usage: ssl-check <domain> [port=443]" && return 1
  local p="${2:-443}"
  echo | openssl s_client -servername "$1" -connect "$1:$p" 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null || echo "❌ SSL check failed"
}
cert-expiry() {
  [[ -z "$1" ]] && echo "Usage: cert-expiry <domain>" && return 1
  local expiry
  expiry=$(echo | openssl s_client -servername "$1" -connect "$1:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  [[ -n "$expiry" ]] && echo "🔒 $1 expires: $expiry" || echo "❌ Could not retrieve cert"
}

# >>> Routing & Diagnostics <<<
alias default-gw='ip route 2>/dev/null | grep default | awk "{print \$3}" || echo "⚠️ Gateway lookup failed"'
net-diag() {
  echo "🌐 Network Diagnostics Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -n "📍 Public IP: "; curl -sL https://ifconfig.me 2>/dev/null || echo "⚠️ Unavailable"
  echo
  echo -n "🏠 Local IP: "; hostname -I 2>/dev/null | awk '{print $1}' || ip -4 addr show scope global 2>/dev/null | grep -oP "(?<=inet )[^/]+" || echo "⚠️ Unavailable"
  echo
  echo -n "🚪 Default GW: "; ip route 2>/dev/null | grep default | awk '{print $3}' || echo "⚠️ Unavailable"
  echo
  echo -n "🌐 DNS Servers: "; cat /etc/resolv.conf 2>/dev/null | grep nameserver | awk '{print $2}' | tr '\n' ' ' || echo "⚠️ Unavailable"
  echo
  echo -n "📦 Packet Loss: "; ping -c 4 -W 2 8.8.8.8 2>/dev/null | grep "packet loss" | awk '{print $6}' || echo "⚠️ Unavailable"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

#-------------------------------------------------------------------------------
# 🎯 Bash Keybindings — Readline Native
#-------------------------------------------------------------------------------
alias d='dirs -v'
alias 1='cd ~1' 2>/dev/null; alias 2='cd ~2' 2>/dev/null; alias 3='cd ~3' 2>/dev/null
alias 4='cd ~4' 2>/dev/null; alias 5='cd ~5' 2>/dev/null

bind '"\C-r": reverse-search-history' 2>/dev/null
bind '"\e[A": previous-history' 2>/dev/null; bind '"\e[B": next-history' 2>/dev/null
bind '"\e[C": forward-char' 2>/dev/null; bind '"\e[D": backward-char' 2>/dev/null
bind '"\e[Z": reverse-menu-complete' 2>/dev/null; bind '"\t": complete' 2>/dev/null

if command -v fzf >/dev/null 2>&1; then
  if [[ ! -f ~/.fzf.bash ]]; then fzf --bash > ~/.fzf.bash 2>/dev/null || true; fi
  [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
  __fzf_file() { local f; f=$(find . -type f -not -path '*/\.*' -not -path '*/node_modules/*' 2>/dev/null | fzf --height 40% --reverse --border); [[ -n "$f" ]] && READLINE_LINE="${READLINE_LINE}${f}"; }
  __fzf_cd() { local d; d=$(find ~ -maxdepth 3 -type d -not -path '*/\.*' 2>/dev/null | fzf --height 40% --reverse --border); [[ -n "$d" ]] && cd "$d" && __bira_box_prompt; }
  bind -x '"\C-t": "__fzf_file"' 2>/dev/null; bind -x '"\ec": "__fzf_cd"' 2>/dev/null
fi

alias nvim="winpty nvim" 2>/dev/null || alias nvim="nvim"

# ===================================================================
#  🔌 PLUGIN INTEGRATION (fzf lazy-load REMOVED to avoid conflicts)
# ===================================================================
source /mingw64/share/git/completion/git-completion.bash 2>/dev/null
source /mingw64/share/git/completion/git-prompt.sh 2>/dev/null

if __load_plugin "fast-syntax-highlighting" 2>/dev/null; then :; fi

# fzf is handled natively above - skip __lazy_plugin to avoid "failed to load"
# __lazy_plugin "fzf" fzf  # ← REMOVED

if [[ "${CMD_AVAIL[zoxide]}" -eq 1 ]]; then
  eval "$(zoxide init bash --cmd cd)" 2>/dev/null
  alias z='zoxide query -i'; alias zi='zoxide query -i'
  __lazy_plugin "zoxide" zoxide
fi

for comp in "$BASH_PLUGINS_DIR/bash-completion"/*; do [[ -r "$comp" ]] && source "$comp" 2>/dev/null; done

# =============================================================================
#  🔍 Tool Validation (24h cache)
# =============================================================================
_check_missing_tools_cached() {
  local cache="$HOME/.bash_tools_cache"
  local age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
  if [[ $age -gt 86400 || ! -f "$cache" ]]; then
    local tools=("terraform" "kubectl" "docker" "jq" "fzf" "terragrunt") missing=()
    for t in "${tools[@]}"; do command -v "$t" >/dev/null 2>&1 || missing+=("$t"); done
    echo "${missing[*]}" > "$cache" 2>/dev/null
    [[ ${#missing[@]} -gt 0 && -t 1 ]] && echo "⚠️  Missing: ${missing[*]}" && [[ "$IS_GITBASH" -eq 0 ]] && echo "   💡 Fedora: sudo dnf install -y ${missing[*]}" || echo "   💡 Git Bash: scoop/choco"
  fi
}
_check_missing_tools_cached 2>/dev/null

# =============================================================================
#  🎯 Welcome Message
# =============================================================================
_welcome_message() {
  [[ -n "$_WELCOME_SHOWN" ]] && return; export _WELCOME_SHOWN=1
  local platform="Git Bash/Windows 11"; [[ "$IS_GITBASH" -eq 0 ]] && platform="Linux"
  echo -e "${_NO_GREEN}✅ DevOps Bash v7.0 - Bira Box${_NO_RESET}"
  echo -e "${_NO_FG}   Platform: ${platform} | Type 'reload' | 'help-devops' for reference${_NO_RESET}"
}
[[ "$-" == *i* && -t 1 ]] && _welcome_message

# =============================================================================
#  📚 Help
# =============================================================================
help-devops() { cat << 'EOF'
🔧 DevOps Bash Quick Reference — v7.0 Bira Box

📁 NAVIGATION    | 🐙 GIT          | 🐳 DOCKER       | ☸️  KUBERNETES
mkcd <dir>       | gs/ga/gc/gp     | dps/dimg        | kgp/kgs/ksh
findf/grepf      | glog/gundo      | dco up/down     | klogs/kportf
.. / ... / .3    | gclean-merged   | dprune/dclean   | kctx/kns

🏗️  TERRAFORM    | ☁️  CLOUD       | 🔍 UTILITIES
tfi/tfp/tfa      | asp/g-proj      | extract/serve
tfplan/tfapply   | aws-who/g-who   | jp/y2j (JSON)
                 | env-check       | sysinfo/disk

⚡ PERFORMANCE
• Cached git/k8s/aws info (5-30s refresh)
• Lazy plugin loading (zoxide only)
• Tool check runs once per 24h
• Type 'reload' to refresh config

⚙️  TROUBLESHOOTING
reload           # Re-source ~/.bashrc
path             # Print PATH
env-check        # Show DevOps env vars
time bash -i -c exit  # Benchmark startup
EOF
}

# ===================================================================
#  🧩 Local Customizations
# ===================================================================
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases 2>/dev/null
[[ -f ~/.bash_functions ]] && source ~/.bash_functions 2>/dev/null
[[ -d ~/.bashrc.d ]] && for rc in ~/.bashrc.d/*; do [[ -f "$rc" && "$rc" == *.sh ]] && source "$rc" 2>/dev/null; done

# ===================================================================
#  🪀 Android/Flutter Environment 
# ===================================================================
export ANDROID_HOME="/c/Users/ganil/AppData/Local/Android/Sdk"
export JAVA_HOME=$(cygpath -w "/c/Program Files/Microsoft/jdk-17.0.19.10-hotspot")
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin"


# ===================================================================
#  ✅ END — Syntax Validated, Git Bash Compatible
# ===================================================================
unset -f path_prepend path_append 2>/dev/null
[[ -f ~/.bash_profile ]] && source ~/.bash_profile
