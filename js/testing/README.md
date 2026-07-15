# js-testing

Testing atoms for TypeScript/React projects. Three commands that form a natural loop — **analyze → cover the gaps → review the result** — but each stands alone.

## Commands

| Command | Verb | What it does |
|---|---|---|
| `/analyze-tests` | diagnose (read-only) | Reports the testing situation. Runs the coverage tool if the project is runnable (`vitest --coverage` / `jest --coverage`) and parses the report; falls back to static reasoning when it can't run the suite. Lists uncovered / weakly-covered files and the highest-value gaps. **Writes nothing.** |
| `/cover-with-tests` | generate | "Cover this component with tests." Detects the runner (Jest vs Vitest, Next.js-aware), writes tests, runs them, reports pass/fail. |
| `/review-code` | evaluate | General TS/React reviewer. Flags best-practice issues; can optionally spawn a fixer subagent and re-check, capped at ~3 loops with stall detection. |

## How it's built

Each command is a thin entry point in `commands/`. The shared knowledge — how to detect the runner, how to write good TS/React tests, what the reviewer looks for — lives in the backing skill under `skills/js-test-authoring/`, which Claude also auto-loads when you ask about testing without invoking a command.

Anything project- or org-specific lives in **`rules/conventions.md`**, a swappable file. Replace it with Quantori's conventions (or another project's) without touching the commands or skill.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install js-testing@quantori-engineering
```

## Roadmap

- `/test-changes` — "review my git changes and write tests for what needs it" (git-diff scoping + a needs-tests judgment, then calls `/cover-with-tests`).
- `scaffold-component`, `pr-desc` — pair with `/review-code` into a pre-commit story.
