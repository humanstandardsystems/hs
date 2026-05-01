# Uninstalling hs

Removes everything hs installed. Your personal data — governance documents, `businesses/`, `primer.md` — is **preserved by default**.

## Quick uninstall

```bash
bash ~/.claude/sources/hs/uninstall.sh ~/humanstandard
```

Replace `~/humanstandard` with whatever master folder path you installed into.

The script asks for confirmation before removing anything.

## What the script removes

**From your master folder (e.g. `~/humanstandard/`):**
- `.claude/commands/standard.md`
- `.claude/hooks/startup-governance.sh`
- `_governance/templates/`
- `plugins/README.md`
- The governance preamble block in `CLAUDE.md` (between `<!-- hs:governance-preamble -->` markers)
- The governance hook from `.claude/settings.json`

**From `~/.claude/`:**
- `commands/done.md` (the `/done` slash command)

## What the script keeps

- `_governance/foundation.md`, `enforcement.md`, `interpretation.md`, `policy.md` — your personal governance
- `businesses/` and all its contents
- `primer.md`
- ICM hooks in `~/.claude/settings.json`
- The cloned source at `~/.claude/sources/hs/`

## Optional: remove ICM hooks

If you want to fully remove ICM (memory layer), run this AFTER the uninstall script:

```bash
python3 - ~/.claude/settings.json <<'PY'
import sys, json
path = sys.argv[1]
data = json.load(open(path))
hooks = data.get("hooks") or {}
for event in list(hooks.keys()):
    filtered = [
        e for e in hooks[event]
        if not any("icm hook" in (h.get("command") or "") for h in (e.get("hooks") or []))
    ]
    if filtered:
        hooks[event] = filtered
    else:
        hooks.pop(event)
data["hooks"] = hooks
json.dump(data, open(path, "w"), indent=2)
PY

brew uninstall icm
brew untap rtk-ai/tap
```

## Optional: delete the source repo

```bash
rm -rf ~/.claude/sources/hs
```

## Optional: delete your governance and businesses

These are yours — the uninstaller doesn't touch them. If you also want them gone:

```bash
rm -rf ~/humanstandard/_governance ~/humanstandard/businesses ~/humanstandard/primer.md
```
