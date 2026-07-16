---
description: Write tests for a TypeScript module or component, run them, report pass/fail. Detects Jest/Vitest.
argument-hint: [path-to-component-or-module]
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# /cover-with-tests

Cover the target with tests: detect the runner, write focused tests, run them, report the result. This is a **generate** atom — it writes files. One target, tests written, suite run.

**Target:** `$ARGUMENTS` — a file path (module or component). If empty, ask which file to cover; do not guess.

Load the backing skill **js-test-authoring** for detection mechanics and runner-specific notes, and read the swappable conventions at `${CLAUDE_PLUGIN_ROOT}/rules/conventions.md` before writing anything.

## Procedure

1. **Detect the runner** (never assume). Run:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/skills/js-test-authoring/scripts/detect-runner.sh" "$(dirname "$ARGUMENTS")"
   ```
   Note `RUNNER`, `CONFIG`, `NEXTJS`, `REACT`, `TEST_SCRIPT`, `PKG_MANAGER`. If `RUNNER=unknown`, report the ambiguity and ask before proceeding.

2. **Read the target and its context.** Read `$ARGUMENTS`. Identify: exported units, inputs (and props, for components) and their types, branches (error/empty/edge — plus loading states for components), side effects, callbacks, and external dependencies to mock. Look for an existing sibling test to match style, and check for a test setup file.

3. **Plan the cases** against `rules/conventions.md` "What to test" priority: the input→output contract, each branch, edge/empty/error states. When `REACT=yes` and the target is a component, add user interactions and prefer role/label queries (React section of the conventions). Skip tests that merely restate the implementation. Briefly list the cases you'll write.

   **Decide each expected outcome from the contract** (types, names, docs, callers) *before* checking what the implementation actually returns — never copy today's output into an assertion. If the implementation contradicts a contract-derived expectation, apply the conventions' bug-enshrinement guard: assert the correct value, mark the case `it.fails` (Vitest) / `test.failing` (Jest), and report the suspected bug.

4. **Write the test file.** Place and name it per the conventions (colocated `*.test.ts` — `*.test.tsx` for components; match the project's existing pattern if different). Use the **detected** runner's import/mock surface (`vi.*` for Vitest, `jest.*`/globals for Jest). TypeScript, no `any`, typed mocks. Mock at module boundaries only.

5. **Run the tests** — prefer the project's script so config is honored:
   ```bash
   <PKG_MANAGER> run test -- <path/to/new/test/file>
   ```
   Fall back to `npx vitest run <path>` / `npx jest <path>` if there's no usable script.

6. **On failure, diagnose the cause:**
   - *Test bug* (wrong query, missing `await`, bad mock) → fix the test and re-run.
   - *Real code bug* → do **not** bend the test to pass — and do **not** quietly rewrite the expectation to match the buggy output. Keep the correct expectation, mark the case `it.fails`/`test.failing`, report the bug clearly, and let the author decide.
   - *Can't run* (missing deps / no install / sandbox) → say so, keep the tests, and note that they're unverified plus the exact command to run them.

7. **Report:** the file written, the cases covered, and the run result (pass/fail counts, or why it couldn't run). Keep it short.

## Guardrails

- Never weaken an assertion to force a green run.
- Don't install packages or edit runner config unless explicitly asked — report what's missing instead.
- Don't touch the source under test except to report a bug you found.
