# `hs` Plugin Contract — v1
_The shape of a Human Standard plugin. Settled in blue room session 2026-04-28._

---

## Premise

`/rise` is a pure boot orchestrator. It does not render. It does not know about pets, brains, governance, or HUDs. It only:

1. Discovers plugins.
2. Reads each plugin's `boot.md` if present.
3. Asks Claude to follow each `boot.md`'s instructions in declared order.

That's it. Everything visible — including the HUD itself — is a plugin.

The same shape applies to `/done` (session-end orchestrator) and any future lifecycle hook.

---

## What is a plugin?

A folder under `<repo-root>/plugins/<Name>/` containing at minimum:

```
plugins/<Name>/
├── plugin.json        # manifest (required)
├── boot.md            # optional — Claude instructions for /rise
├── done.md            # optional — Claude instructions for /done
└── hud_section.py     # optional — only if plugin contributes to HUD
```

A plugin is **opt-in** to each lifecycle: present `boot.md` → /rise runs it; present `done.md` → /done runs it; declare `hud.section` contribution → HUD plugin captures and frames its output.

---

## Manifest — `plugin.json`

```json
{
  "name": "Pets",
  "version": "0.1.0",
  "description": "Buddy pets that heckle and react across the session.",
  "boot_hook": "boot.md",
  "done_hook": "done.md",
  "contributes": {
    "hud.section": {
      "renderer": "hud_section.py",
      "priority": 100
    }
  },
  "priority": 50
}
```

Fields:
- `name` (required) — plugin identifier. Same as folder name. Slug-safe.
- `version` — semver string. Phase 1: informational only.
- `description` — one-liner shown in plugin listings.
- `boot_hook` — relative path to a markdown file with Claude instructions for `/rise`. Omit if the plugin doesn't run at boot.
- `done_hook` — same shape, for `/done`.
- `contributes.hud.section` — if present, plugin emits a HUD section. `renderer` is a relative path to a Python module that, when executed, prints its block to stdout. `priority` orders sections (lower = earlier).
- `priority` (top-level) — orders boot_hook + done_hook execution across plugins. Lower runs earlier.

Future contribution types (declared but not implemented in v1): `slash_commands`, `statusline.section`, `subagents`, etc.

---

## Lifecycle

### `/rise` (boot)

1. Scan `<repo-root>/plugins/*/plugin.json`. Sort by top-level `priority`.
2. For each plugin with `boot_hook`: read the markdown file, follow instructions in order.
3. The HUD plugin's `boot_hook` is what discovers other plugins' `hud.section` contributions and frames them. `/rise` itself does not render.

### `/done` (end of session)

1. Same as boot, but using `done_hook` instead of `boot_hook`.
2. Plugins doing cleanup (commit + push for Brain, primer update for core, etc.) live here.

### Ordering rules

- Top-level `priority` orders boot/done hooks. The HUD plugin should be the last boot hook (highest `priority` value) so other plugins' state is settled before HUD reads it.
- `contributes.hud.section.priority` orders sections within the HUD frame. Plugins fight for visual real estate via this number, not via direct discovery.

---

## HUD contribution — the magic

A plugin contributing to HUD writes `hud_section.py`:

```python
# plugins/Pets/hud_section.py
from hud.render import section, line, meter, divider

def render():
    print(divider("BUDDY"))
    print(line(""))
    print(line(f"  {buddy_name}"))
    print(line(f"  XP [{meter(xp_m)}] {xp}/455"))
    print(line(""))
```

The plugin **prints** its block to stdout using the shared `hud.render` library. It does NOT return data. It does NOT know about HUD's frame or other plugins.

The HUD plugin's `boot.md` instructs Claude to:

1. Open the box frame.
2. Render core sections (governance, tasks, primer, blockers).
3. For each plugin with `contributes.hud.section`, in priority order: import its `renderer` module, capture stdout while calling `render()`, weave captured lines into the frame.
4. Close the frame.

Plugins remain debug-runnable standalone — `python3 plugins/Pets/hud_section.py` prints the unframed BUDDY block directly.

---

## The render library — `hud.render`

Importable Python module shipped by the HUD plugin. Plugin authors `from hud.render import …`. API surface (v1):

- `line(content: str) -> str` — pad and return a framed line (returned, not printed; plugin still calls `print(line(...))`).
- `divider(label: str) -> str` — section divider with label.
- `meter(filled: int, total: int = 20) -> str` — progress bar.
- `wrap_box(text: str, prefix_plain: str = "", prefix_colored: str = "") -> list[str]` — wrap long text into multiple framed lines.
- `section(title: str, body_lines: list[str]) -> None` — convenience that prints divider + body. Optional sugar.

Color constants (`C`, `G`, `Y`, `BR`, `BG`, etc.) are exposed for plugins that need raw ANSI. Most plugins won't.

The render library lives in `plugins/HUD/render/` and is added to `sys.path` by the HUD plugin's boot before any plugin's `hud_section.py` is imported.

---

## Discovery rules

`/rise` (and HUD) discover plugins under `<repo-root>/plugins/*/`. Repo root is determined by walking up from CWD until a `.git` directory is found, OR until a `CLAUDE.md` is found at the candidate root, whichever comes first.

Plugins are project-scoped by default. Universal plugins (e.g. Brain, which has no project-specific state of its own) MAY later be promoted to `~/.claude/plugins/` with project-overrides-user precedence. Phase 1 keeps this simple: per-project only.

---

## Where things live

| What | Where | Why |
|------|-------|-----|
| `/rise` orchestrator | `~/.claude/scripts/rise.py` | One copy. Universal. Future: installed by `hs install`. |
| `/rise` slash command | `~/.claude/commands/rise.md` | Points at the user-level orchestrator. |
| Plugins | `<repo>/plugins/<Name>/` | Project-scoped. Discovered relative to repo root. |
| HUD plugin | `<repo>/plugins/HUD/` | Visual frame + render library + core sections. |
| Plugin contract spec | `hs/docs/plugin-contract.md` | This file. Canonical reference. |

Per-project copies of `rise.py` (currently in `r29k/.claude/`, `humanstandard/.claude/`, `claude-buddy/.claude/`) get overridden once the user-level version is stable. Either deleted, or replaced with a thin shim that `exec`s the user-level one.

---

## Migration plan (Phase 1 implementation)

1. Move existing `rise.py` → `~/.claude/scripts/rise.py` as-is. Update slash command. Verify visual identity. _(sanity checkpoint)_
2. Refactor: split orchestrator from HUD. Orchestrator shrinks to ~30 lines. HUD plugin gets the rest.
3. Migrate hardcoded BUDDY out of HUD into `plugins/Pets/hud_section.py`. Pets manifest declares contribution.
4. Visual regression check — `/rise` output identical to today.
5. Build `plugins/Brain/` (boot_hook + hud_section + done_hook) as second consumer.
6. Override per-project `rise.py` copies with shim or delete.

Each step is a clean checkpoint — no behavior change should sneak between visual-regression-passing states.

---

## Phase 2 — explicitly deferred

- **`contributes.slash_commands`** — plugins registering slash commands. Phase 1 keeps slash commands in `~/.claude/commands/`.
- **`contributes.statusline.section`** — same magic mechanic for the statusline.
- **Plugin install/uninstall via `hs install <plugin>`** — needs hs CLI to grow up first.
- **Universal plugins at `~/.claude/plugins/`** — promote pattern once we have a real candidate (Brain).
- **Plugin dependency declarations** — "Plugin X requires HUD ≥ 0.2." Not needed yet; we have one canonical HUD.
- **Sandbox / capability limits** — plugins import freely from each other's render libs in v1. If trust ever becomes a concern, revisit.

---

## Open questions (still live, not blocking implementation)

- **Where do core HUD sections live?** Currently planned inside `plugins/HUD/render/sections/`. Alternative: each (governance, tasks, primer, blockers) becomes its own plugin. Defer until we have a reason to split.
- **Should Brain be per-project or user-level?** Logic is universal, only the brain repo path differs (resolved from `CLAUDE.md`). Phase 1: per-project. Promote when a second brain-using project exists.
- **Boot hook ordering when plugins genuinely don't care.** Manifest priority works but is ad-hoc. Maybe v2 introduces phases ("pre-render", "render", "post-render"). Not needed yet.

---

_Built from blue room decisions: HUD-as-plugin (Q1 → "make HUD a plugin too, /rise just runs boot logic"), magic stdout capture (Q2), per-user orchestrator + per-project plugins + spec-in-hs (Q3)._
