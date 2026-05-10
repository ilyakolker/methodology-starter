---
name: PM reviews all issues — orchestrator does not dispatch fixes directly
description: When user reports UI/UX issues (screenshots or descriptions), always route through PM first. Never spawn fe-engineer or be-engineer directly.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
When the user shows issues (screenshots, bug reports, UX complaints), the orchestrator must spawn the **pm** agent to review them first — not dispatch a fix agent directly.

**Why:** Routing through PM lets the user set new features and move fast. PM can triage, prioritize, and bundle issues with new feature work into sprint scope. Direct orchestrator-to-fix-agent bypasses this and slows the user down.

**How to apply:** User reports issue → spawn pm → PM defines scope/priority → pipeline runs (Designer if needed → BE/FE → QA). Never skip the PM step for issues, no matter how small the fix looks.
