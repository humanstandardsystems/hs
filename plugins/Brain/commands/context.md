Source added context to the project's brain: $ARGUMENTS

Context is for things that aren't decisions but are useful for future sessions: voice/taste, project history, customer notes, "the way we talk about X", etc.

Extract from $ARGUMENTS:
- **gist** — one line, max 70 chars, the headline
- **body** — the full thought; preserve nuance, don't compress aggressively
- **importance** — critical | high | medium | low (default `medium`)
- **keywords** — 2-5 short lowercase tags

Then run, piping the body via stdin:

```bash
printf '%s\n' "<body>" | python3 ~/.claude/scripts/brain.py write context \
  --gist "<gist>" \
  --importance "<importance>" \
  --keywords "<keywords>"
```

Confirm in one line: "Context: <gist>". Don't commit — that happens on /done.

If the helper errors, surface the message verbatim and stop.
