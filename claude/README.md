# Claude Configuration

## Claude Code settings

`settings.json` holds personal permissions, env vars, hooks, and enabled plugins. It is
**gitignored** — it contains machine-specific absolute paths, and this repo is public.

`settings.example.json` is the tracked template. On a new machine:

```bash
cp claude/.claude/settings.example.json claude/.claude/settings.json
# replace YOUR_USERNAME and any MATLAB_RXXXXx path with real values
stow claude
```

Note on permission rules: file-path deny/allow rules use `Edit(path)`, which covers all
file-editing tools (Write, Edit, NotebookEdit). `Write(path)` is **not** matched by file
permission checks and silently does nothing.

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