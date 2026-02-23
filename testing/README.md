# Uniam Test Suite

Integration tests for the uniam CLI. Exercises all subcommands with a temporary uniam.

## Run

From project root:

```bash
./testing/test-uniam.sh
```

Or with a pre-built binary:

```bash
UNIAM_BIN=./uniam ./testing/test-uniam.sh
```

## What it tests

- **init** — Creates shelves, index.db, config.yaml
- **store** — Basic store, with details, with related-files, validation (requires --title/--what)
- **search** — Keyword search, limit, result content
- **list** — Recent notes, limit
- **retrieve** — By full ID, short ID, details content
- **remove** — Delete note, verify it's gone from search
- **notes** — List daily note files (alias: log)
- **config** — Show config, init --force
- **reindex** — Rebuild vector index (FTS-only when embeddings unavailable)
- **setup/uninstall** — Unknown agent fails, cursor with --config-dir
- **mcp** — Server starts
- **help** — Root, store, search

## Notes

- Uses `UNIAM_HOME` in a temp dir; never touches `~/.uniam`
- Config overrides embedding to `http://127.0.0.1:19999` so tests run without Ollama (FTS-only path)
- Vector search (sqlite-vec) is enabled via `github.com/asg017/sqlite-vec-go-bindings/ncruces`
- Setup/uninstall use `--config-dir` to avoid modifying real agent configs
