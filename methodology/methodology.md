# Methodology — How We Build Features

**Status:** DRAFT v1. Living doc — expect edits as we run features through the pipeline and learn what's wrong with it.

---

## What this is

This is how we take an idea from "owner has a thought in chat" to "shipped on Vercel" without losing the why, breaking the codebase, or shipping something nobody asked for. The methodology is project-agnostic — it's a way of working, not a wedding-app thing — but was first instantiated for a wedding-vendor matching platform. The same files, roles, and protocols would work for the next project unchanged.

The core idea: every feature passes through a small number of named phases, each owned by exactly one role, each producing exactly one artifact. The next phase can't start until the previous artifact is signed off. Build agents only run after Tech Lead approves the plan. Owner only gates the final commit + push.

---

## The flow

```
owner brain (chat)
    ↓
PM: WHY phase  →  why.md
    ↓
Designer: FLOW phase  →  flow.md
    ↓
PM + Designer + Copywriter: SPEC phase  →  spec.md  (copy locked here)
    ↓
PM: PRD authoring  →  prd.json (per-feature)
    ↓
Tech Lead: review  →  prd-review.md
    ↓
Ralph loop: build agent works, runs end-to-end steps verification, flips passes:true
    ↓ exits when all passes:true OR max-iterations
Owner reads max-iterations report (if hit) — decides: rerun, revise prd.json, manual fix
    ↓
Owner commit gate  →  push  →  Vercel deploy
```

Each arrow is a real handoff with a real artifact behind it. No phase skipping. No "I'll just code it real quick."

---

## Task granularity — UI and functional are separate

Every entry in `prd.json` carries a `category`. The category is now load-bearing — it dictates what the verification steps look like and what kind of failure they catch. There is no "mixed" task. A `category: "functional"` task verifies state changes (DB queries, API responses, edge function triggers, DOM presence assertions, integration checks) — its steps never include a screenshot. A `category: "ui"` task verifies pixels (Playwright screenshots + agent visual review with specific assertions, including negative checks like "ONE CTA visible — no duplicate") — its steps never include DB writes or API verification.

A single user behavior decomposes into ONE functional task (the spine — what changes in state) and N UI tasks (one per screen state or viewport that needs visual verification). UI tasks `depends_on` their functional counterpart. If a behavior touches one screen at one viewport, that's 1 functional + 1 UI = 2 entries. If it touches a form on mobile + desktop and a success screen and an updated stat counter, that's 1 functional + 4 UI = 5 entries.

**Example — customer places an order:**

- `order-checkout-functional` — `category: "functional"`. Steps: POST to checkout endpoint, insert into `orders`, fire receipt notification, assert row inserted and status is `confirmed`.
- `order-checkout-form-mobile-ui` — `category: "ui"`, `depends_on: ["order-checkout-functional"]`. Steps: navigate Playwright to `/checkout` at 375px, screenshot, assert form fields visible, submit, screenshot success state.
- `order-checkout-form-desktop-ui` — `category: "ui"`, `depends_on: ["order-checkout-functional"]`. Steps: same page at 1280px, screenshot, assert two-column layout, assert ONE submit button visible (no duplicate CTA).
- `order-success-confirmation-ui` — `category: "ui"`, `depends_on: ["order-checkout-functional"]`. Steps: trigger success state, screenshot, assert confirmation copy, assert order number and totals visible, assert no form fields visible.
- `order-history-recent-orders-ui` — `category: "ui"`, `depends_on: ["order-checkout-functional"]`. Steps: load account page after order placed, screenshot, assert new order row visible, assert status badge correct.

Five entries, one chain of `depends_on` from each UI task back to the single functional task. Mixed tasks get rejected at Tech Lead review and split.

---

## What "passes:true" means

`passes: true` means the build agent walked the task's `steps` end-to-end against real systems and every step passed — functional checks for functional tasks, screenshot + visual assertions for UI tasks. It is the only verification gate in the methodology. There is no second QA pass after Ralph. The build agent's per-task self-verification at flip-time IS the QA. A separate post-Ralph smoke pass would contradict `passes: true` — if the gate is real, no second gate is needed; if a second gate is needed, the first one was a lie.

Max-iterations is the safety net for runaway loops, not a quality gate. If Ralph exits on max-iterations instead of all-green, owner reads the report and decides: rerun, revise `prd.json`, or fix manually.

---

## The roles

**PM** owns *what* and *why*. Writes `why.md` (persona, pain, outcome, success metric). Co-authors `spec.md`. Authors `prd.json` — the mechanical task list Tech Lead reviews. PM does not design and does not code. PM is the gatekeeper for scope creep.

**Designer** owns *flow* and *visual*. Writes `flow.md` — every screen, every state, every transition, every empty/error/loading edge case. Co-authors `spec.md` for the visual side (layout, components, design tokens). Designer does not write copy and does not write code.

**Copywriter** owns *every visible string*. Reviews and locks all Hebrew copy in `spec.md`. After SPEC, copy is frozen — engineers paste it as-is. Copywriter does not design and does not author features.

**Tech Lead** owns *how* and *whether-it's-safe*. Read-only on the codebase during review. Reads `why.md` + `spec.md` + `prd.json`, runs 8 checks per task, and emits `prd-review.md` with APPROVE / REVISE / REJECT verdicts. Tech Lead does not redesign features and does not write code.

**Build agents (FE / BE)** own *code*. Strict separation: FE only writes `src/`, BE only writes `supabase/`. They consume `prd.json` tasks one at a time, implement, and self-verify against the task's `steps`. They don't decide scope, copy, or visuals — those are already locked.

**QA** owns *did-it-actually-work*. Runs a browser smoke pass against the feature's acceptance criteria after build agents finish. Reports bugs back to FE / BE directly (PM doesn't proxy bugs).

**Owner** owns *go / no-go on production*. Only two gates in the entire pipeline: (1) approving anything that touches the remote Supabase project, (2) approving the final `git push`. Everything else runs autonomously.

---

## The artifacts

For every feature `<f>` (kebab-case, short), the pipeline produces these files in `docs/features/<f>/`:

| File | Owner | Purpose |
|---|---|---|
| `why.md` | PM | Persona, pain, outcome, success metric. The reason we're building this. |
| `flow.md` | Designer | Every screen, state, transition, edge case. The full UX map. |
| `spec.md` | PM + Designer + Copywriter | Goals + visual + every visible string. Copy locked here. |
| `prd.json` | PM (Tech Lead reviews) | Mechanical task list, Ralph-readable, machine-executable plan. |
| `prd-review.md` | Tech Lead | Per-task APPROVE / REVISE / REJECT verdicts plus required changes. |

Once `prd-review.md` is fully APPROVED, build starts.

---

## Triggers

The only way a new feature enters the pipeline is the owner saying, in chat:

```
feature-plan: <name> — <one-sentence idea>
```

That fires PM. PM reads the idea, asks the owner clarifying questions if needed, and either: (a) writes `why.md` and pushes to Designer, (b) declares the feature too big and asks the owner to decompose, or (c) declares the request a small fix and routes it directly to an engineer (see "Small fix bypass" below).

Each downstream phase is triggered by the previous role finishing their artifact and pinging the next role with a one-line message: "ready for Designer on `<f>`", "ready for Tech Lead review of feature `<f>`", and so on.

---

## The locked decisions

These were settled today (2026-05-07) and the protocol files reflect them:

1. **One feature folder, all artifacts inside it.** `docs/features/<f>/why.md`, `flow.md`, `spec.md`, `prd.json`, `prd-review.md` — together, never scattered.
2. **Copy is locked in SPEC.** After spec.md is signed, no role rewrites Hebrew strings during build. Copy bugs go through Copywriter, not engineers.
3. **Tech Lead is read-only.** No code, no patches, no edits outside `prd-review.md`. Notes only.
4. **Tech Lead decides architectural patterns.** Owner is not pulled in per pattern. Tech Lead writes a 2-3 line rationale; owner only weighs in if Tech Lead asks.
5. **Schema changes are judged per task, not blanket-passed-through.** Reversible additions pass through with an owner-approval reminder; destructive changes block APPROVE until justified.
6. **PRD reviews are append-only.** Each round adds a new section to `prd-review.md` — history is never overwritten.

Bonus calls from the same session:

- **Build is autonomous.** Owner does not gate per-task. Owner gates only remote-DB writes and final push.
- **Bugs go to engineers, not PM.** PM is for feature scoping. FE / BE handle their own debugging.
- **FE never touches design.** During bug fixes, FE doesn't change colors, spacing, or typography. Visual changes route through Designer.
- **Methodology is project-agnostic.** Same files, same roles work for the next project. Wedding-app is the first instantiation.

---

## Small fix bypass

If the owner's request is a typo, a copy adjustment, a single-line bug fix, or anything that doesn't touch flow, UX, architecture, or data shape — PM redirects: skip the methodology, go straight to FE or BE. Examples: a button label is wrong, a date format is off, a console error needs silencing. Owner can override either way ("actually run the full pipeline" or "actually let's just patch it"). The bypass exists so we don't burn a why.md / flow.md / spec.md cycle on a 3-line fix.

---

## Big feature decomposition

If during PROPOSAL or Q&A it becomes clear a feature is too big to fit one why.md / flow.md / spec.md without becoming a novel, PM declares decomposition: emits sub-feature names back to the owner, and each sub-feature gets its own `feature-plan: <subname>` intake from the owner. Decomposition lives at PM level — Designer and Tech Lead never receive a 50-screen flow.md. If it's that big, it should have been multiple features.

---

## Where Ralph fits

After Tech Lead approves `prd.json`, the build is run by `scripts/ralph.sh` — a loop runner not yet built but designed for: pick the highest-priority `passes: false` task, fire the right build agent (FE or BE based on `category`), the agent implements and self-verifies against the task's `steps`, the agent flips `passes: true`, exits, and the loop picks the next task. The loop stops when every task is green, when it hits a max-iterations safety cap, or when the same task fails twice in a row (stuck — escalate to owner). Owner gates push at the end. Ralph is downstream tooling — the methodology works without it; ralph.sh just automates the worker dispatch step.

Each Ralph iteration consumes the task's pre-baked context bundle (see `methodology/per-task-context-bundles.md`) instead of re-reading the full feature corpus. Tech Lead generates the bundles as Step 7 of the PRD review, so by the time Ralph runs, each task has its own self-sufficient context file referenced via `context_path` in `prd.json`. Features authored before the bundle protocol existed fall back automatically to the legacy mandatory-reading list — no flag day.

---

## Linked protocol files

For the deep dive, each role has its own protocol file. Read these only when you're stepping into that role:

- [`docs/methodology/pm-protocol.md`](./methodology/pm-protocol.md)
- [`docs/methodology/designer-protocol.md`](./methodology/designer-protocol.md)
- [`docs/methodology/designer-flow-checklist.md`](./methodology/designer-flow-checklist.md)
- [`docs/methodology/tech-lead-protocol.md`](./methodology/tech-lead-protocol.md)
- [`docs/methodology/copywriter-protocol.md`](./methodology/copywriter-protocol.md)
- [`docs/methodology/feature-proposal-template.md`](./methodology/feature-proposal-template.md)
- [`docs/methodology/per-task-context-bundles.md`](./methodology/per-task-context-bundles.md) — bundle spec for Ralph cost reduction

---

## Status

DRAFT v1. Living doc.

Open questions still unresolved — to be answered as the first real feature runs through the pipeline:

- **Proposal template cadence.** Is `feature-proposal-template.md` filled by owner before `feature-plan:`, or by PM during intake from a raw chat sentence? Today's default: PM fills it.
- **Ralph stuck-handling.** Two failures in a row escalate to owner — but in what format? Slack-style summary? Open prd-review.md? TBD on first stuck task.
- **Cross-feature dependencies.** If feature B depends on feature A's schema, who owns the wait? PM at intake, or Tech Lead at review? Today: PM declines feature B until A is shipped.
- **Spec-to-code drift.** If during build an engineer finds spec.md is impossible to implement as-written, the protocol says route back to PM. Untested in practice yet.
