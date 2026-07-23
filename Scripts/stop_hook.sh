#!/bin/bash
# Claude Code Stop hook: runs after every turn in this project. Verifies unit tests pass, then
# rebuilds + relaunches the dev build. Exits 2 on failure so Claude sees the output and can fix
# it before the turn actually ends - see CLAUDE.md for why git commit is deliberately NOT here.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"

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

exit 0
