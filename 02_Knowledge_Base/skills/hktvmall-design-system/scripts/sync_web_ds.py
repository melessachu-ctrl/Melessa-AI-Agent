#!/usr/bin/env python3
"""Sync HKTVmall web DS from this skill into a WebView / web frontend repo `ds/`.

Lives inside the installed plugin skill so Claude Code users can run it:

    python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target /path/to/webview-repo
    python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target . --icons icon-cart-regular-outlined,icon-search-regular-outlined
    python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target . --check

Always copies tokens/web + components/web (overwrites; skill wins).
Icons copy only when --icons is passed (on-demand).
Writes ds/PIN.json with meta.synced and content hashes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

# This file: <skill>/scripts/sync_web_ds.py → skill root is parent.parent
SKILL = Path(__file__).resolve().parent.parent
TOKENS_JSON = SKILL / "tokens/tokens.json"
TOKEN_CSS = SKILL / "tokens/web/hktv-tokens.css"
COMPONENTS_WEB = SKILL / "components/web"
ICONS_WEB = SKILL / "icons/web"

COMPONENT_FILES = (
    "hktv-button.css",
    "hktv-button.js",
    "hktv-price.css",
    "hktv-price.js",
    "hktv-cart-button.css",
    "hktv-cart-button.js",
    "hktv-text-field.css",
    "hktv-text-field.js",
    "hktv-dropdown.css",
    "hktv-dropdown.js",
    "hktv-phone-field.css",
    "hktv-phone-field.js",
)


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def load_meta_synced() -> str:
    data = json.loads(TOKENS_JSON.read_text(encoding="utf-8"))
    synced = (data.get("meta") or {}).get("synced")
    if not synced:
        raise SystemExit(f"missing meta.synced in {TOKENS_JSON}")
    return str(synced)


def expected_hashes() -> dict[str, str]:
    files: dict[str, Path] = {"hktv-tokens.css": TOKEN_CSS}
    for name in COMPONENT_FILES:
        files[name] = COMPONENTS_WEB / name
    out: dict[str, str] = {}
    for name, path in files.items():
        if not path.is_file():
            raise SystemExit(f"missing skill file: {path}")
        out[name] = sha256_file(path)
    return out


def read_pin(ds_dir: Path) -> dict | None:
    pin_path = ds_dir / "PIN.json"
    if not pin_path.is_file():
        return None
    try:
        return json.loads(pin_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def pin_matches(pin: dict | None, meta_synced: str, hashes: dict[str, str]) -> bool:
    if not pin:
        return False
    if str(pin.get("meta.synced") or pin.get("metaSynced") or "") != meta_synced:
        return False
    pin_hashes = pin.get("hashes") or {}
    for name, digest in hashes.items():
        if pin_hashes.get(name) != digest:
            return False
    return True


def files_match_disk(ds_dir: Path, hashes: dict[str, str]) -> bool:
    for name, digest in hashes.items():
        path = ds_dir / name
        if not path.is_file() or sha256_file(path) != digest:
            return False
    return True


def copy_core(ds_dir: Path, hashes: dict[str, str]) -> list[str]:
    ds_dir.mkdir(parents=True, exist_ok=True)
    synced: list[str] = []
    shutil.copy2(TOKEN_CSS, ds_dir / "hktv-tokens.css")
    synced.append("hktv-tokens.css")
    for name in COMPONENT_FILES:
        shutil.copy2(COMPONENTS_WEB / name, ds_dir / name)
        synced.append(name)
    return synced


def copy_icons(ds_dir: Path, names: list[str]) -> tuple[list[str], list[str]]:
    icons_dir = ds_dir / "icons"
    icons_dir.mkdir(parents=True, exist_ok=True)
    synced: list[str] = []
    missing: list[str] = []
    for raw in names:
        name = raw.strip()
        if not name:
            continue
        if not name.endswith(".svg"):
            name = f"{name}.svg"
        src = ICONS_WEB / name
        if not src.is_file():
            missing.append(name)
            continue
        shutil.copy2(src, icons_dir / name)
        synced.append(f"icons/{name}")
    return synced, missing


def write_pin(ds_dir: Path, meta_synced: str, hashes: dict[str, str], icons: list[str]) -> dict:
    pin = {
        "meta.synced": meta_synced,
        "syncedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source": "hktvmall-design-system",
        "hashes": hashes,
        "icons": sorted(set(icons)),
    }
    (ds_dir / "PIN.json").write_text(
        json.dumps(pin, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return pin


def existing_icons(ds_dir: Path) -> list[str]:
    icons_dir = ds_dir / "icons"
    if not icons_dir.is_dir():
        return []
    return sorted(p.name for p in icons_dir.glob("*.svg"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--target",
        required=True,
        help="WebView / web frontend repo root (ds/ will be created under it)",
    )
    parser.add_argument(
        "--icons",
        default="",
        help="Comma-separated icon base names or *.svg to copy into ds/icons/",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Only check whether ds/ matches skill; exit 1 if stale (no write)",
    )
    args = parser.parse_args()

    target = Path(args.target).expanduser().resolve()
    if not target.is_dir():
        print(f"error: target is not a directory: {target}", file=sys.stderr)
        return 2

    if not TOKEN_CSS.is_file() or not TOKENS_JSON.is_file():
        print(f"error: skill web tokens missing under {SKILL}", file=sys.stderr)
        return 2

    meta_synced = load_meta_synced()
    hashes = expected_hashes()
    ds_dir = target / "ds"
    pin = read_pin(ds_dir) if ds_dir.is_dir() else None
    up_to_date = (
        ds_dir.is_dir()
        and pin_matches(pin, meta_synced, hashes)
        and files_match_disk(ds_dir, hashes)
    )

    icon_names = [n for n in args.icons.split(",") if n.strip()]

    if args.check:
        status = "current" if up_to_date else "stale"
        print(
            json.dumps(
                {
                    "status": status,
                    "meta.synced": meta_synced,
                    "ds": str(ds_dir),
                    "pin": pin,
                },
                indent=2,
                ensure_ascii=False,
            )
        )
        return 0 if up_to_date else 1

    actions: list[str] = []
    if up_to_date:
        actions.append("skipped_core (PIN and hashes match skill)")
        synced_core: list[str] = []
    else:
        synced_core = copy_core(ds_dir, hashes)
        actions.append("synced_core (overwrite)")

    synced_icons: list[str] = []
    missing_icons: list[str] = []
    if icon_names:
        synced_icons, missing_icons = copy_icons(ds_dir, icon_names)
        actions.append(f"synced_icons ({len(synced_icons)})")

    icon_list = existing_icons(ds_dir)
    pin_out = write_pin(ds_dir, meta_synced, hashes, icon_list)

    result = {
        "target": str(target),
        "ds": str(ds_dir),
        "actions": actions,
        "synced": synced_core + synced_icons,
        "missingIcons": missing_icons,
        "pin": pin_out,
        "skill": str(SKILL),
    }
    print(json.dumps(result, indent=2, ensure_ascii=False))
    if missing_icons:
        print(
            f"warning: {len(missing_icons)} icon(s) not found in skill icons/web",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
