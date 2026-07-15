# git-workflow

Git workflow atoms — language-agnostic, diff-driven. First competency outside `js/` because nothing here cares what language the repo is written in.

## Commands

| Command | Verb | What it does |
|---|---|---|
| `/pr-desc` | generate | Generates a ready-to-paste PR title + description from the branch diff vs the default branch (or a given base ref). Fills the repo's own PR template when one exists; otherwise uses the default shape from `rules/pr-style.md`. Never creates the PR itself. |

## How it's built

The command reads the diff (the truth), groups changes by intent, and writes for the reviewer. House style — title format, required sections, ticket-key rules — lives in **`rules/pr-style.md`**, the swappable seam: replace it with Quantori's PR conventions without touching the command. Repo-local templates (`.github/PULL_REQUEST_TEMPLATE.md`) always win over the seam — detect, don't impose.

## Install

```
/plugin marketplace add azatdavliatshin/quantori-engineering-marketplace
/plugin install git-workflow@quantori-engineering
```

## Roadmap

- `/commit-msg` — generate a commit message from staged changes, matching the repo's observed convention.
- `/changelog` — draft release notes from merged history between two refs.
