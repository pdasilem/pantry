# Uniam — Agent Notes

You have persistent notes across sessions. USE THEM.

## Session start — MANDATORY

Before doing ANY work, retrieve notes from previous sessions:

```bash
uniam list --project
```

If the user's request relates to a specific topic, also search for it:

```bash
uniam search "<relevant terms>" --project
```

When search results show "Details: available", retrieve them:

```bash
uniam retrieve <note-id>
```

Do not skip this step. Prior sessions may contain decisions, bugs, and context that directly affect your current task.

## Session end — MANDATORY

Before ending your response to ANY task that involved making changes, debugging, deciding, or learning something, you MUST store a note. This is not optional. If you did meaningful work, store it.

```bash
uniam store \
  --title "Short descriptive title" \
  --what "What happened or was decided" \
  --why "Reasoning behind it" \
  --impact "What changed as a result" \
  --tags "tag1,tag2,tag3" \
  --category "<category>" \
  --related-files "path/to/file1,path/to/file2" \
  --source "<your-agent-id>" \
  --details "Full context with all important details. Be thorough.
             Include alternatives considered, tradeoffs, config values,
             and anything someone would need to understand this fully later."
```

Categories: `decision`, `bug`, `pattern`, `context`, `learning`.

Set `--source` to your agent identifier: `claude-code`, `codex`, `cursor`, `windsurf`, `antigravity`, or `opencode`.

`--project` defaults to the current directory name — only set it explicitly if storing a note for a different project.

### What to store

You MUST store a note when any of these happen:

- You made an architectural or design decision
- You fixed a bug (include root cause and solution)
- You discovered a non-obvious pattern or gotcha
- You set up infrastructure, tooling, or configuration
- You chose one approach over alternatives
- You learned something about the codebase that isn't in the code
- The user corrected you or clarified a requirement

### What NOT to store

- Trivial changes (typo fixes, formatting)
- Information that's already obvious from reading the code
- Duplicate of an existing note (search first)

## Agent setup (recommended)

Run once to auto-install hooks for your agent:

```bash
uniam setup cursor   # or: claude-code, windsurf, antigravity, codex, codex-cli, opencode, copilot, gemini-cli
```

*Note: The setup command will prompt you to optionally install "fast context" MCP servers (`ripgrep` and `code-search-mcp`) for enhanced codebase indexing.*

#### Security Note for `code-search-mcp`

If you elected to install `code-search-mcp`, it is highly recommended to manually edit your agent's MCP configuration file afterwards to restrict its search boundaries (whitelist workspaces). By default, it runs unrestricted.

```json
{
  "mcpServers": {
    "code-search": {
      "command": "node",
      "args": [
        "~/.local/share/uniam/code-search-mcp/dist/index.js",
        "--allowed-workspace", "/path/to/your/project1",
        "-w", "/path/to/your/project2"
      ]
    }
  }
}
```

To remove: `uniam uninstall cursor`

## Build & develop

```bash
go build ./cmd/uniam
# or: just build
```

## Testing

```bash
go test ./...
./testing/test-uniam.sh   # full CLI integration test (uses temp dir)
```

Unit tests: `internal/redaction`, `internal/models`, `internal/config`, `internal/storage`.
Integration tests: `internal/core`, `internal/db` (require DB).

## Rules

- Retrieve before working. Store before finishing. No exceptions.
- Always capture thorough details — write for a future agent with no context.
- Never include API keys, secrets, or credentials.
- Wrap sensitive values in `<redacted>` tags.
- Search before storing to avoid duplicates.
- One note per distinct decision or event. Don't bundle unrelated things.
