---
description: Generate a PR title/description from the branch diff; uses the repo PR template when present.
argument-hint: [base-ref] (optional; defaults to the repo's default branch)
allowed-tools: Read, Grep, Glob, Bash
---

# /pr-desc

Generate a ready-to-paste PR title and description from what the branch actually changes. This is a **generate** atom: one input (the branch diff), one output (title + body). It does **not** create or push the PR — it hands you the text, plus the `gh pr create` command if you want it.

**Base:** `$ARGUMENTS` — an optional base ref. If empty, detect the default branch (`origin/HEAD`, falling back to `main`/`master`) and use the merge-base.

Read the style seam at `${CLAUDE_PLUGIN_ROOT}/rules/pr-style.md` before writing — it holds house rules (tone, required sections, ticket-reference format).

## Step 1 — Scope

```bash
base="${ARGUMENTS:-$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@.*/@@' || echo main)}"
git log --oneline "$base"..HEAD
git diff --stat "$base"...HEAD
git diff --name-status "$base"...HEAD
```

If the branch has no commits vs base, say so and stop.

## Step 2 — Understand the change

Read the meaningful diffs (`git diff "$base"...HEAD -- <file>` for the substantive files; skip lockfiles and generated output). Group the work by **intent** — feature / fix / refactor / tests / docs / config — not by file. Commit messages are input, not gospel: the diff is the truth. Note anything user-visible, any behavior change, and any migration a reviewer or deployer must know about.

## Step 3 — Detect the template (detect, don't impose)

Look for a repo PR template, in order: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`, and `.github/PULL_REQUEST_TEMPLATE/` (multiple — ask which one). **If one exists, fill it section by section** — keep its headings, checkboxes, and order; leave HTML comments intact only if they're instructions meant to stay. Only when no template exists, use the default shape from `rules/pr-style.md`.

## Step 4 — Generate

**Title:** ≤72 chars, imperative, specific ("Extract review atoms into js-review plugin", not "Update code"). If the repo's history uses conventional-commit prefixes or ticket keys, match that convention — check `git log --oneline -20 "$base"`.

**Body** (default shape when no repo template):

- **Summary** — 2–3 sentences: what and *why*, not a file list.
- **Changes** — grouped by intent, one bullet per logical change.
- **Testing** — what's covered and how it was verified. Never invent this: if tests weren't run, write "not verified" plainly.
- **Breaking changes / Migration** — only when real; omit the section entirely otherwise (no "N/A" noise).

Output the title and body in a single fenced markdown block, ready to paste. Then offer:

```bash
gh pr create --title "<title>" --body-file <(cat <<'EOF'
<body>
EOF
)
```

## Guardrails

- Never fabricate testing or verification claims.
- No marketing adjectives ("amazing", "robust", "comprehensive"). State what changed.
- Don't create, push, or edit the PR — generating text is the whole job.
- Describe only what's in the diff; if the branch mixes unrelated work, say so and suggest splitting rather than papering over it.
