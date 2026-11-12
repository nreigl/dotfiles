# Claude Configuration

## Claude Code settings

`~/.claude/settings.json` holds personal permissions, env vars, hooks, and enabled
plugins. It is a real file, not a stow link, and it is not in this repo. It contains
machine-specific absolute paths, and this repo is public. Claude Code saves settings by
writing a new file, so a link at that path breaks at the next save.

`settings.example.json` is the tracked template. On a new machine:

```bash
cp claude/.claude/settings.example.json ~/.claude/settings.json
# replace YOUR_USERNAME and any MATLAB_RXXXXx path with real values
stow claude
```

Do not put a `settings.json` back in `claude/.claude/`. `.gitignore` keeps it out of
Git, but stow then fails on the `claude` package, because the target is a real file.

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