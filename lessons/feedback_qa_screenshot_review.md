---
name: QA screenshot review must be section-by-section
description: HARD RULE for QA browser pass. QA must walk every screenshot section-by-section, describe what's actually rendered in each region, compare to wireframe + spec, count elements where multiplicity matters, and flag elements present at viewports where spec says they shouldn't be. "Expected element is present" is NOT enough.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for QA browser/screenshot pass.**

When QA reviews screenshots, the bar is "could a careful human spot a regression?" not "is the expected element present?"

**Required workflow per screenshot:**
1. **Section-by-section walkthrough.** Describe what is rendered in EACH region (header, hero, each content block, footer). Anchor in spec terms.
2. **Element-count verification.** For elements where multiplicity matters (CTAs, headings, repeated cards), state the exact count seen and compare against spec.
3. **Negative checks.** For every viewport, list the elements that should NOT be present (e.g., desktop-only row at mobile, mobile-only wrapper at desktop) and confirm absence in the screenshot.
4. **Cross-screenshot consistency.** When two viewports share an element, confirm it's identical (or differs as the spec intends).
5. **Spec deviation log.** ANY visual that doesn't match the spec — even if "looks fine" — gets flagged. The spec is the source of truth.

**Why:** A real bug shipped where the desktop screenshot showed three CTAs in the hero (a mobile-only wrapper leaked through, identical specificity bug to one fixed minutes earlier). QA's review confirmed "two CTAs side-by-side present" but didn't notice the third because it wasn't on the brief's checklist. Owner caught it. The miss cost a full re-cycle.

**How to apply:** Whenever an agent reviews UI screenshots, the prompt MUST include section-by-section walkthrough + negative checks. Generic "verify against spec" is too loose. The QA agent definition at `.claude/agents/qa-engineer.md` should be updated to encode this as a permanent rule.

**Sister rule:** When fixing one specificity collision in scoped CSS vs. Tailwind utilities, ALWAYS sweep the rest of the file for the same pattern. One collision is rarely alone.
