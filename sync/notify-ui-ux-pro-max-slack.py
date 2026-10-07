#!/usr/bin/env python3
"""Optional Slack DM for ui-ux-pro-max upstream sync (GHA).

Env:
  SLACK_BOT_TOKEN, SLACK_DM_USER_ID (required to send)
  STATUS: up_to_date | synced
  UPSTREAM_SHORT, UPSTREAM_SHA, RUN_URL
  COMMIT_SHA (optional; when STATUS=synced)
"""
from __future__ import annotations

import json
import os
import sys
import urllib.request


def slack(token: str, method: str, payload: dict) -> dict:
    req = urllib.request.Request(
        f"https://slack.com/api/{method}",
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; charset=utf-8",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)


def main() -> int:
    token = os.environ.get("SLACK_BOT_TOKEN", "").strip()
    user = os.environ.get("SLACK_DM_USER_ID", "").strip()
    if not token or not user:
        print("SLACK_BOT_TOKEN / SLACK_DM_USER_ID not set — skip GHA Slack.")
        return 0

    status = os.environ["STATUS"]
    short = os.environ["UPSTREAM_SHORT"]
    sha = os.environ["UPSTREAM_SHA"]
    run_url = os.environ["RUN_URL"]
    commit = os.environ.get("COMMIT_SHA") or ""

    if status == "synced":
        text = (
            f"ui-ux-pro-max 已 sync 到 upstream `{short}` 並 push Melessa。\n\n"
            f"- Upstream: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/commit/{sha}\n"
            f"- Melessa commit: `{commit}`\n"
            f"- Actions: {run_url}\n\n"
            "本機：`git pull origin main`\n"
            "設計師（UIUX-Skills）：`./scripts/update-skills.sh`"
        )
    else:
        text = (
            f"ui-ux-pro-max 已是最新（upstream `{short}`）。無需 sync。\n\n"
            f"Actions: {run_url}"
        )

    opened = slack(token, "conversations.open", {"users": user})
    if not opened.get("ok"):
        print(f"conversations.open failed: {opened}", file=sys.stderr)
        return 1
    channel = opened["channel"]["id"]
    posted = slack(token, "chat.postMessage", {"channel": channel, "text": text})
    if not posted.get("ok"):
        print(f"chat.postMessage failed: {posted}", file=sys.stderr)
        return 1
    print("Slack DM sent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
