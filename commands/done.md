# /done — end of session primer update

When the user runs /done, do the following:

1. Find the project's `primer.md` — typically at the repo root. If you don't see one, walk up from the current directory until you find it (or stop at the project root).
2. Review the full conversation from this session.
3. Update primer.md with:
   - **current projects**: add or update any projects touched this session with their current status
   - **key decisions**: log any meaningful choices or direction changes made
   - **next steps / open threads**: update with what's unresolved or queued for next session
   - **session log**: add a new row with today's date and a 1-2 sentence summary of the session
4. Update the `_Last updated:` line at the top with today's date and session number.
5. Write the updated file back to disk.
6. Run plugin done hooks: for each file matching `plugins/*/done-hooks.md` (relative to repo root), read it and follow its instructions in order. If no `done-hooks.md` files exist, skip this step.
7. If a brain is configured (the project's CLAUDE.md has a `brain:` line), commit and push any staged brain changes. The brain slash commands (`/decide`, `/todo`, etc.) stage files but don't commit — `/done` is when they ship to the shared brain repo.
8. Confirm to the user: "primer updated." — nothing more.
