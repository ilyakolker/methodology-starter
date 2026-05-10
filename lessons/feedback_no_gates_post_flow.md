---
name: No owner gates between FLOW approval and PRD-review approval
description: Once flow.md is approved, the SPEC → PRD → Tech-Lead-review chain runs autonomously. Owner only re-engages after Tech Lead approves prd.json (or at the final build commit gate). Copywriter co-authors spec.md in the SAME PHASE as PM and Designer — not as a refinement pass after owner approves spec.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for the methodology pipeline.**

Owner gates exist at exactly these points (and nowhere else between):
1. **After why.md** — owner approves WHY before Designer engages.
2. **After flow.md** — owner approves FLOW before SPEC chain fires.
3. **After Tech Lead approves prd.json (`prd-review.md`)** — owner reviews the full stack before build starts.
4. **After build completes** — final commit/push gate.

Between (2) and (3), the chain runs **without owner gates**:
- Copywriter co-authors spec.md in the SAME phase as PM and Designer (concurrent or sequential, no owner approval between)
- PM decomposes spec.md into prd.json
- Tech Lead reviews prd.json
- All without owner intervention

Owner only sees the chain output at step (3) — the full stack: spec.md + prd.json + prd-review.md.

**Why:** owner pushback (verbatim): "no no no, this should not stop! we lost so many hours. from here we are producing the pr so to copy was required to do his during the spec this is not a gate!"

The previous flow had owner approve spec.md → Copywriter refine → PM decompose → Tech Lead review. That's three unnecessary gate-or-wait points where the owner was forced to micro-manage.

**The corrected mental model:**
- Owner sets DIRECTION at gates (1, 2, 3).
- Agents EXECUTE between gates.
- Copywriter is part of spec authoring, not a separate refinement phase.

**How to apply:**
- After flow.md approval, orchestrator immediately fires the chain: spec authoring (PM + Designer + Copywriter co-author) → PM decomposes → Tech Lead reviews.
- Orchestrator does NOT check in with owner between these steps unless an agent explicitly hits a blocker that needs owner judgment (rare).
- If an agent has a small open question, they make the call themselves and note it; if owner wants to override later, they do it during gate (3).
- Methodology files need updating to remove the implicit "approve spec.md, then refine" step. spec.md is co-authored once, period.
