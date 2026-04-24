# governance-setup

A plug-and-play environment for building your personal AI governance inside Claude Code.

Run `/standard` and Claude walks you through a short questionnaire. Answer how you actually feel — no legal knowledge required. At the end, you get four governance documents that define how AI works for you: what it can do, what it can't, and who stays in charge.

Built on the [Human Standard](https://humanstandard.co) framework.

---

## Setup

```bash
git clone https://github.com/humanstandardsystems/governance-setup.git
cd your-project
bash /path/to/governance-setup/install.sh
```

Then open Claude Code in your project and run:

```
/standard
```

Claude will guide you through the rest.

---

## What gets generated

Four documents written to `_governance/`:

| Document | What it does |
|----------|-------------|
| `foundation.md` | Your core rules — what AI can and can't do, your cognitive sovereignty, your personal boundaries |
| `enforcement.md` | How violations are handled while you're in control |
| `interpretation.md` | Domain-by-domain permissions — business, personal, financial, creative |
| `policy.md` | What happens to your AI systems if something happens to you |

---

## How it works

The questionnaire asks about your philosophy, fears, and desires — not technical preferences. Every answer maps to a specific part of the governance framework. The structure stays tight; your voice fills it in.

---

## License

MIT
