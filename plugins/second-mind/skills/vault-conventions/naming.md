# Naming

Quick reference for naming notes and folders. Meta-principle: name by content, not category — titles are how notes are retrieved, so they earn the effort.

## Atoms

Kebab-case, content-based, one honest title.

Good: `vertx-5-verticlebase-migration.md`, `why-retries-dont-compose-with-backpressure.md`, `zig-comptime-vs-templates.md`.

Bad: `java-concurrency-notes.md` (category, not content), `notes-from-tuesday.md` (no content signal), `vertx-stuff-and-related-thoughts.md` (multi-idea).

If no honest title exists, the atom isn't ready — see `operations.md`.

## Maps

The topic or entity indexed. `vertx.md`, `mediobanca.md`, `active.md`. Map type (topic, area, client, index) lives in frontmatter, not the name.

## Library items

Kebab-case folder with a descriptive name: `matrix-bot-vivy/`, `italian-naval-history/`.

For coding projects linked via the startup flow: exact basename match on the source directory — that's the link contract.

**Inside a library item:** match the item's existing filenames. If unfamiliar, read the contents first. When adding a new file, default to kebab-case content-based names.

## Journal

**Daily notes:** `2026-04-18.md` (ISO date).
**Meeting notes:** `2026-04-18-topic.md` (ISO date plus kebab-case topic).

## Threads

Kebab-case, shaped around the unresolved question or pending decision.

Good: `should-matrix-bot-use-vivy-as-backbone.md`, `naming-convention-for-decision-logs.md`.
Bad: `thread-april-18.md` (no content signal), `ongoing-brainstorm.md` (any thread would qualify).

## Memory files

When splitting `memory.md` into `memories/`, use topic-shaped filenames: `memories/work-regesta.md`, `memories/collaboration-patterns.md`.

## Scratch

No convention. Files are ephemeral.

## Attachments

Obsidian handles attachment naming automatically. Don't rename unless the auto-generated name actively gets in the way.
