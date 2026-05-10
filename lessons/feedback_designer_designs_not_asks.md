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

**How to apply:**
- Designer's first round-trip output = the flow.md draft (or a tight summary thereof). Not a Q&A.
- Owner reacts to specific design choices ("change Q5 to my-vendors view in nav").
- Designer iterates based on owner's reactions.
- Same pattern as PM's pre-launch mode rule — make the call, don't punt.

**For methodology files:** the Designer protocol needs an update — replace "ask flow checklist questions" with "use flow checklist as Designer's own discipline; output is a designed flow, not the question list." Apply on next methodology revision pass.
