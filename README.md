# tbx-mcp

A standalone MCP (Model Context Protocol) server for [Tinderbox](https://www.eastgate.com/Tinderbox/) that provides 9 tools for reading, creating, and manipulating notes, links, and attributes via AppleScript. Unlike the MCP server bundled with Tinderbox, tbx-mcp runs as a separate process — making it usable from containers, remote environments, and any MCP-compatible client.

## Requirements

- [Tinderbox](https://www.eastgate.com/Tinderbox/) installed (any version)
- Ruby 3.1+ with Bundler

## Installation

```bash
git clone <repo-url> tbx-mcp
cd tbx-mcp
bundle install
```

## Setup

### Claude Desktop

Add the following to your Claude Desktop configuration file:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "tinderbox": {
      "command": "ruby",
      "args": ["/full/path/to/tbx-mcp/server.rb"]
    }
  }
}
```

Replace `/full/path/to/tbx-mcp` with the actual path where you cloned the repository.

Restart Claude Desktop after saving the configuration.

### Claude Code

Add the server to your Claude Code project settings or global settings:

**Project-level** (recommended — add to `.claude/settings.json` in your project root):

```json
{
  "mcpServers": {
    "tinderbox": {
      "command": "ruby",
      "args": ["/full/path/to/tbx-mcp/server.rb"]
    }
  }
}
```

**Global** (applies to all projects — add to `~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "tinderbox": {
      "command": "ruby",
      "args": ["/full/path/to/tbx-mcp/server.rb"]
    }
  }
}
```

After saving, restart Claude Code or run `/mcp` to reconnect.

### Verify

Once connected, the server exposes 9 tools and 5 reference resources. In Claude Code you can verify with `/mcp` — you should see `tinderbox` listed with its tools.

## Tools

All tools that operate on a document require a `document` parameter (the document name). Use `get_document` first to discover open document names.

| Tool | Description |
|------|-------------|
| `get_document` | List all open Tinderbox documents with name, modified status, and file path |
| `open_document` | Open a `.tbx` file from a path on disk |
| `get_notes` | Get notes by path or query, with optional attribute values |
| `create_note` | Create one or more notes (note, agent, or adornment) |
| `create_link` | Create a link between two notes with optional link type |
| `set_value` | Set an attribute value on one or more notes |
| `do` | Execute Tinderbox action code on one or more notes |
| `evaluate` | Evaluate a Tinderbox expression in the context of a note |
| `get_view` | Capture a screenshot of the document's current view |

## Resources

The server exposes detailed Tinderbox reference documentation as MCP resources. These are loaded on-demand by the LLM only when deeper reference is needed.

| Resource URI | Description |
|-------------|-------------|
| `tinderbox://ref/adornments` | Map adornments: smart adornments, sticky/lock, grids, dividers |
| `tinderbox://ref/expressions` | Expression and action language syntax with examples |
| `tinderbox://ref/action-functions` | Catalog of 300+ action functions organized by category |
| `tinderbox://ref/action-attributes` | 12 action-holding attributes ($Rule, $AgentQuery, $OnAdd, etc.) |
| `tinderbox://ref/system-containers` | Built-in containers: Prototypes, Templates, Hints, Composites |
| `tinderbox://ref/export-codes` | 46 ^caret^ export template codes for HTML/text export |

## Context-Aware Design

The server is designed to use as little of the LLM's context window as possible:

- **Always-present instructions**: A curated ~970 token quick reference covering expression syntax, key attributes, action code patterns, and common gotchas. This consumes less than **0.5%** of a 200K token context window.
- **On-demand resources**: Five detailed reference documents (~16,500 tokens total) are exposed as MCP resources that the LLM can read only when it needs deeper reference — they carry zero cost when not loaded.
- **Worst case**: Even with all resources loaded, the total is ~17,500 tokens — under **9%** of a 200K context window.

## Running Tests

The test suite requires Tinderbox to be running with at least one document open.

```bash
bundle exec rake test
```

The suite includes 59 tests covering all tools, the AppleScript helper, and cross-tool consistency checks. Test notes are prefixed with `[MCP-TEST]` and cleaned up automatically.

## Architecture

```
.
|-- Gemfile
|-- Rakefile
|-- README.md
|-- server.rb
|-- lib
|   |-- apple_script_helper.rb
|   |-- tinderbox_mcp.rb
|   `-- tinderbox_mcp
|       |-- create_link.rb
|       |-- create_note.rb
|       |-- do_action.rb
|       |-- evaluate.rb
|       |-- get_document.rb
|       |-- get_notes.rb
|       |-- get_view.rb
|       |-- instructions.rb
|       |-- open_document.rb
|       `-- set_value.rb
|-- references
|   |-- action-attributes.md
|   |-- action-functions.md
|   |-- export-codes.md
|   |-- expressions.md
|   `-- system-containers.md
`-- test
    |-- apple_script_helper_test.rb
    |-- consistency_test.rb
    |-- create_link_test.rb
    |-- create_note_test.rb
    |-- do_action_test.rb
    |-- evaluate_test.rb
    |-- get_document_test.rb
    |-- get_notes_test.rb
    |-- get_view_test.rb
    |-- open_document_test.rb
    |-- set_value_test.rb
    `-- test_helper.rb
```

## Design Decisions

- **Version-agnostic AppleScript**: All scripts use `tell application id "Cere"` instead of `tell application "Tinderbox 11"`, so the server works with any Tinderbox version.
- **Explicit document targeting**: Every tool requires a `document` parameter — no `front document` calls that could target the wrong window.
- **No action code for set_value**: Values are set via the AppleScript `attribute of` API to bypass Tinderbox's lack of quote escaping in action strings.
- **Stateless**: No server-side state. Every tool call is self-contained.

## License

MIT
