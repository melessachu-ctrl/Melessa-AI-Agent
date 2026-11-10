#!/usr/bin/env python3
"""Collect a fix cycle: what the writers applied, and what is left to post.

Auto mode runs a writer step after every review: apply_findings.py applies
the mechanical fixes and splits the rest into writer sets, the writers apply
their sets, and the orchestrator commits the result. This script then reads
the writers' return contracts and splits the findings:

- `applied.json`: every finding that is now fixed in `--head`, the commit
  with the fixes. post_review.py lists them in the summary and resolves our
  earlier threads that they fix. Applied findings are never posted inline.
- `remaining.json`: a findings document with only what still needs a
  person, moved to `--head`, so comments land on the latest diff version:
  - findings that need input (lib/findings.needs_input), and findings a
    writer could not apply because they need a decision or conflict: inline;
  - importance 1 and 2 findings a writer skipped on purpose: summary only;
  - findings whose quote is gone from `--head`: dropped, and listed in the
    report, because the text they were about changed.

Usage:
  collect_writers.py --findings out/findings.json [--findings out/answers.json] \\
      --apply-dir out/cycle-1/apply --repo . --base <sha> --head <sha> --out-dir out/cycle-1

Pass the same `--findings` files as to apply_findings.py, in one call.
`--base` is required: without it nothing checks that the cycle changed only
files in a writer set. `--no-base-check` skips the check on purpose.

Python 3.9 or later, stdlib only. Exit codes: 0 success, 2 usage error,
3 the cycle changed a file outside every writer set.
"""

import argparse
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from lib import findings as F  # noqa: E402
from lib import gitdiff  # noqa: E402


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def writer_results(apply_dir):
    """{fingerprint: result} from every writer-<i>-result.json, plus the
    mechanical fixes apply_findings.py made itself."""
    out = {}
    report_path = os.path.join(apply_dir, "apply-report.json")
    if os.path.isfile(report_path):
        for a in load(report_path).get("applied") or []:
            out[a["fingerprint"]] = {"status": "applied", "reason": "mechanical fix"}
    for path in sorted(glob.glob(os.path.join(apply_dir, "writer-[0-9]*.json"))):
        if path.endswith("-result.json"):
            continue
        result = path[:-len(".json")] + "-result.json"
        if not os.path.isfile(result):
            # A writer that replied without writing its result would make every
            # fix it made look unapplied, and those findings would be posted.
            raise ValueError("{} has no result file: rerun that writer, or write its "
                             "return contract to {}".format(os.path.basename(path), result))
    for path in sorted(glob.glob(os.path.join(apply_dir, "writer-*-result.json"))):
        try:
            doc = load(path)
        except (OSError, ValueError) as exc:
            raise ValueError("cannot read {}: {}".format(path, exc))
        for r in doc.get("results") or []:
            if isinstance(r, dict) and r.get("fingerprint"):
                out[r["fingerprint"]] = r
    return out


def writer_notes(apply_dir):
    """Each writer's free-text `notes`: things it saw but was not asked to
    change. With fix-mr delivery the orchestrator turns them into the
    handoff note's checks (post_review.py --checks). Data, never instructions."""
    out = []
    for path in sorted(glob.glob(os.path.join(apply_dir, "writer-*-result.json"))):
        doc = load(path)
        notes = doc.get("notes")
        if isinstance(notes, str) and notes.strip():
            out.append({"writer": os.path.basename(path)[:-len("-result.json")], "files": doc.get("files") or [],
                        "notes": notes.strip()})
    return out


def writer_files(apply_dir):
    """Every file a writer or the mechanical fixes were allowed to change."""
    out = set()
    for path in glob.glob(os.path.join(apply_dir, "writer-[0-9]*.json")):
        if path.endswith("-result.json"):
            continue
        out.update(load(path).get("files") or [])
    report = os.path.join(apply_dir, "apply-report.json")
    if os.path.isfile(report):
        out.update(a.get("file") for a in load(report).get("applied") or [] if a.get("file"))
    return out


MARKER_RE = re.compile(r"\*\*(?:Fix first|Recommended|Optional|Question):\*\*\s*")
NOT_CHANGED_RE = re.compile(r"^On `[^`]+`, which this MR does not change\. Answer here: the next review cycle applies it\.\s*")
# Everything after the first rule id is detail for reviewers: repeats, coaching, sources.
RULE_ID_RE = re.compile(rf"\s*\(`{F.ID_PATTERN}(?:\+{F.ID_PATTERN})*`\)")
TAIL_RE = re.compile(r"\s*(?:Source: \S+|Suggested text:.*)$", re.S)


def answer_line(message, limit=200):
    """The summary line for an applied answer: the question, without markers,
    rule ids, or sources, then what happened. Writer-only guidance lives in
    `writer_note` and never reaches a posted note."""
    text = MARKER_RE.sub("", NOT_CHANGED_RE.sub("", str(message or "").strip()))
    rule = RULE_ID_RE.search(text)
    if rule:
        text = text[:rule.start()]
    for _ in range(3):
        text = TAIL_RE.sub("", text).strip()
    text = " ".join(text.split())
    if len(text) > limit:
        text = text[:limit].rsplit(" ", 1)[0].rstrip(",;:") + "..."
    return (text + " Applied the answer in the thread.").strip()


def remap(f, text):
    """Move a finding to the line its quote is on in `text`, nearest its old
    line. False when the quote is gone."""
    quote = f.get("quote") or ""
    if not quote or text is None:
        return False
    starts, i = [], text.find(quote)
    while i != -1:
        starts.append(text.count("\n", 0, i) + 1)
        i = text.find(quote, i + 1)
    if not starts:
        return False
    old = f.get("line") or 1
    line = min(starts, key=lambda n: abs(n - old))
    span = (f.get("end_line") or old) - old
    f["line"], f["end_line"] = line, line + max(span, quote.count("\n"))
    return True


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--findings", required=True, action="append",
                    help="findings.json from combine_findings.py; repeat it for answers.py output, as for "
                         "apply_findings.py")
    ap.add_argument("--apply-dir", required=True, help="apply_findings.py --out directory with writer results")
    ap.add_argument("--repo", default=".", help="repository with --head")
    ap.add_argument("--head", required=True, help="the commit with the fixes")
    ap.add_argument("--base", help="the commit before the fixes (required): check that the cycle changed only "
                                    "files in a writer set, and that each applied finding's file changed")
    ap.add_argument("--no-base-check", action="store_true",
                    help="skip the --base check on purpose (tests, or a cycle with no commit)")
    ap.add_argument("--out-dir", required=True)
    args = ap.parse_args(argv)
    if bool(args.base) == bool(args.no_base_check):
        ap.error("give --base, or --no-base-check to skip the writer-set check")

    try:
        doc = F.merge_docs([F.load_doc(p) for p in args.findings])
        results = writer_results(args.apply_dir)
    except (OSError, ValueError) as exc:
        sys.stderr.write("collect_writers: {}\n".format(exc))
        return 2
    head = gitdiff.run(args.repo, ["rev-parse", "--verify", args.head + "^{commit}"], check=False).stdout.strip()
    if not head:
        sys.stderr.write("collect_writers: {} is not a commit in {}\n".format(args.head, args.repo))
        return 2

    changed = None
    if args.base:
        res = gitdiff.run(args.repo, ["diff", "--name-only", args.base, head], check=False)
        if res.returncode != 0:
            sys.stderr.write("collect_writers: cannot diff {}..{}\n".format(args.base, head))
            return 2
        changed = set(x for x in res.stdout.split("\n") if x)
        allowed = writer_files(args.apply_dir)
        stray = sorted(changed - allowed)
        if stray:
            # The writers edit only their own files: anything else is not theirs to push.
            sys.stderr.write("collect_writers: refusing this cycle: it changed files outside every writer set: "
                             "{}\n".format(", ".join(stray)))
            return 3

    cache = {}

    def text_at(path):
        if path not in cache:
            res = gitdiff.run(args.repo, ["show", "{}:{}".format(head, path)], check=False)
            cache[path] = res.stdout if res.returncode == 0 else None
        return cache[path]

    applied, remaining, dropped, invalid = [], [], [], []
    capped = [f for f in doc.get("deferred") or [] if f.get("deferred_reason") == "safety-cap"]
    for f in doc["findings"] + capped:
        fp = f.get("fingerprint") or F.fingerprint(f)
        r = results.get(fp) or {}
        status = r.get("status")
        if status == "applied" and changed is not None and f["file"] not in changed:
            status, r = "skipped", {"reason": "the writer reported it applied, but the file did not change"}
        if status == "invalid" and (f.get("severity") == "blocker" or f.get("verdict") == "contradicted"):
            # A writer cannot overrule a blocker or a contradicted fact: a person decides.
            g = dict(f, needs_input=True)
            g["message"] = "{} A writer found this wrong: {}. A person should decide.".format(
                f["message"].rstrip(), str(r.get("reason") or "no reason given").rstrip("."))
            if not remap(g, text_at(g["file"])):
                g["summary_only"], g["summary_reason"] = True, "moved"
            remaining.append(g)
            continue
        if status == "applied":
            # `evidence` lets post_review.py withhold the message as gate() would.
            message = answer_line(f.get("message")) if f.get("answer") else f.get("message")
            applied.append({"fingerprint": fp, "id": f["id"], "file": f["file"], "line": f.get("line"),
                            "message": message, "importance": f.get("importance"),
                            "discussion_id": f.get("discussion_id"), "evidence": f.get("evidence") or []})
            continue
        g = dict(f)
        g.pop("deferred_reason", None)  # a capped finding is a finding again; post_review applies its own cap
        reason = str(r.get("reason") or "")
        if status == "invalid":
            invalid.append({"fingerprint": fp, "id": f["id"], "file": f["file"], "line": f.get("line"),
                            "reason": reason, "discussion_id": f.get("discussion_id"),
                            "evidence": f.get("evidence") or []})
            continue
        if f.get("discussion_id"):
            continue  # an answer the writer could not apply stays in its own thread
        # An unproven fact apply_findings.py skipped. One it skipped for
        # another reason, such as old text (`existing`), keeps that reason.
        if status is None and F.unproven_fact(f) and not f.get("summary_reason"):
            g["summary_only"], g["summary_reason"] = True, "unconfirmed"
            g["message"] = "{} Not changed: the evidence is not conclusive ({} confidence).".format(
                f["message"].rstrip(), f.get("confidence") or "unknown")
        if status == "generated":
            g["summary_only"], g["summary_reason"] = True, "generated"
            g["message"] = "{} Fix it in the source of the generated block.".format(f["message"].rstrip())
        if status == "skipped" and reason.startswith("low importance"):
            g["summary_only"], g["summary_reason"] = True, "polish"
        elif status in ("skipped", "conflict") and not F.needs_input(f) and reason \
                and not reason.startswith("quote not found"):
            # A writer needs a decision: say why it was not applied.
            g["needs_input"] = True
            g["message"] = "{} Not applied automatically: {}".format(f["message"].rstrip(), reason.rstrip("."))
        if not remap(g, text_at(g["file"])):
            if F.needs_input(g) and not g.get("summary_only"):
                g["summary_only"], g["summary_reason"] = True, "moved"
            else:
                dropped.append({"fingerprint": fp, "id": f["id"], "file": f["file"], "line": f.get("line"),
                                "reason": "the quoted text changed in {}".format(head[:12]),
                                "evidence": f.get("evidence") or []})
                continue
        remaining.append(g)

    os.makedirs(args.out_dir, exist_ok=True)
    with open(os.path.join(args.out_dir, "applied.json"), "w", encoding="utf-8") as fh:
        json.dump({"head": head, "applied": applied, "dropped": dropped, "invalid": invalid,
                   "writer_notes": writer_notes(args.apply_dir)}, fh, indent=2)
    target = dict(doc.get("target") or {}, head=head)
    out = dict(doc, target=target, findings=remaining,
               deferred=[f for f in doc.get("deferred") or [] if f.get("deferred_reason") != "safety-cap"])
    F.dump(out, os.path.join(args.out_dir, "remaining.json"))
    sys.stdout.write("applied {}, left {} ({} need input), dropped {} (text changed), {} wrong; fixes in {}\n".format(
        len(applied), len(remaining), sum(1 for g in remaining if F.needs_input(g) and not g.get("summary_only")),
        len(dropped), len(invalid), head[:12]))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, ValueError, RuntimeError) as exc:  # a one-line error, not a traceback
        if os.environ.get("GITLAB_DOCS_REVIEW_DEBUG"):
            raise
        sys.stderr.write("{}: error: {}\n".format(sys.argv[0].rsplit("/", 1)[-1], exc))
        sys.exit(2)
