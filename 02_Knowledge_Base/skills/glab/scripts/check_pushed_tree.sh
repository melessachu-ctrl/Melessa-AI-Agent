#!/usr/bin/env bash
# pre-push guard: the other pre-push checks read the working tree and HEAD, not
# the commit being pushed. Refuse to run them against something else.
#
# Git (via lefthook `use_stdin: true`) feeds "<local ref> <local sha>
# <remote ref> <remote sha>" lines on stdin for a real push. With no ref lines
# (TTY, /dev/null, an idle pipe: a manual run) there is no push to guard, so
# exit 0. For a real push, fail when tracked files have uncommitted changes or
# a pushed local sha does not resolve to HEAD. Untracked files are ignored, and
# a push that only deletes refs is not checked.
#
# `use_stdin` makes lefthook itself wait for stdin EOF, so run it by hand as
# `lefthook run pre-push </dev/null`.
set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

zero_sha=0000000000000000000000000000000000000000

# Bounded read, so a manual run does not wait on a terminal or an open pipe.
# `|| [[ -n ... ]]` keeps an unterminated last line.
# Initialized because bash 3.2 leaves them unset when `read -t` times out.
local_ref=""
local_sha=""
pushes=()
while read -r -t 1 local_ref local_sha _ || [[ -n "$local_ref" ]]; do
  [[ -z "$local_ref" ]] && break
  pushes+=("$local_ref $local_sha")
  local_ref=""
done

[[ ${#pushes[@]} -eq 0 ]] && exit 0

head_sha=$(git rev-parse HEAD)
status=0
checked=0
for push in "${pushes[@]}"; do
  local_ref=${push% *}
  local_sha=${push##* }
  [[ -z "$local_sha" || "$local_sha" == "$zero_sha" ]] && continue
  checked=1
  pushed_commit=$(git rev-parse --verify --quiet "${local_sha}^{commit}" || echo "$local_sha")
  if [[ "$pushed_commit" != "$head_sha" ]]; then
    echo "Pushing $local_ref ($local_sha) but HEAD is $head_sha." >&2
    echo "The pre-push checks only see HEAD. Check out the ref you push, then push." >&2
    status=1
  fi
done

[[ $checked -eq 0 ]] && exit 0

dirty=$(git status --porcelain --untracked-files=no)
if [[ -n "$dirty" ]]; then
  echo "Uncommitted changes to tracked files:" >&2
  echo "$dirty" >&2
  echo "Commit or stash your changes, then push." >&2
  status=1
fi
exit $status
