# Operations

Depth on writes that touch multiple notes or cross categories. Load when extraction, linking, or restructuring go beyond the preamble's basics.

## Extraction

### Is it ready?

An atom is ready when you can name it in one honest title — a phrase a reader with no context would understand. If the title needs qualification ("our approach to X", "what we decided about Y"), the idea is still tangled and belongs where it came from. If you catch yourself wanting "and" in the title or splitting the body with a subheader, it's two atoms.

Negative knowledge counts: "Why X doesn't work for Y" is a valid atom. Articulating failure is often more useful than articulating success; the test stays the same.

Don't extract too early. A premature atom is a cleanup tax, and ideas that want to exist keep resurfacing — you don't lose them by waiting.

### The three moves

1. **Write the atom.** Named by content, flat in `10-atoms/`.
2. **Link back.** In the originating context, replace the tangled version with a one-sentence summary plus `[[atom-name]]`.
3. **Garden forward.** Search the vault for places this concept already comes up. Add forward links to the new atom from anywhere it's relevant.

Step 3 is easy to skip and expensive to miss. Backlinks appear on their own; forward links are manual, and without them the atom is only reachable from where it was born.

## Linking

Wikilinks are `[[note-name]]`; alias as `[[note-name|display text]]`; target a heading with `[[note-name#heading]]`.

### When to link, when not to

Link first mentions where the reader would benefit from following. Subsequent mentions in the same note can stay plain — dense wikilink-per-noun prose reads poorly. If a note is already tightly linked (it's in a map, the adjacent library item references it), extra links add noise.

### Forward linking is the gardening work

Incoming links don't appear by themselves. After writing a new note, search the vault for a few keywords from it; any notes where the new note is relevant get a forward link added. This is the habit that keeps the graph connected over time.

## Cross-category notes

When content could plausibly live in more than one place:

**Atom vs. library item section.** Reused across contexts → atom, referenced from the library item. Single-context → inside the library item. Dual existence is fine when it's natural — an atom for the portable idea, a library-item section with project-specific framing around it. Don't duplicate content; pick a home and link.

**Atom vs. map.** Maps index; atoms contain. If you're putting reasoning in a map, it should be an atom the map links to.

**Journal vs. atom.** The journal entry stays as the timestamped record; durable content extracts to an atom; the atom links back. Don't merge — they serve different purposes.

When a category question has no clean answer, pick one and move on. Wrong calls are cheap to fix.

## Multi-note updates

When a change affects several notes, do them in one coherent pass:

1. **Scan first.** Search for the topic everywhere it surfaces before writing anything.
2. **Consistent terminology.** If you're renaming a concept, rename everywhere — partial renames create drift.
3. **Cross-links.** If updated notes should reference each other, add the links as you go.

For coding sessions surfacing contradictions between code and library-item docs: update the docs in a single pass, not correction-layers on top of the old content.

## Restructuring within a library item

When a library item has drifted — files piled up, sections overlap, the structure no longer matches the content:

- **Preserve links.** Renames and moves update incoming references. Obsidian does most of this automatically on rename; double-check anyway.
- **Moves separate from edits.** Don't bundle a reorganization with a content update; the diff becomes unreadable.
- **Leave a trace.** For substantive restructures, drop a one-line note in the item about what changed and why.
