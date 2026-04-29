Add or update a glossary term in the project's brain: $ARGUMENTS

Glossary entries are the project's shared vocabulary — terms both humans and Claudes use the same way ("host-flow", "welcome-packet", "B2B route list", etc.). One file per term, slug-named, edit in place.

Parse `$ARGUMENTS`:
- First word(s) before `--` or first sentence = **term** (e.g. "Host Flow")
- Remainder = **definition** (1-3 sentences, the canonical meaning)

If `$ARGUMENTS` is just one word, ask Source what the definition should be before writing.

Run, piping the definition via stdin:

```bash
printf '%s\n' "<definition>" | python3 ~/.claude/scripts/brain.py glossary "<term>"
```

The helper writes/updates `glossary/<slug>.md`. If the term already exists, it preserves the original `created:` and updates the `updated:` field.

Confirm in one line: "Glossary: <term>". Don't commit — that happens on /done.
