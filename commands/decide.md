Source just made a decision: $ARGUMENTS

Record it in the project's brain.

Extract from $ARGUMENTS:
- **gist** — one line, max 70 chars, the punchline (e.g. "Going with Stripe, not PayPal")
- **body** — the reasoning, multi-line OK; expand the "why" if Source gave it
- **importance** — critical | high | medium | low (decisions default to `high`)
- **keywords** — 2-5 short lowercase tags (e.g. `pricing,stripe,payments`)

Then run, piping the body via stdin:

```bash
printf '%s\n' "<body>" | python3 ~/.claude/scripts/brain.py write decisions \
  --gist "<gist>" \
  --importance "<importance>" \
  --keywords "<keywords>"
```

Confirm in one line: "Decided: <gist>". The helper resolves brain path + author and stages the file. Don't commit — that happens on /done.

If the helper errors (no brain configured, etc.), surface the message verbatim and stop.
