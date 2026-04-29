# Human Standard AI Policy Specification
**Version:** 1.0
**Status:** Public

---

## What This Is

Human Standard is a personal AI governance framework for independent professionals. It produces four plain-language documents that define how AI works for you — what it can do, what it can't, and who stays in charge.

The framework is built on one principle: **responsibility lives with the living user.** AI is a tool. The human operating it bears accountability for its output, its reach, and its consequences.

---

## The Framework

Governance is expressed across four layers, each building on the one above:

| Layer | Document | Purpose |
|-------|----------|---------|
| 1 | **Foundation** | Core rules, limits, and authority boundaries. Immutable — may only be superseded, never edited in place. |
| 2 | **Enforcement** | How violations are identified and corrected. Determines what constitutes a breach and who has authority to act. |
| 3 | **Interpretation** | Permitted AI behavior by domain and context. Defines what AI may assist with in your specific work. |
| 4 | **Policy** | Succession and stewardship. Who manages your digital presence if you're unable to. |

These four documents form a complete, self-consistent governance set. No layer creates permissions that contradict a higher layer.

---

## The Ten Questions

Setup is a guided questionnaire. Each question establishes a specific governance clause.

### Work Context
**Q1 — What best describes your work?**
Establishes the operational scope of the framework. Whether you work solo, across multiple organizations, or in an admin/ops context determines how the Interpretation layer is structured.

### Permitted Use
**Q2 — What do you want AI to help you with?**
Defines the permitted use list in the Interpretation layer. Drafting, organizing, and research each carry different trust levels and disclosure requirements.

### Hard Limits
**Q3 — What should AI never do without asking you first?**
Populates the Authority Limits section of the Foundation. These become named prohibitions — not guidelines, hard stops.

### Voice and Representation
**Q4 — AI drafting messages that sound like you — how do you feel about that?**
Sets the Representation Restriction clause in the Foundation. Ranges from hard prohibition (nothing unseen leaves) to tiered approval (routine permitted, material requires review).

### Client Data
**Q5 — How should AI handle information that belongs to your clients?**
Adds explicit confidentiality requirements to the Interpretation layer. Task-only use, no retention, and no sharing are each enforceable clauses, not defaults.

### Team Structure
**Q6 — Do you work with other people?**
Determines whether the Organizational domain section appears in the Interpretation layer at all. Solo operators get a simpler document; teams get scope-limited rules for collaborator context.

### Cognitive Sovereignty
**Q7 — How do you feel about AI learning your habits and patterns over time?**
Sets the Cognitive Sovereignty clause in the Foundation. No profiling, task-only analysis, and disclosed analysis are meaningfully different positions — each produces different language.

### Past Concerns
**Q8 — Has AI ever done something that made you uncomfortable?**
Adds a Personal Boundaries section to the Foundation. Assumed intent, unexpected data use, and loss of control each become named rules based on lived experience, not hypotheticals.

### Control Philosophy
**Q9 — What does 'being in control' mean to you when it comes to AI?**
Shapes the oversight philosophy in the Enforcement layer. Full approval-gate, transparency-and-revocability, human-accountability-first, and AI-mediated-with-alerts are distinct governance postures with different operational implications. The AI-mediated option captures delegated monitoring: AI handles routine operations, notifies the user of exceptions, and the user retains override authority at all times.

### Stewardship
**Q10 — Who would you trust to manage your digital presence if something happened to you?**
Names the steward role in the Policy document. Family, business contact, or legal executor. This question has no wrong answer — it just needs one.

---

## Core Positions

These are fixed across all generated documents regardless of questionnaire answers:

- AI systems do not possess agency, authority, or decision-making power
- Final responsibility always remains with a living human
- Permissions are scoped, temporary, and revocable — never perpetual
- No automated system may trigger, authorize, or execute a version change to the Foundation
- Human review is required before any consequential action
- Any attempt by an AI system to escalate its own authority results in immediate revocation

---

## What Gets Generated

Running `/standard` produces:

- `_governance/foundation.md` — The core document. Defines your rules, limits, and hard stops.
- `_governance/enforcement.md` — How you identify and correct violations during active use.
- `_governance/interpretation.md` — What AI may and may not do in the context of your specific work.
- `_governance/policy.md` — Succession and stewardship for your digital presence.
- `_governance/README.md` — Index of all four with generation date.
- `businesses/<name>/memory.md` — One file per client or company you named, ready for notes.

Setup takes under five minutes. The documents are yours — plain markdown, no lock-in.

---

## Design Decisions

**Why four documents instead of one?**
Each layer has a different lifecycle. The Foundation is immutable by design. Enforcement is operational and may need adjustment as tools change. Interpretation is context-specific and may vary by client. Policy is rarely touched but must exist. Separating them lets you update what needs updating without reopening settled questions.

**Why questions instead of a policy template?**
Governance that doesn't reflect how you actually think and work won't be followed. The questions surface real positions — including positions you may not have articulated before — and turn them into durable language. The output is yours, not a generic terms-of-service.

**Why is the Foundation immutable?**
A governance document that can be quietly edited in place isn't governance. The Foundation may only be superseded by a new version you explicitly author. This is intentional friction — it means the core principles require your active decision to change, not just a file edit.

---

*Human Standard is built and maintained by Human Standard Systems.*
