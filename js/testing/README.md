# js-testing

Testing atoms for TypeScript projects — Node libraries, backends, CLIs, and React apps alike. React is a **detected** first-class case, not an assumption: the runner detector reports `REACT=yes|no` and the React-specific guidance (Testing Library, jsdom, component priorities) switches on only when it applies. Two commands form a natural loop — **analyze the gaps → cover them** — but each stands alone. (Code review lives in the sibling **js-review** plugin.)

## Commands

| Command | Verb | What it does |
|---|---|---|
| `/analyze-tests` | diagnose (read-only) | Reports the testing situation. Runs the coverage tool if the project is runnable (`vitest --coverage` / `jest --coverage`) and parses the report; falls back to static reasoning when it can't run the suite. Lists uncovered / weakly-covered files and the highest-value gaps. **Writes nothing.** |
| `/cover-with-tests` | generate | "Cover this module/component with tests." Detects the runner (Jest vs Vitest, Next.js-aware) and React, writes tests, runs them, reports pass/fail. |

## How it's built

Each command is a thin entry point in `commands/`. The shared knowledge — how to detect the runner and stack, how to write good TypeScript tests — lives in the backing skill under `skills/js-test-authoring/`, which Claude also auto-loads when you ask about testing without invoking a command.

Anything project- or org-specific lives in **`rules/conventions.md`**, a swappable file structured as a general TS core plus a React section applied only when React is detected. Replace it with Quantori's conventions (or another project's) without touching the commands or skill.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install js-testing@quantori-engineering
```

## Roadmap

- `/test-changes` — "review my git changes and write tests for what needs it" (git-diff scoping + a needs-tests judgment, then calls `/cover-with-tests`).
- `scaffold-component`, `pr-desc` — pair with js-review's `/review-code` into a pre-commit story.
