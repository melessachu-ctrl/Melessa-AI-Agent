#!/usr/bin/env bash
# Tests for scripts/apply_findings.py. No network, no credentials.
set -Eeuo pipefail

# Git exports these to hooks. Inherited, they point the repos these tests create
# at the caller's repository.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_PREFIX

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../scripts/apply_findings.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0

check() {
    # check <description> <python expression over the report `r`>
    if python3 -c "import json,sys; r=json.load(open(sys.argv[1])); sys.exit(0 if ($2) else 1)" "$TMP/out/apply-report.json"; then
        echo "ok - $1"
    else
        echo "not ok - $1" >&2
        fail=1
    fi
}

mkdir -p "$TMP/repo/doc"
cat >"$TMP/repo/doc/page.md" <<'EOF'
# Example

In order to create a project, select **New project**.

You can utilize the API.
Second line of a paragraph.

Unchanged line.
EOF
cp "$TMP/repo/doc/page.md" "$TMP/original.md"
printf 'Other page.\n' >"$TMP/repo/doc/other.md"

cat >"$TMP/findings.json" <<'EOF'
{"version": 1, "findings": [
  {"id": "lint.in-order-to", "reviewer": "lint", "severity": "minor", "confidence": "high",
   "file": "doc/page.md", "line": 3, "end_line": 3, "quote": "In order to create",
   "message": "Use 'To' instead of 'In order to'.", "fixable": "auto",
   "suggestion": "To create a project, select **New project**.", "source": "https://docs.gitlab.com/x", "deterministic": true},
  {"id": "word-list.utilize", "reviewer": "lint", "severity": "major", "confidence": "high",
   "file": "doc/page.md", "line": 5, "end_line": 5, "quote": "utilize",
   "message": "Use 'use' instead.", "fixable": "auto",
   "suggestion": "You can use the API.", "source": "https://docs.gitlab.com/x", "deterministic": true},
  {"id": "brevity.merge-lines", "reviewer": "brevity", "severity": "major", "confidence": "high",
   "file": "doc/page.md", "line": 5, "end_line": 6, "quote": "Second line",
   "message": "Overlaps the word-list fix.", "fixable": "auto",
   "suggestion": "You can use the API in one line.", "source": "https://docs.gitlab.com/x", "deterministic": false},
  {"id": "lint.stale", "reviewer": "lint", "severity": "minor", "confidence": "high",
   "file": "doc/page.md", "line": 8, "end_line": 8, "quote": "text that is not there",
   "message": "Quote does not match.", "fixable": "auto",
   "suggestion": "Changed.", "source": "https://docs.gitlab.com/x", "deterministic": true},
  {"id": "style.rewrite", "reviewer": "style", "severity": "major", "confidence": "high",
   "file": "doc/other.md", "line": 1, "end_line": 1, "quote": "Other page.",
   "message": "Rewrite.", "fixable": "suggest", "suggestion": "Another page.", "source": "https://docs.gitlab.com/x", "deterministic": false},
  {"id": "structure.move", "reviewer": "structure", "severity": "minor", "confidence": "medium",
   "file": "doc/other.md", "line": 1, "end_line": 1, "quote": "Other page.",
   "message": "Move this section.", "fixable": "manual", "source": "https://docs.gitlab.com/x", "deterministic": false}
]}
EOF

# Dry run: no file changes, a patch is written.
python3 "$SCRIPT" --findings "$TMP/findings.json" --repo "$TMP/repo" --out "$TMP/out" --dry-run >/dev/null
if cmp -s "$TMP/repo/doc/page.md" "$TMP/original.md"; then echo "ok - dry run leaves files unchanged"; else echo "not ok - dry run changed a file" >&2; fail=1; fi
check "dry run writes a patch" "__import__('os').path.getsize(sys.argv[1].replace('apply-report.json','apply.patch')) > 0"

# Real run.
rm -rf "$TMP/out"
python3 "$SCRIPT" --findings "$TMP/findings.json" --repo "$TMP/repo" --out "$TMP/out" >/dev/null
check "two mechanical fixes applied" "len(r['applied']) == 2"
check "overlapping fix becomes a conflict" "any('overlaps' in c['reason'] for c in r['conflicts'])"
check "stale quote becomes a conflict" "any('no longer matches' in c['reason'] for c in r['conflicts'])"
check "manual finding with medium confidence is skipped under the auto policy" "len(r['skipped']) == 1"
check "conflicts and the suggest finding go to writers" "sum(s['findings'] for s in r['writer_sets']) == 3"
check "a file is in only one writer set" "len([f for s in r['writer_sets'] for f in s['files']]) == len({f for s in r['writer_sets'] for f in s['files']})"

if grep -q '^To create a project' "$TMP/repo/doc/page.md" && grep -q '^You can use the API.$' "$TMP/repo/doc/page.md" && grep -q '^Unchanged line.$' "$TMP/repo/doc/page.md"; then
    echo "ok - file content is correct after apply"
else
    echo "not ok - file content after apply:" >&2
    cat "$TMP/repo/doc/page.md" >&2
    fail=1
fi

# Policy all: the manual finding reaches a writer too.
rm -rf "$TMP/out"
cp "$TMP/original.md" "$TMP/repo/doc/page.md"
python3 "$SCRIPT" --findings "$TMP/findings.json" --repo "$TMP/repo" --out "$TMP/out" --policy all --partition 1 >/dev/null
check "policy all sends the manual finding to a writer" "sum(s['findings'] for s in r['writer_sets']) == 4 and len(r['writer_sets']) == 1"

# Usage error.
if python3 "$SCRIPT" --findings "$TMP/findings.json" --partition 0 >/dev/null 2>&1; then
    echo "not ok - --partition 0 should fail" >&2; fail=1
else
    echo "ok - --partition 0 is a usage error"
fi

# A CRLF file keeps its line endings after a fix.
crlf="$(mktemp -d)"
printf 'Line one.\r\nUse utilize here.\r\nEnd.\r\n' > "$crlf/a.md"
cat > "$crlf/f.json" << 'JSON'
{"findings": [{"id": "lint.word-list.utilize", "reviewer": "lint", "severity": "minor", "confidence": "high", "file": "a.md", "line": 2, "quote": "Use utilize here.", "message": "m", "fixable": "auto", "suggestion": "Use use here.", "deterministic": true, "importance": 2, "source": "x"}]}
JSON
python3 "$SCRIPT" --findings "$crlf/f.json" --repo "$crlf" --out "$crlf/out" > /dev/null 2>&1 || true
if [ "$(cat "$crlf/a.md")" = "$(printf 'Line one.\r\nUse use here.\r\nEnd.\r')" ]; then
    echo "ok - a fix keeps CRLF line endings"
else
    echo "FAIL - a fix keeps CRLF line endings"; fail=1
fi
rm -rf "$crlf"

# A finding cannot write outside the repo, and one with no quote is never applied mechanically.
esc="$(mktemp -d)"
mkdir -p "$esc/repo"
printf 'keep me\n' > "$esc/victim.txt"
printf 'Line.\n' > "$esc/repo/a.md"
cat > "$esc/f.json" << 'JSON'
{"findings": [
 {"id": "lint.x", "reviewer": "lint", "severity": "minor", "confidence": "high", "file": "../victim.txt", "line": 1, "quote": "keep me", "message": "m", "fixable": "auto", "suggestion": "owned", "deterministic": true, "importance": 2, "source": "x"},
 {"id": "lint.y", "reviewer": "lint", "severity": "minor", "confidence": "high", "file": "a.md", "line": 1, "quote": "", "message": "m", "fixable": "auto", "suggestion": "Changed.", "deterministic": true, "importance": 2, "source": "x"}]}
JSON
python3 "$SCRIPT" --findings "$esc/f.json" --repo "$esc/repo" --out "$esc/out" > /dev/null 2>&1 || true
if [ "$(cat "$esc/victim.txt")" = "keep me" ] && [ "$(cat "$esc/repo/a.md")" = "Line." ] \
  && grep -q 'file outside the repo' "$esc/out/apply-report.json"; then
    echo "ok - a file outside the repo and a finding with no quote are not applied"
else
    echo "FAIL - a file outside the repo and a finding with no quote are not applied"; fail=1
fi
rm -rf "$esc"

# Auto mode: --policy input sends everything but questions to writers, and
# collect_writers.py splits what was applied from what still needs a person.
if command -v git > /dev/null 2>&1; then
cw="$(mktemp -d)"
git -C "$cw" init -q -b main
mkdir -p "$cw/doc"
printf 'Line one.\nYou can utilize it.\nPick a size.\nOld text here.\n' > "$cw/doc/a.md"
git -C "$cw" add -A && git -C "$cw" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qm base
cat > "$cw/f.json" << 'JSON'
{"version": 1, "target": {"head": "x"}, "findings": [
 {"id": "editor.word-list.utilize", "reviewer": "editor", "severity": "minor", "confidence": "medium", "file": "doc/a.md", "line": 2, "end_line": 2, "quote": "You can utilize it.", "message": "Use use.", "fixable": "suggest", "suggestion": "You can use it.", "source": "x", "deterministic": false, "importance": 2, "fingerprint": "1111111111111111111111111111111111111111"},
 {"id": "facts.size", "reviewer": "facts", "severity": "major", "confidence": "low", "file": "doc/a.md", "line": 3, "end_line": 3, "quote": "Pick a size.", "message": "**Question:** which sizes exist?", "fixable": "manual", "source": "x", "deterministic": false, "importance": 4, "fingerprint": "2222222222222222222222222222222222222222"},
 {"id": "editor.style.x", "reviewer": "editor", "severity": "minor", "confidence": "high", "file": "doc/a.md", "line": 4, "end_line": 4, "quote": "Old text here.", "message": "Old.", "fixable": "manual", "source": "x", "deterministic": false, "importance": 3, "summary_only": true, "summary_reason": "existing", "fingerprint": "3333333333333333333333333333333333333333"},
 {"id": "editor.style.y", "reviewer": "editor", "severity": "minor", "confidence": "high", "file": "doc/a.md", "line": 1, "end_line": 1, "quote": "Line one.", "message": "Merge the lines.", "fixable": "manual", "source": "x", "deterministic": false, "importance": 3, "fingerprint": "4444444444444444444444444444444444444444"}]}
JSON
python3 "$SCRIPT" --findings "$cw/f.json" --repo "$cw" --out "$cw/apply" --policy input > /dev/null
if python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); r=json.load(open(sys.argv[2])); fps=[f["fingerprint"][0] for f in d["findings"]]; sys.exit(0 if sorted(fps)==["1","4"] and sum(1 for s in r["skipped"] if s.get("needs_input"))==1 else 1)' "$cw/apply/writer-1.json" "$cw/apply/apply-report.json"; then
    echo "ok - --policy input sends everything but questions and old text to writers"
    python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d["deferred"]=[dict(d["findings"][0], fingerprint="5"*40, line=2, deferred_reason="safety-cap")]; json.dump(d, open(sys.argv[1]+".cap", "w"))' "$cw/f.json"
    python3 "$SCRIPT" --findings "$cw/f.json.cap" --repo "$cw" --out "$cw/apply-cap" --policy input > /dev/null
    if grep -q 5555555555 "$cw/apply-cap/writer-1.json"; then echo "ok - findings over the safety cap still go to writers"; else echo "FAIL - findings over the safety cap still go to writers"; fail=1; fi
    python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); d["findings"].append(dict(d["findings"][3], id="facts.x", reviewer="facts", confidence="medium", fingerprint="8"*40)); json.dump(d, open(sys.argv[1]+".uf", "w"))' "$cw/f.json"
    python3 "$SCRIPT" --findings "$cw/f.json.uf" --repo "$cw" --out "$cw/apply-uf" --policy input > /dev/null
    if ! grep -q 8888888888 "$cw/apply-uf/writer-1.json" && grep -q '"unproven": true' "$cw/apply-uf/apply-report.json"; then echo "ok - an unproven fact is not changed and not asked"; else echo "FAIL - an unproven fact is not changed and not asked"; fail=1; fi
else
    echo "FAIL - --policy input sends everything but questions and old text to writers"; fail=1
fi
# A writer applies one finding and needs a decision on another.
printf 'Line one.\nYou can use it.\nPick a size.\nOld text here.\n' > "$cw/doc/a.md"
git -C "$cw" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qam fixes
cat > "$cw/apply/writer-1-result.json" << 'JSON'
{"writer": "writer-1", "results": [{"fingerprint": "1111111111111111111111111111111111111111", "status": "applied"},
 {"fingerprint": "4444444444444444444444444444444444444444", "status": "skipped", "reason": "needs a decision: which line to keep"}]}
JSON
python3 "$HERE/../scripts/collect_writers.py" --findings "$cw/f.json" --apply-dir "$cw/apply" --repo "$cw" --no-base-check --head HEAD --out-dir "$cw/out" > /dev/null
if python3 -c '
import json,sys
a=json.load(open(sys.argv[1])); r=json.load(open(sys.argv[2]))
by={f["fingerprint"][0]: f for f in r["findings"]}
ok = [x["fingerprint"][0] for x in a["applied"]] == ["1"] and sorted(by) == ["2","3","4"]
ok = ok and by["4"].get("needs_input") and "Not applied automatically: needs a decision" in by["4"]["message"]
ok = ok and r["target"]["head"] == a["head"] and len(a["head"]) == 40
sys.exit(0 if ok else 1)' "$cw/out/applied.json" "$cw/out/remaining.json"; then
    echo "ok - collect_writers splits applied from what needs a person, at the fix commit"
else
    echo "FAIL - collect_writers splits applied from what needs a person, at the fix commit"; fail=1
fi
# Round 3: the cycle may change only writer-set files; "applied" needs a changed file; a writer cannot drop a blocker.
base2="$(git -C "$cw" rev-parse HEAD)"
printf 'other\n' > "$cw/stray.md"
printf 'Line one changed.\nYou can use it.\nPick a size.\nOld text here.\n' > "$cw/doc/a.md"
git -C "$cw" add -A && git -C "$cw" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qm cycle2
rc=0; python3 "$HERE/../scripts/collect_writers.py" --findings "$cw/f.json" --apply-dir "$cw/apply" --repo "$cw" --base "$base2" --head HEAD --out-dir "$cw/out2" > /dev/null 2> "$cw/err" || rc=$?
if [ "$rc" -eq 3 ] && grep -q "stray.md" "$cw/err"; then echo "ok - a cycle that changes a file outside every writer set is refused"; else echo "FAIL - stray file refusal (rc $rc)"; fail=1; fi
git -C "$cw" rm -q stray.md && git -C "$cw" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qm unstray
python3 -c '
import json,sys
p=sys.argv[1]; d=json.load(open(p))
d["results"]=[{"fingerprint":"1"*40,"status":"applied"},{"fingerprint":"4"*40,"status":"invalid","reason":"looks fine"}]
json.dump(d,open(p,"w"))' "$cw/apply/writer-1-result.json"
python3 -c '
import json,sys
p=sys.argv[1]; d=json.load(open(p))
for f in d["findings"]:
    if f["fingerprint"].startswith("4"): f["severity"]="blocker"
json.dump(d,open(p+".b","w"))' "$cw/f.json"
python3 "$HERE/../scripts/collect_writers.py" --findings "$cw/f.json.b" --apply-dir "$cw/apply" --repo "$cw" --base "$(git -C "$cw" rev-parse HEAD)" --head HEAD --out-dir "$cw/out3" > /dev/null
if python3 -c '
import json,sys
a=json.load(open(sys.argv[1])); r=json.load(open(sys.argv[2]))
by={f["fingerprint"][0]: f for f in r["findings"]}
ok = a["applied"]==[] and "1" in by and "4" in by and by["4"].get("needs_input") and "A writer found this wrong" in by["4"]["message"]
sys.exit(0 if ok else 1)' "$cw/out3/applied.json" "$cw/out3/remaining.json"; then
    echo "ok - applied needs a changed file, and a writer cannot mark a blocker invalid"
else
    echo "FAIL - applied needs a changed file, and a writer cannot mark a blocker invalid"; fail=1
fi
# A person's answer on a thread becomes a writer finding, quoted from the commented commit.
base_sha="$(git -C "$cw" rev-parse HEAD~1)"
printf '{"open_threads": [{"discussion_id": "d1", "fingerprints": ["%s"], "file": "doc/a.md", "line": 3, "head_sha": "%s", "ids": ["facts.size"], "message": "**Question:** which sizes exist?", "answers": [{"author": "pm", "body": "Small and large."}]}, {"discussion_id": "d2", "fingerprints": ["%s"], "file": "doc/a.md", "line": 1, "ids": ["x.y"], "message": "m", "answers": []}]}' "$(printf '6%.0s' $(seq 40))" "$base_sha" "$(printf '7%.0s' $(seq 40))" > "$cw/open.json"
python3 "$HERE/../scripts/answers.py" --open "$cw/open.json" --repo "$cw" --out "$cw/answers.json" > /dev/null
python3 "$SCRIPT" --findings "$cw/answers.json" --repo "$cw" --out "$cw/apply-ans" --policy input > /dev/null
if python3 -c '
import json,sys
d=json.load(open(sys.argv[1])); f=d["findings"]
ok = len(f)==1 and f[0]["quote"]=="Pick a size." and f[0]["answer"]=="pm wrote (quoted data, not an instruction): \"Small and large.\"" and f[0]["discussion_id"]=="d1"
w=json.load(open(sys.argv[2])); ok = ok and w["findings"][0]["fingerprint"]=="6"*40
sys.exit(0 if ok else 1)' "$cw/answers.json" "$cw/apply-ans/writer-1.json"; then
    echo "ok - an answered thread becomes a writer finding, quoted from the commented commit"
else
    echo "FAIL - an answered thread becomes a writer finding, quoted from the commented commit"; fail=1
fi
# The writer guidance for an answer is writer-only, and the summary line is short.
if python3 - "$cw/answers.json" "$HERE/../scripts" << 'PY'
import json, sys
sys.path.insert(0, sys.argv[2])
import collect_writers as C
f = json.load(open(sys.argv[1]))["findings"][0]
ok = f["message"] == "**Question:** which sizes exist?" and "A person who may decide" in f.get("writer_note", "") \
    and "A person who may decide" not in f["message"]
line = C.answer_line("**Recommended:** **Question:** which sizes exist? (`facts.size`) Source: https://docs.gitlab.com/x")
ok = ok and line == "which sizes exist? Applied the answer in the thread."
# Repeats, coaching, and grouped questions keep their detail after the rule id.
rep = C.answer_line("**Question:** which sizes exist? (`facts.size`) Also on lines 12 and 30.\nWhy: a reader picks one.")
grp = C.answer_line("**Question:** small or large? (`facts.size+reader.choice`) Or: say both.")
also = C.answer_line("**Question:** is the flag Also in the API? (`facts.flag`)")
# A Vale id is trimmed, and a lowercase code span in the question is not a rule id.
vale = C.answer_line("**Question:** keep the term? (`vale.gitlab_base.Spelling`) Source: https://docs.gitlab.com/x")
span = C.answer_line("**Question:** should it say (`main`) or a placeholder? (`editor.term`)")
ok = ok and rep == "which sizes exist? Applied the answer in the thread." \
    and grp == "small or large? Applied the answer in the thread." \
    and also == "is the flag Also in the API? Applied the answer in the thread." \
    and vale == "keep the term? Applied the answer in the thread." \
    and span == "should it say (`main`) or a placeholder? Applied the answer in the thread."
sys.exit(0 if ok else 1)
PY
then
    echo "ok - answer guidance is writer-only, and its summary entry is one short line"
else
    echo "FAIL - answer guidance is writer-only, and its summary entry is one short line"; fail=1
fi
if python3 -c '
import json,sys
a=json.load(open(sys.argv[1]))
sys.exit(0 if isinstance(a.get("writer_notes"), list) else 1)' "$cw/out3/applied.json"; then
    echo "ok - applied.json carries the writers' notes for the handoff checks"
else
    echo "FAIL - applied.json carries the writers' notes for the handoff checks"; fail=1
fi
# A writer that replied without writing its result file stops the cycle, instead of every fix it made being posted.
mv "$cw/apply/writer-1-result.json" "$cw/apply/kept.json"
rc=0; python3 "$HERE/../scripts/collect_writers.py" --findings "$cw/f.json" --apply-dir "$cw/apply" --repo "$cw" --no-base-check --head HEAD --out-dir "$cw/out4" > /dev/null 2> "$cw/err" || rc=$?
if [ "$rc" -ne 0 ] && grep -q "writer-1.json has no result file" "$cw/err" && [ ! -e "$cw/out4/remaining.json" ]; then
    echo "ok - a missing writer result file stops the cycle"
else
    echo "FAIL - a missing writer result file stops the cycle (rc $rc)"; fail=1
fi
mv "$cw/apply/kept.json" "$cw/apply/writer-1-result.json"
rm -rf "$cw"

# Round 4.
r4="$(mktemp -d)"
git -C "$r4" init -q -b main
mkdir -p "$r4/doc"
printf 'Alpha line.\nBeta line.\nGamma line.\n' > "$r4/doc/a.md"
printf 'One.\nTwo.\n' > "$r4/doc/b.md"
git -C "$r4" add -A && git -C "$r4" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qm base
base4="$(git -C "$r4" rev-parse HEAD)"

# Under --policy input a mechanical fix passes the same checks as a writer's:
# no unproven fact, no old text, no question. Other policies apply them as before.
cat > "$r4/m8.json" << 'JSON'
{"version": 1, "target": {"head": "x"}, "findings": [
 {"id": "facts.version", "reviewer": "facts", "severity": "major", "confidence": "medium", "file": "doc/a.md", "line": 1, "end_line": 1, "quote": "Alpha line.", "message": "Says 19.2.", "fixable": "auto", "suggestion": "Alpha line 19.3.", "source": "x", "deterministic": false, "importance": 4, "fingerprint": "1111111111111111111111111111111111111111"},
 {"id": "editor.style.x", "reviewer": "editor", "severity": "minor", "confidence": "high", "file": "doc/a.md", "line": 2, "end_line": 2, "quote": "Beta line.", "message": "Old.", "fixable": "auto", "suggestion": "Beta.", "source": "x", "deterministic": true, "importance": 3, "summary_only": true, "summary_reason": "existing", "fingerprint": "2222222222222222222222222222222222222222"},
 {"id": "editor.style.y", "reviewer": "editor", "severity": "minor", "confidence": "high", "file": "doc/a.md", "line": 3, "end_line": 3, "quote": "Gamma line.", "message": "**Question:** Gamma or Delta?", "fixable": "auto", "suggestion": "Delta line.", "source": "x", "deterministic": true, "importance": 3, "fingerprint": "3333333333333333333333333333333333333333"}]}
JSON
python3 "$SCRIPT" --findings "$r4/m8.json" --repo "$r4" --out "$r4/apply8" --policy input > /dev/null
if [ -z "$(git -C "$r4" status --porcelain doc)" ] && python3 -c '
import json,sys
r=json.load(open(sys.argv[1])); by={s["fingerprint"][0]: s for s in r["skipped"]}
ok = r["applied"]==[] and r["writer_sets"]==[] and sorted(by)==["1","2","3"]
ok = ok and by["1"]["unproven"] and "old text" in by["2"]["reason"] and by["3"]["needs_input"]
sys.exit(0 if ok else 1)' "$r4/apply8/apply-report.json"; then
    echo "ok - --policy input never applies a mechanical unproven fact, old text, or question"
else
    echo "FAIL - --policy input never applies a mechanical unproven fact, old text, or question"; fail=1
fi
# A finding the author settled (`summary_reason: decided`) never reaches a writer.
python3 -c '
import json,sys
d=json.load(open(sys.argv[1])); f=dict(d["findings"][1]); f.update(fingerprint="9"*40, summary_reason="decided", summary_only=True, fixable="suggest", quote="Gamma line.", line=3, end_line=3, message="Settled.", confidence="high", reviewer="editor")
d["findings"]=[f]; json.dump(d,open(sys.argv[2],"w"))' "$r4/m8.json" "$r4/m9.json"
python3 "$SCRIPT" --findings "$r4/m9.json" --repo "$r4" --out "$r4/apply9" --policy input > /dev/null
if python3 -c '
import json,sys
r=json.load(open(sys.argv[1]))
ok = r["writer_sets"]==[] and r["applied"]==[] and r["skipped"] and "settled" in r["skipped"][0]["reason"]
sys.exit(0 if ok else 1)' "$r4/apply9/apply-report.json"; then
    echo "ok - --policy input never sends a settled finding to a writer"
else
    echo "FAIL - --policy input never sends a settled finding to a writer"; fail=1
fi
python3 "$SCRIPT" --findings "$r4/m9.json" --repo "$r4" --out "$r4/apply9s" --policy safe > /dev/null
if python3 -c '
import json,sys
r=json.load(open(sys.argv[1]))
sys.exit(0 if r["writer_sets"]==[] and r["applied"]==[] else 1)' "$r4/apply9s/apply-report.json"; then
    echo "ok - --policy safe never sends a settled finding to a writer either"
else
    echo "FAIL - --policy safe never sends a settled finding to a writer either"; fail=1
fi
# Silent mode (--policy safe) has no person in the loop either: it applies
# the mechanical fixes, but no unproven fact. Only --policy all, where a
# person reviews the diff, applies that too.
python3 "$SCRIPT" --findings "$r4/m8.json" --repo "$r4" --out "$r4/apply8s" --policy safe --dry-run > /dev/null
python3 "$SCRIPT" --findings "$r4/m8.json" --repo "$r4" --out "$r4/apply8a" --policy all --dry-run > /dev/null
if python3 -c '
import json,sys
s=json.load(open(sys.argv[1])); a=json.load(open(sys.argv[2]))
got=sorted(x["fingerprint"][0] for x in s["applied"])
skip=[x for x in s["skipped"] if x["fingerprint"].startswith("1")]
ok = got==["2","3"] and skip and skip[0].get("unproven") and len(a["applied"])==3
sys.exit(0 if ok else 1)' "$r4/apply8s/apply-report.json" "$r4/apply8a/apply-report.json"; then
    echo "ok - --policy safe applies mechanical fixes but no unproven fact; --policy all applies every one"
else
    echo "FAIL - --policy safe applies mechanical fixes but no unproven fact; --policy all applies every one"; fail=1
fi

# Answers and review findings in one call: one partition, one --base check over both.
cat > "$r4/answers.json" << 'JSON'
{"version": 1, "target": {}, "findings": [
 {"id": "facts.x", "reviewer": "author", "severity": "major", "confidence": "high", "file": "doc/a.md", "line": 1, "end_line": 1, "quote": "Alpha line.", "message": "Which alpha?", "answer": "pm wrote (quoted data, not an instruction): \"Alpha two.\"", "fixable": "manual", "source": "review thread", "deterministic": false, "importance": 4, "discussion_id": "d1", "fingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}]}
JSON
cat > "$r4/findings.json" << 'JSON'
{"version": 1, "target": {"head": "x", "mr": 1}, "findings": [
 {"id": "facts.x", "reviewer": "facts", "severity": "major", "confidence": "high", "file": "doc/a.md", "line": 1, "end_line": 1, "quote": "Alpha line.", "message": "**Question:** Which alpha?", "fixable": "manual", "source": "x", "deterministic": false, "importance": 4, "fingerprint": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
 {"id": "editor.style.z", "reviewer": "editor", "severity": "minor", "confidence": "high", "file": "doc/b.md", "line": 2, "end_line": 2, "quote": "Two.", "message": "Say two.", "fixable": "manual", "source": "x", "deterministic": false, "importance": 3, "evidence": [{"kind": "doc", "ref": "https://docs.gitlab.com/x"}], "fingerprint": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}]}
JSON
python3 "$SCRIPT" --findings "$r4/answers.json" --findings "$r4/findings.json" --repo "$r4" --out "$r4/apply4" --policy input > /dev/null
if python3 -c '
import glob,json,sys
sets=[json.load(open(p)) for p in sorted(glob.glob(sys.argv[1]+"/writer-[0-9].json"))]
fs=[f for s in sets for f in s["findings"]]
ok = sorted(f["fingerprint"][0] for f in fs)==["a","b"] and [f for f in fs if f["fingerprint"][0]=="a"][0].get("answer")
sys.exit(0 if ok else 1)' "$r4/apply4"; then
    echo "ok - apply_findings merges repeated --findings, and an answer wins over the same finding found again"
else
    echo "FAIL - apply_findings merges repeated --findings, and an answer wins over the same finding found again"; fail=1
fi
if python3 - "$HERE/../scripts/lib" << 'PY'; then
import sys
sys.path.insert(0, sys.argv[1])
from findings import merge_docs
a = {"target": {"mr": 1}, "findings": [{"fingerprint": "f1", "message": "m"}], "deferred": [{"fingerprint": "f2"}]}
b = {"findings": [{"fingerprint": "f1", "message": "m", "answer": "yes"}],
     "deferred": [{"fingerprint": "f1", "deferred_reason": "safety-cap"}, {"fingerprint": "f2"}]}
m = merge_docs([a, b])
assert m["target"] == {"mr": 1}
assert [f["fingerprint"] for f in m["findings"]] == ["f1"] and m["findings"][0]["answer"] == "yes"
assert [f["fingerprint"] for f in m["deferred"]] == ["f2"], m["deferred"]
PY
    echo "ok - merge_docs keeps one copy per fingerprint across findings and deferred"
else
    echo "FAIL - merge_docs keeps one copy per fingerprint across findings and deferred"; fail=1
fi
cp "$r4/apply4/apply-report.json" "$r4/report-before.json"
rc=0; python3 "$SCRIPT" --findings "$r4/findings.json" --repo "$r4" --out "$r4/apply4" --policy input > /dev/null 2> "$r4/err" || rc=$?
if [ "$rc" -eq 2 ] && grep -q "already holds an earlier run" "$r4/err" && cmp -s "$r4/apply4/apply-report.json" "$r4/report-before.json"; then
    echo "ok - a second apply_findings call does not overwrite an earlier run's --out"
else
    echo "FAIL - a second apply_findings call does not overwrite an earlier run's --out (rc $rc)"; fail=1
fi
python3 -c '
import glob,json,sys
for p in glob.glob(sys.argv[1]+"/writer-[0-9].json"):
    s=json.load(open(p))
    json.dump({"results": [{"fingerprint": f["fingerprint"], "status": "applied"} for f in s["findings"]]}, open(p[:-5]+"-result.json","w"))' "$r4/apply4"
printf 'Alpha two.\nBeta line.\nGamma line.\n' > "$r4/doc/a.md"
printf 'One.\nSay two.\n' > "$r4/doc/b.md"
git -C "$r4" -c user.name=t -c user.email=t@e.com -c commit.gpgsign=false commit -qam cycle
rc=0; python3 "$HERE/../scripts/collect_writers.py" --findings "$r4/answers.json" --findings "$r4/findings.json" --apply-dir "$r4/apply4" --repo "$r4" --base "$base4" --head HEAD --out-dir "$r4/out4" > /dev/null 2> "$r4/err" || rc=$?
if [ "$rc" -eq 0 ] && python3 -c '
import json,sys
a=json.load(open(sys.argv[1])); by={x["fingerprint"][0]: x for x in a["applied"]}
ok = sorted(by)==["a","b"] and by["a"]["discussion_id"]=="d1" and by["b"]["evidence"][0]["kind"]=="doc"
sys.exit(0 if ok else 1)' "$r4/out4/applied.json"; then
    echo "ok - one collect_writers call over answers and findings passes the --base check and keeps evidence"
else
    echo "FAIL - one collect_writers call over answers and findings (rc $rc: $(cat "$r4/err"))"; fail=1
fi
rc=0; python3 "$HERE/../scripts/collect_writers.py" --findings "$r4/findings.json" --apply-dir "$r4/apply4" --repo "$r4" --head HEAD --out-dir "$r4/out5" > /dev/null 2> "$r4/err" || rc=$?
if [ "$rc" -eq 2 ] && grep -q -- "--no-base-check" "$r4/err" && [ ! -e "$r4/out5" ]; then
    echo "ok - collect_writers needs --base unless --no-base-check"
else
    echo "FAIL - collect_writers needs --base unless --no-base-check (rc $rc)"; fail=1
fi

# An old-text fact keeps `existing` (no "Not changed" suffix), and a writer cannot mark a contradicted fact invalid.
mkdir -p "$r4/apply9"
cat > "$r4/f9.json" << 'JSON'
{"version": 1, "target": {"head": "x"}, "findings": [
 {"id": "facts.old", "reviewer": "facts", "severity": "minor", "confidence": "medium", "file": "doc/a.md", "line": 3, "end_line": 3, "quote": "Gamma line.", "message": "Old claim.", "fixable": "manual", "source": "x", "deterministic": false, "importance": 3, "summary_only": true, "summary_reason": "existing", "fingerprint": "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"},
 {"id": "facts.wrong", "reviewer": "facts", "severity": "major", "confidence": "high", "verdict": "contradicted", "file": "doc/a.md", "line": 2, "end_line": 2, "quote": "Beta line.", "message": "The code says otherwise.", "fixable": "manual", "source": "x", "deterministic": false, "importance": 4, "fingerprint": "cccccccccccccccccccccccccccccccccccccccc"}]}
JSON
printf '{"files": ["doc/a.md"], "findings": []}' > "$r4/apply9/writer-1.json"
printf '{"results": [{"fingerprint": "cccccccccccccccccccccccccccccccccccccccc", "status": "invalid", "reason": "The page is right."}]}' > "$r4/apply9/writer-1-result.json"
python3 "$HERE/../scripts/collect_writers.py" --findings "$r4/f9.json" --apply-dir "$r4/apply9" --repo "$r4" --no-base-check --head HEAD --out-dir "$r4/out9" > /dev/null
if python3 - "$HERE/../scripts" "$r4/out9/remaining.json" "$r4/out9/applied.json" << 'PY'; then
import json, sys
sys.path.insert(0, sys.argv[1])
import post_review as P
r = json.load(open(sys.argv[2])); a = json.load(open(sys.argv[3]))
by = {f["fingerprint"][0]: f for f in r["findings"]}
old, wrong = by["e"], by["c"]
assert old["summary_reason"] == "existing" and old["message"] == "Old claim.", old
assert "Existing issues on this page" in "\n".join(P.summary_only_sections([old]))
assert wrong.get("needs_input") and "A writer found this wrong: The page is right" in wrong["message"], wrong
assert a["invalid"] == [], a
PY
    echo "ok - an old-text fact stays in Existing issues, and a writer cannot mark a contradicted fact invalid"
else
    echo "FAIL - an old-text fact stays in Existing issues, and a writer cannot mark a contradicted fact invalid"; fail=1
fi
rm -rf "$r4"
else
    echo "ok - skipped the collect_writers checks: git is not installed"
fi

exit "$fail"
