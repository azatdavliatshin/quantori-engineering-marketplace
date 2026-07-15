# Code Review Standard (swappable)

> **This file is the swappable seam for `/review-code`.** It defines *what the reviewer flags* — the standard code is judged against. The command holds the procedure (scoping, severity workflow, fix loop); this file holds the policy. Drop in Quantori's house standard (or another project's) without editing the command or skill.
>
> To swap: keep the same headings so the command can find each area; change the content under them.

## Severity definitions

- **[blocker]** — bugs, type-safety holes, security issues, resource leaks: things that are wrong, not debatable.
- **[warning]** — likely-problem patterns and contract gaps that deserve a fix but won't break today.
- **[nit]** — preference and polish. Never escalate a preference above nit.

## TypeScript

- `any` or unsafe casts (`as` chains, double assertions), missing/loose types on public surfaces.
- Non-null assertions (`!`) hiding real nullability.
- Unhandled `Promise` / floating async, missing `await` on error paths.

## React (applies only when the project uses React — `REACT=yes` from the detector, or the files contain JSX)

- Missing/incorrect hook deps; state derivable from props; keys on lists.
- Effects that should be event handlers; unnecessary re-renders; unstable callbacks passed to memoized children.
- Direct DOM access where refs/state fit.

## Correctness

- Unhandled error/empty states (plus loading states in UI code).
- Off-by-one/boundary bugs, race conditions.
- Resource leaks: listeners, timers, subscriptions not cleaned up.

## Tests (if test files are in scope)

- Implementation-detail assertions instead of behavior.
- Missing branch coverage for the code under test; brittle snapshots.
- In React tests: `data-testid` where a role/label query fits.

## General

- Dead code, misleading names, duplicated logic.
- Security foot-guns: unsanitized `dangerouslySetInnerHTML`, secrets in code, injection-prone string building.
- Do **not** flag style a formatter/linter already enforces unless it's a real correctness issue.

---

<!--
QUANTORI STANDARD: replace the content above with Quantori's house review rules,
keeping these headings so the command can locate each area. Add a "House rules"
section for anything Quantori-specific (banned patterns, required error handling,
logging/observability requirements).
-->
