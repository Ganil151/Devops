#===============================================================================
# ~/.zshrc - DevOps Power User Configuration (Zinit Edition)
# ✅ Clean, fast, no plugin manager conflicts
#===============================================================================

#-------------------------------------------------------------------------------
# ⚡ Instant Prompt (Powerlevel10k) - MUST BE FIRST
#-------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#-------------------------------------------------------------------------------
# 📦 Zinit Loader
#-------------------------------------------------------------------------------
source "${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git/zinit.zsh}"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#-------------------------------------------------------------------------------
# ⚙️ Zsh Core Options & Performance
#-------------------------------------------------------------------------------
setopt EXTENDED_GLOB
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS AUTO_CD INTERACTIVE_COMMENTS
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS INC_APPEND_HISTORY CORRECT CORRECT_ALL

# History config
HISTFILE="${ZSH_HISTFILE:-${HOME}/.zsh_history}"
HISTSIZE=10000
SAVEHIST=10000

# Completion system (cached for speed)
autoload -Uz compinit
if [[ ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:corrections' format '[%d]'
zstyle ':completion:*:warnings' format '[No matches for: %d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

#-------------------------------------------------------------------------------
# 🔌 Plugins via Zinit (lazy-loaded for speed)
#-------------------------------------------------------------------------------
# Syntax highlighting (load immediately)
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions (lazy-load after 0.1s)
zinit ice wait'0.1' lucid
zinit light zsh-users/zsh-autosuggestions

# fzf-tab for interactive completions
zinit ice wait'1' lucid
zinit light Aloxaf/fzf-tab

# Powerlevel10k prompt (lazy-load)
zinit ice wait'1' lucid
zinit light romkatv/powerlevel10k

# Optional: history substring search (if you prefer arrow-key history)
# zinit ice wait'0.2' lucid
# zinit light zsh-users/zsh-history-substring-search

#-------------------------------------------------------------------------------
# 🎨 Prompt Finalization (P10k)
#-------------------------------------------------------------------------------
# Source P10k theme AFTER plugins load
if [[ -f "${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git}/plugins/romkatv---powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git}/plugins/romkatv---powerlevel10k/powerlevel10k.zsh-theme"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#-------------------------------------------------------------------------------
# 🧭 Aliases & Functions (Your DevOps Toolkit)
#-------------------------------------------------------------------------------
# >>> System & Navigation <<<
alias cls='clear'
alias reload='source ~/.zshrc && echo "✅ Config reloaded"'
alias path='print -l ${PATH//:/\\n}'
alias l='ls -lah --color=auto --group-directories-first 2>/dev/null || ls -lah'
alias ll='ls -alF --color=auto --group-directories-first 2>/dev/null || ls -alF'
alias la='ls -A --color=auto 2>/dev/null || ls -A'
alias lt='ls -lh --color=auto --sort=time 2>/dev/null || ls -lh -t'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias h='history | grep -i --color=auto'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp 2>/dev/null || echo "⚠  Port tools unavailable"'
alias myip='curl -sL https://ifconfig.me 2>/dev/null || curl -sL https://icanhazip.com 2>/dev/null || echo "⚠  IP lookup unavailable"'
alias df='df -h --total 2>/dev/null || df -h'
alias du='du -h --max-depth=2 2>/dev/null || du -h -d 2'
alias free='free -h 2>/dev/null || free -m'
alias top='htop 2>/dev/null || top'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias timestamp='date "+%Y%m%d_%H%M%S"'

# >>> Git Mastery <<<
alias gs='git status -sb 2>/dev/null || echo "⚠  Not a git repo"'
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
alias gclean='git branch --merged 2>/dev/null | grep -v "\*\|main\|master\|develop" | xargs -r git branch -d 2>/dev/null'
alias gprune='git remote prune origin'
alias gamend='git commit --amend --no-edit'
alias gwho='git log -1 --pretty=format:"%an <%ae>"'
alias gtime='git log -1 --pretty=format:"%ai"'

gclone() {
  [[ -z "$1" ]] && echo "Usage: gclone <repo-url> [directory]" && return 1
  local target="${2:-$(basename "$1" .git)}"
  git clone --quiet "$1" "$target" && cd "$target" && echo "✅ Cloned: $target"
}

gswitch() {
  local branch
  branch=$(git branch -a 2>/dev/null | grep -v HEAD | sed 's/^..//' | cut -d' ' -f1 | grep -v '^remotes' | sort -u)
  [[ -z "$branch" ]] && echo "⚠  No branches found" && return 1
  echo "$branch" | fzf --preview 'git log -10 --oneline {}' 2>/dev/null | xargs -r git checkout || echo "⚠  fzf unavailable or cancelled"
}

gclean-merged() {
  local protected="main master develop"
  git branch --merged 2>/dev/null | grep -v "\*" | while read -r b; do
    [[ "$protected" != *"$b"* ]] && git branch -d "$b" 2>/dev/null && echo "✅ Deleted: $b"
  done
}

# >>> Docker & Compose <<<
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

# Docker Compose detection
if docker compose version &>/dev/null; then
  alias dco='docker compose'
elif command -v docker-compose &>/dev/null; then
  alias dco='docker-compose'
else
  alias dco='echo "⚠  Docker Compose not installed"'
fi 2>/dev/null

alias dcup='dco up -d' 2>/dev/null || true
alias dcdn='dco down' 2>/dev/null || true
alias dcl='dco logs -f' 2>/dev/null || true
alias dcps='dco ps' 2>/dev/null || true

# >>> Kubernetes <<<
alias kgp='kubectl get pods 2>/dev/null || true'
alias kgpw='kubectl get pods -o wide 2>/dev/null || true'
alias kgs='kubectl get svc 2>/dev/null || true'
alias kgd='kubectl get deployments 2>/dev/null || true'
alias kga='kubectl get all 2>/dev/null || true'
alias kd='kubectl describe' 2>/dev/null || true
alias kl='kubectl logs -f --tail=100' 2>/dev/null || true
alias kexec='kubectl exec -it' 2>/dev/null || true
alias kdelp='kubectl delete pod' 2>/dev/null || true
alias kw='watch -n 2 kubectl get pods 2>/dev/null || kubectl get pods --watch' 2>/dev/null || true
alias kaf='kubectl apply -f' 2>/dev/null || true
alias kdf='kubectl delete -f' 2>/dev/null || true

ksh() {
  [[ -z "$1" ]] && echo "Usage: ksh <pod-name> [-n namespace]" && return 1
  local ns="${3:-default}"
  kubectl exec -it "$1" -n "$ns" -- /bin/bash 2>/dev/null || \
  kubectl exec -it "$1" -n "$ns" -- /bin/sh 2>/dev/null || \
  echo "❌ Could not exec into $1 (try /bin/sh)"
}

klogs() {
  [[ -z "$1" ]] && echo "Usage: klogs <pod-name> [-n namespace]" && return 1
  local ns="${3:-default}"
  kubectl logs -f --tail=200 "$1" -n "$ns" 2>/dev/null || echo "❌ Logs unavailable"
}

kportf() {
  [[ -z "$1" || -z "$2" ]] && echo "Usage: kportf <pod> <local-port>[:<remote-port>] [-n namespace]" && return 1
  local ns="${4:-default}"
  kubectl port-forward "$1" "$2" -n "$ns" 2>/dev/null || echo "❌ Port-forward failed"
}

kctx() { kubectl config current-context 2>/dev/null || echo "⚠  No context set"; }
kns() { kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "default"; }

# >>> Terraform <<<
alias tf='terraform 2>/dev/null || echo "⚠  terraform not installed"'
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

tfinit() { terraform init -upgrade -reconfigure "$@"; }

tfplan() {
  terraform plan -out=tfplan "$@" && echo "✅ Plan saved to tfplan. Apply with: terraform apply tfplan"
}

tfapply() {
  [[ -f tfplan ]] && terraform apply tfplan "$@" || echo "⚠  No tfplan file. Run 'tfplan' first."
}

# >>> Cloud Platforms (AWS/GCP/Azure) <<<
alias aws-who='aws sts get-caller-identity 2>/dev/null || echo "⚠  AWS CLI unavailable"'
alias aws-ls='aws s3 ls 2>/dev/null || true'
alias aws-logs='aws logs tail --follow 2>/dev/null || true'
alias aws-ec2='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress}" --output table 2>/dev/null || true'

asp() {
  [[ -z "$1" ]] && echo "Usage: asp <profile-name>" && return 1
  export AWS_PROFILE="$1"
  echo "✅ AWS Profile: $AWS_PROFILE"
}

ec2-connect() {
  [[ -z "$1" ]] && echo "Usage: ec2-connect <instance-id>" && return 1
  echo "🔐 Starting SSM Session for $1..."
  aws ssm start-session --target "$1" 2>/dev/null || echo "❌ SSM failed (check permissions/region)"
}

alias g-who='gcloud auth list 2>/dev/null || echo "⚠  gcloud not installed"'
alias g-list='gcloud projects list 2>/dev/null || true'
alias g-compute='gcloud compute instances list 2>/dev/null || true'
alias g-ssh='gcloud compute ssh 2>/dev/null || echo "Usage: g-ssh <instance-name>"'

g-proj() {
  [[ -z "$1" ]] && echo "Usage: g-proj <project-id>" && return 1
  gcloud config set project "$1" 2>/dev/null && echo "✅ GCP Project: $1" || echo "❌ Failed to set project"
}

g-zone() {
  [[ -z "$1" ]] && echo "Usage: g-zone <zone>" && return 1
  gcloud config set compute/zone "$1" 2>/dev/null && echo "✅ GCP Zone: $1" || echo "❌ Failed to set zone"
}

alias az-who='az account show 2>/dev/null || echo "⚠  Azure CLI not installed"'
alias az-login='az login --use-device-code 2>/dev/null || az login'
alias az-list='az account list --output table 2>/dev/null || true'
alias az-vm='az vm list --output table 2>/dev/null || true'

az-sub() {
  [[ -z "$1" ]] && echo "Usage: az-sub <subscription-name-or-id>" && return 1
  az account set --subscription "$1" 2>/dev/null && echo "✅ Azure Subscription: $1" || echo "❌ Failed to set subscription"
}

# >>> Utilities <<<
extract() {
  [[ -f "$1" ]] || { echo "❌ '$1' is not a valid file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.rar)            unrar e -y "$1" 2>/dev/null || bsdtar x -f "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip -q "$1" ;;
    *.7z)             7z x -y "$1" 2>/dev/null || echo "⚠  7z not installed" ;;
    *.Z)              uncompress "$1" ;;
    *)                echo "❌ Unknown format: $1"; return 1 ;;
  esac && echo "✅ Extracted: $1"
}

mkcd() { mkdir -p "$1" && cd "$1" && pwd; }

findf() { 
  local results
  results=$(find . -type f -iname "*$1*" 2>/dev/null | head -20)
  [[ -n "$results" ]] && print -l "$results" || echo "⚠  No matches for: $1"
}

grepf() { grep -rIn --color=always "$@" . 2>/dev/null | head -50; }

serve() {
  local port="${1:-8080}"
  echo "🌐 Serving $(pwd) on http://localhost:${port}"
  python3 -m http.server "$port" 2>/dev/null || python -m http.server "$port" 2>/dev/null || echo "❌ Python not available"
}

jp() { jq -C . 2>/dev/null || python3 -m json.tool 2>/dev/null || cat; }
y2j() { yq -o=json . 2>/dev/null || python3 -c "import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin),indent=2))" 2>/dev/null || cat; }

alias sysinfo='echo "🖥  $(uname -s) $(uname -r) | 🐧 $OSTYPE | 👤 $(whoami)@$(hostname)"'
alias disk='df -h / /home 2>/dev/null | tail -2'
alias mem='free -h 2>/dev/null | grep -i mem'
alias cpu='lscpu 2>/dev/null | grep -E "Model name|CPU\(s\)|Architecture" || echo "⚠  CPU info unavailable"'

alias ping8='ping -c 8 8.8.8.8'
alias ping1='ping -c 1 1.1.1.1'
alias dns-test='nslookup google.com 2>/dev/null || dig google.com +short 2>/dev/null || echo "⚠  DNS tools unavailable"'
alias http-test='curl -ILs https://httpbin.org/ip 2>/dev/null | head -5 || echo "⚠  HTTP test failed"'

alias ssh-keys='ls -la ~/.ssh/*.pub 2>/dev/null || echo "⚠  No SSH keys found"'
alias perms-check='find . -maxdepth 3 -perm /o+w -type f 2>/dev/null | head -10 || echo "✅ No world-writable files in current tree"'
alias env-check='env | grep -E "(AWS|AZURE|GCLOUD|KUBE|TF_|DOCKER)" | sort'

#-------------------------------------------------------------------------------
# 🎯 Zsh Enhancements & Keybindings
#-------------------------------------------------------------------------------
# Directory stack navigation
alias d='dirs -v'
alias 1='cd ~1'
alias 2='cd ~2'
alias 3='cd ~3'
alias 4='cd ~4'
alias 5='cd ~5'

# FZF integration (if installed)
if command -v fzf >/dev/null 2>&1; then
  # Source fzf.zsh FIRST to enable widgets
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  
  # Keybindings (only if widgets exist)
  bindkey '^R' fzf-history-widget 2>/dev/null || bindkey '^R' history-incremental-search-backward
  bindkey '^T' fzf-file-widget 2>/dev/null
  bindkey '^[c' fzf-cd-widget 2>/dev/null
else
  # Fallback keybindings
  bindkey '^[[A' up-history
  bindkey '^[[B' down-history
  bindkey '^R' history-incremental-search-backward
fi

# Reverse Tab for completion menu
bindkey '^[[Z' reverse-menu-complete

#-------------------------------------------------------------------------------
# 🔁 Native Completions for DevOps Tools (Zsh-native, not plugins)
#-------------------------------------------------------------------------------
# Kubernetes
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh) 2>/dev/null || true
  compdef __start_kubectl=k 2>/dev/null || true
fi

# Helm
if command -v helm >/dev/null 2>&1; then
  source <(helm completion zsh) 2>/dev/null || true
fi

# Docker (Zsh has native completions in most distros)
if command -v docker >/dev/null 2>&1; then
  autoload -Uz +X _docker 2>/dev/null && compdef _docker docker 2>/dev/null || true
fi

# Terraform (modern completion method)
if command -v terraform >/dev/null 2>&1; then
  source <(terraform completion zsh) 2>/dev/null || true
fi

# AWS CLI v2 (bashcompinit fallback for zsh)
if command -v aws >/dev/null 2>&1; then
  autoload -Uz +X bashcompinit && bashcompinit 2>/dev/null
  complete -C aws aws 2>/dev/null || true
fi

#-------------------------------------------------------------------------------
# 🌐 Fedora Networking Aliases (Preserved)
#-------------------------------------------------------------------------------
# NetworkManager
alias nm='nmcli'
alias nms='nmcli general status'
alias nmc='nmcli connection show'
alias nmca='nmcli connection show --active'
alias nmd='nmcli device status'
alias nmda='nmcli device show'
alias nmr='nmcli radio all'
alias nmw='nmcli radio wifi'
alias nmup='nmcli connection up'
alias nmdown='nmcli connection down'
alias nmre='nmcli connection reload'
alias nmcon='nmcli connection edit'
alias wifiscan='nmcli device wifi list'
alias wificon='nmcli device wifi connect'
alias wifipsw='nmcli -s -g 802-11-wireless-security.psk connection show'

# IP & Routing
alias ipa='ip -c a'
alias ipaddr='ip -br -c a'
alias ipr='ip -c r'
alias iproute='ip -br -c r'
alias ipn='ip -c n'
alias ipneigh='ip -br -c n'
alias ipl='ip -s -c l'
alias ipdev='ip -br -c l'
alias ipup='sudo ip link set'
alias ipdown='sudo ip link set dev'
alias ipflush='sudo ip addr flush dev'

# Sockets & Firewall
alias ss='ss -tulanp --no-pager'
alias sst='ss -tan'
alias ssu='ss -uan'
alias ssl='ss -tln'
alias ssul='ss -uln'
alias ssest='ss -tan state established'
alias sstime='ss -tan -o'
alias fw='sudo firewall-cmd'
alias fws='sudo firewall-cmd --state'
alias fwz='sudo firewall-cmd --get-zone'
alias fwzs='sudo firewall-cmd --get-zones'
alias fwl='sudo firewall-cmd --list-all'
alias fwls='sudo firewall-cmd --list-services'
alias fwlp='sudo firewall-cmd --list-ports'
alias fwr='sudo firewall-cmd --runtime-to-permanent'
alias fwreload='sudo firewall-cmd --reload'

fw-add-port() { sudo firewall-cmd --permanent --add-port="$1" && sudo firewall-cmd --reload && echo "✅ Port $1 opened"; }
fw-remove-port() { sudo firewall-cmd --permanent --remove-port="$1" && sudo firewall-cmd --reload && echo "✅ Port $1 closed"; }
fw-add-service() { sudo firewall-cmd --permanent --add-service="$1" && sudo firewall-cmd --reload && echo "✅ Service $1 enabled"; }

# DNS & Troubleshooting
alias dns-resolv='cat /etc/resolv.conf'
alias dns-flush='sudo resolvectl flush-caches 2>/dev/null || sudo systemd-resolve --flush-caches 2>/dev/null || echo "⚠  DNS flush not available"'
alias dns-status='resolvectl status 2>/dev/null || systemd-resolve --status 2>/dev/null || cat /etc/resolv.conf'
alias ping-fast='ping -c 4 -W 2'
alias ping-gw='ping -c 4 $(ip route | grep default | awk "{print \$3}" | head -1) 2>/dev/null || echo "⚠  No default gateway"'
alias ping-dns='ping -c 4 8.8.8.8'
alias ping-cf='ping -c 4 1.1.1.1'
alias mtr-test='mtr -rwc 10 google.com 2>/dev/null || traceroute google.com 2>/dev/null || echo "⚠  Path tools unavailable"'
alias latency='ping -c 20 -i 0.2 google.com | tail -1'

# Podman (Fedora default)
alias podnet='podman network'
alias podnet-ls='podman network ls'
alias podnet-inspect='podman network inspect'
alias podport='podman port'
alias podlogs-net='podman logs --follow --tail=100'
alias pod-ip='podman inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $(podman ps -q | head -1) 2>/dev/null || echo "⚠  No running containers"'

# Network summary
alias net-info='echo "🖧 Host: $(hostname) | 🌐 IP: $(myip-local) | 🌍 Public: $(myip-public 2>/dev/null | head -c 15) | 🔥 FW: $(sudo firewall-cmd --state 2>/dev/null || echo "unknown")"'
alias net-interfaces='ip -br link show | grep -v lo'
alias net-routes='ip route show table all | grep -v "cache\|broadcast"'
alias net-listeners='ss -tlnp | grep LISTEN'
alias net-connections='ss -tan state established | wc -l | xargs echo "🔗 Active connections:"'
alias net-summary='echo "=== NETWORK SUMMARY ===" && net-info && echo && echo "📡 Interfaces:" && net-interfaces && echo && echo "🔌 Listening:" && net-listeners | head -10'

#-------------------------------------------------------------------------------
# 🧩 Local Overrides (gitignored)
#-------------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

#===============================================================================
# ✅ DONE: Clean Zinit-only config, no Oh My Zsh conflicts
# 🔧 To update plugins: run `zinit update`
# 🐌 Slow startup? Run `zinit report` to find bottlenecks
#===============================================================================