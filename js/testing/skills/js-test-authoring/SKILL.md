---
name: js-test-authoring
description: Use when writing, analyzing, or reviewing tests in TS/React projects. Detects Jest vs Vitest.
---

# JS/TS Test Authoring

Shared knowledge for the `js-testing` plugin's commands (`/analyze-tests`, `/cover-with-tests`, `/review-code`). Claude also auto-loads this when a testing task comes up without an explicit command.

Always read the swappable conventions before writing or judging tests: **`${CLAUDE_PLUGIN_ROOT}/rules/conventions.md`**. That file is the source of truth for language, file placement, what-to-test priorities, mocking, and coverage expectations. This SKILL.md covers the mechanics (detection, running) that don't change per project.

## Step 1 — Detect the test runner (never assume)

Both Jest and Vitest appear across Quantori's projects, sometimes both in one monorepo. Detect per project/package before doing anything.

Fastest path — run the helper:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/js-test-authoring/scripts/detect-runner.sh" [dir]
```

It prints `RUNNER=vitest|jest|unknown`, `CONFIG=<path>`, `NEXTJS=yes|no`, `TEST_SCRIPT=<package.json test script>`, and the detected package manager. If you'd rather reason manually, apply the same signals in this precedence:

1. **Config file present** → decisive. `vitest.config.*` or `vite.config.*` with a `test` block → Vitest. `jest.config.*` or a `jest` key in `package.json` → Jest.
2. **Dependencies** in `package.json` (`devDependencies`/`dependencies`): `vitest` → Vitest; `jest` / `ts-jest` / `babel-jest` → Jest.
3. **The `test` script** in `package.json`: what it actually invokes wins over everything else.
4. **Next.js** (`next` dependency): note it. Next projects typically wire Jest through `next/jest`; if adding/adjusting config, use that transform rather than ts-jest/babel. Next also supports Vitest — trust the config/deps signal.
5. **Monorepo:** detect at the nearest package (closest `package.json`), not the repo root. The nearest config wins.

If signals conflict, prefer the config file, then the `test` script. If genuinely `unknown`, say so and ask rather than guessing.

## Step 2 — Apply conventions

Read `rules/conventions.md` and follow it for file location/naming, TypeScript strictness, query priority, mocking, and assertions. Match the project's **existing** patterns where they differ from defaults (test folder vs colocated, `.spec` vs `.test`) — detect, don't impose.

## Step 3 — Runner-specific authoring notes

**Vitest**
- `import { describe, it, expect, vi, beforeEach } from 'vitest'` (imports are explicit unless `globals: true` is set in config — check).
- Mocks: `vi.fn()`, `vi.mock('module')`, `vi.spyOn()`. Timers: `vi.useFakeTimers()`.
- jest-dom matchers: rely on `@testing-library/jest-dom/vitest` in the setup file; if missing and matchers are used, note it.

**Jest**
- Globals (`describe`/`it`/`expect`/`jest`) are usually available without imports (`injectGlobals`). Don't add imports that fight the project's config.
- Mocks: `jest.fn()`, `jest.mock('module')`, `jest.spyOn()`. Timers: `jest.useFakeTimers()`.
- Next.js: transform via `next/jest`; test environment `jsdom`.

Both use `@testing-library/react` and `@testing-library/user-event` identically. Test *code* is nearly runner-agnostic except for the mock/import surface above — write to the detected runner.

## Step 4 — Run and verify

Prefer the project's own script so config is respected:

```bash
<pkg-manager> run test -- <path/to/file>        # e.g. npm run test -- src/Button.test.tsx
```

Coverage:

```bash
# Vitest
npx vitest run --coverage <path>
# Jest
npx jest --coverage <path>
```

If the suite can't run (missing deps, no install, sandboxed), fall back to **static reasoning**: read source + existing tests and reason about covered vs uncovered branches. Always state which mode you used.

## Guardrails

- Verify before declaring done: a command that writes tests must run them (or explain why it couldn't).
- Never weaken a test to make it pass. If code is buggy, report the bug; don't assert the wrong behavior.
- Don't install packages or change runner config unless the task explicitly calls for it — report what's missing instead.
