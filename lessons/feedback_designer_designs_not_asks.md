---
name: Designer presents the designed flow, not a Q&A list
description: Designer OWNS the flow. They design the user flow with their best judgment, then present THAT FLOW to the owner for reaction. Never present a list of open questions / "what do you think?" decisions for the owner to design themselves. Owner reacts to the design, doesn't author it.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for Designer.**

Designer's output to the owner is a **designed flow**, not a Q&A.

Designer reads why.md, reads the codebase (pre-launch mode applies), and DESIGNS the user flow — every entry point, every screen, every state, every transition. Decisions Designer makes themselves based on their judgment. The output is the flow as Designer thinks it should be.

Owner reads the designed flow and reacts: "approve" or "change X to Y." Owner never authors the design by answering 7 questions.

**OUT of Designer's output:**
- "What should the entry point be? My default is X."
- "Where should the form live? My default is sheet."
- "Should we have a my-vendors view? My default is no."
- Any structure that pushes the design decision to the owner.

**IN Designer's output:**
- "Entry point lives at the top of the dashboard. Button labelled X."
- "Form is a bottom sheet on mobile, modal on desktop. Three required fields..."
- "My-vendors is a top-level nav item at /my-vendors. Cards stacked vertically, status pill on each..."
- A presented design with rationale baked in where useful.

**Why this matters:** owner pushback (verbatim): "designer who owns the flow can't create a flow and have open issues to himself to present to me, I need to see the flow as he designed it."

If Designer is genuinely stuck on a decision that needs owner taste/strategic input (e.g., "do we want the brand to feel A or B?"), Designer surfaces that as ONE focused question — not a checklist of 7 design choices punted upstream.

**The "ONE focused question" exception is narrow.** It's for emotional / brand / strategic taste — NOT for UX-engineering choices Designer can solve themselves. UX-engineering = tabs vs scroll, modal vs full page, banner vs silent restore, inline error vs toast, sidebar vs bottom-tab. Those are Designer's job. If Designer frames a UX-engineering choice as a "genuine open issue for owner," they're punting. Owner has called this out (verbatim): "but why I'm deciding? how was that flipped on me?"

**Orchestrator catches the punt too.** When Designer's output contains "ONE genuine open issue for owner" or equivalent framing, orchestrator must inspect whether the issue is genuinely taste/strategic. If it's UX-engineering, send it back to Designer with "make the call, don't punt." Do NOT pass it through to owner verbatim. Both Designer's punt AND orchestrator's pass-through are failures of the same rule.

**How to apply:**
- Designer's first round-trip output = the flow.md draft (or a tight summary thereof). Not a Q&A.
- Owner reacts to specific design choices ("change Q5 to my-vendors view in nav").
- Designer iterates based on owner's reactions.
- Same pattern as PM's pre-launch mode rule — make the call, don't punt.

**For methodology files:** the Designer protocol needs an update — replace "ask flow checklist questions" with "use flow checklist as Designer's own discipline; output is a designed flow, not the question list." Apply on next methodology revision pass.
