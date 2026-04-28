# /done — end of session primer update

When the user runs /done, do the following in order:

## 1. Update primer.md (keep it lean — target ~50 lines)

Find the project's `primer.md` (typically at the repo root). Review the full session conversation. Update:

- **current projects**: rewrite rows for any project touched. Remove completed/stable entries that no longer need tracking.
- **environment**: only update if something actually changed (new tool, path, etc.). Don't touch if stable.
- **next steps**: remove completed items. Add new actionable items. Keep only what's actually queued next.
- **session log**: add ONE new row (date + 1-2 sentence summary). If there are more than 5 rows, move the oldest to `lab/session-archive.md` (append, don't overwrite) until only 5 remain.

Update the `_Last updated:` line. Write primer.md back. **Do not add a "key decisions" section to primer.md.**

## 2. Archive decisions

If any meaningful architectural decisions or durable rules were made this session: append them to `lab/decisions-log.md` as bullet points. One tight line each. Skip trivial choices.

## 3. Run plugin done hooks

Discover done hooks by running (if rise.py is present):

```bash
python3 ~/.claude/scripts/rise.py --done
```

For each path returned: read that file and follow its instructions.

## 4. Commit brain changes (if brain is configured)

If the project's CLAUDE.md has a `brain:` line: commit and push any staged brain files. The brain slash commands (`/decide`, `/todo`, etc.) stage files but don't commit — `/done` is when they ship to the shared repo.

## 5. Confirm

Say "primer updated." — nothing more.
