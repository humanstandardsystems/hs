Mark a todo as done in the project's brain: $ARGUMENTS

`$ARGUMENTS` is a substring of the todo's gist, body, or filename. The helper finds the matching open todo and moves it to `todos/done/`, recording who closed it and when.

Run:

```bash
python3 ~/.claude/scripts/brain.py done-todo "$ARGUMENTS"
```

If the helper reports multiple matches, show Source the list and ask which one (re-run with a more specific substring). If no matches, surface that and stop.

Confirm in one line: "Closed: <filename or gist>".

Don't commit — that happens on /done.
