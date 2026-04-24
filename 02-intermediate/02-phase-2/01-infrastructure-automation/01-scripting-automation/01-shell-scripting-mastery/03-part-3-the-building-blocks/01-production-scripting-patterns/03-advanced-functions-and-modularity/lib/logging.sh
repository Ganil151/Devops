#!/usr/bin/env bash
# Author: Ganil
# Library: Advanced Logging Framework

log_info() {
    local message="$1"
    echo -e "\e[32m[INFO]\e[0m $(date +'%Y-%m-%d %H:%M:%S') - $message"
}

log_error() {
    local message="$1"
    echo -e "\e[31m[ERROR]\e[0m $(date +'%Y-%m-%d %H:%M:%S') - $message" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "\e[34m[DEBUG]\e[0m $(date +'%Y-%m-%d %H:%M:%S') - $message"
    fi
}
