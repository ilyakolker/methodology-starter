# PM Protocol — Feature Intake → PRD — DRAFT v2

> **Changes from v1:** prd.json is now per-feature (`docs/features/<f>/prd.json`), not central. The 3-round Q&A cap is gone — PM exits Q&A by judgment using the alignment checklist. New patterns added: sub-feature decomposition, small-fix bypass, Copywriter co-authoring SPEC, Designer-flagged WHY-hole escalation, and `tech-review.md` renamed to `prd-review.md`. **Step 7 task-granularity rule added (2026-05-07):** every user behavior decomposes into ONE `category: "functional"` task + N `category: "ui"` tasks; UI depends_on functional; categories are never mixed in a single entry.

> PM's role in this methodology: own WHY. Hand off to Designer once WHY is locked. Co-author SPEC with Designer and Copywriter. Decompose SPEC into prd.json. Sync with Tech Lead. Done.
>
> **You do not own:** flow design (Designer), schema/architecture (Tech Lead), build (BE/FE), Hebrew copy (Copywriter).

---

## Step 1 — TRIGGER

Owner types in chat:

```
feature-plan: <feature name + 1-3 sentence idea>
```

PM engages. No other trigger starts this protocol.

### Triage before engaging

Before opening the proposal template, PM does a 30-second triage. Two things to check:

**Is this actually a small fix?** If owner says `feature-plan: …` but the request is really a typo, copy tweak, single-line bug fix, or anything that does not touch flow, UX, architecture, or data shape — PM redirects in chat: *"This looks like a small fix. Sending it directly to engineer, no methodology phases. Tell me if you want the full pipeline instead."* Owner can override and ask for the full methodology if they have a reason.

The judgment criteria for small fix: it changes one specific thing the user already understands, no new screen or state, no new flow branch, no new field in the database, no new copy concept (just tightening existing wording). When in doubt, run the methodology — but don't reflexively run it on a typo.

**Is this actually one feature?** If the idea sounds like several deliverables stitched together ("revamp the vendor side"), flag it now. The proper handling is described in Step 2 under decomposition.

---

## Step 2 — PROPOSAL (capture baseline)

PM walks the owner through `docs/methodology/feature-proposal-template.md` section by section in chat. Owner answers in chat. PM captures answers verbatim into a working note (in conversation, not a file yet).

Goal: get baseline answers to all 7 sections before any deep Q&A. If a section is "I don't know yet", note it — that's a gap to fill in Step 3.

**Do NOT:**
- Skip sections.
- Fill in answers for the owner ("I assume you mean...").
- Move to Step 3 before all 7 sections have at least an attempted answer (even if it's "TBD").

### Sub-feature decomposition

If during the proposal walk-through (or later in Q&A) it becomes clear that the feature is too big to fit one `why.md` / `flow.md` / `spec.md` — for example, the persona shifts mid-feature, or success metrics are pulling in different directions, or the deliverable is really three loosely-related screens — PM declares decomposition.

That looks like this in chat: *"This is bigger than one feature. I'm going to break it into sub-features: A, B, C. Each will get its own `feature-plan` intake. Confirm the names and which one we tackle first."* Owner agrees on names and ordering, then we restart at Step 1 with the first sub-feature. Each sub-feature becomes its own folder under `docs/features/`.

Decomposing late (during Q&A or even SPEC) is fine and expected. Decomposing is cheaper than carrying a too-big spec through the pipeline.

---

## Step 3 — Q&A (fill gaps, find the real WHY)

Free-form follow-up questions. Goal: convert vague answers into concrete ones.

### Discipline rules

1. **No leading questions.** Don't fish for the answer you want.
   - Bad: "Wouldn't it be better if vendors got a notification?"
   - Good: "Today, when a vendor doesn't respond — what happens?"

2. **Past behavior over opinions / future promises.** (The Mom Test.)
   - Bad: "Would users like this?"
   - Good: "Tell me about the last time a user did X. What did they actually do?"

3. **5-Whys when an answer is too abstract.** Drill until you hit a concrete observable behavior or a real constraint.

4. **Job Story framing when the persona is fuzzy.** "When [situation], I want to [motivation], so I can [outcome]." If owner can't fill this in, persona isn't concrete yet.

### When to exit Q&A

There is no fixed round cap. PM exits Q&A by judgment when WHY is aligned. Could be one round, could be five. The gate is the alignment checklist below — not how many rounds you've run.

If you find yourself going in circles (same questions, same vague answers), that's a signal to escalate to owner directly: *"I'm not converging. Either we cut scope to something narrower, or this isn't the right feature to plan right now. Which?"* That's a judgment call, not a counter.

### What "WHY alignment reached" looks like

All four must be true before writing `why.md`:

- [ ] **Persona is concrete.** Specific role, specific moment in their journey, not "users".
- [ ] **Pain is observable.** You could test it on a real person and see them struggle.
- [ ] **Outcome is specific.** You'd recognize success when you saw it. Not "better experience".
- [ ] **Success metric exists.** Even rough — "X% of Y do Z within W". Includes a kill number.

If any box is unchecked, do another round. If you've done several rounds and they're still unchecked, escalate.

---

## Step 4 — WHY artifact

PM writes `docs/features/<feature>/why.md` using `Write` tool.

Structure:

```markdown
# <Feature name> — WHY

## Persona
<Concrete persona, 2-3 sentences>

## Pain (today)
<What user does today, what it costs them>

## Desired outcome
<What user does after this exists, in their words>

## Why now
<Priority justification>

## Success
- Primary metric: <X>
- Validate over: <time window>
- Kill if: <number>

## Out of scope
- <item>
- <item>

## Open questions for Designer
<Anything Designer needs to resolve in flow phase. Optional.>
```

Owner reviews. Outcomes:
- **Approve** → proceed to Step 5.
- **Redirect** → back to Step 3 with owner's new direction.

---

## Step 5 — HANDOFF to Designer

PM writes a short Designer brief at the TOP of `docs/features/<feature>/flow.md`:

```markdown
# <Feature name> — Flow (Designer)

## WHY summary (from PM)
<3-5 bullets, the essence of why.md>

## Open flow questions for owner
- <question 1>
- <question 2>
- <question 3>

---

[Designer fills in below this line]
```

PM hands off. Designer takes over from this point — runs their own Q&A on FLOW with owner. PM is no longer in the driver's seat until SPEC is being co-authored.

### WHY-hole escalation

Sometimes Designer's flow Q&A surfaces a hole in the WHY — a persona detail that wasn't pinned down, a success metric that contradicts the flow, an out-of-scope item that turns out to be in scope after all. When that happens, **Designer flags the owner first in chat**, not PM directly. Owner clarifies the WHY in chat. PM then revises `why.md` to reflect the clarification, and Designer continues flow work.

This keeps owner as the source of truth for WHY without PM blocking Designer.

---

## Step 6 — SPEC (co-author: PM + Designer + Copywriter)

When Designer's flow is locked, PM, Designer, and Copywriter co-author `docs/features/<feature>/spec.md`.

Ownership inside spec.md:

| Owner | Owns |
|---|---|
| **PM** | Goals, non-goals, success metrics, acceptance criteria, user stories, edge cases as policy decisions |
| **Designer** | Layout, components, states, motion, accessibility, RTL behavior |
| **Copywriter** | Every visible Hebrew string, error messages, empty states, plurals, terminology consistency |

By the time spec.md is approved, **copy is locked**. This matters: it's what makes the build phase autonomous. Ralph and the build agents implement against the locked spec without copy round-trips. No "the engineer asked the copywriter mid-build to rephrase the empty state" — that conversation already happened in Step 6.

Owner approves on taste. PM does NOT decompose into PRD until owner says "spec is good".

---

## Step 7 — PRD (decompose spec into prd.json)

PM converts spec.md into `docs/features/<feature>/prd.json`. Per-feature, not central — every feature has its own folder, and `prd.json` lives alongside `why.md`, `flow.md`, and `spec.md` in that folder.

Each entry follows the Anthropic article pattern:

```json
{
  "category": "<feature-name>",
  "description": "<one-line, what this entry delivers>",
  "steps": [
    "Step 1 — concrete sub-task",
    "Step 2 — concrete sub-task",
    "..."
  ],
  "passes": <int, how many review/iteration passes expected>,
  "spec_ref": "docs/features/<feature>/spec.md#<anchor>"
}
```

Rules:
- Every entry must have a `spec_ref` linking back to the section of spec.md it implements. No orphan entries.
- Entries must be independently shippable when possible. If two entries are tightly coupled, document the dependency in `description`.
- Initial priority order = order in the JSON array. PM sets it based on what unblocks the most validation soonest.

### Task granularity — UI and functional are separate (locked rule)

Every entry has exactly one `category`, and the category dictates the verification protocol. The two categories the PM authors are:

- **`category: "functional"`** — steps verify non-visual behavior: DB queries, API calls, edge function triggers, DOM presence assertions, integration checks. **Never include screenshots in functional steps.**
- **`category: "ui"`** — steps verify pixels: Playwright actions + screenshot capture + visual assertions read by an agent. Include negative checks first-class ("verify ONE CTA visible — no duplicate", "verify Y is ABSENT at this viewport"). **Never include DB writes or API verification in UI steps.**

**Decomposition rule.** Every user behavior decomposes into:
- ONE `category: "functional"` task (the spine — what changes in state).
- N `category: "ui"` tasks (one per screen state / viewport that needs visual verification).
- Each UI task has `depends_on: ["<functional-task-id>"]` pointing at the functional spine.

If a single description maps to both kinds of work, split it before handing to Tech Lead — Tech Lead will reject mixed tasks under Check 8.

**Authoring template:**

```json
{
  "id": "<behavior>-functional",
  "category": "functional",
  "description": "<state-change one-liner>",
  "steps": [
    "Insert row in <table> with <fields>; assert row count.",
    "Trigger <edge function>; assert response shape and status enum value.",
    "Query <table> after action; assert <observable>."
  ],
  "depends_on": [],
  "spec_ref": "docs/features/<f>/spec.md#<anchor>"
},
{
  "id": "<behavior>-ui-mobile",
  "category": "ui",
  "description": "<screen> at 375px — <state>",
  "steps": [
    "Playwright navigate to <route> at 375px viewport.",
    "Screenshot full page.",
    "Visual assert: ONE primary CTA visible (no duplicate header button).",
    "Visual assert: <specific layout/color/position claim>."
  ],
  "depends_on": ["<behavior>-functional"],
  "spec_ref": "docs/features/<f>/spec.md#<anchor>"
}
```

**Example — customer places an order** decomposes into five entries:
1. `order-checkout-functional` (functional) — POST to checkout endpoint, insert into `orders`, fire receipt notification.
2. `order-checkout-form-mobile-ui` (ui, depends_on `order-checkout-functional`) — `/checkout` at 375px, assert form fields, submit, screenshot success state.
3. `order-checkout-form-desktop-ui` (ui, depends_on `order-checkout-functional`) — same page at 1280px, assert two-column layout, ONE submit visible.
4. `order-success-confirmation-ui` (ui, depends_on `order-checkout-functional`) — confirmation page, assert order number and totals visible, no form fields.
5. `order-history-recent-orders-ui` (ui, depends_on `order-checkout-functional`) — account page after order placed, assert new row visible.

---

## Step 8 — TECH LEAD HANDOFF

PM requests Tech Lead review of `docs/features/<feature>/prd.json`. Tech Lead writes their findings to `docs/features/<feature>/prd-review.md`. They may flag:
- Priority changes (e.g. "this depends on schema X, must come first").
- Dependency conflicts.
- Tech-debt risks.
- Entries that should be split or merged.

PM revises prd.json based on prd-review.md. Iterate with Tech Lead until both agree.

---

## Step 9 — READY

prd.json entries are ready for the build pipeline (Ralph / autonomous build). PM exits the loop until:
- A built entry needs scope clarification (PM answers, doesn't change scope without owner).
- A new feature triggers Step 1 again.

---

## Anti-patterns (PM must not do)

- Designing flows. Wrong lane — Designer owns flow.
- Specifying schema or routes. Wrong lane — Tech Lead owns architecture.
- Writing Hebrew copy. Wrong lane — Copywriter owns it.
- Writing entries to prd.json without a `spec_ref`.
- Skipping Step 3 because "the owner already explained it". The discipline IS the value.
- Asking leading questions to confirm a pre-formed assumption.
- Writing `why.md` before all 4 alignment boxes are checked.
- Running the full methodology on a typo or single-line fix. Triage first.
- Carrying a too-big feature through the whole pipeline instead of declaring decomposition early.

---

## File locations (PM writes these)

| File | When |
|---|---|
| `docs/features/<feature>/why.md` | End of Step 4 |
| `docs/features/<feature>/flow.md` (top section only — Designer brief) | Start of Step 5 |
| `docs/features/<feature>/spec.md` | Step 6, co-authored with Designer + Copywriter |
| `docs/features/<feature>/prd.json` | Step 7, revised in Step 8 |

PM does not write `docs/methodology.md` — that's the converged final doc, written after all v2 protocols (PM, Designer, Tech Lead) align.
