#!/usr/bin/env python3
"""Plugin discovery for /rise and /done orchestrators.
Usage: plugin-hooks.py [--done]
  (no flag)  outputs boot hook paths in priority order
  --done     outputs done hook paths in priority order
Each output line is an absolute path to a boot.md or done.md file.

Two-tier scan, merged + sorted by priority (lower runs first; default 50):
  - User-level:     ~/.claude/sources/*/plugin.json
  - Project-local:  <project_root>/plugins/*/plugin.json
"""

import json
import sys
from pathlib import Path

mode = "boot" if "--done" not in sys.argv else "done"
hook_key = "boot_hook" if mode == "boot" else "done_hook"


def _find_root() -> Path:
    cwd = Path.cwd()
    home = Path.home()
    d = cwd
    while True:
        if (d / "CLAUDE.md").exists() or (d / ".git").exists():
            return d
        if d == home or d.parent == d:
            return cwd
        d = d.parent


def _collect(plugins_dir: Path, hooks: list) -> None:
    if not plugins_dir.is_dir():
        return
    for manifest_path in sorted(plugins_dir.glob("*/plugin.json")):
        try:
            manifest = json.loads(manifest_path.read_text())
        except (json.JSONDecodeError, OSError):
            continue
        hook = manifest.get(hook_key)
        if not hook:
            continue
        hook_path = manifest_path.parent / hook
        if hook_path.exists():
            hooks.append((manifest.get("priority", 50), hook_path))


hooks: list = []
_collect(Path.home() / ".claude" / "sources", hooks)
_collect(_find_root() / "plugins", hooks)

hooks.sort(key=lambda x: x[0])
for _, path in hooks:
    print(path)
