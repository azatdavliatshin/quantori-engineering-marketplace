# js-testing

Testing atoms for TypeScript projects — Node libraries, backends, CLIs, and React apps alike. React is a **detected** first-class case, not an assumption: the runner detector reports `REACT=yes|no` and the React-specific guidance (Testing Library, jsdom, component priorities) switches on only when it applies. The commands form a natural loop — **analyze the gaps → cover them** — plus a composition that covers your git changes; each stands alone. (Code review lives in the sibling **js-review** plugin.)

## Commands

| Command | Verb | What it does |
|---|---|---|
| `/analyze-tests` | diagnose (read-only) | Reports the testing situation. Runs the coverage tool if the project is runnable (`vitest --coverage` / `jest --coverage`) and parses the report; falls back to static reasoning when it can't run the suite. Lists uncovered / weakly-covered files and the highest-value gaps. **Writes nothing.** |
| `/cover-with-tests` | generate | "Cover this module/component with tests." Detects the runner (Jest vs Vitest, Next.js-aware) and React, writes tests, runs them, reports pass/fail. |
| `/test-changes` | compose (scope → judge → generate) | "Test what I just changed." Scopes to the git diff (optionally vs a base ref), judges which changed files actually need tests (bug fixes get regression tests; renames/type-only changes are skipped with reasons), then delegates each to `/cover-with-tests`. |

## How it's built

Each command is a thin entry point in `commands/`. The shared knowledge — how to detect the runner and stack, how to write good TypeScript tests — lives in the backing skill under `skills/js-test-authoring/`, which Claude also auto-loads when you ask about testing without invoking a command.

Anything project- or org-specific lives in **`rules/conventions.md`**, a swappable file structured as a general TS core plus a React section applied only when React is detected. Replace it with Quantori's conventions (or another project's) without touching the commands or skill.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install js-testing@quantori-engineering
```

## Roadmap

- `scaffold-component` — pairs with js-review's `/review-code` and git-workflow's `/pr-desc` into a pre-commit story.
