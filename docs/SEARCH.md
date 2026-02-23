# Search Configuration

Uniam supports two main search functionalities for context retrieval: **Fast Context MCP Servers** for codebase search, and **Semantic Search** for vector-based AI note retrieval.

## Fast Context MCP Servers (code-search-mcp & ripgrep)

During setup (`uniam setup`), you will be prompted to install `ripgrep` and `code-search-mcp`. These provide powerful context retrieval plugins to your agent's configuration.

### Prerequisites for `code-search-mcp`

The `code-search-mcp` package is published to GitHub Packages and requires authentication to install. Before running setup:

1. Navigate to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with the `read:packages` scope
3. Create a `.npmrc` file in your home directory with your token:

**macOS/Linux**:

```bash
echo "@LLMTooling:registry=https://npm.pkg.github.com" > ~/.npmrc
echo "//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN" >> ~/.npmrc
```

**Windows (PowerShell)**:

```powershell
Set-Content -Path $env:USERPROFILE\.npmrc -Value "@LLMTooling:registry=https://npm.pkg.github.com"
Add-Content -Path $env:USERPROFILE\.npmrc -Value "//npm.pkg.github.com/:_authToken=YOUR_GITHUB_TOKEN"
```

### Security Note for `code-search-mcp`

The `code-search` plugin provides powerful searching capabilities. By default, it searches all paths if allowed. It is highly recommended to configure it to restrict searches to specific working directories for security.

When you run `uniam setup`, it configures `code-search` with the `--allowed-workspace` flag set to your home directory (`~`) by default. You are encouraged to modify your agent's MCP settings file to point to specific project folders instead:

```json
{
  "mcpServers": {
    "code-search": {
      "command": "node",
      "args": [
        "~/.local/share/uniam/code-search-mcp/dist/index.js",
        "--allowed-workspace", "/path/to/your/project1",
        "--allowed-workspace", "/path/to/your/project2"
      ]
    }
  }
}
```

| Option | Description |
|---|---|
| `--allowed-workspace <path>` | Whitelist a directory for search operations. Can be specified multiple times. If omitted, all paths are allowed (use with caution). |
| `-w <path>` | Short alias for `--allowed-workspace`. |

## Semantic search (optional)

Keyword search (FTS5) works with no extra setup. To also enable semantic vector search, configure an embedding provider in `~/.uniam/config.yaml`:

**Ollama (local, free):**

```yaml
embedding:
  provider: ollama
  model: nomic-embed-text
  base_url: http://localhost:11434
```

Install [Ollama](https://ollama.com), then: `ollama pull nomic-embed-text`

**OpenAI:**

```yaml
embedding:
  provider: openai
  model: text-embedding-3-small
  api_key: sk-...
```

**OpenRouter:**

```yaml
embedding:
  provider: openrouter
  model: openai/text-embedding-3-small
  api_key: sk-or-...
```

**Google (Gemini API):**

```yaml
embedding:
  provider: google
  model: gemini-embedding-001
  api_key: AIzaSy...
```

After changing providers, rebuild the vector index:

```bash
uniam reindex
```
