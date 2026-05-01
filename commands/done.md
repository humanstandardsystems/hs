# /done — end of session primer update

When the user runs /done, do the following in order:

## 1. Update primer.md (keep it lean — target ~50 lines)

Find the project's `primer.md` (typically at the repo root). Review the full session conversation. Update:

- **current projects**: rewrite rows for any project touched. Remove completed/stable entries that no longer need tracking.
- **environment**: only update if something actually changed (new tool, path, etc.). Don't touch if stable.
- **next steps**: remove completed items. Add new actionable items. Keep only what's actually queued next.
- **session log**: add ONE new row (date + 1-2 sentence summary). If there are more than 5 rows, drop the oldest until only 5 remain.

Update the `_Last updated:` line. Write primer.md back.

## 2. Run plugin done hooks

Scan `~/.claude/sources/*/plugin.json`. For each file found:
- Read it and check for a `done_hook` field
- If present, read the file at that path (relative to the plugin's repo root) and follow its instructions
- Run hooks in order of the manifest's top-level `priority` field (lower = earlier; default 50)

If `~/.claude/sources/` doesn't exist or no plugins declare a `done_hook`, skip this step silently. Repos in `~/.claude/sources/` without a `plugin.json` are not plugins — skip them.

## 3. Store session summary to ICM

Review the full session conversation for anything worth remembering long-term. Store each significant item using `icm_memory_store`. Skip this step entirely if ICM tools are unavailable.

What to store and how:

| What happened | topic | importance |
|---|---|---|
| Decision made (architecture, tooling, design) | `decisions-{project}` | high |
| Error diagnosed and resolved | `errors-resolved` | high |
| Feature or significant task completed | `context-{project}` | high |
| User preference or working style discovered | `preferences` | critical |

Rules:
- Derive `{project}` from the primer.md project name or CLAUDE.md identity. If unclear, use `general`.
- One store call per distinct item. Don't bundle unrelated things.
- Skip items already captured in primer.md that have no long-term reuse value.
- If nothing significant happened, skip silently.

## 4. Confirm

Say "primer updated." — nothing more.
