# Branch Style (swappable)

> **This file is the swappable seam for `/branch`.** It defines how branch names are composed. Replace with house rules without editing the command; keep the headings.

## Pattern

```
<type>/<ticket>-<slug>        # with a ticket:  feat/qntr-123-token-refresh
<type>/<slug>                 # without one:    fix/flaky-retry-test
```

- **type** — the work's nature, same vocabulary as commit types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `build`, `perf`. Infer from the description; ask only if genuinely ambiguous.
- **ticket** — from the per-repo config (`.claude/git-workflow.json`) or given explicitly. Lowercase in the branch name (`qntr-123`); the `Refs:` footer and PR title keep it uppercase.
- **slug** — 2–5 words of the description, kebab-case, ASCII only: lowercase, digits, hyphens. Drop filler words; keep it meaningful (`token-refresh`, not `fix-the-bug`).

## Constraints

- Full name ≤50 characters where possible; the slug is what gets trimmed.
- No slashes beyond the single type separator, no consecutive or trailing hyphens.

## Precedence

1. The repo's **observed** convention wins: if existing branches follow a different pattern (`users/<name>/...`, `JIRA-123_desc`, no type prefix), match it — detect, don't impose.
2. Otherwise this file's pattern applies.

---

<!--
QUANTORI BRANCH RULES: replace the content above with Quantori's house scheme,
keeping these headings. Typical changes: mandatory ticket, restricted type list,
username prefixes (users/azat/...), release-branch conventions.
-->
