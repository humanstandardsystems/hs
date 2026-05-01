#!/usr/bin/env bash
# update.sh — pull the latest hs and re-run install against the same target.
# Usage: bash update.sh <target-dir>
#   e.g. bash update.sh ~/humanstandard

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    echo "usage: bash update.sh <target-dir>" >&2
    echo "  e.g. bash update.sh ~/humanstandard" >&2
    exit 1
fi

echo "Pulling latest hs..."
git -C "$SOURCE_DIR" pull --rebase --autostash

echo ""
bash "$SOURCE_DIR/install.sh" "$TARGET"
