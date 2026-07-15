---
name: js-review
description: Use when reviewing TypeScript/JS code quality. Severity taxonomy, stack detection, capped fixer loop.
---

# JS/TS Review

Shared machinery for the `js-review` plugin's review atoms (`/review-code` now; more review targets later). Every atom follows the same shape: **read target → judge against a swappable standard → report by severity → optionally fix via a capped loop.** This file holds the machinery; the standards live in `${CLAUDE_PLUGIN_ROOT}/rules/` (one file per review target, e.g. `rules/code.md`).

## Detect the stack (never assume)

Some packages are plain TypeScript (Node libs, CLIs, backends), others are React. Detect before judging — React-specific findings on a Node lib are noise. Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/js-review/scripts/detect-runner.sh" [dir]
```

It prints `RUNNER=vitest|jest|unknown`, `REACT=yes|no`, `NEXTJS=yes|no`, `TEST_SCRIPT`, `PKG_MANAGER`, `PACKAGE_DIR`. Use `REACT` to gate React-specific review areas, and `RUNNER`/`TEST_SCRIPT`/`PKG_MANAGER` to run tests when verifying fixes. Detect at the nearest package (monorepos: closest `package.json` wins).

## Severity discipline

Three levels, defined in the rules file: **[blocker]** (objectively wrong), **[warning]** (likely problem), **[nit]** (preference). Every finding names a location and a concrete fix — no vague "consider refactoring." Separate objective issues from taste; taste is always a nit.

## The capped reviewer→fixer loop

Used only when the user asked to fix (or approves). Max **3** iterations:

1. Collect current **[blocker]** and agreed **[warning]** findings.
2. Delegate to the fixer subagent (the bundled `js-code-fixer`, or `general-purpose` via the Task tool): hand it the file list, the specific findings, and a strict fix-only-these instruction.
3. Re-review the touched files only.
4. **Stall detection — stop early when any holds:** no blockers/warnings remain; a pass resolved nothing new; a fix introduced a regression; 3 iterations reached.
5. **Verify:** if the project has a test script and tests touch the changed files, run them:
   ```bash
   <PKG_MANAGER> run test -- <paths>
   ```

Report each iteration briefly and why the loop stopped. Never loop silently past the cap.

## Guardrails

- Review-only mode changes nothing.
- The fixer never expands scope — fixes address flagged findings only.
- Don't install packages or change config to make verification run; report what's missing instead.
