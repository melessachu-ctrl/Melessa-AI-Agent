"""Fix branch names for `fix-mr` delivery, shared by fix_mr.py and post_review.py.

A fix branch is `gitlab-docs-review/mr-<iid>`, or `-<n>` from 2 up when an
earlier one is left with no open fix MR of ours (fix_mr.py --plan).

Python 3.9 or later, stdlib only.
"""

import re

PREFIX = "gitlab-docs-review/"


def name(iid, n=1):
    return "{}mr-{}".format(PREFIX, int(iid)) + ("" if n == 1 else "-{}".format(int(n)))


def is_for(branch, iid):
    """A fix branch for the reviewed MR `iid`: mr-<iid> or mr-<iid>-<n>, n >= 2."""
    return bool(re.match(r"^{}mr-{}(?:-[2-9]|-[1-9]\d+)?$".format(re.escape(PREFIX), int(iid)), branch or ""))


def is_fix_branch(branch):
    """Any fix branch, for any reviewed MR."""
    return str(branch or "").startswith(PREFIX)
