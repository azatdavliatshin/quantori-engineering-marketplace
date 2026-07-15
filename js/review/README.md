# js-review

Review atoms for TypeScript projects. The plugin is the **activity** (review); each command is one **review target**. Every atom follows the same shape — read target → judge against a swappable standard → report by severity → optionally fix via a capped loop — and each target gets its own rules file.

## Commands

| Command | Target | What it does |
|---|---|---|
| `/review-code` | code | Reviews TypeScript (React-aware when React is detected) against `rules/code.md`. Flags issues as [blocker]/[warning]/[nit]; can optionally spawn the `js-code-fixer` subagent and re-check, capped at 3 loops with stall detection. |

## How it's built

The shared machinery — severity discipline, stack detection (`REACT=yes|no`, runner, package manager), the capped reviewer→fixer loop — lives in the backing skill under `skills/js-review/`. Each review target's **standard** lives in `rules/` (one swappable file per target, `rules/code.md` today). Replace a rules file with Quantori's house standard (or another project's) without touching the command or skill.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install js-review@quantori-engineering
```

## Roadmap

More review targets, each a sibling atom with its own rules file:

- `/review-tests` — evaluate existing tests' *quality* (behavior-focused? brittle? meaningful branches?). Distinct from js-testing's `/analyze-tests`, which diagnoses coverage *gaps*.
- `/review-structure` — folder layout, module boundaries, naming.
- `/review-arch` — dependency direction, layering, coupling.
