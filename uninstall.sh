#!/usr/bin/env bash
# uninstall.sh — remove hs install artifacts. Preserves governance docs and businesses/.
# Usage: bash uninstall.sh <target-dir>

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"
USER_CLAUDE="$HOME/.claude"

if [ -z "$TARGET" ]; then
    echo "usage: bash uninstall.sh <target-dir>" >&2
    echo "  e.g. bash uninstall.sh ~/humanstandard" >&2
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "error: target does not exist: $TARGET" >&2
    exit 1
fi

cat <<EOF
Uninstalling hs from: $TARGET

Will REMOVE:
  - $TARGET/.claude/commands/standard.md
  - $TARGET/.claude/hooks/startup-governance.sh
  - $TARGET/_governance/templates/
  - $TARGET/plugins/README.md
  - Governance preamble block in $TARGET/CLAUDE.md (between markers)
  - Governance hook from $TARGET/.claude/settings.json
  - $USER_CLAUDE/commands/done.md (the /done slash command)

Will KEEP:
  - $TARGET/_governance/foundation.md, enforcement.md, interpretation.md, policy.md
  - $TARGET/businesses/ (your data)
  - $TARGET/primer.md
  - ICM hooks in $USER_CLAUDE/settings.json (see UNINSTALL.md to remove)
  - The source repo at $SOURCE_DIR (delete with: rm -rf $SOURCE_DIR)

EOF

printf "Continue? [y/N] "
read -r REPLY </dev/tty || REPLY="n"
case "$REPLY" in
    y|Y|yes|YES) ;;
    *)
        echo "Aborted."
        exit 0
        ;;
esac

rm -f "$TARGET/.claude/commands/standard.md"
rm -f "$TARGET/.claude/hooks/startup-governance.sh"
rm -rf "$TARGET/_governance/templates"
rm -f "$TARGET/plugins/README.md"
echo "  removed install artifacts"
rmdir "$TARGET/plugins" 2>/dev/null && echo "  removed empty plugins/ folder" || true

if [ -f "$TARGET/CLAUDE.md" ]; then
    python3 - "$TARGET/CLAUDE.md" <<'PY'
import sys, re
path = sys.argv[1]
text = open(path).read()
new_text = re.sub(
    r'<!-- hs:governance-preamble -->.*?<!-- /hs:governance-preamble -->\n*(---\n*)?',
    '',
    text,
    flags=re.DOTALL
)
open(path, 'w').write(new_text.lstrip())
PY
    echo "  stripped governance preamble from CLAUDE.md"
fi

if [ -f "$TARGET/.claude/settings.json" ]; then
    python3 - "$TARGET/.claude/settings.json" <<'PY'
import sys, json
path = sys.argv[1]
try:
    data = json.load(open(path))
except (json.JSONDecodeError, FileNotFoundError):
    sys.exit(0)
hooks_block = data.get("hooks") or {}
upps = hooks_block.get("UserPromptSubmit", [])
filtered = [h for h in upps if "startup-governance.sh" not in json.dumps(h)]
if filtered != upps:
    if filtered:
        hooks_block["UserPromptSubmit"] = filtered
    else:
        hooks_block.pop("UserPromptSubmit", None)
    data["hooks"] = hooks_block
    json.dump(data, open(path, "w"), indent=2)
PY
    echo "  removed governance hook from project settings.json"
fi

rm -f "$USER_CLAUDE/commands/done.md"
echo "  removed /done command (user-level)"

cat <<EOF

Done. Your governance docs, businesses/, and primer.md are preserved.

Optional cleanup:
  rm -rf $SOURCE_DIR             # delete the cloned hs source
  brew uninstall icm             # uninstall ICM
  brew untap rtk-ai/tap          # remove the brew tap

To remove ICM hooks from $USER_CLAUDE/settings.json, see $SOURCE_DIR/UNINSTALL.md
EOF
