# danko-plugins

Personal Claude Code plugin marketplace.

## Install

```bash
/plugin marketplace add fn-danko/danko-plugins
```

## Available plugins

- **second-mind** — brainstorming agent paired with a vault-conventions
  skill for working in an Obsidian vault through the obsidian MCP server.
- **peer-messaging** — skill for messaging your other Claude Code sessions
  (local, Remote Control, cloud, Docker containers).

## Install a plugin

```bash
/plugin install <plugin-name>@danko-plugins
```

## Structure

```
.claude-plugin/
  marketplace.json    # catalog
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json     # manifest
    skills/
    agents/
    commands/
    hooks/
```

## License

MIT. See `LICENSE`.
