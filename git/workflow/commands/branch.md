---
description: Create a well-named branch from a ticket and/or description; follows the repo's naming convention.
argument-hint: [ticket and/or short description] (e.g. "QNTR-123 token refresh")
allowed-tools: Read, Grep, Glob, Bash
---

# /branch

Create a correctly named branch for a piece of work. This is a **generate-and-act** atom: compose the name (ticket-aware, convention-matching), confirm, create, switch. It never pushes and never touches existing branches.

**Input:** `$ARGUMENTS` — a ticket key, a short description, or both. If there's no description at all, ask what the work is; don't invent one.

Read the naming seam at `${CLAUDE_PLUGIN_ROOT}/rules/branch-style.md`. If `.claude/git-workflow.json` exists (created by `/init-workflow`), use its `projectCode`/`ticketPattern` to recognize and format the ticket.

## Step 1 — Context

```bash
git branch --show-current
git status --short
git branch -a --format='%(refname:short)' | head -30
```

- **Observed convention first:** if existing branches follow a clear pattern, match it over the seam's default (see the seam's precedence rule).
- **Uncommitted changes present:** fine — git carries them over — but tell the user they'll move to the new branch.
- **Currently on another feature branch** (not the default branch): ask whether to branch from here (stacked) or from the default branch. Don't assume.

## Step 2 — Base

Default: branch from the up-to-date default branch.

```bash
git fetch origin
base="origin/$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@.*/@@' || echo main)"
```

If fetch fails (offline), say so and branch from the local default branch instead.

## Step 3 — Compose the name

Per the seam: infer the type from the description, extract the ticket from `$ARGUMENTS` or the config's pattern, slugify the description. If a ticket is expected (config present) but missing from the input, ask for it once — accepting "no ticket" as an answer.

## Step 4 — Confirm and create

Show the name and base. On confirmation:

```bash
git switch -c <name> "$base"
```

If the name already exists (locally or on the remote), say so and propose a variant — never reuse or force.

Report: branch created, base, and the natural next steps (`/commit` when work is staged, `/pr-desc` when it's pushed).

## Guardrails

- Never delete, rename, or force-recreate branches.
- Never push — creating the branch locally is the whole job.
- Never invent a ticket number; no ticket means no ticket segment.
- Confirm the final name before creating — the user owns their branch namespace.
