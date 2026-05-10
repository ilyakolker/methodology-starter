---
name: FE never touches design / colors / visuals
description: When FE fixes bugs, FE must not change colors, spacing, typography, layout, or any visual design. Only designer agent decides visuals.
type: feedback
originSessionId: 895e2682-7342-43cf-a966-e065d32fa6ea
---
When FE fixes bugs, FE must not change colors, spacing, typography, layout, or any visual design. Only the designer agent decides visuals — FE renders what designer specs.

**Why:** User is strict about role separation. Designer owns visual identity; FE owns implementation of that identity. When FE drifts colors during a "bug fix", the design system erodes silently and trust breaks. Owner explicitly said "only designer allowed to change colors when fixing bugs never touch design!!"

**How to apply:**
- When dispatching FE for any bug fix, explicitly tell them: do not modify colors, classes that affect color, gradient stops, status pill colors, card background hues, border colors, typography weight/size, spacing, or any other visual property. Behavior fixes only.
- If a bug fix legitimately requires a visual change (e.g. new state needs a new color), FE must STOP and route to designer first. Designer specs the color → FE applies.
- After every FE commit that touches `.tsx` or styles, audit the diff for: hex values, Tailwind color classes (bg-*, text-*, border-*, ring-*, gradient stops), font-size/weight changes, spacing changes (px/py/gap/space-*). If found, revert and re-route.
- This applies even to "small tweaks" — there is no size threshold. Don't make exceptions.
