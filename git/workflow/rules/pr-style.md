# PR Style (swappable)

> **This file is the swappable seam for `/pr-desc`.** It holds house rules for PR titles and descriptions. Drop in Quantori's (or another org's) conventions without editing the command. Everything below is a generic default.
>
> To swap: keep the same headings; change the content under them.

## Title

- ≤72 characters, imperative mood, specific: "Extract review atoms into js-review plugin", not "Update code".
- Match the repo's observed convention (conventional-commit prefix, ticket key like `PROJ-123:`) when its history uses one; don't introduce a convention the repo doesn't have.

## Required sections

When no repo template exists, the body uses, in order:

1. **Summary** — 2–3 sentences, what and why. A reviewer should understand the point of the PR without opening a file.
2. **Changes** — bullets grouped by intent (feature/fix/refactor/tests/docs/config), one per logical change.
3. **Testing** — what's covered, how verified. "Not verified" is an acceptable, honest entry.

Optional, only when real: **Breaking changes**, **Migration**, **Screenshots** (UI work).

## Tone

- Plain and factual. No marketing adjectives, no filler ("This PR aims to...").
- Write for the reviewer first, the changelog reader second.
- Link issues/tickets in the summary line when the branch or commits reference one.

---

<!--
QUANTORI PR RULES: replace the content above with Quantori's house style,
keeping these headings. Typical additions: mandatory JIRA key format in titles,
required checklist items, deploy-notes section, reviewer-assignment rules.
-->
