# CLAUDE.md

Working notes for agents editing this marketplace. Read before making
changes.

## What this repo is

A **plugin marketplace** for Claude Code, named `danko-plugins`. The
marketplace is the top-level container; each plugin lives under
`plugins/` and is installed independently.

```
.claude-plugin/
  marketplace.json         catalog — lists every plugin
README.md                  public landing page
CLAUDE.md                  this file
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json          plugin manifest
    README.md              plugin-facing docs
    agents/*.md            agent definitions
    skills/<name>/SKILL.md skill definitions (plus supporting .md)
    commands/*.md          slash commands (optional)
    hooks/
      hooks.json           hook event registrations
      scripts/             hook scripts
```

Plugin-specific context (design decisions, gotchas, in-flight work)
lives in each plugin's own `README.md` or `hooks/NOTES.md`. This file
does not duplicate it.

## Adding a plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json`. Required field:
   `name`. Recommended: `description`, `version`, `author`, `keywords`,
   `license`.
2. Add an entry to `.claude-plugin/marketplace.json` under `plugins`
   with required `name` and `source: "./plugins/<name>"`. Optional:
   `description`, `version`, `license`, and any other plugin-manifest
   field (merged with `plugin.json` per strict mode, default strict).
3. Write `plugins/<name>/README.md` — what it does, how to install,
   dependencies.
4. Add any agent / skill / hook / command files under their respective
   directories.

### Source path resolution

Relative `source` values starting with `./` are resolved **from the
marketplace root** (the directory containing `.claude-plugin/`). Do not
rely on `metadata.pluginRoot` while using `./`-prefixed sources — the
prefix only applies to bare names like `"source": "my-plugin"`.

## Versioning

Semver per plugin. Bump the plugin's `version` in its `plugin.json`
**and** the catalog entry in `marketplace.json` together — they must
stay in sync.

- Patch (`0.1.0 → 0.1.1`) — doc-only fixes, typos, internal refactor.
- Minor (`0.1.0 → 0.2.0`) — new agent, new skill, new hook, or
  non-breaking behavior change.
- Major (`0.1.0 → 1.0.0`) — breaking change: renamed or removed
  skill/agent, changed hook contract, altered public interface.

Marketplace-level `metadata.version` in `marketplace.json` bumps
independently, and only when the marketplace structure itself changes
(new top-level directories, catalog schema change). Adding or updating
individual plugins does not require a marketplace bump.

## Gotchas (general, apply to any plugin in this marketplace)

- **Plugin agent frontmatter restrictions.** Plugin agents silently
  ignore `hooks`, `mcpServers`, and `permissionMode`. If any of those
  are needed, the agent has to live in `~/.claude/agents/` instead.

- **Agent frontmatter is stripped from the system prompt.** The harness
  parses the YAML for metadata; only the body reaches the model.
  Anything the model itself must see — identity markers, flags — has
  to live in the body.

- **Hook input JSON is under-documented.** Official docs publish only
  a generic "common fields" example, not per-event schemas. Community
  references (base76 hooks reference, FrancisBourre gist) are the
  source for `source` on SessionStart and `stop_hook_active` on Stop.
  Verify empirically before relying on anything beyond `session_id`,
  `transcript_path`, `cwd`, `hook_event_name`.

- **Hook scripts run in a plain shell, not a Claude session.** They
  cannot invoke MCP tools directly. Available env:
  `${CLAUDE_PLUGIN_ROOT}` (plugin install dir),
  `${CLAUDE_PLUGIN_DATA}` (persistent data dir), plus the normal
  session environment.

- **Hook script paths in `hooks.json`** should use
  `${CLAUDE_PLUGIN_ROOT}` so they resolve regardless of where the
  plugin is installed.
