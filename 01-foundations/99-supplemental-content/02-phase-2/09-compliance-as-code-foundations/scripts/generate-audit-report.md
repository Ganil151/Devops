# Audit Report

**Date**: 2026-01-25
**Scope**: Production Servers

## Executive Summary
This report summarizes the compliance findings.

## Findings

| Resource | Status | Detail |
|----------|--------|--------|
| /etc/ssh/sshd_config | PASS | Permissions 600 |
| SSH Root Login | FAIL | Enabled (Should be disabled) |
| Firewall | PASS | Active |

## Recommendations
1. Disable Root Login immediately.
2. Review remaining warnings.
