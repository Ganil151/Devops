# ==========================================
#         General System & Navigation
# ==========================================
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'          
alias reload='source ~/.zshrc'                  
alias mkdir='mkdir -p' 
alias l='ls -lah --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../../'
alias h='history | grep'              # Fast history search: h docker
alias ports='netstat -tulanp'         # List open ports
alias myip='curl -s https://ifconfig.me; echo'

# ==========================================
#             Docker & Container Ops
# ==========================================
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpa='docker ps -a'
alias dstop='docker stop $(docker ps -q)'
alias dkill='docker rm -f $(docker ps -aq)'
alias dex='docker exec -it'
alias dimg='docker images'
alias dprune='docker system prune -af --volumes'

# Docker Compose
alias dco='docker-compose'
alias dcup='docker-compose up -d'
alias dcdn='docker-compose down'
alias dcl='docker-compose logs -f'

# Deep Dive: Remove all untagged images
alias dclean='docker rmi $(docker images -q -f dangling=true)'

# ==========================================
#            Kubernetes Power-User
# ==========================================
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kgpw='kubectl get pods -o wide'
alias kdelp='kubectl delete pod'
alias kctx='kubectx'
alias kns='kubens'

# Deep Dive: Get shell on a pod immediately (Usage: ksh pod-name)
ksh() { kubectl exec -it "$1" -- /bin/bash || kubectl exec -it "$1" -- /bin/sh; }

# Deep Dive: Watch pods in real-time
alias kw='watch kubectl get pods'

# ==========================================
#            Terraform & IaC
# ==========================================
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfa-auto='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfw='terraform workspace'

# ==========================================
#               Git Mastery
# ==========================================
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff --staged'
alias gcm='git checkout main || git checkout master'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Deep Dive: Undo last commit but keep changes
alias gundo='git reset --soft HEAD~1'

# ==========================================
#               AWS Deep Dive
# ==========================================
alias aws-who='aws sts get-caller-identity'
alias aws-ls='aws s3 ls'

# Switch AWS Profile easily (Usage: asp my-profile)
asp() { export AWS_PROFILE=$1; echo "AWS Profile set to: $AWS_PROFILE"; }

# Advanced EC2 List: Shows Name, ID, Instance Type, and Public IP
alias aws-ec2='aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,ID:InstanceId,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress}" --output table'

# Get CloudWatch Logs for a group (Usage: aws-logs /my/log/group)
alias aws-logs='aws logs tail --follow'

# ==========================================
#               GCP Deep Dive
# ==========================================
alias g-who='gcloud auth list'
alias g-list='gcloud projects list'
alias g-compute='gcloud compute instances list'
alias g-ssh='gcloud compute ssh'

# Switch Project (Usage: g-proj my-project-id)
g-proj() { gcloud config set project "$1"; }

# Set Region/Zone (Usage: g-zone us-central1-a)
g-zone() { gcloud config set compute/zone "$1"; }

# ==========================================
#               Azure Deep Dive
# ==========================================
alias az-who='az account show'
alias az-list='az account list --output table'
alias az-vm='az vm list --output table'
alias az-rg='az group list --output table'
alias az-login='az login'

# Switch Subscription (Usage: az-sub "Subscription Name")
az-sub() { az account set --subscription "$1"; echo "Switched to Azure Sub: $1"; }

# List all Azure Resources in a specific Group
az-res() { az resource list --resource-group "$1" --output table; }