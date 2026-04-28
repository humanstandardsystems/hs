Source added a todo: $ARGUMENTS

Record it in the project's brain (todos/open/).

Extract from $ARGUMENTS:
- **gist** — one line, max 70 chars, action-oriented ("Wire up Stripe webhook")
- **body** — any extra context Source gave; can be brief
- **importance** — critical | high | medium | low (default `medium`)
- **keywords** — 2-5 short lowercase tags

Then run, piping the body via stdin:

```bash
printf '%s\n' "<body>" | python3 ~/.claude/scripts/brain.py write todos \
  --gist "<gist>" \
  --importance "<importance>" \
  --keywords "<keywords>"
```

Confirm in one line: "Todo: <gist>". Don't commit — that happens on /done.

If the helper errors, surface the message verbatim and stop.
