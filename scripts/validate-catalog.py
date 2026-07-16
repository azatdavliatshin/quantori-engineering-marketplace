#!/usr/bin/env python3
"""Validate the marketplace catalog structure and discipline rules.

Checks (all hard failures):
- marketplace.json parses; name and owner present
- every plugin entry: source dir exists, plugin.json exists/parses,
  names match, version present
- plugin names are globally unique and prefixed by their competency folder
- every plugin has a README.md
- description discipline: plugin + command + skill descriptions <= LIMIT chars
- every command .md has frontmatter with a description
- command names are unique across the whole catalog (installed plugins
  share one slash-command namespace)
"""
import json
import re
import sys
from pathlib import Path

LIMIT = 110  # hard cap; house discipline aims for ~100

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def frontmatter_description(md: Path) -> str | None:
    text = md.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return None
    d = re.search(r"^description:\s*(.+)$", m.group(1), re.MULTILINE)
    return d.group(1).strip() if d else None


def check_desc(owner: str, desc: str | None) -> None:
    if desc is None:
        err(f"{owner}: missing frontmatter description")
    elif len(desc) > LIMIT:
        err(f"{owner}: description is {len(desc)} chars (limit {LIMIT})")


def main() -> int:
    mp_path = ROOT / ".claude-plugin" / "marketplace.json"
    try:
        mp = json.loads(mp_path.read_text(encoding="utf-8"))
    except Exception as e:  # noqa: BLE001
        print(f"FATAL: {mp_path}: {e}")
        return 1

    for key in ("name", "owner", "plugins"):
        if key not in mp:
            err(f"marketplace.json: missing '{key}'")

    seen_plugins: set[str] = set()
    seen_commands: dict[str, str] = {}

    for entry in mp.get("plugins", []):
        name = entry.get("name", "<unnamed>")

        if name in seen_plugins:
            err(f"duplicate plugin name: {name}")
        seen_plugins.add(name)

        desc = entry.get("description")
        if desc is None:
            err(f"{name}: marketplace entry missing description")
        elif len(desc) > LIMIT:
            err(f"{name}: marketplace description is {len(desc)} chars (limit {LIMIT})")

        if "version" not in entry:
            err(f"{name}: marketplace entry missing version")

        src = entry.get("source", "")
        src_dir = (ROOT / src).resolve()
        if not src_dir.is_dir():
            err(f"{name}: source dir does not exist: {src}")
            continue

        competency = Path(src).parts[0] if Path(src).parts else ""
        if not name.startswith(f"{competency}-") and name != competency:
            err(f"{name}: name must be prefixed by its competency folder '{competency}-'")

        pj_path = src_dir / ".claude-plugin" / "plugin.json"
        if not pj_path.is_file():
            err(f"{name}: missing {pj_path.relative_to(ROOT)}")
        else:
            try:
                pj = json.loads(pj_path.read_text(encoding="utf-8"))
                if pj.get("name") != name:
                    err(f"{name}: plugin.json name '{pj.get('name')}' != marketplace name")
                if "version" not in pj:
                    err(f"{name}: plugin.json missing version")
                pdesc = pj.get("description")
                if pdesc and len(pdesc) > LIMIT:
                    err(f"{name}: plugin.json description is {len(pdesc)} chars (limit {LIMIT})")
            except Exception as e:  # noqa: BLE001
                err(f"{name}: plugin.json parse error: {e}")

        if not (src_dir / "README.md").is_file():
            err(f"{name}: missing README.md")

        for cmd in sorted((src_dir / "commands").glob("*.md")) if (src_dir / "commands").is_dir() else []:
            check_desc(f"{name}/commands/{cmd.name}", frontmatter_description(cmd))
            if cmd.stem in seen_commands:
                err(f"command name collision: /{cmd.stem} in both {seen_commands[cmd.stem]} and {name}")
            seen_commands[cmd.stem] = name

        skills_dir = src_dir / "skills"
        for skill_md in sorted(skills_dir.glob("*/SKILL.md")) if skills_dir.is_dir() else []:
            check_desc(f"{name}/skills/{skill_md.parent.name}", frontmatter_description(skill_md))

    if errors:
        print(f"FAIL — {len(errors)} problem(s):")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"OK — {len(seen_plugins)} plugins, {len(seen_commands)} commands validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
