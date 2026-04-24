# --- 1. NAVIGATION & CORE OPS ---
# mkcd: Create a directory and enter it immediately
mkcd() {
    mkdir -p "$1" && cd "$1"
}

alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -alFh'      # Long format, human-readable sizes
alias la='ls -A'         # All files, including hidden
alias l='ls -CF'
alias grep='grep --color=auto'

# --- 2. ENHANCED GIT WORKFLOW ---
alias gs='git status'
alias ga='git add .'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'  # Quick fix for the last commit
alias gp='git push'
alias gpl='git pull'
alias glog='git log --oneline --graph --decorate' # Visual history
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'    # Create and switch to new branch
alias gpom='git push origin main'

# --- 3. DOCKER SHORTCUTS ---
alias d='docker'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dlogs='docker logs -f'   # Follow logs
# Cleanup: Remove all stopped containers and unused images
alias dclean='docker system prune -f'

# --- 4. KUBERNETES (K8S) COMMANDS ---
# Note: Ensure 'kubectl' is installed
if command -v kubectl &> /dev/null; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get svc'
    alias kgd='kubectl get deployments'
    alias kdel='kubectl delete'
    alias kdesc='kubectl describe'
    alias klogs='kubectl logs -f'
    # Quickly switch contexts/namespaces (if kubectx/kubens are installed)
    alias kns='kubens'
    alias kctx='kubectx'
fi

# --- 5. UNIVERSAL EXTRACTOR (Fixed & Optimized) ---
extract () {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xvjf "$1"    ;;
            *.tar.gz)    tar xvzf "$1"    ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xvf "$1"     ;;
            *.tbz2)      tar xvjf "$1"    ;;
            *.tgz)       tar xvzf "$1"    ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;; # Added 7-zip support
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# --- 6. SYSTEM MONITORING & NETWORKING ---
alias path='echo -e ${PATH//:/\\n}'  # Print PATH in a readable list
alias myip='curl ifconfig.me'        # Get public IP quickly
alias top='htop'                     # Use htop if available
alias ports='netstat -tulanp'        # List all open ports

# --- 7. SAFETY NETS ---
alias rm='rm -i'  # Confirmation before deleting
alias cp='cp -i'  # Confirmation before overwriting
alias mv='mv -i'  # Confirmation before moving
