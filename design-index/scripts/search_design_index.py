#!/usr/bin/env python3
"""Keyword search over design-index/*.yaml (PoC helper)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Install PyYAML: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

INDEX_DIR = Path(__file__).resolve().parents[1]


def load_entries() -> list[dict]:
    entries: list[dict] = []
    for path in sorted(INDEX_DIR.glob("*.yaml")):
        with path.open(encoding="utf-8") as f:
            data = yaml.safe_load(f)
        if isinstance(data, dict):
            data["_file"] = path.name
            entries.append(data)
    return entries


def matches(entry: dict, query: str) -> bool:
    q = query.lower()
    haystack: list[str] = [
        str(entry.get("id", "")),
        str(entry.get("name", "")),
        str(entry.get("jira", "")),
        str(entry.get("status", "")),
    ]
    for kw in entry.get("keywords") or []:
        haystack.append(str(kw))
    figma = entry.get("figma") or {}
    haystack.append(str(figma.get("file_key", "")))
    blob = " ".join(haystack).lower()
    return q in blob or all(part in blob for part in q.split())


def main() -> None:
    parser = argparse.ArgumentParser(description="Search design-index YAML entries")
    parser.add_argument("query", nargs="+", help="Keywords (space-separated)")
    args = parser.parse_args()
    query = " ".join(args.query)

    hits = [e for e in load_entries() if matches(e, query)]
    if not hits:
        print("No matches.")
        return

    for e in hits:
        figma = e.get("figma") or {}
        print(f"{e.get('id')} [{e.get('status')}] — {e.get('name')}")
        print(f"  file: {e.get('_file')}")
        print(f"  url:  {figma.get('url', '(none)')}")
        print(f"  jira: {e.get('jira', '(none)')}")
        print()


if __name__ == "__main__":
    main()
