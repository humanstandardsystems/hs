#!/usr/bin/env bash
# install.sh — set up a Human Standard environment
# Usage: bash /path/to/hs/install.sh [target-dir]
# Defaults to current directory if no target is given.
#
# Installs:
#   - Project-level: governance scaffold, /standard, startup hook, CLAUDE.md, settings.json
#   - User-level:    /done command
#   - User-level:    ICM hooks (required — install via: brew tap rtk-ai/tap && brew install icm && icm init)
#   - Project root:  primer.md template (only if missing)

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"
USER_CLAUDE="$HOME/.claude"

if [ "$TARGET" = "$SOURCE_DIR" ]; then
    echo "error: target cannot be the hs repo itself." >&2
    exit 1
fi

echo "Setting up Human Standard in: $TARGET"

# ── Create directory structure ───────────────────────────────────────────────
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/hooks"
mkdir -p "$TARGET/_governance/templates"
mkdir -p "$USER_CLAUDE/commands"

# ── Gitignore — exclude session state file ───────────────────────────────────
GITIGNORE="$TARGET/.gitignore"
if ! grep -qF "_governance/.session" "$GITIGNORE" 2>/dev/null; then
    echo "_governance/.session" >> "$GITIGNORE"
    echo "  added _governance/.session to .gitignore"
fi

# ── Copy Claude commands (project) ───────────────────────────────────────────
cp "$SOURCE_DIR/.claude/commands/standard.md" "$TARGET/.claude/commands/"
echo "  copied /standard command"

# ── Copy hook scripts ────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/hooks/startup-governance.sh" "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/startup-governance.sh"
echo "  copied startup-governance hook"

# ── Copy governance templates ────────────────────────────────────────────────
cp "$SOURCE_DIR/_governance/templates/"*.md "$TARGET/_governance/templates/"
echo "  copied governance templates"

# ── Scaffold plugins folder ──────────────────────────────────────────────────
mkdir -p "$TARGET/plugins"
if [ -f "$SOURCE_DIR/plugins/README.md" ]; then
    cp "$SOURCE_DIR/plugins/README.md" "$TARGET/plugins/README.md"
    echo "  scaffolded plugins/ folder"
fi

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

# ── Write or merge project settings.json ─────────────────────────────────────
SETTINGS="$TARGET/.claude/settings.json"
GOVERNANCE_HOOK="bash $TARGET/.claude/hooks/startup-governance.sh"

if [ -f "$SETTINGS" ]; then
    python3 - "$SETTINGS" "$GOVERNANCE_HOOK" <<'PY'
import sys, json

settings_path, hook_cmd = sys.argv[1], sys.argv[2]

with open(settings_path) as f:
    existing = json.load(f)

existing.setdefault("hooks", {})
existing["hooks"].setdefault("UserPromptSubmit", [])

already = any(
    hook_cmd in (h.get("command") or "")
    for entry in existing["hooks"]["UserPromptSubmit"]
    for h in entry.get("hooks", [])
)

if already:
    print("  governance hook already wired — nothing to do")
else:
    existing["hooks"]["UserPromptSubmit"].append(
        {"hooks": [{"type": "command", "command": hook_cmd}]}
    )
    with open(settings_path, 'w') as f:
        json.dump(existing, f, indent=2)
    print("  merged governance hook into existing settings.json")
PY
else
    cat > "$SETTINGS" <<EOF
{
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
}
EOF
    echo "  created settings.json"
fi

# ── Install /done command (user-level) ───────────────────────────────────────
cp "$SOURCE_DIR/commands/done.md" "$USER_CLAUDE/commands/done.md"
echo "  installed /done command (user-level)"

# ── Write/prepend top-level CLAUDE.md with governance read-order ─────────────
ROOT_CLAUDE_MD="$TARGET/CLAUDE.md"
GOVERNANCE_MARKER="<!-- hs:governance-preamble -->"
GOVERNANCE_BLOCK="$GOVERNANCE_MARKER
# Read first

Before responding to any user message, read these governance documents in this exact order:

1. \`_governance/foundation.md\` — what AI is for
2. \`_governance/enforcement.md\` — what happens when policy is broken
3. \`_governance/interpretation.md\` — how to read ambiguous situations
4. \`_governance/policy.md\` — what AI is allowed and not allowed to do

Then read any \`businesses/*/memory.md\` files for company-specific context.

These documents are binding on your behavior this session.

If \`_governance/foundation.md\` does not exist yet, run \`/standard\` immediately to set it up before doing anything else.
<!-- /hs:governance-preamble -->
"

if [ -f "$ROOT_CLAUDE_MD" ] && grep -qF "$GOVERNANCE_MARKER" "$ROOT_CLAUDE_MD"; then
    echo "  CLAUDE.md governance preamble already present — leaving as-is"
elif [ -f "$ROOT_CLAUDE_MD" ]; then
    EXISTING_CLAUDE=$(cat "$ROOT_CLAUDE_MD")
    {
        printf "%s\n---\n\n%s\n" "$GOVERNANCE_BLOCK" "$EXISTING_CLAUDE"
    } > "$ROOT_CLAUDE_MD"
    echo "  prepended governance preamble to existing CLAUDE.md"
else
    printf "%s" "$GOVERNANCE_BLOCK" > "$ROOT_CLAUDE_MD"
    echo "  created CLAUDE.md with governance preamble"
fi

# ── Drop primer.md template at project root (only if missing) ────────────────
PRIMER="$TARGET/primer.md"
if [ -f "$PRIMER" ]; then
    echo "  primer.md already exists — leaving as-is"
else
    cp "$SOURCE_DIR/templates/primer.md" "$PRIMER"
    echo "  created primer.md template"
fi

# ── Wire ICM hooks into user settings.json (required) ────────────────────────
USER_SETTINGS="$USER_CLAUDE/settings.json"
ICM_BIN="$(command -v icm || true)"

if [ -z "$ICM_BIN" ]; then
    echo ""
    echo "ICM (memory layer) is required but not installed."
    if ! command -v brew >/dev/null 2>&1; then
        echo "error: Homebrew isn't installed either. Install brew first:" >&2
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" >&2
        echo "Then re-run this installer." >&2
        exit 1
    fi
    printf "Install ICM now via Homebrew? [Y/n] "
    read -r REPLY </dev/tty || REPLY="n"
    case "$REPLY" in
        ""|y|Y|yes|YES)
            brew tap rtk-ai/tap
            brew install icm
            icm init
            ICM_BIN="$(command -v icm || true)"
            if [ -z "$ICM_BIN" ]; then
                echo "error: ICM install ran but \`icm\` still not on PATH. Open a new shell and re-run this installer." >&2
                exit 1
            fi
            ;;
        *)
            echo "Skipping. Re-run this installer after manually installing ICM:" >&2
            echo "    brew tap rtk-ai/tap && brew install icm && icm init" >&2
            exit 1
            ;;
    esac
fi

python3 - "$USER_SETTINGS" "$ICM_BIN" <<'PY'
import sys, json, os

settings_path, icm_bin = sys.argv[1], sys.argv[2]

if os.path.exists(settings_path):
    with open(settings_path) as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            data = {}
else:
    data = {}

data.setdefault("hooks", {})

icm_hooks = {
    "PreToolUse":       {"matcher": "Bash", "command": f"{icm_bin} hook pre"},
    "PostToolUse":      {"command": f"{icm_bin} hook post"},
    "PreCompact":       {"command": f"{icm_bin} hook compact"},
    "UserPromptSubmit": {"command": f"{icm_bin} hook prompt"},
    "SessionStart":     {"command": f"{icm_bin} hook start"},
}

def already_wired(events, cmd_substr):
    for entry in events or []:
        for h in entry.get("hooks", []) or []:
            if cmd_substr in (h.get("command") or ""):
                return True
    return False

added = 0
for event, spec in icm_hooks.items():
    data["hooks"].setdefault(event, [])
    if already_wired(data["hooks"][event], "icm hook"):
        continue
    new_entry = {"hooks": [{"type": "command", "command": spec["command"]}]}
    if "matcher" in spec:
        new_entry["matcher"] = spec["matcher"]
    data["hooks"][event].append(new_entry)
    added += 1

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)

if added:
    print(f"  wired {added} ICM hook(s) into {settings_path}")
else:
    print("  ICM hooks already wired — nothing to do")
PY

echo ""
echo "Done. Open Claude Code in $TARGET"
echo "  - On first session, Claude reads CLAUDE.md and auto-runs /standard to build your governance."
echo "  - After that, your governance docs in _governance/ are loaded on every session."
echo "  - Edit primer.md to capture current project state when you're ready."
echo ""
echo "Your governance loads automatically every session."
