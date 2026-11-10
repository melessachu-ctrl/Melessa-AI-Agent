#!/usr/bin/env python3
"""Plan, open, or find the fix MR for an auto mode review with `fix-mr` delivery.

With `fix-mr` delivery, auto mode never commits to the reviewed MR's branch.
The orchestrator commits each cycle's fixes to a fix branch,
`gitlab-docs-review/mr-<iid>`, pushed to the reviewed MR's project. This
script says which fix branch a run uses (--plan), then opens a draft MR from
it into the reviewed MR's source branch, or finds the one an earlier run
opened (--branch). post_review.py posts the questions on the fix MR, and
with --handoff, a note on the reviewed MR that links it.

Usage:
  fix_mr.py --project group/proj --mr 42 --plan
  fix_mr.py --project group/proj --mr 42 --branch gitlab-docs-review/mr-42 [--dry-run]

--plan prints {"branch", "start", "fix_mr"}:
  - `fresh`: no such branch yet. Create it from the reviewed head.
  - `continue`: the branch has our open fix MR. Fetch the branch and merge
    the reviewed head into it, so the push is a fast-forward.
  A branch with no open fix MR of ours (its MR was closed, or someone else
  made it) is never reused: the plan moves to `gitlab-docs-review/mr-42-2`,
  then `-3`, and so on.

--branch prints {"iid", "web_url", "created", "target_branch"}.

Guardrails:
  - The only write is creating one merge request, as a draft, that removes
    its source branch when merged.
  - The fix branch must be `gitlab-docs-review/mr-<iid>` or
    `gitlab-docs-review/mr-<iid>-<n>` for the reviewed MR's own IID, never its
    source branch, and must already exist in the project.
  - An existing MR counts as the fix MR only when it comes from this project
    (not a fork) and our account opened it. Anyone can open an MR from a fork
    with the same branch name.
  - The reviewed MR must be open, and its source branch must be in the same
    project: a fork MR's branch takes a fix MR in the fork, which needs
    --project set to the fork.

Python 3.9 or later, stdlib only. Exit codes: 0 success, 2 usage, guardrail,
or API error.
"""

import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from lib import fix_branch  # noqa: E402
from lib import gitlab_api  # noqa: E402

PREFIX = ":robot: Agent docs review"
MAX_BRANCHES = 20


def warn(msg):
    sys.stderr.write("fix_mr: {}\n".format(msg))


def description(reviewed_iid, branch):
    return "\n".join([
        PREFIX,
        "",
        "Fixes from the agent docs review of !{}. Merge this MR into `{}` to take them. Nothing is committed "
        "to that branch directly.".format(reviewed_iid, branch),
        "",
        "The review comments on this MR list each fix and ask the questions that need an author or expert "
        "answer. The handoff note on !{} lists every open item. Answer in the threads here: the next review "
        "cycle applies the answers.".format(reviewed_iid),
    ])


class Refused(Exception):
    pass


def read_context(api, pid, iid):
    """(me, project, reviewed MR), checked: our account is known, the MR is
    open, and its source branch is in this project."""
    me = api.get("user")
    me = me.get("username") if isinstance(me, dict) else None
    project = api.get("projects/{}".format(pid))
    mr = api.get("projects/{}/merge_requests/{}".format(pid, iid))
    if not me:
        raise Refused("the current user could not be read")
    if not isinstance(project, dict) or not isinstance(mr, dict):
        raise Refused("cannot read the project or !{}".format(iid))
    if mr.get("state") != "opened":
        raise Refused("!{} is {}, not open".format(iid, mr.get("state")))
    if mr.get("source_project_id") != project.get("id"):
        raise Refused("!{} comes from another project (a fork): rerun with --project set to that project, "
                      "with the fix branch pushed there".format(iid))
    if not mr.get("source_branch"):
        raise Refused("!{} has no source branch".format(iid))
    return me, project, mr


def ours(found, project, me):
    """The open MRs in `found` that are ours: from this project, opened by us."""
    return [m for m in found or [] if m.get("source_project_id") == project.get("id")
            and (m.get("author") or {}).get("username") == me]


def open_mrs(api, pid, branch, target):
    found, _ = api.get_pages("projects/{}/merge_requests?state=opened&source_branch={}&target_branch={}".format(
        pid, gitlab_api.enc(branch), gitlab_api.enc(target)), per_page=100, max_pages=5)
    return found


def branch_exists(api, pid, branch):
    try:
        api.get("projects/{}/repository/branches/{}".format(pid, gitlab_api.enc(branch)))
        return True
    except gitlab_api.GlabError as exc:
        # The status, never the text: the endpoint in the message holds the IID.
        if exc.status == 404:
            return False
        raise


def plan(api, pid, iid, me, project, mr):
    for n in range(1, MAX_BRANCHES + 1):
        branch = fix_branch.name(iid, n)
        if not branch_exists(api, pid, branch):
            return {"branch": branch, "start": "fresh", "fix_mr": None}
        mine = ours(open_mrs(api, pid, branch, mr["source_branch"]), project, me)
        if mine:
            return {"branch": branch, "start": "continue", "fix_mr": mine[0].get("iid")}
    raise Refused("{} fix branches for !{} already exist with no open fix MR of ours: a person can delete the "
                  "stale {}-* branches".format(MAX_BRANCHES, iid, fix_branch.name(iid)))


def open_or_find(api, pid, iid, branch, me, project, mr, dry_run):
    source = mr["source_branch"]
    if not branch_exists(api, pid, branch):
        raise Refused("{} does not exist in the project: push it first".format(branch))
    found = open_mrs(api, pid, branch, source)
    mine = ours(found, project, me)
    if mine:
        return {"iid": mine[0].get("iid"), "web_url": mine[0].get("web_url"), "created": False, "target_branch": source}
    # Someone else's MR from this project's branch blocks ours (GitLab allows
    # one open MR per source branch). A fork MR with the same name does not.
    if any(m.get("source_project_id") == project.get("id") for m in found or []):
        raise Refused("an open MR from {} exists that our account did not open: use the branch --plan gives".format(
            branch))
    if dry_run:
        return {"iid": None, "web_url": None, "created": False, "would_create": True, "target_branch": source}
    created = api.write("POST", "projects/{}/merge_requests".format(pid), {
        "source_branch": branch,
        "target_branch": source,
        "title": "Draft: docs: apply gitlab-docs-review fixes for !{}".format(iid),
        "description": description(iid, source),
        "remove_source_branch": True,
    })
    return {"iid": created.get("iid"), "web_url": created.get("web_url"), "created": True, "target_branch": source}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--project", required=True, help="project path of the reviewed MR's source branch")
    ap.add_argument("--mr", required=True, type=int, help="the reviewed MR's IID")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--plan", action="store_true", help="print the fix branch to use and how to start it")
    mode.add_argument("--branch", help="the pushed fix branch, from --plan")
    ap.add_argument("--dry-run", action="store_true", help="print what would be created; never write")
    ap.add_argument("--glab", default=None, help="glab binary (default: $GITLAB_DOCS_REVIEW_GLAB or glab)")
    args = ap.parse_args(argv)

    if args.branch is not None and not fix_branch.is_for(args.branch, args.mr):
        warn("the fix branch must be {} or {}-<n>".format(fix_branch.name(args.mr), fix_branch.name(args.mr)))
        return 2
    api = gitlab_api.GitLab(args.glab)
    pid = gitlab_api.enc(args.project)
    try:
        me, project, mr = read_context(api, pid, args.mr)
        if args.plan:
            out = plan(api, pid, args.mr, me, project, mr)
        else:
            out = open_or_find(api, pid, args.mr, args.branch, me, project, mr, args.dry_run)
    except Refused as exc:
        warn(str(exc))
        return 2
    except gitlab_api.GlabError as exc:
        warn(str(exc)[:300])
        return 2
    sys.stdout.write(json.dumps(out) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
