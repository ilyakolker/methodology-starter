---
name: Bug routing goes to engineers, not PM
description: When a bug is reported, spawn FE or BE engineer directly — not PM. PM is for scoping new features, not debugging.
type: feedback
originSessionId: 895e2682-7342-43cf-a966-e065d32fa6ea
---
Bugs go straight to the engineer responsible for that area (FE or BE). Do NOT route bugs through PM first.

**Why:** PM is a product/scope tool, not a debugger. Routing a "vendors not loading" bug to PM wastes a step and frustrates the user.

**How to apply:** User reports bug → identify whether it's FE or BE → spawn that engineer to investigate and fix. Only involve PM if the bug reveals a product decision (e.g., "should this behavior exist at all?").
