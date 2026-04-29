# Brain plugin — /done hook

## Commit brain changes

Check if the project's CLAUDE.md has a `brain:` line.

If it does:
- Run `git -C <brain-path> status --porcelain` to check for staged or unstaged changes
- If any exist, run `git -C <brain-path> add -A && git -C <brain-path> commit -m "brain: session update" && git -C <brain-path> push`
- If nothing to commit, skip silently

If no `brain:` line is found, skip this step entirely.
