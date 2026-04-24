# /standard — Human Standard Governance Setup

Guide the user through building their personal AI governance documents.

---

## Step 1 — Check for existing governance

Check if `_governance/foundation.md` already exists.

If it does, tell the user their governance is already configured and ask if they want to rebuild it. If they say no, stop here.

---

## Step 2 — Introduction

Say this to the user, warmly and in plain language:

> "We're going to build your personal AI governance — it only takes a few minutes. These documents define how AI works for you: what it can do, what it can't, and who stays in charge. Answer however feels right. There are no wrong answers."

---

## Step 3 — Questionnaire Batch 1

Use AskUserQuestion with these 4 questions:

**Q1**
- question: "What best describes your work?"
- header: "Your work"
- multiSelect: false
- options:
  - label: "Solo consultant" | description: "I work directly with clients on projects"
  - label: "Multi-org work" | description: "I work across multiple businesses and organizations"
  - label: "Admin & ops" | description: "I handle administrative and operational work independently"

**Q2**
- question: "What do you want AI to help you with?"
- header: "AI help"
- multiSelect: true
- options:
  - label: "Drafting" | description: "Emails and documents I review before sending"
  - label: "Organizing" | description: "Summarizing, note-taking, structuring information"
  - label: "Research" | description: "Finding information and giving me analysis I can use"

**Q3**
- question: "What should AI never do without asking you first?"
- header: "Hard limits"
- multiSelect: true
- options:
  - label: "Send messages" | description: "Any communication going out under my name"
  - label: "Modify my data" | description: "Changes to my files, accounts, or records"
  - label: "Affect clients" | description: "Any decision or action that touches my clients or business"

**Q4**
- question: "AI drafting messages that sound like you — how do you feel about that?"
- header: "Your voice"
- multiSelect: false
- options:
  - label: "Always approve" | description: "Never — I review everything before it goes out"
  - label: "Drafts only" | description: "Drafts are fine, but I always approve before sending"
  - label: "Routine is ok" | description: "Simple replies could be automated; important things need review"

---

## Step 4 — Questionnaire Batch 2

Use AskUserQuestion with these 4 questions:

**Q5**
- question: "How should AI handle information that belongs to your clients?"
- header: "Client data"
- multiSelect: true
- options:
  - label: "Task-only use" | description: "Only use it for the specific task I give it — nothing else"
  - label: "No retention" | description: "Never retain or reference client info beyond the active task"
  - label: "No sharing" | description: "Never share it with other systems or outside its original context"

**Q6**
- question: "Do you work with other people?"
- header: "Your team"
- multiSelect: false
- options:
  - label: "Yes, regularly" | description: "Contractors or collaborators I work with often"
  - label: "Sometimes" | description: "I bring people in on specific projects"
  - label: "Just me" | description: "No — it's just me right now"

**Q7**
- question: "How do you feel about AI learning your habits and patterns over time?"
- header: "Your patterns"
- multiSelect: false
- options:
  - label: "No profiling" | description: "I don't want a profile built of how I think or work"
  - label: "Task-only" | description: "Fine to analyze for the current task, but don't retain it"
  - label: "With disclosure" | description: "Fine as long as I'm told about it upfront"

**Q8**
- question: "Has AI ever done something that made you uncomfortable?"
- header: "Past concerns"
- multiSelect: true
- options:
  - label: "Assumed intent" | description: "It assumed what I wanted instead of asking"
  - label: "Unexpected use" | description: "It used my information in a way I didn't expect"
  - label: "Took over" | description: "It felt like it was making decisions for me"

---

## Step 5 — Questionnaire Batch 3

Use AskUserQuestion with these 2 questions:

**Q9**
- question: "What does 'being in control' mean to you when it comes to AI?"
- header: "Control"
- multiSelect: false
- options:
  - label: "Full approval" | description: "Nothing moves without my explicit approval"
  - label: "Informed + stop" | description: "I stay informed and can stop or undo anything at any time"
  - label: "My responsibility" | description: "AI helps me, but the responsibility always stays with me"

**Q10**
- question: "Who would you trust to manage your digital presence if something happened to you?"
- header: "Stewardship"
- multiSelect: false
- options:
  - label: "Family member" | description: "Someone in my family I trust completely"
  - label: "Business contact" | description: "A business partner, colleague, or professional contact"
  - label: "Legal executor" | description: "My attorney, executor, or estate representative"

After batch 3, ask in plain text:

> "Almost done — three quick things:
> 1. What's your name?
> 2. What's the name of your business or LLC? (Legal name is only used to organize your setup — it won't be shared or used for anything formal.)
> 3. What companies or clients do you work with regularly? List each one by name, one per line — legal name just helps keep your folders organized. Skip this if it's just you."

Wait for their full response before continuing. Parse it for: name, business name, and a list of company/client names (may be empty).

---

## Step 6 — Generate the governance documents

Read each template from `_governance/templates/`. Personalize based on answers. Write final documents to `_governance/`.

### Answer → document mapping

**foundation.md**
- Replace `{{AUTHOR_NAME}}` with their name throughout
- Replace `{{CONTROLLED_ENTITY}}` with their business name
- Q3 → expand the Authority Limits prohibited list with their specific concerns written as plain rules
- Q4 → set Representation Restriction tone:
  - "Always approve" = zero-tolerance language, hard prohibition on anything unseen
  - "Drafts only" = review-required language, drafts permitted, sending never
  - "Routine is ok" = tiered language, routine permitted, material requires review
- Q7 → set Cognitive Sovereignty language:
  - "No profiling" = hard prohibition on pattern analysis and retention
  - "Task-only" = scoped analysis permitted, zero retention
  - "With disclosure" = analysis permitted with prior disclosure
- Q8 → add a "Personal Boundaries" section after Cognitive Sovereignty. Write each selected concern as a named plain-language rule. If "Other" text was provided, incorporate it.

**interpretation.md**
- Replace `{{AUTHOR_NAME}}` with their name
- Q2 → populate permitted uses list in Business domain from their selections
- Q5 → add as explicit confidentiality requirements under Business domain
- Q6 → "Just me" = omit Organizational domain section entirely; "Sometimes" or "Yes, regularly" = include it
- Q7 → set memory and data retention rules per domain to match their stance

**policy.md**
- Replace `{{AUTHOR_NAME}}` with their name
- Replace `{{CONTROLLED_ENTITY}}` with their business name
- Q10 → name the steward role. If they provided a name, use it. Otherwise use their selected description (e.g., "a designated family member", "a trusted business partner")

**enforcement.md**
- Replace `{{AUTHOR_NAME}}` with their name
- Q9 → shape the oversight philosophy opening:
  - "Full approval" = explicit approval-gate framing
  - "Informed + stop" = transparency and revocability framing
  - "My responsibility" = human accountability framing

### Output locations

Write completed documents to:
- `_governance/foundation.md`
- `_governance/enforcement.md`
- `_governance/interpretation.md`
- `_governance/policy.md`
- `_governance/README.md` — brief index with one-line description of each doc and the date generated

Do not modify or overwrite anything in `_governance/templates/`.

### Business folder structure

For each company or client name collected (including their own business):

1. Create a folder at `businesses/<exact name as provided>/`
2. Inside it, create `memory.md` with this template:

```markdown
# <Company Name>

## About
_(Add notes about this company here — type of work, key contacts, context.)_

## Notes
```

If the companies list is empty, skip this step entirely — do not create the `businesses/` folder.

Do not rename, slugify, or alter the company names. Use them exactly as the user provided.

---

## Step 7 — Completion

Say:

> "Your governance is set up. These four documents define how AI works for you — what it can do, what it can't, and who stays in charge. You'll find them in the _governance/ folder anytime you need them. Welcome to Human Standard."

Then list the four governance documents with a one-line description of each. If the `businesses/` folder was created, also list each company folder and note that their `memory.md` is ready to fill in.
