Sync the project's brain — pull latest from the remote, import into ICM if available.

Use this mid-session when the other person ("mom messaged me she just pushed something") has written into the brain since /rise pulled it.

Run:

```bash
python3 ~/.claude/scripts/brain.py sync
```

The helper will:
1. `git pull --rebase --autostash` the brain repo.
2. If `icm` is installed, run `icm import` per topic folder.

After it returns, briefly tell Source what's new — scan recent commits in the brain repo for anything since the last sync:

```bash
cd <brain-path> && git log --oneline -10
```

If there's nothing new, say "Brain's already current."
