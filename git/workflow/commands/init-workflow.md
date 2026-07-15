---
description: Set up per-repo workflow config (project/ticket code) that /commit and /pr-desc then use. Optional.
argument-hint: [project-code] (optional, e.g. QNTR)
allowed-tools: Read, Grep, Glob, Bash, Write
---

# /init-workflow

One-time, per-repo setup: establish the **project code** (the ticket prefix, e.g. the `QNTR` in `QNTR-123`) and ticket rules, and save them to `.claude/git-workflow.json`. After this, `/commit` adds `Refs: QNTR-123` footers and `/pr-desc` puts the ticket in PR titles — derived from branch names automatically.

**Optional but recommended:** both commands work without this config; they just skip ticket references they can't derive.

## Step 1 — Detect before asking

Look for an existing ticket convention:

```bash
cat .claude/git-workflow.json 2>/dev/null           # already configured?
git branch -a --format='%(refname:short)' | head -30
git log --oneline -30
```

Extract candidate codes from patterns like `ABC-123` in branch names and commit history. If config already exists, show it and ask whether to update.

## Step 2 — Confirm with the user

- `$ARGUMENTS` given → that's the project code; just confirm.
- Detected a candidate → propose it ("Branches use QNTR-###; use QNTR as the project code?").
- Nothing detected → ask for the code, or whether to proceed without one (config can still pin commit/PR style choices).

Also ask (one question, sensible defaults): should the ticket be **required** in commits/PRs, or best-effort? Default: best-effort (`false`).

## Step 3 — Write the config

```json
{
  "projectCode": "QNTR",
  "ticketPattern": "QNTR-\\d+",
  "requireTicketInCommits": false,
  "requireTicketInPrTitle": false
}
```

Write to `.claude/git-workflow.json` (create `.claude/` if needed). This file is meant to be committed so the whole team shares it — suggest committing it (via `/commit`, naturally: `chore: add git-workflow config`).

## Step 4 — Report

Show the saved config and one example of the effect: the `Refs:` footer `/commit` will add and the PR title shape `/pr-desc` will use.

## Guardrails

- Never guess a project code silently — detection proposes, the user confirms.
- Don't touch anything outside `.claude/git-workflow.json`.
- Re-running is safe: show current config, update only what the user changes.
