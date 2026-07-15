---
description: Create a Conventional Commit from staged changes; composes the message, confirms, commits.
argument-hint: [extra context for the message] (optional)
allowed-tools: Read, Grep, Glob, Bash
---

# /commit

Turn the **staged** changes into one well-formed commit. This is a **generate-and-act** atom: read the staged diff, compose a message per the commit standard, show it, and commit on confirmation. It never pushes.

Read the standard at `${CLAUDE_PLUGIN_ROOT}/rules/commit-style.md` (Conventional Commits v1.0.0 by default) before composing. `$ARGUMENTS`, if given, is extra context for the message (e.g. a ticket number or the "why"), not a path.

## Step 1 — What's staged

```bash
git diff --cached --stat
git status --short
```

- **Nothing staged, working tree dirty:** show the unstaged/untracked files and ask what to stage — offer "all of it" or a selection. **Never `git add` anything silently.**
- **Nothing staged, tree clean:** say so and stop.
- **Staged diff mixes unrelated work** (per the granularity rule): say so and suggest splitting with `git add -p`; only proceed with an umbrella commit if the user insists.

## Step 2 — Project context

If `.claude/git-workflow.json` exists (created by `/init-workflow`), read it: `projectCode`, ticket rules. Try to derive the ticket from the branch name (`git branch --show-current`, e.g. `qntr-123-fix-auth` → `QNTR-123`) or from `$ARGUMENTS`. No config and no derivable ticket → skip the `Refs` footer; don't invent one.

## Step 3 — Compose

Read the staged diff (`git diff --cached`) — the diff is the truth. Pick **one type** (and scope if clear) per the standard; write the header, body (what/why, when non-trivial), and footers (`BREAKING CHANGE` when the public contract changes; `Refs` per Step 2).

## Step 4 — Confirm and commit

Show the full message. On confirmation:

```bash
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

Report the resulting hash (`git log --oneline -1`).

## Guardrails

- Staged changes only — never commit unstaged work, never stage silently.
- Never push, amend, or rewrite history; `--amend` only if the user explicitly asks.
- The message describes what's in the diff — no aspirational claims, no invented ticket numbers.
- One type per commit; honesty over convenience when the diff is mixed.
