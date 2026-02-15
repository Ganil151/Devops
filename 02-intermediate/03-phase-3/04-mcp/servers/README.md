# 🔌 MCP Servers Directory

This directory contains the implementations of various MCP servers. 

## 📂 Subdirectories
- `/python-example`: A reference implementation using the Python `fastmcp` SDK.
- `/typescript-example`: A reference implementation using the `@modelcontextprotocol/sdk`.

## 🚀 How to add a new server
1. Create a new subfolder (e.g., `git-helper`).
2. Initialize your project (e.g., `npm init` or `poetry init`).
3. Implement the MCP server following the patterns in the `MASTER_MCP_REFERENCE.md`.
4. Update your host configuration (Claude/Cursor) to point to the entry point.
