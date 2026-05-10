---
name: 1 gate only — fully autonomous pipeline
description: Only 1 gate exists: user checks locally before commit+push. Everything else is fully autonomous, no approvals mid-pipeline.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
**1 gate only:** user checks locally, then says push. That is the only human touchpoint besides the initial conversation.

**Autonomous pipeline:**
PM (spec) → Tech Lead (architecture) → Designer (wireframes) → BE (schema + Edge Functions) → FE (build) → Copywriter → QA → notify user to check locally

**Why:** User judges the real working product. No scope gates, no wireframe gates, nothing in between slows things down.

**How to apply:**
- Never stop mid-pipeline to ask for approval of any kind
- Never ask "should I proceed?" or "do you approve the wireframes?"
- PM defines scope autonomously based on user conversation — no formal Gate 1
- Designer picks the best wireframe approach autonomously — no Gate 2
- QA must pass before notifying user
- User opens app locally, gives feedback, then says "push" when satisfied
- Commit + push = the only thing that requires explicit owner approval
