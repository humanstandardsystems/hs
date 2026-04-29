#!/usr/bin/env bash
# UserPromptSubmit hook — injects governance docs into context once per session.
# Fires on first prompt of every new session. Skipped if no docs exist yet.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GOVERNANCE_DIR="$REPO_ROOT/_governance"
SESSION_FILE="$GOVERNANCE_DIR/.session"

# Nothing to inject if docs haven't been generated yet
[ -f "$GOVERNANCE_DIR/foundation.md" ] || exit 0

# Identify the current session by transcript path
INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path',''))" 2>/dev/null)
[ -z "$TRANSCRIPT" ] && exit 0

# Check if we already injected for this session
stored=""
[ -f "$SESSION_FILE" ] && stored=$(cat "$SESSION_FILE" 2>/dev/null | tr -d '[:space:]')
[ "$stored" = "$TRANSCRIPT" ] && exit 0

# New session — store it and inject governance docs
echo "$TRANSCRIPT" > "$SESSION_FILE"

echo "ACTIVE GOVERNANCE — the following documents are binding this session:"
echo ""
cat "$GOVERNANCE_DIR/foundation.md"
echo ""
cat "$GOVERNANCE_DIR/enforcement.md"
echo ""
cat "$GOVERNANCE_DIR/interpretation.md"
echo ""
cat "$GOVERNANCE_DIR/policy.md"
