# Claude Desktop Configuration

## Zotero MCP Server Setup

To enable Zotero integration in Claude Desktop:

1. Install zotero-mcp:
   ```bash
   uv tool install "git+https://github.com/54yyyu/zotero-mcp.git"
   ```

2. Configure Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`):
   ```json
   {
     "mcpServers": {
       "zotero": {
         "command": "/Users/nicolasreigl/.local/bin/zotero-mcp",
         "env": {
           "ZOTERO_LOCAL": "true"
         }
       }
     }
   }
   ```

3. Ensure Zotero Desktop is running
4. Restart Claude Desktop

## Requirements
- Zotero Desktop application
- UV package manager
- Claude Desktop app