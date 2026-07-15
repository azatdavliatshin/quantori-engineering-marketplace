# git-workflow

Git workflow atoms — language-agnostic, diff-driven. First competency outside `js/` because nothing here cares what language the repo is written in. Together they cover the branch lifecycle: `/branch` → work → `/commit` → push → `/pr-desc`.

## Commands

| Command | Verb | What it does |
|---|---|---|
| `/pr-desc` | generate | Generates a ready-to-paste PR title + description from the branch diff vs the default branch (or a given base ref). Fills the repo's own PR template when one exists; otherwise uses the default shape from `rules/pr-style.md`. Never creates the PR itself. |
| `/commit` | generate + act | Turns the **staged** changes into one [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/): picks type/scope from the diff, writes header/body/footers per `rules/commit-style.md`, shows the message, commits on confirmation. Never stages silently, never pushes. |
| `/init-workflow` | configure (optional) | One-time per-repo setup: detects or asks for the project code (the `QNTR` in `QNTR-123`), saves `.claude/git-workflow.json`. After that, `/commit` adds `Refs:` footers and `/pr-desc` puts tickets in titles, derived from branch names. The other commands work without it. |
| `/branch` | generate + act | Creates a well-named branch from a ticket and/or description (`feat/qntr-123-token-refresh`), matching the repo's observed convention over the default in `rules/branch-style.md`. Branches from the up-to-date default branch; confirms the name first; never pushes. |

## How it's built

The commands read the diff (the truth), group changes by intent, and write for the reviewer. House style lives in the swappable seams: **`rules/pr-style.md`** (PR tone, sections, ticket format), **`rules/commit-style.md`** (Conventional Commits v1.0.0 by default — types, header, footers, granularity), and **`rules/branch-style.md`** (branch naming). Replace either with Quantori's conventions without touching the commands. Repo-local artifacts always win over the seams — the PR template (`.github/PULL_REQUEST_TEMPLATE.md`) and the per-repo config (`.claude/git-workflow.json`, committed so the team shares it) — detect, don't impose.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install git-workflow@quantori-engineering
```

## Roadmap

- `/changelog` — draft release notes from merged history between two refs (Conventional Commits make this nearly mechanical).
