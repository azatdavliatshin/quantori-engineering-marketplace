# Contributing to the Quantori Engineering Marketplace

This marketplace grows by people adding small, sharp capabilities. This guide covers the concepts, the design rules, and the mechanics of adding a skill, command, or plugin.

## Concepts (glossary)

- **Skill** — a folder with a `SKILL.md`: instructions (plus optional scripts/templates) that teach Claude a task. Claude auto-loads it when a task matches its description. *Knowledge.*
- **Command** — a saved prompt invoked explicitly with `/name`. *A manual shortcut.*
- **MCP server** — a running service exposing tools that connect Claude to an external system (needs hosting + auth). *A connection.*
- **Plugin** — the package: a folder with `.claude-plugin/plugin.json` bundling any mix of skills / commands / MCP servers. Installed as one unit.
- **Marketplace** — this repo: a `.claude-plugin/marketplace.json` listing plugins. Added once, then plugins are installed from it.

Nesting: **marketplace → plugins → (skills, commands, MCPs).**

**Skill vs command:** a *command* you invoke by name (`/cover-with-tests`); a *skill* Claude auto-loads by relevance and can be richer (bundled scripts and templates). Many capabilities ship as a thin command that leans on a backing skill for the detail — see `js/testing`.

## Design rules (non-negotiable)

1. **Atomic-first.** Every skill or command is **one verb, one clear trigger, one obvious result.** "Cover this component with tests" is the gold-standard shape. If you're writing a multi-mode command with flags that change what it fundamentally does, split it.
2. **Non-overlapping triggers.** Two atoms that could both fire on the same request will fight. Keep verbs distinct (diagnose vs generate vs evaluate) so routing stays unambiguous.
3. **Verification in the loop.** An atom that changes code must verify before declaring done — run the tests it wrote, re-run the linter after a fix. Bake this into the instructions.
4. **Description discipline.** Cap plugin/skill descriptions at ~100 characters and lead with the trigger. This keeps the always-loaded surface small (a token budget that matters as the catalog grows). CI lints this — see below.
5. **Generic first, conventions swappable.** Write to generic best-practices. Put anything project- or org-specific in a swappable `rules/` file (see `js/testing/rules/conventions.md`) so the atom doesn't need rewriting when conventions change or when the same atom is reused elsewhere.
6. **Auto-detect, don't assume.** Probe the project (which test runner, which framework) rather than hard-coding one stack.

### Patterns borrowed from GSD

We reference [GSD](https://github.com/open-gsd/gsd-core) for the workflow layer rather than rebuilding it, but several of its patterns are worth reusing in atoms:

- **Reviewer + fixer as separate subagents with a capped loop** (~3 iterations, with stall detection so it stops when a pass stops improving). Used by `/review-code`.
- **Verification-in-the-loop** — verify before declaring done (rule 3 above).
- **Skill-description discipline** — the ~100-char cap and lint gate (rule 4 above).
- **Two-stage namespace routing** — not needed yet, but design competency folders so a router can be added once the catalog is large.
- **Supply-chain "slopcheck"** — an `[OK]/[SUS]/[SLOP]` gate before adding an npm dependency; a seed for a future dependency-audit skill.

## Adding a command to an existing plugin

1. Add a markdown file to the plugin's `commands/` folder, e.g. `js/testing/commands/my-atom.md`.
2. Give it frontmatter and a prompt body:

   ```markdown
   ---
   description: One-line trigger, ~100 chars, leads with the verb.
   argument-hint: [component-path]
   allowed-tools: Read, Grep, Glob, Edit, Bash
   ---

   Instructions to Claude. Reference arguments with $ARGUMENTS (or $1, $2).
   Reference the plugin's conventions so behavior stays swappable.
   ```

3. The command is invoked as `/my-atom` once the plugin is installed. Plugin-namespaced commands appear as `js-testing:my-atom` in the UI.

## Adding a skill to an existing plugin

1. Create `skills/<skill-name>/SKILL.md` in the plugin.
2. Frontmatter needs `name` and `description` (the description is the auto-load trigger — keep it ~100 chars, lead with when to use it):

   ```markdown
   ---
   name: my-skill
   description: Use when <trigger>. <What it does.>
   ---

   # My Skill
   Detailed instructions, optionally referencing bundled scripts/templates.
   ```

3. Bundled scripts/templates live alongside `SKILL.md` and are referenced with the `${CLAUDE_PLUGIN_ROOT}` path variable so they resolve regardless of install location.

## Adding a whole new plugin

1. Pick the competency folder (`js/`, or add a new one like `python/`).
2. Create `<competency>/<plugin>/` with a `.claude-plugin/plugin.json`:

   ```json
   {
     "name": "js-react",
     "version": "0.1.0",
     "description": "≤100-char description, leads with the trigger.",
     "keywords": ["react", "..."]
   }
   ```

   **Name it globally-uniquely** by prefixing the competency: `js-react`, `python-testing`. Names must be unique across the whole marketplace.
3. Put components at the **plugin root**: `commands/`, `skills/`, `agents/`, `hooks/`. Only `plugin.json` goes inside `.claude-plugin/`.
4. Register it in the root `.claude-plugin/marketplace.json` `plugins` array with a `source` pointing at the folder:

   ```json
   {
     "name": "js-react",
     "description": "...",
     "source": "./js/react",
     "version": "0.1.0",
     "keywords": ["react"]
   }
   ```

## Validate before you PR

```
claude plugin validate ./js/testing --strict
```

This checks `plugin.json`, skill/command/agent frontmatter, and hooks for schema errors. Also confirm every JSON file parses and that no component folders were placed inside `.claude-plugin/`.

## Versioning

Set `version` in the plugin's `plugin.json` and bump it on every change you want users to receive — Claude Code caches by version string, so pushing commits without bumping does nothing. For fast internal iteration you may instead omit `version` so the git commit SHA is used and every commit ships.

## Governance

Contributions go through PR review. Each competency should have a listed owner (TODO: assign owners). Keep the catalog curated: prefer improving an existing atom over adding a near-duplicate.
