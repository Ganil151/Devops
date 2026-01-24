import asyncio
from mcp.server import Server
from mcp.types import Tool, TextContent, ImageContent

# --- MCP SERVER BOILERPLATE ---
# A standardized template for building agentic tool servers.

app = Server("devops-assistant-tool")

@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available tools for the AI agent."""
    return [
        Tool(
            name="get_system_load",
            description="Returns CPU and Memory load of the target server.",
            input_schema={
                "type": "object",
                "properties": {
                    "host": {"type": "string"}
                },
                "required": ["host"]
            }
        ),
        Tool(
            name="check_service_status",
            description="Checks if a systemd service is active.",
            input_schema={
                "type": "object",
                "properties": {
                    "service_name": {"type": "string"}
                }
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    """Execute a tool called by the agent."""
    if name == "get_system_load":
        # Simulate logic
        return [TextContent(type="text", text="CPU: 12%, MEM: 450MB")]
    
    elif name == "check_service_status":
        service = arguments.get("service_name", "unknown")
        return [TextContent(type="text", text=f"Service '{service}' is ACTIVE")]

async def main():
    # Run the server via standard I/O (Compatible with Claude Desktop, etc)
    from mcp.server.stdio import stdio_server
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
