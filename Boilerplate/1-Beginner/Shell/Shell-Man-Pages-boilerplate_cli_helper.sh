#!/bin/bash

# boilerplate_cli_helper.sh - Self-documenting automation script
# DevOps Context: Team script documentation

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

A production-grade CLI tool demonstrating best practices.

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -e, --env ENV       Environment (dev/staging/prod)
    -d, --deploy        Execute deployment

EXAMPLES:
    Deploy to production:
        $ $(basename "$0") --env prod --deploy

    Verbose dry-run:
        $ $(basename "$0") --env staging --verbose

AUTHOR:
    DevOps Team

EOF
}

[ "$1" == "-h" ] && show_help && exit 0
echo "Run with -h for help"
