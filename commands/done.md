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

Scan `plugins/*/plugin.json` at the project root. For each file found:
- Read it and check for a `done_hook` field
- If present, read the file at that path and follow its instructions

If no `plugins/` directory exists or no plugins declare a `done_hook`, skip this step.

## 3. Confirm

Say "primer updated." — nothing more.
