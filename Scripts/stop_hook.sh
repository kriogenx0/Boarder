#!/bin/bash
# Claude Code Stop hook: runs after every turn in this project.
#  1. Runs unit tests - blocks (exit 2) with the failure output if they fail, so Claude fixes it
#     before the turn ends.
#  2. Runs make dev - blocks the same way on failure.
#  3. If tests+build are green and there are uncommitted changes Claude hasn't been told about
#     yet, blocks once telling Claude to write a commit message from the diff and commit it right
#     away - no approval wait for this project, per explicit user instruction overriding the
#     default (always confirm) commit rule in CLAUDE.md.
# A sentinel file tracks the hash of the last-flagged diff so this only fires once per change-set
# instead of every turn - e.g. if a commit attempt ever fails, it won't loop forever on the same diff.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"

SENTINEL=".claude/.last_commit_prompt"

test_output=$(make test 2>&1)
if [ $? -ne 0 ]; then
    echo "Unit tests failed - fix before stopping:" >&2
    echo "$test_output" >&2
    exit 2
fi

dev_output=$(make dev 2>&1)
if [ $? -ne 0 ]; then
    echo "make dev failed - fix before stopping:" >&2
    echo "$dev_output" >&2
    exit 2
fi

diff_state=$(git status --porcelain 2>/dev/null)
if [ -z "$diff_state" ]; then
    rm -f "$SENTINEL"
    exit 0
fi

diff_hash=$(printf '%s' "$diff_state" | shasum -a 256 | awk '{print $1}')
last_hash=$(cat "$SENTINEL" 2>/dev/null || echo "")

if [ "$diff_hash" = "$last_hash" ]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"
echo "$diff_hash" > "$SENTINEL"
echo "Tests passed and make dev succeeded. There are uncommitted changes:" >&2
echo "$diff_state" >&2
echo "Write a short one-line commit message describing this diff and run git commit yourself right now - do not wait for approval, this project's hook has pre-approved auto-commit on green tests." >&2
exit 2
