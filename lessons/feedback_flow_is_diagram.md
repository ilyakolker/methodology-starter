---
name: flow.md is a diagram-first artifact, not a prose document
description: Owner wants flow.md to be a decision/flow DIAGRAM (mermaid or ASCII flowchart) + minimal supporting notes. NOT a 10-section prose document covering every state and edge case in paragraphs. The diagram IS the flow; notes are short callouts only.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for Designer flow.md output.**

`flow.md` is a **decision flow diagram** with minimal supporting notes. Owner reads diagrams fast. Owner does NOT want a 10-section prose document.

**Primary artifact: a flowchart**
- Mermaid `flowchart TD` (preferred — renders in most viewers) or ASCII flowchart.
- Shows: entry point → user actions → decision branches → states → exits.
- Decision diamonds for every yes/no branch (validation, dedup, verified, quote received, etc.).
- Compact — entire flow visible without scrolling deeply.

**Supporting notes (short bulleted lists, NOT prose):**
- Cross-device deltas (mobile vs desktop) — 1-3 lines.
- Accessibility callouts — focus order, ARIA, RTL — 1-3 lines.
- Visual markers — labels, badges, dir="ltr" zones — 1-3 lines.
- Failure modes the diagram can't show — short list.

**OUT of flow.md:**
- Multi-paragraph descriptions of every screen.
- Re-explanations of why decisions were made (that's why.md).
- Implementation hints (that's prd.json + Tech Lead).
- Long lists of edge cases enumerated in prose.

**Why:** owner pushback (verbatim): "flow need to be decision flow diagram as well not huge file I need to read." Owner reads at scan-speed. A flowchart conveys 80% of a flow in 5% of the words.

**How to apply:**
- First thing in flow.md after the heading: the flowchart.
- Notes section is short — owner should scroll past it in seconds, not minutes.
- If a category from `designer-flow-checklist.md` doesn't have a meaningful answer, omit — don't pad.
- Designer protocol needs an update on next methodology revision pass to make this canonical.
