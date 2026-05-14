#!/usr/bin/env bash
set -e

tmpindex=$(mktemp)
export GIT_INDEX_FILE="$tmpindex"

# Build temp index from HEAD
git read-tree HEAD 2>/dev/null || git read-tree "$(git mktree </dev/null)"

# Mark untracked files as intent-to-add so they show in diff
git ls-files --others --exclude-standard -z | xargs -0 sh -c 'git add -N "$@"' _ 2>/dev/null || true

# Full diff: tracked changes + untracked files
git diff HEAD

rm -f "$tmpindex"
