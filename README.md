# Quantori Engineering Marketplace

A catalog of installable [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) capabilities — skills, plugins, and commands — for Quantori engineers. Add the marketplace once, then install the plugins you want.

## What this is

This repo follows the **catalog** model (like `anthropics/life-sciences`): a single Git repo whose top-level `.claude-plugin/marketplace.json` lists independent, individually-installable plugins. Each plugin is a self-contained folder bundling commands, skills, and/or MCP servers, installed as one unit.

It is **not** a workflow framework. It ships focused, atomic capabilities you compose yourself. For a full discuss → plan → execute → verify → ship loop, we recommend the external [GSD](https://github.com/open-gsd/gsd-core) toolkit; this marketplace borrows several of GSD's patterns (see [CONTRIBUTING.md](./CONTRIBUTING.md)) but does not rebuild it.

## Structure

The catalog is organized by **competency**, and each competency folder holds one folder per **plugin**:

```
engineering-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # the catalog: lists every plugin
├── README.md
├── CONTRIBUTING.md
└── js/                           # JavaScript/TypeScript competency
    ├── testing/                  # plugin: js-testing
    │   ├── .claude-plugin/plugin.json
    │   ├── commands/             # /analyze-tests, /cover-with-tests
    │   ├── skills/               # backing knowledge the commands share
    │   ├── rules/                # swappable conventions (generic now, Quantori-specific later)
    │   └── README.md
    └── review/                   # plugin: js-review
        ├── .claude-plugin/plugin.json
        ├── commands/             # /review-code (more review targets later)
        ├── skills/               # severity discipline, detection, fixer loop
        ├── agents/               # js-code-fixer subagent
        ├── rules/                # swappable review standards, one file per target
        └── README.md
```

Competencies extend by adding sibling folders (`python/`, `life-science/`); plugins extend by adding folders inside a competency (`js/react/`, `js/typescript/`). Plugin **names** stay globally unique by prefixing the competency — `js-testing`, later `js-react`, `python-testing` — so install commands never collide.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install js-testing@quantori-engineering
```

Then restart your Claude Code session. Verify with `/plugin` or `claude plugin list`.

## Available plugins

| Plugin | Competency | What it gives you |
|---|---|---|
| **js-testing** | JavaScript/TypeScript | `/analyze-tests`, `/cover-with-tests` — a testing loop for TypeScript projects (Node libs, backends, CLIs, React apps). Auto-detects Jest vs Vitest and React. |
| **js-review** | JavaScript/TypeScript | `/review-code` — evaluates TypeScript against a swappable standard (React-aware when detected); optional capped reviewer→fixer loop. More review targets (tests quality, structure, architecture) planned. |

More plugins and competencies are on the roadmap: a `/test-changes` composition, `scaffold-component`, and Python and Life-Science competencies.

## Contributing

Adding a skill, command, or whole plugin? See [CONTRIBUTING.md](./CONTRIBUTING.md). The short version: keep every atom **one verb, one clear trigger, one obvious result.**
