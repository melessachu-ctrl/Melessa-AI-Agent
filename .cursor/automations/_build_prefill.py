import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
lines = (root / "sync/cursor-automation-ui-ux-pro-max-monthly.md").read_text().splitlines()
# Prompt lives in the ```text ... ``` block that ends just before "## 建立步驟".
heading_idx = next(i for i, line in enumerate(lines) if line.startswith("## 建立步驟"))
start = next(i for i, line in enumerate(lines) if line.strip() == "```text") + 1
end = None
for i in range(heading_idx - 1, start - 1, -1):
    if lines[i].strip() == "```":
        end = i
        break
if end is None:
    raise SystemExit(f"prompt block not found: start={start} heading={heading_idx}")
prompt = "\n".join(lines[start:end])
assert "完成準則" in prompt
assert "有依賴改動 ⇒ 有 PR" in prompt

data = {
    "name": "Monthly ui-ux-pro-max dependency audit",
    "description": "每月檢查 Melessa 的 ui-ux-pro-max 是否剛 sync；審計依賴 skills；Slack `#melessa-cursor` 通知；有改動則開 PR 等確認",
    "workflow": {
        "triggers": [{"cron": {"cron": "0 10 1 * *"}}],
        "actions": [{"slack": {}}],
        "prompts": [{"prompt": prompt}],
        "gitConfig": {
            "repo": "melessachu-ctrl/Melessa-AI-Agent",
            "branch": "main",
        },
        "model": "",
        "agentOptions": {"skipInstall": False},
        "memoryEnabled": True,
    },
}
out = Path(__file__).with_name(
    "monthly-ui-ux-pro-max-dependency-audit.prefill.json"
)
out.write_text(json.dumps(data, ensure_ascii=False))
print(f"wrote {out} size={out.stat().st_size} prompt_len={len(prompt)}")
