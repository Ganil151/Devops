# Docker Commands Reference

Quick reference guides and cheat sheets for Docker commands and operations.

## Available References

### [Docker Commands Reference](./docker-commands-reference.md)
Comprehensive command reference covering:
- **Container Operations**: Run, stop, start, remove containers
- **Image Management**: Build, pull, push, remove images
- **Network Management**: Create, connect, inspect networks
- **Volume Management**: Create, mount, manage volumes
- **Docker Compose**: Multi-container application commands
- **System Management**: Cleanup, monitoring, diagnostics
- **Troubleshooting**: Common issues and solutions

## Quick Command Categories

### Essential Daily Commands
```bash
# Container lifecycle
docker run <image>                 # Create and start container
docker ps                         # List running containers
docker stop <container>           # Stop container
docker rm <container>             # Remove container

# Image management
docker images                     # List images
docker pull <image>               # Download image
docker build -t <name> .          # Build image
docker rmi <image>                # Remove image

# Logs and debugging
docker logs <container>           # View container logs
docker exec -it <container> bash  # Access container shell
```

### Docker Compose Essentials
```bash
docker-compose up -d              # Start services in background
docker-compose down               # Stop and remove services
docker-compose logs -f            # Follow service logs
docker-compose ps                 # List services
```

### System Maintenance
```bash
docker system df                  # Show disk usage
docker system prune               # Clean up unused resources
docker container prune            # Remove stopped containers
docker image prune                # Remove unused images
```

## Command Patterns

### Container Operations Pattern
```bash
# Standard workflow
docker run [OPTIONS] IMAGE [COMMAND]
docker exec [OPTIONS] CONTAINER COMMAND
docker logs [OPTIONS] CONTAINER
docker stop CONTAINER
docker rm CONTAINER
```

### Image Operations Pattern
```bash
# Standard workflow
docker build [OPTIONS] PATH
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker push [OPTIONS] NAME[:TAG]
docker pull [OPTIONS] NAME[:TAG]
```

### Network Operations Pattern
```bash
# Standard workflow
docker network create [OPTIONS] NETWORK
docker network connect [OPTIONS] NETWORK CONTAINER
docker network inspect [OPTIONS] NETWORK [NETWORK...]
docker network disconnect [OPTIONS] NETWORK CONTAINER
```

## Useful Aliases

Add these to your shell profile (`.bashrc`, `.zshrc`):

```bash
# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlog='docker logs -f'
alias dexec='docker exec -it'
alias dclean='docker system prune -f'

# Docker Compose aliases
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclog='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcbuild='docker-compose build'
```

## Command Completion

### Bash Completion
```bash
# Install bash completion (Ubuntu/Debian)
sudo apt-get install bash-completion

# Add to ~/.bashrc
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
```

### Zsh Completion
```bash
# Add to ~/.zshrc
autoload -U compinit && compinit
```

## Environment Variables

### Common Docker Environment Variables
```bash
export DOCKER_HOST=unix:///var/run/docker.sock
export DOCKER_API_VERSION=1.41
export COMPOSE_PROJECT_NAME=myproject
export COMPOSE_FILE=docker-compose.yml
```

## Tips and Tricks

### Formatting Output
```bash
# Custom format for docker ps
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# JSON output with jq
docker inspect container_name | jq '.[0].NetworkSettings.IPAddress'

# Get container IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name
```

### Bulk Operations
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Remove dangling images
docker image prune -f
```

### Monitoring Commands
```bash
# Real-time container stats
docker stats

# System events
docker events

# Disk usage
docker system df -v
```

For detailed command explanations and examples, see the [Docker Commands Reference](./docker-commands-reference.md).