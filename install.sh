#!/usr/bin/env bash
# install.sh — set up a Human Standard governance environment
# Usage: bash /path/to/governance-setup/install.sh [target-dir]
# Defaults to current directory if no target is given.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

if [ "$TARGET" = "$SOURCE_DIR" ]; then
    echo "error: target cannot be the governance-setup repo itself." >&2
    exit 1
fi

echo "Setting up Human Standard governance in: $TARGET"

# ── Create directory structure ───────────────────────────────────────────────
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/hooks"
mkdir -p "$TARGET/_governance/templates"

# ── Copy Claude commands ─────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/commands/standard.md" "$TARGET/.claude/commands/"
echo "  copied /standard command"

# ── Copy hook scripts ────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/hooks/startup-governance.sh" "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/startup-governance.sh"
echo "  copied startup-governance hook"

# ── Copy governance templates ────────────────────────────────────────────────
cp "$SOURCE_DIR/_governance/templates/"*.md "$TARGET/_governance/templates/"
echo "  copied governance templates"

# ── Write or merge CLAUDE.md ─────────────────────────────────────────────────
CLAUDE_MD="$TARGET/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    echo "  CLAUDE.md already exists — appending governance instructions"
    echo "" >> "$CLAUDE_MD"
    echo "---" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
    cat "$SOURCE_DIR/.claude/CLAUDE.md" >> "$CLAUDE_MD"
else
    cp "$SOURCE_DIR/.claude/CLAUDE.md" "$CLAUDE_MD"
    echo "  created CLAUDE.md"
fi

# ── Write or merge settings.json ─────────────────────────────────────────────
SETTINGS="$TARGET/.claude/settings.json"
HOOK_BLOCK='{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash $TARGET/.claude/hooks/startup-governance.sh"
          }
        ]
      }
    ]
  }
}'

if [ -f "$SETTINGS" ]; then
    python3 - "$SETTINGS" <<PY
import sys, json

with open(sys.argv[1]) as f:
    existing = json.load(f)

new_hooks = {"UserPromptSubmit": [{"hooks": [{"type": "command", "command": "bash $TARGET/.claude/hooks/startup-governance.sh"}]}]}

if "hooks" not in existing:
    existing["hooks"] = {}

# Merge UserPromptSubmit — append if already has entries
if "UserPromptSubmit" in existing["hooks"]:
    existing["hooks"]["UserPromptSubmit"].extend(new_hooks["UserPromptSubmit"])
else:
    existing["hooks"]["UserPromptSubmit"] = new_hooks["UserPromptSubmit"]

with open(sys.argv[1], 'w') as f:
    json.dump(existing, f, indent=2)

print("  merged hook into existing settings.json")
PY
else
    echo "$HOOK_BLOCK" > "$SETTINGS"
    echo "  created settings.json"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Open Claude Code in $TARGET"
echo "  2. Run /standard to build your personal governance"
echo "  3. After that, your governance loads automatically every session"
