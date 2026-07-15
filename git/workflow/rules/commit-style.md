# Commit Style (swappable)

> **This file is the swappable seam for `/commit`.** Default standard: [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). Replace with house rules without editing the command; keep the headings.

## Format

```
<type>(<scope>)!: <description>

[body]

[footer(s)]
```

- `scope` optional: the affected area, a noun in parentheses — `feat(parser): ...`
- `!` before the colon marks a breaking change (in addition to, or instead of, the footer).

## Types

- **feat** — new feature (SemVer MINOR).
- **fix** — bug fix (SemVer PATCH).
- Also allowed: **build**, **chore**, **ci**, **docs**, **style**, **refactor**, **perf**, **test**.
- One type per commit. If the diff honestly needs two types, it should be two commits.

## Header (first line)

- Imperative mood, lowercase after the colon, no trailing period: `fix(auth): handle expired refresh tokens`.
- ≤72 characters total. Specific over generic — never `chore: update code`.

## Body

- Blank line after the header. Explain **what and why**, not how; wrap at ~72 chars.
- Omit entirely for trivial changes where the header says it all.

## Footers

- Git-trailer format: `Token: value`, one per line, after a blank line.
- **Breaking changes:** `BREAKING CHANGE: <description of the break and migration>` (must be uppercase; `!` in the header alone is also valid — prefer both for visibility).
- **Tickets:** `Refs: <PROJECT-123>` when a project code is configured (see `/init-workflow`) or a ticket is derivable from the branch name.

## Granularity

- One logical change per commit. If the staged diff mixes unrelated work, say so and suggest splitting (`git add -p`) rather than writing an umbrella message.

---

<!--
QUANTORI COMMIT RULES: replace the content above with Quantori's house style,
keeping these headings. Typical changes: restricted type list, mandatory scope
from an approved list, mandatory Refs footer, different ticket token (Closes/Fixes).
-->
