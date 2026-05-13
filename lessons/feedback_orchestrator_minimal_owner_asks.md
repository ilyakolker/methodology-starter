---
name: Orchestrator minimizes owner asks — agents decide, owner reacts
description: Owner is getting hit with too many decisions during normal feature work. Orchestrator must default to letting agents make the call. Owner-surfaced questions are reserved for production gates and genuinely strategic taste, NOT UX-engineering, NOT scope-tightening, NOT meta-scoping of agent work. NEVER ask about firing Ralph — that's always owner's decision from a fresh session.
type: feedback
---
**HARD RULE for orchestrator.** When a decision arises, default order:

1. **Can the responsible agent decide?** Designer for UX-engineering, PM for scope/product, Tech Lead for architecture/mechanism, BE/FE for implementation details, Copywriter for copy. If yes — agent decides, doesn't punt. If they DO punt, orchestrator sends back with "make the call." (Already covered by `feedback_designer_designs_not_asks.md`, applies to PM/Tech Lead/etc. equally.)

2. **Is it a production gate?** Push, remote database migration, remote secret, deploy. Per `feedback_production_gates.md` — yes, ask owner. These are non-negotiable.

3. **Is it genuinely strategic taste?** Brand direction, product scope tradeoff (e.g. "include feature X in v1?"), risk tradeoff with real consequences. Yes, ask owner — but frame as ONE focused question, not 3 bundled.

4. **Otherwise: orchestrator routes, doesn't ask.** Bundle 3 small ops into one tight dispatch. Pick the recommended option silently. Report state when done, not before.

**The questions owner pushed back on (2026-05-11):**
- "Draft scope: response only / both / +decline" — should've been Designer/PM
- "Tech Lead scope: full or tight pass?" — should've been Tech Lead's own call
- Three unrelated small tasks as 3 separate questions — should've been one or zero
- "Ready to fire Ralph?" — NEVER ask, see below

**Ralph rule — restated as a separate hard line.** Owner fires Ralph. Always. From a fresh session per `feedback_methodology_long_term_vision.md`. Orchestrator NEVER asks "should we fire Ralph?", NEVER offers "should I fire Ralph?", NEVER includes Ralph-firing as an option in `AskUserQuestion`. The only acceptable orchestrator-side action regarding Ralph is: "scope is locked. Files X, Y, Z updated. Fire Ralph when ready."

**Why this matters:** owner's verbatim pushback: "I'm starting to get confused here. why do I need to answer so many questions? and I'm the only one fires ralph!"

**How to apply:**
- Before any `AskUserQuestion` call, check: agent could decide → reject. Bundled into 3+ questions → collapse or eliminate. About Ralph → never. About work-scoping of agent's own task → reject.
- When agents return with "open issue for owner," inspect whether it's UX-engineering or strategic taste. UX-engineering = send back. Strategic = surface as ONE focused question.
- Default report shape between phases: 3-5 line state update + "next: <single autonomous action>" or "next: <single owner gate>." Don't pad with optionals.
