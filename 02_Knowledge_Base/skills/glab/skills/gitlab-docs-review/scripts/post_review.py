#!/usr/bin/env python3
"""Post combined gitlab-docs-review findings to a GitLab MR: inline comments on the
reviewed diff version plus one summary note. Tier, technical writer, and
first-time writer come from `target` in findings.json.

Usage:
  post_review.py out/findings.json --project group/proj --mr 42 --dry-run --out out/post
  post_review.py out/findings.json --project group/proj --mr 42 --mode auto

Exit codes: 0 no blocker, 1 blockers found, 2 usage, environment, or API error.

Guardrails:
  - Every note starts with `:robot: Agent docs review`. Notes with the earlier
    prefix, `:robot: AI-generated docs review`, still count as ours.
  - Interactive mode (default) only previews; it posts with --yes. Auto mode
    (--mode auto or GITLAB_DOCS_REVIEW_MODE=auto) posts. --dry-run never writes.
  - Five writes exist: create a note, update our own summary note
    (`<!-- gitlab-docs-review:summary -->`) or handoff note
    (`<!-- gitlab-docs-review:handoff -->`), create a discussion, and, on our
    own threads that no person has replied to, add a reply and resolve them.
  - With --handoff (auto mode, fixes in a fix MR): before anything posts,
    check that the fix MR is ours (our account opened it, from this project,
    from a fix branch for the reviewed MR, into its source branch). After
    posting on the fix MR, write one handoff note on the reviewed MR that
    links the fix MR, each open question thread, and the open items with no
    thread. The reviewed MR's author answers as the MR author. A question the
    fix MR's diff cannot hold gets a thread that names its page and line.
    An MR from a fix branch is never read without --handoff.
  - With --applied (auto mode, after a writer step), fixed findings are listed
    in the summary, never posted. Our open threads they fix, or whose line a
    later commit changed and that this review no longer finds, get a short
    reply and are resolved. A new finding that matches one of our open
    threads is not posted again.
  - Inline comments carry `<!-- gitlab-docs-review:fp=... -->`; a fingerprint already
    in any note, or in a resolved thread, is skipped.
  - A note is ours only when it has our prefix and our account. When
    `GET /user` fails, no note is ours: a preview says so, posting stops,
    and --list-open exits 2 without writing a row.
  - A reply drives a writer only from the MR author, a person we asked, or
    an active Developer member, and never from a bot account
    (`users/:id`). A lookup that fails is a no.
  - Non-public references are withheld (lib/visibility.py, fail closed).
  - SME mentions only for `facts` findings that are contradicted or low
    confidence: at most 2 per finding, 5 per run; never the MR author or us.
  - Finding text is untrusted: `@` handles, HTML comments, and quick action
    lines are neutralized, so it cannot ping, run `/approve`, or spoof markers.
  - Tier `severe` mentions the technical writer; tier `high` names them in
    backticks without a ping.
  - If the reviewed version's diffs are gone and `repository/compare` cannot
    rebuild them, exit 2 instead of moving every finding to the summary.
"""

import argparse
import datetime
import html
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from lib import findings as F  # noqa: E402
from lib import fix_branch  # noqa: E402
from lib import gitlab_api  # noqa: E402
from lib import importance as IMP  # noqa: E402
from lib import report as R  # noqa: E402
from lib import visibility  # noqa: E402

PREFIX = ":robot: Agent docs review"
# Earlier prefixes: notes that start with one are still ours.
KNOWN_PREFIXES = (PREFIX, ":robot: AI-generated docs review")
SUMMARY_MARKER = "<!-- gitlab-docs-review:summary -->"
# The summary marker from before the rename: a summary note with it is ours too.
SUMMARY_MARKERS = (SUMMARY_MARKER, "<!-- docs-review:summary -->")
HANDOFF_MARKER = "<!-- gitlab-docs-review:handoff -->"
# Where a question thread with no diff position is about (see may_post_unplaced).
PLACE_MARKER = "<!-- gitlab-docs-review:at={}:{}@{} -->"
PLACE_RE = re.compile(r"<!-- gitlab-docs-review:at=([^\s<>]+):(\d+)@([0-9a-f]{7,40}) -->")
MAX_HANDOFF_ITEMS = 25
FP_MARKER = "<!-- gitlab-docs-review:fp={} -->"
# Our marker is always the last line, so a marker quoted inside a suggestion
# block cannot hide another finding.
FP_RE = re.compile(r"<!-- (?:gitlab-)?docs-review:fp=([0-9a-f]{40}(?:,[0-9a-f]{40})*) -->\s*$")
SHA_RE = re.compile(r"^[0-9a-f]{7,40}$")
MAX_MENTIONS = 5
MENTIONS_PER_FINDING = 2
DEFAULT_SAFETY_CAP = 50
MAX_SUMMARY_ITEMS = 50

# The only write endpoints this script may call.
ALLOWED_WRITES = (
    ("POST", re.compile(r"^projects/[^/]+/merge_requests/\d+/notes$")),
    ("PUT", re.compile(r"^projects/[^/]+/merge_requests/\d+/notes/\d+$")),
    ("POST", re.compile(r"^projects/[^/]+/merge_requests/\d+/discussions$")),
    ("POST", re.compile(r"^projects/[^/]+/merge_requests/\d+/discussions/([0-9a-f]+)/notes$")),
    ("PUT", re.compile(r"^projects/[^/]+/merge_requests/\d+/discussions/([0-9a-f]+)$")),
)
MATCH_LINES = 10  # a new finding within this many lines of our open thread, same file and rule, is that thread
QUICK_ACTION_RE = re.compile(r"^(\s*)/(?=[A-Za-z_])", re.M)
MENTION_RE = re.compile(r"(?<![A-Za-z0-9_])@([A-Za-z0-9_][A-Za-z0-9_.\-/]*)")
AT_ENTITY_RE = re.compile(r"&(?:#0*64(?!\d);?|#[xX]0*40(?![0-9A-Fa-f]);?|commat;)")
AT_RE = re.compile(r"(?<![A-Za-z0-9_])@(?!\u200b)")
BOT_RE = re.compile(r"(^|[-_.])bot($|[-_.\d])|^project_\d+_bot|^group_\d+_bot|^ghost$", re.I)


def warn(msg):
    sys.stderr.write("post_review: {}\n".format(msg))


class GuardrailError(RuntimeError):
    pass


# ---------------------------------------------------------------- text safety

def untrusted(text):
    """Make finding text safe to embed: no mentions, markers, or quick actions."""
    if text is None:
        return ""
    text = str(text)
    text = text.replace("<!--", "&lt;!--").replace("-->", "--&gt;")
    # GitLab decodes `&#64;`, `&#x40;` and `&commat;` before it looks for mentions, so
    # break the handle after the entity. A literal at-sign gets the same break whatever
    # follows it: `@&#100;x` is a mention once decoded. The lookbehind is ASCII-only like
    # GitLab's, so `é@name` is still a mention.
    text = AT_ENTITY_RE.sub(lambda m: m.group(0) + "\u200b", text)
    text = AT_RE.sub("@\u200b", text)
    return QUICK_ACTION_RE.sub(lambda m: m.group(1) + "\\/", text)


OPEN_FENCE_RE = re.compile(r"^(`{3,})[^`]*$")  # CommonMark: a backtick fence's info string has no backtick
CLOSE_FENCE_RE = re.compile(r"^(`{3,})[ \t]*$")


def one_line(text):
    """Untrusted text on one line, so it cannot open a fence or start a line."""
    return R.one_line(text, untrusted)


def _code_lines(lines):
    """Indexes of lines inside closed ``` fences that start at column 0: the only
    blocks GitLab's quick action parser skips. A line that only looks like a
    fence, such as ```a`b, is paragraph text, so it is not counted."""
    inside, start, fence = set(), None, None
    for i, line in enumerate(lines):
        if fence is None:
            m = OPEN_FENCE_RE.match(line)
            if m:
                start, fence = i, m.group(1)
            continue
        m = CLOSE_FENCE_RE.match(line)
        if m and len(m.group(1)) >= len(fence):
            inside.update(range(start, i + 1))
            start, fence = None, None
    return inside


def escape_quick_actions(body):
    """Escape lines that start with `/` outside closed fenced code blocks."""
    lines = body.split("\n")
    code = _code_lines(lines)
    return "\n".join(line if i in code else QUICK_ACTION_RE.sub(lambda m: m.group(1) + "\\/", line)
                     for i, line in enumerate(lines))


def check_body(body):
    if not body.startswith(PREFIX):
        raise GuardrailError("note body must start with the agent review prefix")
    lines = body.split("\n")
    code = _code_lines(lines)
    for i, line in enumerate(lines):
        if i not in code and re.match(r"^\s*/[A-Za-z_]", line):
            raise GuardrailError("note body contains a quick action line: {!r}".format(line[:60]))


def strip_prefix(body):
    for p in KNOWN_PREFIXES:
        if body.startswith(p):
            return body[len(p):]
    return body


def is_marked(body, markers):
    """A note of ours whose second line is one of `markers`: the summary or handoff note."""
    markers = (markers,) if isinstance(markers, str) else markers
    lines = body.split("\n")
    return len(lines) > 1 and lines[0] in KNOWN_PREFIXES and lines[1] in markers


CODE_SPAN_RE = re.compile(r"(`+)(?!`).+?(?<!`)\1(?!`)")


def live_mentions(body):
    """Lowercased handles GitLab would render as mentions: outside fenced code and code spans."""
    lines = body.split("\n")
    code = _code_lines(lines)
    text = "\n".join(line for i, line in enumerate(lines) if i not in code)
    text = html.unescape(CODE_SPAN_RE.sub("", text))
    return set(m.group(1).rstrip(".-/").lower() for m in MENTION_RE.finditer(text))


class SafeWriter(object):
    """Allowlisted writes only. In dry-run it records and never calls."""

    def __init__(self, api, dry_run, vis=None, own_threads=()):
        self.api = api
        self.dry_run = dry_run
        self.vis = vis
        self.own_threads = set(own_threads)  # discussions we may reply to or resolve
        self.redacted = 0
        self.planned = []
        self.mentionable = ()    # handles this run may mention (its MentionBudget.people)

    def write(self, method, endpoint, body, label):
        match = next((rx.match(endpoint) for m, rx in ALLOWED_WRITES if m == method and rx.match(endpoint)), None)
        if match is None:
            raise GuardrailError("write not allowed: {} {}".format(method, endpoint))
        thread = match.group(1) if match.groups() else None
        if thread is not None and thread not in self.own_threads:
            raise GuardrailError("not our thread, or a person replied to it: {}".format(thread))
        allowed = set(["resolved"]) if (method == "PUT" and thread) else set(["body", "position"])
        if set(body) - allowed or (method == "PUT" and thread and body != {"resolved": True}):
            raise GuardrailError("unexpected body keys: {}".format(sorted(set(body) - allowed) or body))
        if "body" not in body:
            self.planned.append({"method": method, "endpoint": endpoint, "body": body, "label": label})
            return None if self.dry_run else self.api.write(method, endpoint, body)
        if self.vis is not None:
            # The last gate: no rendered text names a reference that is not
            # confirmed public, whatever field it came from.
            text, n = visibility.redact_text(body["body"], self.vis)
            if n:
                body = dict(body, body=text)
                self.redacted += n
        check_body(body["body"])
        stray = live_mentions(body["body"]) - set(u.lower() for u in self.mentionable)
        if stray:
            raise GuardrailError("note body mentions someone this run did not choose: {}".format(sorted(stray)))
        self.planned.append({"method": method, "endpoint": endpoint, "body": body, "label": label})
        if self.dry_run:
            return None
        return self.api.write(method, endpoint, body)


# ---------------------------------------------------------------- MR context

def parse_diff_positions(diff):
    """{new_line: old_line or None} for lines a comment can attach to."""
    return parse_diff(diff)[0]


def parse_diff(diff):
    """({new_line: old_line or None} for the lines in the hunks, [(new_line,
    old_line)] at the start of each hunk). The hunk starts give the old line
    of an unchanged line outside the hunks."""
    pos, starts, old, new = {}, [], 0, 0
    for line in (diff or "").split("\n"):
        m = re.match(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@", line)
        if m:
            if starts:
                starts[-1] = starts[-1] + ((new, old),)
            old, new = int(m.group(1)), int(m.group(2))
            starts.append(((new, old),))
            continue
        if not line or line.startswith("\\"):
            continue
        tag = line[0]
        if tag == "+":
            pos[new] = None
            new += 1
        elif tag == "-":
            old += 1
        elif tag == " ":
            pos[new] = old
            new += 1
            old += 1
    if starts:
        starts[-1] = starts[-1] + ((new, old),)
    return pos, starts


def outside_old_line(starts, new_line, new_file=False):
    """The old line of `new_line` when it is an unchanged line outside every
    hunk, else None. GitLab accepts a note on such a line with both line
    numbers. An added file has no unchanged lines."""
    if new_file or not starts:
        return None
    prev_new, prev_old = 1, 1
    for hunk in starts:
        (h_new, _), (e_new, e_old) = hunk[0], hunk[1]
        if new_line < h_new:
            return prev_old + (new_line - prev_new)
        if new_line < e_new:
            return None
        prev_new, prev_old = e_new, e_old
    return prev_old + (new_line - prev_new)


class Context(object):
    def __init__(self):
        self.me = None
        self.author = None
        self.state = None
        self.refs = {}
        self.files = {}          # new_path -> {"old_path", "positions"}
        self.fps = set()         # fingerprints in notes other than our summary note
        self.resolved_fps = set()
        self.summary_note = None  # {"id", "discussion_id"}
        self.read_errors = []
        self.notes = []
        self.version = None       # the MR diff version used for positions
        self.inline_ok = True     # False when the reviewed head is not an MR version
        self.positions_error = None  # set when no diff could be read for positions
        self.visibility = None
        self.project_path = None  # group/project, for same-project references
        self.threads = []         # our inline threads: see load_context
        self.member_cache = {}
        self.ignored_answers = []  # replies from people who may not drive a writer
        self.web_url = None
        self.source_branch = None
        self.target_branch = None
        self.project_id = None


def sha_match(a, b):
    a, b = (a or "").lower(), (b or "").lower()
    if not SHA_RE.match(a) or not SHA_RE.match(b):
        return False
    return a.startswith(b) or b.startswith(a)


def pick_version(versions, head_sha):
    """(version, is_latest). With a head SHA, the version with that head_sha,
    or (None, False). Without one, the latest version."""
    if not versions:
        return None, False
    if not head_sha:
        return versions[0], True
    for i, v in enumerate(versions):
        if sha_match(v.get("head_commit_sha"), head_sha):
            return v, i == 0
    return None, False


def rebuild_diffs(api, base, refs):
    """(diffs, error) from read-only `repository/compare` for a version whose
    diffs GitLab pruned (replays of older MR versions hit this)."""
    b, h = refs.get("base_sha"), refs.get("head_sha")
    if not b or not h:
        return None, "the MR version has no base or head SHA"
    pid = base.split("/merge_requests/")[0]
    try:
        cmp_ = api.get("{}/repository/compare?{}".format(pid, gitlab_api.query({"from": b, "to": h, "straight": "true"})))
    except gitlab_api.GlabError as exc:
        return None, "repository/compare failed: {}".format(str(exc)[:160])
    diffs = cmp_.get("diffs") if isinstance(cmp_, dict) else None
    return (diffs, None) if diffs else (None, "repository/compare returned no diffs")


def load_context(api, project, mr, dry_run, head_sha=None, mr_author=None):
    """`mr_author`: with --handoff, the reviewed MR's author, who answers as
    the MR author on the fix MR (the fix MR's own author is us)."""
    ctx = Context()
    pid = gitlab_api.enc(project)
    base = "projects/{}/merge_requests/{}".format(pid, mr)

    def read(fn, label):
        try:
            return fn()
        except gitlab_api.GlabError as exc:
            if not dry_run:
                raise
            ctx.read_errors.append("{}: {}".format(label, str(exc)[:160]))
            return None

    me = read(lambda: api.get("user"), "current user")
    ctx.me = (me or {}).get("username") if isinstance(me, dict) else None
    if ctx.me is None:
        # Fail closed: with no account to compare, no note is ours.
        ctx.notes.append("The current user could not be read, so earlier notes of ours were not recognized. "
                         "This preview may repeat them.")
    info = read(lambda: api.get(base), "merge request")
    if isinstance(info, dict):
        ctx.author = mr_author or (info.get("author") or {}).get("username")
        full = str((info.get("references") or {}).get("full") or "")
        ctx.project_path = full.rsplit("!", 1)[0] or None
        ctx.state = info.get("state")
        ctx.refs = dict(info.get("diff_refs") or {})
        ctx.web_url = info.get("web_url")
        ctx.source_branch = info.get("source_branch")
        ctx.target_branch = info.get("target_branch")
        ctx.project_id = info.get("project_id")
    # Long-lived MRs have many versions: read them all, or the reviewed head is missed.
    versions = read(lambda: api.get_pages(base + "/versions", per_page=100, max_pages=20)[0], "versions")
    diffs = None
    if isinstance(versions, list) and versions:
        v, latest = pick_version(versions, head_sha)
        if v is None:
            ctx.refs = {}
            ctx.inline_ok = False
            ctx.notes.append("The reviewed head {} is not a diff version of this MR, so nothing was posted inline. "
                             "Rerun the review on the current head.".format(str(head_sha)[:12]))
        else:
            ctx.version = v.get("id")
            ctx.refs = {"base_sha": v.get("base_commit_sha"), "start_sha": v.get("start_commit_sha"),
                        "head_sha": v.get("head_commit_sha")}
            if latest:
                diffs = read(lambda: api.get_pages(base + "/diffs", per_page=50, max_pages=20)[0], "diffs")
                pruned = not diffs
            else:
                ver = read(lambda: api.get("{}/versions/{}".format(base, v.get("id"))), "version diffs")
                diffs = ver.get("diffs") if isinstance(ver, dict) else None
                # GitLab prunes the diffs of old versions: `diffs` comes back empty
                # and `state` is no longer `collected`.
                pruned = not diffs or (isinstance(ver, dict) and ver.get("state") not in (None, "collected"))
                ctx.notes.append("Inline positions use MR diff version {} (head {}), not the latest version.".format(
                    v.get("id"), str(v.get("head_commit_sha"))[:12]))
            if pruned:
                diffs, err = rebuild_diffs(api, base, ctx.refs)
                if diffs:
                    ctx.notes.append("The diffs of that version are no longer stored, so positions were rebuilt "
                                     "from repository/compare.")
                else:
                    ctx.positions_error = "MR diff version {} has no stored diffs, and rebuilding them failed: {}".format(
                        v.get("id"), err)
    elif head_sha and ctx.refs.get("head_sha") and not sha_match(ctx.refs.get("head_sha"), head_sha):
        ctx.refs = {}
        ctx.inline_ok = False
        ctx.notes.append("The reviewed head {} is not the MR head, so nothing was posted inline.".format(
            str(head_sha)[:12]))
    elif ctx.refs.get("head_sha"):
        diffs = read(lambda: api.get_pages(base + "/diffs", per_page=50, max_pages=20)[0], "diffs")
    for d in diffs or []:
        if d.get("deleted_file"):
            continue
        positions, starts = parse_diff(d.get("diff"))
        ctx.files[d.get("new_path")] = {"old_path": d.get("old_path"), "positions": positions, "starts": starts,
                                         "new_file": bool(d.get("new_file"))}
    discussions = read(lambda: api.get_pages(base + "/discussions", per_page=100, max_pages=20)[0], "discussions")
    summary_candidates = []
    for disc in discussions or []:
        notes = disc.get("notes") or []
        resolved = any(n.get("resolvable") and n.get("resolved") for n in notes)
        record_thread(ctx, disc, notes, resolved, api, pid)
        for n in notes:
            body = n.get("body") or ""
            if is_marked(body, SUMMARY_MARKERS):
                owner = (n.get("author") or {}).get("username")
                if ctx.me is not None and owner == ctx.me:
                    summary_candidates.append({"id": n.get("id"), "discussion_id": disc.get("id"),
                                               "created_at": n.get("created_at") or ""})
                    continue
            if not body.startswith(KNOWN_PREFIXES) or ctx.me is None \
                    or (n.get("author") or {}).get("username") != ctx.me:
                continue  # only our own comments count, or anyone could hide a finding
            for group in FP_RE.findall(body.rstrip()):
                for fp in group.split(","):
                    ctx.fps.add(fp)
                    if resolved:
                        ctx.resolved_fps.add(fp)
    if summary_candidates:
        summary_candidates.sort(key=lambda c: (c["created_at"], c["id"] or 0))
        ctx.summary_note = summary_candidates[0]
    return ctx


ID_IN_BODY_RE = re.compile(rf"\(`({F.ID_PATTERN})`\)")


ANSWER_MIN_ACCESS = 30  # Developer
# load_context reads that decide which threads are ours and who replied.
THREAD_READS = ("current user", "merge request", "discussions")


def ours(ctx, n):
    """Our note: the AI prefix and our account. Fails closed: when we do not
    know who we are, no note is ours."""
    return (n.get("body") or "").startswith(KNOWN_PREFIXES) and ctx.me is not None \
        and (n.get("author") or {}).get("username") == ctx.me


def may_answer(ctx, author, api, pid, asked):
    """Whether a reply may drive a writer: the MR author, a person a review
    note asked, or an active project member with at least the Developer role.
    Never a bot: the username is a cheap first check, then the account itself
    (`users/:id`), because a bot can have an ordinary name. Fails closed: a
    lookup that errors is a no."""
    name = (author or {}).get("username") or ""
    if not name or BOT_RE.search(name) or (author or {}).get("bot"):
        return False
    uid = (author or {}).get("id")
    if api is None or not uid:
        return False
    if not cached(ctx, ("user", uid), lambda: api.get("users/{}".format(uid)).get("bot") is False):
        return False
    if name == ctx.author or name in asked:
        return True

    def member():
        m = api.get("projects/{}/members/all/{}".format(pid, uid))
        return int(m.get("access_level") or 0) >= ANSWER_MIN_ACCESS \
            and m.get("membership_state") == "active"
    return cached(ctx, ("member", uid), member)


def cached(ctx, key, check):
    """check() once per key, cached in ctx.member_cache. An error or a reply
    that is not an object is False."""
    if key not in ctx.member_cache:
        try:
            ctx.member_cache[key] = bool(check())
        except Exception:  # noqa: BLE001 - not confirmed, so not allowed
            ctx.member_cache[key] = False
    return ctx.member_cache[key]


def asked_people(body):
    """The people a review note asked: live mentions that the run chose. A
    handle quoted from MR text carries a zero-width space, so it never counts."""
    return set(re.findall(r"(?<![A-Za-z0-9_`])@([A-Za-z0-9_][A-Za-z0-9_.\-]*)", body or ""))


def thread_place(body):
    """The place an unplaced question thread names: {new_path, new_line, head_sha} or {}.
    Only the last line before our fp marker counts, as for FP_RE: text above
    it, such as a quoted suggestion, cannot move the thread."""
    lines = [line for line in str(body or "").rstrip().split("\n") if line.strip()]
    m = PLACE_RE.fullmatch(lines[-2].strip()) if len(lines) >= 2 and FP_RE.search(lines[-1]) else None
    return {"new_path": m.group(1), "new_line": int(m.group(2)), "head_sha": m.group(3)} if m else {}


def record_thread(ctx, disc, notes, resolved, api=None, pid=None, mr=None):
    """Our inline thread, for repeat matching and resolving: its fingerprints,
    rule ids, place, whether a person replied, and whether a later commit
    changed its line (GitLab's "changed this line" system note)."""
    if not notes:
        return
    first = notes[0]
    body = first.get("body") or ""
    if not body.startswith(KNOWN_PREFIXES) or set(SUMMARY_MARKERS) & set(body.split("\n")[:2]):
        return
    if ctx.me is None or (first.get("author") or {}).get("username") != ctx.me:
        return  # not ours, or we do not know who we are: fail closed
    m = FP_RE.search(body.rstrip())
    if not m:
        return
    pos = first.get("position") or thread_place(body)
    # A person's note: anything that is not ours. A note with our prefix from
    # another account is a person's too.
    human = any(not n.get("system") and not ours(ctx, n) for n in notes[1:])
    outdated = any(n.get("system") and "changed this line" in (n.get("body") or "") for n in notes[1:])
    # A person's replies after our last note: answers for the next writer step.
    # Only people who may decide count: anyone else's reply is data for a
    # person to read, never an instruction for the writer.
    answers = []
    asked = asked_people(body)
    for n in notes[1:]:
        if n.get("system"):
            continue
        if ours(ctx, n):
            answers = []
        elif may_answer(ctx, n.get("author"), api, pid, asked):
            answers.append({"author": (n.get("author") or {}).get("username"), "body": n.get("body") or ""})
        else:
            ctx.ignored_answers.append({"discussion_id": disc.get("id"),
                                        "author": (n.get("author") or {}).get("username")})
    ctx.threads.append({"id": disc.get("id"), "note_id": first.get("id"), "mr": mr, "fps": set(m.group(1).split(",")),
                        "ids": ID_IN_BODY_RE.findall(body),
                        "file": pos.get("new_path"), "line": pos.get("new_line"), "resolved": resolved,
                        "head_sha": pos.get("head_sha"),
                        "human": human, "outdated": outdated, "answers": answers,
                        "message": " ".join(re.sub(r"<!--.*?-->|```.*?```", " ", strip_prefix(body), flags=re.S).split())[:3000],
                        "replied": [n.get("body") or "" for n in notes[1:] if not n.get("system")]})


def thread_for(f, threads):
    """Our thread about the same point: same fingerprint, or the same rule on
    the same file within MATCH_LINES lines."""
    fp, line = f.get("fingerprint"), f.get("line") or 0
    for t in threads:
        if fp and fp in t["fps"]:
            return t
    for t in threads:
        if t["file"] == f.get("file") and f.get("id") in t["ids"] and t["line"] \
                and abs(t["line"] - line) <= MATCH_LINES:
            return t
    return None


def open_threads(ctx):
    return [t for t in ctx.threads if not t["resolved"]]


def resolve_fixed(ctx, writer, endpoint_base, findings, applied, head, stale_threads=()):
    """Reply to and resolve our open threads that are fixed: an applied
    finding matches them, or a later commit changed their line and this
    review no longer finds them. A thread a person replied to stays open."""
    done = []
    applied_list = (applied or {}).get("applied") or []
    answered = {}
    for kind, items in (("applied", applied_list), ("invalid", (applied or {}).get("invalid") or [])):
        for a in items:
            if a.get("discussion_id"):
                answered.setdefault(a["discussion_id"], []).append((kind, a))
    for t in open_threads(ctx):
        if t["id"] in answered and t["answers"]:
            # The person answered our question and a writer acted on it.
            kind, a = primary_answer(t, answered[t["id"]])
            text = ("Applied your answer in {}.".format(head[:12]) if kind == "applied" else
                    "No change needed at {}: {}".format(head[:12], R.one_line(a.get("reason"), untrusted)))
            base = thread_base(endpoint_base, t)
            writer.write("POST", base + "/notes", {"body": PREFIX + "\n\n" + text}, "reply " + t["id"])
            writer.write("PUT", base, {"resolved": True}, "resolve " + t["id"])
            t["resolved"] = True
            done.append(t["id"])
            continue
        if t["human"] or thread_for_any(t, findings):
            continue
        hit = thread_for_any(t, applied_list)
        wrong = thread_for_any(t, (applied or {}).get("invalid") or [])
        stale = next((s for s in stale_threads if s.get("file") == t["file"] and set(s.get("ids") or []) & set(t["ids"])
                      and (not s.get("line") or not t["line"] or abs(s["line"] - t["line"]) <= MATCH_LINES)), None)
        if hit:
            text = "Applied in {}.".format(head[:12])
        elif stale:
            text = "No longer applies at {}: {}".format(head[:12], R.one_line(stale.get("reason"), untrusted))
        elif wrong:
            text = "Not a problem at {}: {}".format(head[:12], R.one_line(wrong.get("reason"), untrusted))
        elif t["outdated"]:
            text = "Fixed in {}: a later commit changed this line, and this review no longer finds the problem.".format(
                head[:12])
        else:
            continue
        base = thread_base(endpoint_base, t)
        writer.write("POST", base + "/notes", {"body": PREFIX + "\n\n" + text}, "reply " + t["id"])
        writer.write("PUT", base, {"resolved": True}, "resolve " + t["id"])
        t["resolved"] = True
        done.append(t["id"])
    return done


def primary_answer(t, entries):
    """One answer can reach several findings ("Also in" other pages). The
    reply speaks for the finding on the thread's own file, nearest its line;
    without one, the first by file and line, applied before invalid."""
    def key(e):
        kind, a = e
        own = a.get("file") == t.get("file")
        dist = abs((a.get("line") or 0) - (t.get("line") or 0)) if own else 0
        return (not own, dist, kind != "applied", a.get("file") or "", a.get("line") or 0)
    return sorted(entries, key=key)[0]


def thread_for_any(t, items):
    return next((f for f in items if thread_for(f, [t]) is t), None)


# ---------------------------------------------------------------- planning

def mention_eligible(f):
    return f.get("reviewer") == "facts" and (f.get("verdict") == "contradicted" or f.get("confidence") == "low")


class MentionBudget(object):
    """At most MAX_MENTIONS distinct people per run; never anyone in `exclude`."""

    def __init__(self, exclude, limit=MAX_MENTIONS):
        self.limit = limit
        self.people = []
        self.exclude = set(u.lower() for u in exclude if u)

    def take(self, usernames, limit=MENTIONS_PER_FINDING):
        picked = []
        for u in usernames:
            if not u or len(picked) >= limit:
                continue
            u = u.lstrip("@")
            if u.lower() in self.exclude or BOT_RE.search(u) or not re.match(r"^[A-Za-z0-9_][A-Za-z0-9_.\-]*$", u):
                continue
            if u not in self.people:
                if len(self.people) >= self.limit:
                    continue
                self.people.append(u)
            if u not in picked:
                picked.append(u)
        return picked


def sme_question(f, people):
    ev = next((e for e in f.get("evidence") or [] if isinstance(e, dict) and e.get("ref") != "non-public"), {})
    if ev.get("ref"):
        evidence = untrusted(ev.get("ref"))
    elif f.get("withheld_internal"):
        evidence = "internal, withheld from this comment"
    else:
        evidence = "none recorded"
    who = ", ".join("@" + p for p in people)
    claim = " ".join(untrusted(f.get("quote") or f.get("message")).split())
    return "{}, can you confirm whether this is accurate: \"{}\"? Evidence: {}".format(who, claim[:300], evidence)


def preservation_details(rows):
    """Brevity reviewer `preservation` facts as a collapsed table."""
    table = R.preservation_table(rows, untrusted)
    if not table:
        return []
    return ["", "<details><summary>Facts this change must keep ({})</summary>".format(len(rows)), ""] + table + \
        ["", "</details>"]


def plain_block(text):
    """Untrusted suggestion text shown as a plain code block, not a suggestion.
    The fence is longer than any backtick run in the text, so nothing inside can
    close it, and GitLab neither links mentions nor runs quick actions in it."""
    return R.fenced(str(text), "markdown", fence=R.fence_for(text))


def line_label(a):
    where = R.span(a)
    return " ({})".format(where) if where else ""


def conflict_notes(members, by_fp):
    """One line for each conflict (`conflicts_with`) of a finding in this
    comment: a fix that cuts text another fix keeps."""
    out, seen = [], set()
    here = set(m["fingerprint"] for m in members)
    for m in members:
        for fp in m.get("conflicts_with") or []:
            pair = tuple(sorted((m["fingerprint"], fp)))
            other = by_fp.get(fp)
            if pair in seen or other is None:
                continue
            seen.add(pair)
            where = "in this comment" if fp in here else "on{}".format(line_label(other).replace(" (", " ").rstrip(")"))
            out.append("Conflict: `{}` and `{}` ({}) disagree. One cuts text that the other keeps. "
                       "Pick one.".format(untrusted(m["id"]), untrusted(other["id"]), where))
    return ["", "\n".join("- " + o for o in out)] if out else []


# Summary reasons that still post a question inline: the answer comes back in
# its thread, so a question only in the summary can never be answered and
# applied. Settled and unconfirmed findings stay in the summary.
ASK_INLINE_REASONS = ("existing", "reader", "polish")


def asks_inline(f):
    return F.needs_input(f) and f.get("summary_reason") in ASK_INLINE_REASONS


def may_post_unplaced(f, args, ctx):
    """With fix-mr delivery (--handoff), a question on a line the fix MR does
    not change still gets a thread on the fix MR, with its place in the text
    and an `at` marker, so its answer comes back. Only for a plain file path
    and a known head: the marker must parse back."""
    return args.handoff is not None and F.needs_input(f) and f.get("summary_only") is not True \
        and ctx.inline_ok and bool(SHA_RE.match(str(ctx.refs.get("head_sha") or args.head_sha or "").lower())) \
        and isinstance(f.get("line"), int) and bool(re.match(r"^[^\s<>:]+$", str(f.get("file") or "")))


def position_for(f, ctx):
    rng = F.line_range(f)
    if f.get("summary_only") is True or not ctx.inline_ok:
        return None
    if rng is None or not ctx.refs.get("head_sha"):
        return None
    info = ctx.files.get(f.get("file"))
    if not info:
        return None
    if rng[0] not in info["positions"]:
        # A question needs a thread for its answer, so it can sit on an
        # unchanged line of a changed file, outside the hunks: GitLab expands
        # the diff to show it. Other findings there go to the summary.
        outside = None
        if f.get("suggestion") is None and F.needs_input(f):
            outside = outside_old_line(info.get("starts"), rng[0], info.get("new_file"))
        if outside is None:
            return None
        return {"position_type": "text", "base_sha": ctx.refs.get("base_sha"),
                "start_sha": ctx.refs.get("start_sha"), "head_sha": ctx.refs.get("head_sha"),
                "old_path": info["old_path"] or f["file"], "new_path": f["file"],
                "new_line": rng[0], "old_line": outside}
    # A multi-line suggestion needs every line in the diff.
    if f.get("suggestion") is not None and any(n not in info["positions"] for n in range(rng[0], rng[1] + 1)):
        return None
    pos = {"position_type": "text", "base_sha": ctx.refs.get("base_sha"), "start_sha": ctx.refs.get("start_sha"),
           "head_sha": ctx.refs.get("head_sha"), "old_path": info["old_path"] or f["file"], "new_path": f["file"],
           "new_line": rng[0]}
    old_line = info["positions"][rng[0]]
    if old_line is not None:
        pos["old_line"] = old_line
    return pos


IMPORTANCE_LABELS = {5: "Fix first", 4: "Fix first", 3: "Recommended", 2: "Optional", 1: "Optional"}
DEFERRED_TEXT = {"safety-cap": "over the safety cap", "importance-1": "cosmetic (importance 1), kept in the report",
                 "alternative": "alternatives to a more important suggestion"}
DEFERRED_OTHER = "kept in the report"
# The orientation for a first-time docs writer: at most 3 sentences, plain words.
ORIENTATION = ("Thanks for working on the docs. Each comment below says why it matters and links to the rule in "
               "the GitLab documentation style guide. Start with the comments marked **Fix first**, and ask in "
               "the thread if anything is unclear.")
MAX_ALTERNATIVES = 3


WITHHELD_TEXT = "Details withheld: they name an item that is not public."


def gate_applied(applied, stale, vis):
    """The writer step's lists and reasons, with any text that names an item
    not confirmed public replaced whole, as gate() does for findings: the text
    may describe the item as well as name it. An entry whose evidence names
    such an item is withheld too, even when its text names nothing: gate()
    withholds that finding's message, so the list does the same. Evidence
    marked `non-public` keeps the text, as in gate()."""
    def clean(item, keys):
        item = dict(item)
        _, leaked = visibility.gate({"evidence": item.get("evidence") or []}, vis)
        for k in keys:
            v = item.get(k)
            if isinstance(v, str) and (leaked or any(not vis.public(r) for r in vis.refs(v))):
                item[k] = WITHHELD_TEXT
        item.pop("evidence", None)
        return item
    if applied is not None:
        applied = dict(applied)
        for k in ("applied", "invalid", "dropped"):
            applied[k] = [clean(a, ("message", "reason")) for a in applied.get(k) or []]
    return applied, [clean(s, ("reason",)) for s in stale or []]


def public_entries(entries, vis):
    """(entries, dropped): free text that names an item not confirmed public is
    dropped whole, because it may describe the item as well as name it."""
    kept = [x for x in entries or [] if not (isinstance(x, str) and any(not vis.public(r) for r in vis.refs(x)))]
    return kept, len(kept) < len(entries or [])


def coaching_line(f):
    why = " ".join(untrusted(f.get("why")).split())
    if not why:
        return []
    src = one_line(f.get("source")) if f.get("source") else ""
    return ["", "Why: {}{}".format(why, " See [the rule]({}).".format(src) if src else "")]


def alternatives_line(members):
    """Other wordings or rules for these lines, one line each, never a second
    suggestion block."""
    alts, here = [], set(m.get("fingerprint") for m in members)
    for m in members:
        for a in m.get("alternatives") or []:
            # A finding already in this comment is not an alternative to it.
            if isinstance(a, dict) and a.get("message") and a.get("fingerprint") not in here \
                    and a.get("reason") != "covered":
                alts.append(a)
    if not alts:
        return []
    out = [""]
    for a in alts[:MAX_ALTERNATIVES]:
        out.append("- Alternative ({}): {}".format(R.code(untrusted(a.get("id"))), " ".join(untrusted(a.get("message")).split())))
    if len(alts) > MAX_ALTERNATIVES:
        out.append("- And {} more in the report.".format(len(alts) - MAX_ALTERNATIVES))
    return out


MAX_ALSO = 12


def repeats_line(f):
    also = [a for a in f.get("_also") or [] if F.line_range(a)]
    if not also:
        return []
    if all(a.get("file") == f.get("file") for a in also):
        return ["", "Also on lines {}.".format(", ".join(str(F.line_range(a)[0]) for a in also))]
    where = [R.code(untrusted("{}:{}".format(a["file"], F.line_range(a)[0]))) for a in also[:MAX_ALSO]]
    more = " and {} more".format(len(also) - MAX_ALSO) if len(also) > MAX_ALSO else ""
    return ["", "Also in {}{}.".format(", ".join(where), more)]


def inline_body(group, mention_lines, by_fp=None, coaching=False, where=None, at=None):
    """One comment for a position or location group: one suggestion at most, alternatives as one line each, repeats as line
    numbers, and a coaching line for a first-time docs writer. `where` and `at`: the place line and marker of a
    thread with no diff position."""
    f = group[0]
    parts = [PREFIX, ""]
    if where:
        parts += [where, ""]
    parts.append("**{}:** {} (`{}`)".format(IMPORTANCE_LABELS[IMP.level(f)], one_line(f["message"]),
                                           one_line(f["id"])))
    shown = False
    if f.get("suggestion") is not None and f.get("fixable") in ("auto", "suggest"):
        # A note with no diff position cannot apply a suggestion: show the text.
        parts += [""] + (["Suggested text:", ""] + plain_block(f["suggestion"]) if at
                         else R.suggestion_block(f["suggestion"], F.line_range(f)))
        shown = True
    if coaching and f.get("why"):
        parts += coaching_line(f)
    elif f.get("source"):
        parts += ["", "Source: {}".format(one_line(f["source"]))]
    parts += preservation_details(f.get("preservation"))
    parts += repeats_line(f)
    primary_rng = F.line_range(f)
    for other in group[1:]:
        rng = F.line_range(other)
        where = " Line {}:".format(rng[0]) if rng and rng != primary_rng else ""
        parts += ["", "**{}:**{} {} (`{}`)".format(IMPORTANCE_LABELS[IMP.level(other)], where,
                                                 one_line(other["message"]), one_line(other["id"]))]
        if other.get("suggestion") is not None and not shown and other.get("fixable") in ("auto", "suggest"):
            parts += ["", "Suggested text:", ""] + plain_block(other["suggestion"])
            shown = True
        if coaching and other.get("why"):
            parts += coaching_line(other)
        parts += repeats_line(other)
    parts += alternatives_line(group)
    parts += conflict_notes(group + [a for g in group for a in g.get("_also") or []], by_fp or {})
    for line in mention_lines:
        parts += ["", line]
    fps = [g["fingerprint"] for g in group] + [a["fingerprint"] for g in group for a in g.get("_also") or []]
    if at:
        parts += ["", at]
    parts += ["", FP_MARKER.format(",".join(fps))]
    return escape_quick_actions("\n".join(parts))


def final_pass_summary(findings, doc, sme_lines):
    """The "For the final human pass" section of the summary note. Existing
    issues are not for this MR, and `deferred` is never posted: only its
    counts appear."""
    current = [f for f in findings if f.get("summary_reason") != "existing"]
    unverified = [f for f in findings if f.get("verdict") == "unverified"]
    left_alone = [x for x in doc.get("left_alone") or [] if isinstance(x, str)][:5]
    return R.final_pass(current, rank, unverified[:MAX_SUMMARY_ITEMS], sme_lines, doc.get("deferred"), DEFERRED_TEXT,
                        left_alone, escape=untrusted, note=True, limit=MAX_SUMMARY_ITEMS, deferred_other=DEFERRED_OTHER)


SUMMARY_SECTIONS = (
    (None, "### Page-level findings and findings outside the diff", None, False),
    ("reader", "### Reader questions", "Lower-importance questions from the first-time-reader pass.", False),
    ("polish", "Optional polish", "Wording ideas without a specific style guide rule. Take them or leave them.",
     True),
    ("decided", "Settled by the author",
     "The author already decided these. The docs follow the decision, so they are not asked again.", True),
    ("unconfirmed", "Unconfirmed facts, not changed",
     "The facts reviewer could not prove these with code, a test, or CLI output, so auto mode did not change them. "
     "Check them in the final pass.", True),
    ("generated", "Fix in the generated source",
     "These are in generated blocks. Fix them in the source the block is generated from.", True),
    ("moved", "Questions whose text changed",
     "The text these questions were about changed in the fix commit. Check that the answer still matters.", True),
    ("existing", "Existing issues on this page",
     "These were on the page before this change. They are not blockers for this MR. Fix them here if it is "
     "easy, or in a follow-up.", True),
)


def summary_only_sections(not_inline):
    """The summary-only findings, in sections by `summary_reason`. Optional
    polish and existing issues are collapsed."""
    out = []
    known = set(r for r, _, _, _ in SUMMARY_SECTIONS if r)
    for reason, title, intro, collapsed in SUMMARY_SECTIONS:
        items = [f for f in not_inline if (f.get("summary_reason") if f.get("summary_reason") in known else None)
                 == reason]
        if not items:
            continue
        if collapsed:
            out += ["<details><summary>{} ({})</summary>".format(title, len(items)), ""]
        else:
            out += [title, ""]
        if intro:
            out += [intro, ""]
        for f in sorted(items, key=lambda x: -IMP.level(x))[:MAX_SUMMARY_ITEMS]:
            out.append("- **{}** `{}` in {}: {}".format(IMPORTANCE_LABELS[IMP.level(f)], untrusted(f["id"]),
                                                        R.code(untrusted(R.loc(f))), R.one_line(f["message"], untrusted)))
        if len(items) > MAX_SUMMARY_ITEMS:
            out.append("- And {} more. See the full report in the job output.".format(len(items) - MAX_SUMMARY_ITEMS))
        out.append("")
        if collapsed:
            out += ["</details>", ""]
    return out


MAX_APPLIED_LINES = 40


def applied_section(applied):
    """What the writer step fixed, collapsed: one line for each fix."""
    items = (applied or {}).get("applied") or []
    if not items:
        return []
    out = ["<details><summary>Applied automatically in {} ({})</summary>".format(
        R.code(str(applied.get("head") or "")[:12]), len(items)), ""]
    for a in items[:MAX_APPLIED_LINES]:
        out.append("- `{}` in {}: {}".format(untrusted(a.get("id")), R.code(untrusted(
            "{}:{}".format(a.get("file"), a.get("line")))), R.one_line(a.get("message"), untrusted)))
    if len(items) > MAX_APPLIED_LINES:
        out.append("- And {} more in the job report.".format(len(items) - MAX_APPLIED_LINES))
    out += ["", "</details>", ""]
    wrong = (applied or {}).get("invalid") or []
    if wrong:
        out += ["<details><summary>Not applied: the writer found these findings wrong ({})</summary>".format(len(wrong)), ""]
        out += ["- `{}` in {}: {}".format(untrusted(w.get("id")), R.code(untrusted("{}:{}".format(w.get("file"), w.get("line")))),
                                         R.one_line(w.get("reason"), untrusted)) for w in wrong[:MAX_APPLIED_LINES]]
        out += ["", "</details>", ""]
    return out


def summary_body(findings, posted, not_inline, skipped_dup, skipped_resolved, sme_lines, tier, tw_mention, head,
                 notes=None, deferred=0, doc=None, first_time=False, applied=None):
    doc = doc or {}
    lines = [PREFIX, SUMMARY_MARKER, "", "## Docs review summary", ""]
    if first_time:
        lines += [ORIENTATION, ""]
    if tier in ("high", "severe"):
        ask = "This change is tier **{}**. It needs a review from a human technical writer".format(tier)
        lines += [ask + (", {}.".format(tw_mention) if tw_mention else "."), ""]
    if findings:
        counts = dict((n, 0) for n in (5, 4, 3, 2, 1))
        for f in findings:
            counts[IMP.level(f)] += 1
        cols = [n for n in (5, 4, 3, 2, 1) if counts[n]]
        lines.append("| " + " | ".join("Importance {}".format(n) for n in cols) + " | Total |")
        lines.append("|" + "---|" * (len(cols) + 1))
        lines.append("| " + " | ".join(str(counts[n]) for n in cols) + " | {} |".format(len(findings)))
        lines.append("")
    else:
        lines += ["No findings to post." if deferred else "No findings. Nice work.", ""]
    stats = ["{} new inline comment(s)".format(posted)]
    if skipped_dup:
        stats.append("{} already posted".format(skipped_dup))
    if skipped_resolved:
        stats.append("{} in resolved threads".format(skipped_resolved))
    lines += ["This run: " + ", ".join(stats) + ".", ""]
    for n in notes or []:
        lines += ["- " + untrusted(n)]
    if notes:
        lines.append("")
    lines += applied_section(applied)
    lines += final_pass_summary(findings, doc, sme_lines)
    lines += summary_only_sections(not_inline)
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    lines.append("_Updated {}{}. A rerun updates this note._".format(stamp, " for {}".format(head[:12]) if head else ""))
    return escape_quick_actions("\n".join(lines))


def rank(f):
    return (-IMP.level(f), F.severity_rank(f["severity"]), f["file"], f.get("line") or 0)


def plan_and_post(doc, ctx, writer, args, endpoint_base):
    findings = []
    for f in doc["findings"]:  # only `findings`: `deferred` is never posted
        if isinstance(f, dict):
            f = dict(f)
            F.coerce_finding(f)
        errs = F.validate_finding(f)
        if errs:
            warn("skipping invalid finding {}: {}".format(f.get("id") if isinstance(f, dict) else "?", "; ".join(errs)))
            continue
        f.setdefault("fingerprint", F.fingerprint(f))
        findings.append(f)
    # Never post non-public content: confidential items or private projects
    # that the reviewing account could read (lib/visibility.py).
    vis = ctx.visibility or visibility.Visibility(None)
    gated, withheld = [], False
    for f in findings:
        g, n = visibility.gate(f, vis)
        gated.append(g)
        withheld = withheld or bool(n) or bool(g.get("withheld_internal"))
    findings = gated
    args.applied_doc, stale_threads = gate_applied(args.applied_doc, doc.get("stale_threads"), vis)
    doc = dict(doc, stale_threads=stale_threads)
    if args.applied_doc is not None:
        # A fix that was applied is not still open, whichever findings file it came from.
        fixed = set(a.get("fingerprint") for a in args.applied_doc.get("applied") or [])
        fixed |= set(a.get("fingerprint") for a in args.applied_doc.get("invalid") or [])
        findings = [f for f in findings if f["fingerprint"] not in fixed]
    left_alone, dropped = public_entries(doc.get("left_alone"), vis)
    withheld = withheld or dropped
    doc = dict(doc, left_alone=left_alone)
    if withheld:
        ctx.notes.append("{} finding(s) rely on internal evidence that is withheld from this comment. A team member "
                         "with access can check them in the job report.".format(
                             sum(1 for f in findings if f.get("withheld_internal"))))
    target = doc.get("target") or {}
    first_time = bool(target.get("first_time_writer"))
    findings.sort(key=rank)

    tier = target.get("tier")
    budget = MentionBudget([ctx.author or target.get("author"), ctx.me], 0 if args.no_mentions else MAX_MENTIONS)
    writer.mentionable = budget.people
    tw = args.tw or target.get("technical_writer")
    tw_mention = None
    if tier == "severe" and tw:
        # Severe: a technical writer review is required, so mention them.
        picked = budget.take([tw.lstrip("@")], limit=1)
        tw_mention = "@" + picked[0] if picked else R.code(untrusted(tw.lstrip("@")))
    elif tier == "high" and tw:
        # High: name the writer without a notification (triage.md).
        tw_mention = R.code(untrusted(tw.lstrip("@")))

    skipped_dup = skipped_resolved = posted = 0
    not_inline, sme_lines = [], []
    cap = args.safety_cap
    if cap is None:
        stat_cap = (doc.get("stats") or {}).get("safety_cap", DEFAULT_SAFETY_CAP)
        cap = stat_cap if isinstance(stat_cap, int) and stat_cap > 0 else DEFAULT_SAFETY_CAP
    inline_left = 0 if args.summary_only else cap
    by_fp = dict((f["fingerprint"], f) for f in findings)
    pending = []
    still_open = 0
    for f in findings:
        if f.get("summary_only") is True and asks_inline(f):
            f["summary_only"] = False
        if f["fingerprint"] in ctx.fps:
            if f["fingerprint"] in ctx.resolved_fps:
                skipped_resolved += 1
            else:
                skipped_dup += 1
            continue
        t = thread_for(f, ctx.threads) if f.get("summary_only") is not True else None
        if t is not None:
            # The same point in other words: its thread already says it.
            if t["resolved"]:
                skipped_resolved += 1
            else:
                still_open += 1
            continue
        pending.append(f)
    # One question asked on many pages is one comment: the answer is the same.
    for f in pending:
        if f.get("withheld_internal") and f.get("message") == visibility.NEUTRAL:
            f["summary_only"] = True  # a comment that can say nothing specific helps no one inline
        if F.needs_input(f) and f.get("summary_only") is not True:
            core = str(f.get("message") or "").split(" Not applied automatically:", 1)[0]
            f["group"] = "input:" + (f.get("occurrence_root") or "{}:{}".format(
                f["id"], " ".join(core.lower().split())[:200]))
    # Repeats of one rule (merge `group`) are one comment on their first line.
    carriers, first = [], {}
    for f in sorted(pending, key=lambda x: (x.get("group") or "", x["file"], x.get("line") or 0)):
        g = f.get("group")
        if g and g in first and f.get("summary_only") is not True:
            first[g].setdefault("_also", []).append(f)
            continue
        if g:
            first[g] = f
        carriers.append(f)
    carriers.sort(key=rank)

    def unpack(f):
        return [f] + list(f.get("_also") or [])

    groups, order = {}, []  # comment key -> [(finding, position, mention line)]
    unplaced = []  # (finding, mention line): questions with no diff position, posted as threads (fix-mr)
    for f in carriers:
        mention_line = None
        for m in unpack(f):
            if mention_eligible(m) and m.get("sme"):
                people = budget.take([s.get("username") for s in m["sme"] if isinstance(s, dict)])
                if people:
                    line = sme_question(m, people)
                    mention_line = line if mention_line is None else mention_line + "\n\n" + line
        # Findings in one location group (merge `spot`) share one comment.
        skey = ("spot", f["file"], f["spot"]) if f.get("spot") and f.get("summary_only") is not True else None
        if skey in groups:
            pos = position_for(f, ctx)
            entry = (f, pos, mention_line)
            if f["fingerprint"][:12] == f["spot"] and pos is not None:
                groups[skey].insert(0, entry)  # the location group's owner leads the comment
            else:
                groups[skey].append(entry)
            continue
        pos = position_for(f, ctx) if (inline_left > 0 or groups) else None
        key = skey or ((pos["new_path"], pos["new_line"]) if pos else None)
        if pos is None and may_post_unplaced(f, args, ctx) and len(order) + len(unplaced) < inline_left:
            unplaced.append((f, mention_line))
            continue
        if pos is None or (key not in groups and len(order) + len(unplaced) >= inline_left):
            not_inline.extend(unpack(f))
            if mention_line:
                sme_lines.append(mention_line)
            continue
        if key not in groups:
            groups[key] = []
            order.append(key)
        groups[key].append((f, pos, mention_line))

    folded = 0
    for key in order:
        group = groups[key]
        primary, pos, _ = group[0]
        members = [primary] + [g[0] for g in group[1:]]
        folded += sum(len(unpack(m)) for m in members) - 1
        mentions = [g[2] for g in group if g[2]]
        body = {"body": inline_body(members, mentions, by_fp, first_time), "position": pos}
        label = "inline {} {}:{}".format("+".join(m["id"] for m in members), primary["file"], primary["line"])
        try:
            writer.write("POST", endpoint_base + "/discussions", body, label)
            posted += 1
        except gitlab_api.GlabError as exc:
            warn("inline comment for {} {}:{} failed, moving it to the summary: {}".format(
                primary["id"], primary["file"], primary["line"], str(exc)[:160]))
            writer.planned.pop()
            for m in members:
                not_inline.extend(unpack(m))
            sme_lines.extend(mentions)

    for f, mention_line in unplaced:
        where = "On `{}:{}`, which this MR does not change. Answer here: the next review cycle applies it.".format(
            one_line(f["file"]), f.get("line"))
        at = PLACE_MARKER.format(f["file"], f.get("line"), ctx.refs.get("head_sha") or args.head_sha)
        body = {"body": inline_body([f], [mention_line] if mention_line else [], by_fp, first_time, where, at)}
        try:
            writer.write("POST", endpoint_base + "/discussions", body, "thread {} {}:{}".format(
                f["id"], f["file"], f.get("line")))
            posted += 1
        except gitlab_api.GlabError as exc:
            warn("thread for {} {}:{} failed, moving it to the summary: {}".format(
                f["id"], f["file"], f.get("line"), str(exc)[:160]))
            writer.planned.pop()
            not_inline.extend(unpack(f))
            if mention_line:
                sme_lines.append(mention_line)

    head = ctx.refs.get("head_sha") or args.head_sha or ""
    resolved_now = resolve_fixed(ctx, writer, endpoint_base, findings, args.applied_doc, head,
                                 doc.get("stale_threads") or []) if args.applied_doc is not None else []
    if still_open:
        ctx.notes.append("{} earlier comment(s) still apply. They stay in their threads.".format(still_open))
    if resolved_now:
        ctx.notes.append("Resolved {} earlier comment(s) that are fixed.".format(len(resolved_now)))
    deferred = len(doc.get("deferred") or [])
    body = summary_body(findings, posted, not_inline, skipped_dup, skipped_resolved, sme_lines, tier, tw_mention,
                        head, ctx.notes, deferred, doc, first_time, args.applied_doc)
    if ctx.summary_note and ctx.summary_note.get("id"):
        writer.write("PUT", "{}/notes/{}".format(endpoint_base, ctx.summary_note["id"]), {"body": body}, "update summary")
        summary_id = ctx.summary_note["id"]
    else:
        resp = writer.write("POST", endpoint_base + "/notes", {"body": body}, "create summary")
        summary_id = resp.get("id") if isinstance(resp, dict) else None
    return {"inline": posted, "folded": folded, "deferred_not_posted": deferred, "skipped_duplicate": skipped_dup,
            "skipped_resolved": skipped_resolved, "mentions": budget.people, "version": ctx.version,
            "notes": ctx.notes, "summary_action": "update" if ctx.summary_note else "create",
            "still_open": still_open, "resolved": resolved_now, "summary_id": summary_id,
            "not_inline": not_inline}


# ---------------------------------------------------------------- handoff note

QUESTION_TEXT_RE = re.compile(r"\*\*Question:\*\*\s*(.+?\?)(?:\s|$)")
LABEL_RE = re.compile(r"^\*\*(?:Fix first|Recommended|Optional):\*\*\s*")
RULE_TAIL_RE = re.compile(r"\s*\(`[a-z0-9][a-z0-9_.-]*(?:\+[a-z0-9_.-]+)*`\)\s*$")


def short_text(message, limit=200):
    """The question a thread asks, or its first sentence: one line, untrusted."""
    text = " ".join(str(message or "").split())
    m = QUESTION_TEXT_RE.search(text)
    if m:
        text = m.group(1)
    else:
        text = LABEL_RE.sub("", text)
        text = text.split(" Not applied automatically:", 1)[0]
        text = RULE_TAIL_RE.sub("", text)
        end = re.search(r"(?<=[.?!])\s", text)
        text = text[:end.start()] if end else text
    text = LABEL_RE.sub("", text.strip())
    if len(text) > limit:
        text = text[:limit - 3].rsplit(" ", 1)[0] + "..."
    return one_line(text)


def link_text(text):
    """Text that is safe inside a Markdown link label."""
    return text.replace("[", "(").replace("]", ")")


def handoff_open_items(not_inline, checks, vis=None):
    """What is left with no thread: questions that could not go inline,
    unconfirmed facts, and the orchestrator's checks from the writers' notes.
    Findings asked on many pages are one item."""
    items, seen = [], {}
    for f in not_inline:
        # combine_findings.py says `unverified`, collect_writers.py `unconfirmed`.
        if not (F.needs_input(f) or f.get("summary_reason") in ("unverified", "unconfirmed")):
            continue
        root = f.get("occurrence_root") or f.get("fingerprint")
        where = "`{}:{}`".format(one_line(f["file"]), f["line"]) if f.get("line") else "`{}`".format(one_line(f["file"]))
        if root in seen:
            seen[root]["where"].append(where)
            continue
        seen[root] = {"where": [where], "text": short_text(f.get("message"), 260)}
        items.append(seen[root])
    withheld = 0
    for c in checks or []:
        if not isinstance(c, dict) or not str(c.get("text") or "").strip():
            continue
        # Free text that names an item not confirmed public is left out
        # whole: it may describe the item as well as name it.
        if vis is not None and any(not vis.public(r) for r in vis.refs(str(c.get("text")) + " " + str(c.get("file") or ""))):
            withheld += 1
            continue
        where = "`{}`".format(one_line(c["file"])) if c.get("file") else None
        items.append({"where": [where] if where else [], "text": one_line(" ".join(str(c["text"]).split()))[:400]})
    if withheld:
        items.append({"where": [], "text": "{} check(s) left out: they name an item that is not public. "
                                          "Read them in the job report.".format(withheld)})
    return items


def handoff_body(fix, threads, items, applied_count, summary_id, head):
    url = fix["web_url"] or ""
    lines = [PREFIX, HANDOFF_MARKER, "", "**Docs review fixes are in !{}**".format(fix["iid"]), ""]
    summary = "[The summary note]({}#note_{})".format(url, summary_id) if summary_id else "The summary note on !{}".format(
        fix["iid"])
    lines.append("The agent review of this MR put its fixes in [!{iid}]({url}). It targets `{branch}`, so nothing "
                 "is committed to this branch directly. It has {n} fix(es). {summary} lists each one.".format(
                     iid=fix["iid"], url=url, branch=one_line(fix["target_branch"]), n=applied_count,
                     summary=summary))
    lines += ["", "**Open questions (answer in each thread)**", ""]
    if threads:
        for t in threads[:MAX_HANDOFF_ITEMS]:
            text = link_text(short_text(t.get("message")))
            lines.append("- [{}]({}#note_{})".format(text, t.get("url") or url, t["note_id"]) if t.get("note_id")
                         else "- {} (`{}:{}`)".format(text, one_line(t.get("file")), t.get("line")))
        if len(threads) > MAX_HANDOFF_ITEMS:
            lines.append("- And {} more on !{}.".format(len(threads) - MAX_HANDOFF_ITEMS, fix["iid"]))
    else:
        lines.append("None.")
    lines += ["", "**Open items with no thread**", ""]
    if items:
        for it in items[:MAX_HANDOFF_ITEMS]:
            where = ", ".join(it["where"])
            lines.append("- {}{}".format(where + ": " if where else "", it["text"]))
        if len(items) > MAX_HANDOFF_ITEMS:
            lines.append("- And {} more in the summary note on !{}.".format(len(items) - MAX_HANDOFF_ITEMS, fix["iid"]))
    else:
        lines.append("None.")
    lines += ["", "Merge !{} into this branch to take the fixes. The next review cycle applies the answers from "
                  "the threads.".format(fix["iid"]), "",
              "_Updated {} for {}. A rerun updates this note._".format(
                  datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC"), str(head)[:12])]
    return "\n".join(lines)


def load_reviewed_threads(api, project, reviewed_iid, ctx):
    """With --handoff, our question threads on the reviewed MR too: a cycle
    with no fix MR posts its questions there (writer.md#delivery). They are
    matched, answered, and resolved like the fix MR's, each on its own MR. A
    failed read raises: a partial list of answers is worse than none."""
    pid = gitlab_api.enc(project)
    discs, _ = api.get_pages("projects/{}/merge_requests/{}/discussions".format(pid, reviewed_iid),
                             per_page=100, max_pages=20)
    for d in discs or []:
        notes = d.get("notes") or []
        record_thread(ctx, d, notes, any(n.get("resolvable") and n.get("resolved") for n in notes), api, pid,
                      mr=int(reviewed_iid))


def thread_base(endpoint_base, t):
    """The discussions endpoint of thread `t`, on the MR it lives on."""
    if t.get("mr"):
        endpoint_base = "{}/{}".format(endpoint_base.rsplit("/", 1)[0], int(t["mr"]))
    return "{}/discussions/{}".format(endpoint_base, t["id"])


def require_handoff(ctx, args):
    """An MR from a fix branch is read only as a fix MR, with --handoff, so
    its pair is checked: as an ordinary MR its opener, who can be anyone with
    a fork, would answer as the MR author."""
    if args.handoff is None and fix_branch.is_fix_branch(ctx.source_branch):
        raise GuardrailError("!{} is from a fix branch: pass --handoff <the reviewed MR's IID>".format(args.mr))


def check_fix_pair(api, project, fix_iid, reviewed_iid):
    """The reviewed MR, after checking, before anything is posted, that the
    fix MR is ours: our account opened it, from this project (not a fork),
    from a fix branch for the reviewed MR, into the reviewed MR's source
    branch. Anyone can open an MR from a fork with the fix branch's name, so
    the branch name alone proves nothing. Raises GuardrailError."""
    pid = gitlab_api.enc(project)
    me = api.get("user")
    me = me.get("username") if isinstance(me, dict) else None
    fix = api.get("projects/{}/merge_requests/{}".format(pid, fix_iid))
    reviewed = api.get("projects/{}/merge_requests/{}".format(pid, reviewed_iid))
    if not me:
        raise GuardrailError("the current user could not be read")
    if not isinstance(fix, dict) or not isinstance(reviewed, dict):
        raise GuardrailError("cannot read !{} or !{}".format(fix_iid, reviewed_iid))
    if reviewed.get("state") != "opened" or fix.get("state") != "opened":
        raise GuardrailError("!{} and !{} must both be open".format(fix_iid, reviewed_iid))
    if (fix.get("author") or {}).get("username") != me:
        raise GuardrailError("our account did not open !{}, so it is not our fix MR".format(fix_iid))
    project_id = fix.get("project_id")
    if project_id is None or fix.get("source_project_id") != project_id \
            or reviewed.get("source_project_id") != project_id:
        raise GuardrailError("!{} and the branch of !{} must both come from this project, not a fork".format(
            fix_iid, reviewed_iid))
    if not fix_branch.is_for(fix.get("source_branch"), reviewed_iid):
        raise GuardrailError("!{} is not from a fix branch for !{}".format(fix_iid, reviewed_iid))
    if fix.get("target_branch") != reviewed.get("source_branch"):
        raise GuardrailError("!{} does not target the source branch of !{}".format(fix_iid, reviewed_iid))
    return reviewed


def drop_resolving(threads, planned):
    """The open threads that the planned writes do not resolve."""
    resolving = set(p["endpoint"].rsplit("/", 1)[-1] for p in planned
                    if p.get("method") == "PUT" and (p.get("body") or {}).get("resolved") is True)
    return [t for t in threads if str(t.get("id")) not in resolving]


def post_handoff(api, args, ctx, writer, result, applied_doc, checks):
    """Write or update the handoff note on the reviewed MR (args.handoff) for
    the fix MR (args.mr). Returns "create", "update", or raises."""
    # check_fix_pair ran in main, before anything was posted.
    pid = gitlab_api.enc(args.project)
    target_base = "projects/{}/merge_requests/{}".format(pid, args.handoff)
    # Our open threads on the fix MR, as they are after this run's posts.
    discs, _ = api.get_pages("projects/{}/merge_requests/{}/discussions".format(pid, args.mr), per_page=100,
                             max_pages=20)
    fresh = Context()
    fresh.me = ctx.me
    for d in discs or []:
        notes = d.get("notes") or []
        record_thread(fresh, d, notes, any(n.get("resolvable") and n.get("resolved") for n in notes))
    fix_url = ctx.web_url or ""
    for t in fresh.threads:
        t["url"] = fix_url
    reviewed_url = ((getattr(args, "reviewed", None) or {}).get("web_url")) or ""
    for t in ctx.threads:
        if t.get("mr") and not t["resolved"]:
            fresh.threads.append(dict(t, url=reviewed_url))
    threads = [t for t in fresh.threads if not t["resolved"]]
    if writer.dry_run:
        # Threads this run resolves are still open on GitLab in a dry run:
        # leave them out, so the preview matches what a real run posts.
        threads = drop_resolving(threads, writer.planned)
        # Posts planned in this dry run have no note yet.
        for p in writer.planned:
            if p["endpoint"].endswith("/discussions") and p["method"] == "POST":
                pos = p["body"].get("position") or thread_place(p["body"]["body"])
                threads.append({"message": strip_prefix(p["body"]["body"]), "file": pos.get("new_path"),
                                "line": pos.get("new_line"), "note_id": None})
    # The handoff note goes to the same project, checked above, so its
    # readers can read the fix MR and our notes on it.
    if ctx.visibility is not None:
        path = ctx.project_path or args.project
        ctx.visibility.same_audience("merge_requests", path, int(args.mr),
                                     [t.get("note_id") for t in threads if not t.get("mr")] + [result.get("summary_id")])
        # The note goes on the reviewed MR itself: its own threads are its readers' to see.
        ctx.visibility.same_audience("merge_requests", path, int(args.handoff),
                                     [t.get("note_id") for t in threads if t.get("mr")])
    items = handoff_open_items(result.get("not_inline") or [], checks, ctx.visibility)
    fix = {"iid": args.mr, "web_url": ctx.web_url, "target_branch": ctx.target_branch}
    applied_count = len((applied_doc or {}).get("applied") or [])
    body = handoff_body(fix, threads, items, applied_count, result.get("summary_id"),
                        (applied_doc or {}).get("head") or ctx.refs.get("head_sha") or "")
    existing = None
    notes, _ = api.get_pages(target_base + "/notes", per_page=100, max_pages=20)
    for n in notes or []:
        if is_marked(n.get("body") or "", HANDOFF_MARKER) and (
                ctx.me is not None and (n.get("author") or {}).get("username") == ctx.me):
            existing = n
            break
    if existing:
        writer.write("PUT", "{}/notes/{}".format(target_base, existing["id"]), {"body": body}, "update handoff")
        return "update"
    writer.write("POST", target_base + "/notes", {"body": body}, "create handoff")
    return "create"


def write_out(out_dir, writer, result, ctx):
    os.makedirs(os.path.join(out_dir, "payloads"), exist_ok=True)
    for i, p in enumerate(writer.planned, 1):
        with open(os.path.join(out_dir, "payloads", "{:03d}.json".format(i)), "w", encoding="utf-8") as fh:
            json.dump(p, fh, indent=2)
            fh.write("\n")
    with open(os.path.join(out_dir, "preview.md"), "w", encoding="utf-8") as fh:
        fh.write(render_preview(writer, result, ctx))


def render_preview(writer, result, ctx):
    lines = ["# Docs review: posting preview", ""]
    lines.append("- Inline comments: {} ({} finding(s) folded into a comment on the same line)".format(
        result["inline"], result.get("folded", 0)))
    lines.append("- Diff version: {}".format(result.get("version") or "latest"))
    if result.get("deferred_not_posted"):
        lines.append("- Deferred findings (report only, not posted): {}".format(result["deferred_not_posted"]))
    for n in result.get("notes") or []:
        lines.append("- Note: {}".format(n))
    lines.append("- Summary note: {}".format(result["summary_action"]))
    lines.append("- Skipped (already posted): {}".format(result["skipped_duplicate"]))
    lines.append("- Skipped (resolved threads): {}".format(result["skipped_resolved"]))
    lines.append("- Mentions: {}".format(", ".join(result["mentions"]) or "none"))
    for e in ctx.read_errors:
        lines.append("- Read error (dry-run continued): {}".format(e))
    lines.append("")
    for p in writer.planned:
        lines.append("## {} {} ({})".format(p["method"], p["endpoint"], p["label"]))
        if p["body"].get("position"):
            pos = p["body"]["position"]
            lines.append("")
            lines.append("Position: `{}` line {}".format(pos["new_path"], pos["new_line"]))
        lines.append("")
        if "body" in p["body"]:
            lines += R.fenced(p["body"]["body"], "markdown") + [""]
        else:
            lines += ["`{}`".format(json.dumps(p["body"])), ""]
    return "\n".join(lines)


def parse_args(argv):
    p = argparse.ArgumentParser(
        description="Post gitlab-docs-review findings to a GitLab MR (summary note + inline suggestions), or preview them.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Exit codes: 0 no blocker, 1 blockers found, 2 usage, environment, or API error.")
    p.add_argument("findings", nargs="?", help="combined findings.json from combine_findings.py (or "
                                               "remaining.json from collect_writers.py)")
    p.add_argument("--project", required=True, help="project path, such as group/project")
    p.add_argument("--mr", required=True, type=int, help="merge request IID")
    p.add_argument("--mode", choices=("interactive", "auto"), help="default: $GITLAB_DOCS_REVIEW_MODE or interactive")
    p.add_argument("--no-mentions", action="store_true", help="name people in backticks; mention nobody "
                                                          "(test copies of real MRs)")
    p.add_argument("--dry-run", action="store_true", help="write payloads and preview.md; never call a write API")
    p.add_argument("--yes", action="store_true", help="interactive mode: post after the user approved the preview")
    p.add_argument("--out", help="output directory for payloads and preview.md (required with --dry-run)")
    p.add_argument("--safety-cap", type=int,
                   help="most inline comments per run (default: stats.safety_cap in findings.json, else {})".format(
                       DEFAULT_SAFETY_CAP))
    p.add_argument("--summary-only", action="store_true", help="post only the summary note")
    p.add_argument("--tw", help="technical writer for tier high or severe (default: target.technical_writer)")
    p.add_argument("--head-sha", help="reviewed head commit; inline positions use the MR diff version with this "
                                      "head (default: target.head in findings.json)")
    p.add_argument("--applied", help="applied.json from collect_writers.py: list the fixes, resolve the threads "
                                     "they fix, and post only what is left")
    p.add_argument("--handoff", type=int, metavar="MR",
                   help="fix-mr delivery: --mr is the fix MR; after posting there, write the handoff note on this "
                        "reviewed MR, which the fix MR must target")
    p.add_argument("--checks", metavar="FILE", help="with --handoff: JSON list of {file, text} items to check before "
                                                    "merge, written from the writers' notes")
    p.add_argument("--list-open", metavar="FILE", help="write our open threads as JSON (for the reviewers) and exit; "
                                                       "read-only")
    p.add_argument("--glab", default=None, help="glab binary (default: $GITLAB_DOCS_REVIEW_GLAB or glab)")
    args = p.parse_args(argv)
    args.applied_doc = None
    if args.applied:
        with open(args.applied, encoding="utf-8") as fh:
            args.applied_doc = json.load(fh)
    args.checks_doc = []
    if args.checks:
        with open(args.checks, encoding="utf-8") as fh:
            args.checks_doc = json.load(fh)
        if not isinstance(args.checks_doc, list):
            raise ValueError("--checks must hold a JSON list")
    return args


def main(argv=None):
    args = parse_args(argv if argv is not None else sys.argv[1:])
    mode = args.mode or os.environ.get("GITLAB_DOCS_REVIEW_MODE") or "interactive"
    if mode not in ("interactive", "auto"):
        warn("GITLAB_DOCS_REVIEW_MODE must be interactive or auto")
        return 2
    if args.list_open:
        api = gitlab_api.GitLab(args.glab)
        try:
            # On a fix MR, the reviewed MR's author answers as the MR author.
            author = None
            if args.handoff is not None:
                author = (check_fix_pair(api, args.project, args.mr, args.handoff).get("author") or {}).get("username")
            ctx = load_context(api, args.project, args.mr, True, mr_author=author)
            require_handoff(ctx, args)
            if args.handoff is not None and ctx.me is not None:
                load_reviewed_threads(api, args.project, args.handoff, ctx)
        except GuardrailError as exc:
            warn("guardrail: {}".format(exc))
            return 2
        except gitlab_api.GlabError as exc:
            warn(str(exc))
            return 2
        # A partial list of answers is worse than none, and with no account
        # to compare, any prefixed note would look like ours. Only the reads
        # that decide which threads are ours count: a diff that cannot be
        # read does not change them.
        errors = [e for e in ctx.read_errors if e.split(":", 1)[0] in THREAD_READS]
        if ctx.me is None or errors:
            warn("--list-open: cannot list our open threads: {}; nothing written".format(
                "; ".join(errors) or "the current user has no username"))
            return 2
        ignored = {}
        for i in ctx.ignored_answers:
            ignored.setdefault(i["discussion_id"], set()).add(i["author"] or "")
        # `ignored_replies`: who replied without the right to decide, so the
        # orchestrator can tell a person. Usernames only, never the reply text.
        rows = [{"discussion_id": t["id"], "mr": t.get("mr") or args.mr, "fingerprints": sorted(t["fps"]),
                 "answers": t["answers"],
                 "file": t["file"], "line": t["line"], "head_sha": t["head_sha"], "ids": t["ids"],
                 "message": t["message"], "outdated": t["outdated"],
                 "human_reply": t["human"], "ignored_replies": sorted(ignored.get(t["id"], ()))}
                for t in open_threads(ctx)]
        with open(args.list_open, "w", encoding="utf-8") as fh:
            json.dump({"open_threads": rows}, fh, indent=2)
        sys.stdout.write("{} open thread(s) written to {}\n".format(len(rows), args.list_open))
        return 0
    if not args.findings:
        warn("give the findings file, or --list-open FILE")
        return 2
    if args.dry_run and not args.out:
        warn("--dry-run needs --out DIR")
        return 2
    if args.safety_cap is not None and args.safety_cap < 0:
        warn("--safety-cap must be 0 or more")
        return 2
    if args.checks and not args.handoff:
        warn("--checks needs --handoff")
        return 2
    if args.handoff is not None and args.handoff == args.mr:
        warn("--handoff names the reviewed MR; --mr is the fix MR")
        return 2
    try:
        doc = F.load_doc(args.findings)
    except (OSError, ValueError) as exc:
        warn(str(exc))
        return 2
    blockers = F.has_blocker(doc["findings"])
    if not args.head_sha:
        head = str((doc.get("target") or {}).get("head") or "")
        args.head_sha = head if SHA_RE.match(head.lower()) else None
    preview_only = mode == "interactive" and not args.yes and not args.dry_run
    dry = args.dry_run or preview_only
    api = gitlab_api.GitLab(args.glab)
    try:
        author = None
        args.reviewed = None
        if args.handoff is not None:
            # Before anything is posted: --mr must be our fix MR for --handoff.
            args.reviewed = check_fix_pair(api, args.project, args.mr, args.handoff)
            author = (args.reviewed.get("author") or {}).get("username")
        ctx = load_context(api, args.project, args.mr, dry, args.head_sha, mr_author=author)
        require_handoff(ctx, args)
        if args.handoff is not None and ctx.me is not None:
            load_reviewed_threads(api, args.project, args.handoff, ctx)
    except GuardrailError as exc:
        warn("guardrail: {}".format(exc))
        return 2
    except gitlab_api.GlabError as exc:
        warn(str(exc))
        return 2
    if not dry and ctx.me is None:
        warn("cannot tell which notes are ours: the current user has no username; not posting")
        return 2
    project_path = ctx.project_path or (args.project if "/" in str(args.project) else None)
    ctx.visibility = visibility.Visibility(api, project_path)
    if ctx.positions_error and not args.summary_only:
        # Never move every finding to the summary without saying so.
        bar = "!" * 72
        warn("\n{}\nNO INLINE POSITIONS: {}.\nNothing was posted. Rerun with --summary-only to post only the "
             "summary.\n{}".format(bar, ctx.positions_error, bar))
        return 2
    if not dry and ctx.state in ("merged", "closed"):
        warn("MR !{} is {}; not posting".format(args.mr, ctx.state))
        return 1 if blockers else 0
    answered = set(a.get("discussion_id") for k in ("applied", "invalid") for a in (args.applied_doc or {}).get(k) or []
                   if a.get("discussion_id"))
    writer = SafeWriter(api, dry, ctx.visibility,
                        [t["id"] for t in ctx.threads if not t["human"] or (t["id"] in answered and t["answers"])])
    endpoint_base = "projects/{}/merge_requests/{}".format(gitlab_api.enc(args.project), args.mr)
    try:
        result = plan_and_post(doc, ctx, writer, args, endpoint_base)
        result["handoff_action"] = None
        if args.handoff is not None and not args.summary_only:
            result["handoff_action"] = post_handoff(api, args, ctx, writer, result, args.applied_doc,
                                                    args.checks_doc)
    except GuardrailError as exc:
        warn("guardrail: {}".format(exc))
        return 2
    except gitlab_api.GlabError as exc:
        warn(str(exc))
        return 2
    if args.out:
        write_out(args.out, writer, result, ctx)
    if preview_only:
        sys.stdout.write(render_preview(writer, result, ctx))
        sys.stdout.write("\nNothing was posted. Review the text above, then rerun with --yes to post.\n")
    else:
        verb = "would post" if dry else "posted"
        sys.stdout.write("{} {} inline comment(s) and {} the summary note; skipped {} duplicate(s), {} resolved; "
                         "mentions: {}\n".format(verb, result["inline"], ("would " if dry else "") + result["summary_action"]
                                                 + ("" if dry else "d"), result["skipped_duplicate"],
                                                 result["skipped_resolved"], ", ".join(result["mentions"]) or "none"))
        if result.get("handoff_action"):
            sys.stdout.write("{} the handoff note on !{}\n".format(
                ("would " if dry else "") + result["handoff_action"] + ("" if dry else "d"), args.handoff))
        if args.dry_run:
            sys.stdout.write("payloads and preview.md written to {}\n".format(args.out))
    return 1 if blockers else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, UnicodeError, ValueError, RuntimeError) as exc:  # a one-line error, not a traceback
        if os.environ.get("GITLAB_DOCS_REVIEW_DEBUG"):
            raise
        sys.stderr.write("{}: error: {}\n".format(sys.argv[0].rsplit("/", 1)[-1], exc))
        sys.exit(2)
