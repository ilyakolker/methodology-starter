---
name: flow.md must include a RENDERED diagram (PNG/SVG), not raw Mermaid source
description: Mermaid source `flowchart TD\n A --> B` is unreadable to the owner unless their viewer renders it inline. flow.md must embed a rendered PNG/SVG of the flowchart. Mermaid source can stay below as an editable representation but the rendered image is the primary artifact.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for flow.md.**

Owner views markdown in viewers that may or may not render Mermaid inline. flow.md must include a **rendered image** (PNG or SVG) of the flowchart. Raw Mermaid source alone is unreadable — looks like `A --> B[do thing]\nB -- yes --> C` to the owner.

**Required structure for flow.md:**
1. Heading + one-line summary.
2. **Rendered diagram image** — PNG/SVG embedded with `![flow](./flow.png)`. Image lives at `docs/features/<f>/flow.png` (or .svg). Owner sees this immediately when opening the file.
3. Mermaid source as a fenced code block BELOW the image, for future edits. Marked as "source" or "editable representation."
4. Short supporting notes (mobile/desktop deltas, accessibility, RTL, visual markers, failure modes the diagram skips).

**How to render:**
- `npx -y @mermaid-js/mermaid-cli -i input.mmd -o output.png` — works without installing anything globally.
- Designer should write the Mermaid source to a temp `.mmd` file, run mmdc, then move the resulting PNG to `docs/features/<f>/flow.png`.
- Verify the PNG actually renders cleanly (Designer can `Read` the PNG to inspect after rendering).

**Visual style targets (owner's example):**
- Color-coded nodes: green for start, red/orange for terminal/error, distinct colors for decision diamonds vs action boxes.
- Decision diamonds with `yes` / `no` labels on the edges.
- Top-to-bottom linear flow (`flowchart TD`).
- ~10-20 nodes max. Trim aggressively. If a flow needs more, split into a primary diagram + a side diagram for the secondary path (not all branches in one).

**Why:** owner pushback (verbatim): "see example diagram whatever the fuck you created is not humanly readble." The Mermaid source was written but never rendered. The user opens flow.md and sees code, not a diagram.

**How to apply:**
- Every flow.md ships with a `flow.png` (or `.svg`) embedded at the top. No exceptions.
- Methodology files need this rule baked in on next revision pass.
