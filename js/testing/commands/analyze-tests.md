---
description: Diagnose TypeScript test coverage; runs the coverage tool if runnable, else static. Writes nothing.
argument-hint: [dir-or-scope] (optional, defaults to the project)
allowed-tools: Read, Grep, Glob, Bash
---

# /analyze-tests

Report the testing situation for a project or scope. This is a **read-only diagnose** atom — it **writes nothing** (no test files, no config, no edits). Its output is a prioritized map of gaps.

**Scope:** `$ARGUMENTS` — a directory or path to focus on. If empty, analyze the current project (nearest package).

Load the backing skill **js-test-authoring** and read `${CLAUDE_PLUGIN_ROOT}/rules/conventions.md` for coverage expectations and what counts as a meaningful gap.

## Procedure

1. **Detect the runner and scope:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/skills/js-test-authoring/scripts/detect-runner.sh" "${ARGUMENTS:-.}"
   ```
   Note `RUNNER`, `REACT`, `TEST_SCRIPT`, `PKG_MANAGER`, `PACKAGE_DIR`.

2. **Try to run coverage** (preferred — real data). Use the project's tooling:
   ```bash
   # Vitest
   npx vitest run --coverage --reporter=dot
   # Jest
   npx jest --coverage
   ```
   Scope to `$ARGUMENTS` when supported. Parse the coverage report (text summary, or `coverage/coverage-summary.json` / `lcov.info` if present) for per-file lines/branches/functions.

3. **If the suite can't run** (no install, missing deps, sandbox, or it errors), fall back to **static reasoning**: enumerate source files under scope (`Glob`), find which have a colocated/matching test (`Glob`/`Grep`), and read logic-heavy or user-facing files to judge which branches look untested. **State clearly that this is a static estimate, not measured coverage.**

4. **Rank the gaps by value, not by percentage.** Prioritize, in order: logic-heavy modules (and, when `REACT=yes`, user-facing components); uncovered branches (error/empty/edge paths — plus loading states for React); exported units with no test file at all; weakly-covered files (a test exists but misses key branches). Deprioritize trivial/generated/config files.

5. **Report** (concise, no files written):
   - **Mode used:** measured coverage vs static estimate, and the runner.
   - **Headline:** overall coverage if measured; or "N of M source files under scope have no test."
   - **Top gaps:** a short ranked list — file, what's missing, why it matters.
   - **Suggested next step:** e.g. `/cover-with-tests <highest-value-file>`.

## Guardrails

- Write nothing and change nothing — not even to "quickly try" a fix. If asked to fix, that's `/cover-with-tests` or `/review-code`.
- Don't install packages or alter config to make coverage run; if it can't run as-is, use the static fallback and say so.
- Don't inflate the picture: distinguish "no test file" from "tested but shallow," and never present a static estimate as a measured number.
