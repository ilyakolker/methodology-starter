---
name: PM does not invent file paths — files are engineer territory
description: PM authors prd.json describing user-visible behavior. PM does NOT populate `files_touched` with invented or guessed paths. New files for the app are decided by engineers (FE/BE) during build, or by Tech Lead during cascade-impact analysis. PM saying "files X, Y, Z will change" is hallucination contamination of prd.json.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for PM authoring prd.json.**

PM owns: WHAT the user does, WHY, acceptance criteria, behavior steps.
PM does NOT own: which files in `src/` or `supabase/` exist or get created.

**The failure (verbatim from owner):** "add a rule to no invent anything by the pm new files creating for the app needs to be created by the engineers. pm can say what needed but the files are not the pms area"

**Why this matters:** PM in a feature's prd.json wrote `src/integrations/<thirdparty>/types.ts` — a file that doesn't exist (actual path is whatever the codebase chose; PM didn't grep first). Owner caught it. The fabrication pollutes the build plan; an engineer following the prd.json blindly would either create a file that shouldn't exist OR get confused.

**The rule:**

1. **PM omits `files_touched` from prd.json entries** OR leaves it as an empty array `[]`.
2. **Tech Lead populates `files_touched`** during their Check 5 (cascade impact) review. Tech Lead reads the codebase and knows what's actually there.
3. **Engineers (FE/BE)** during build can ADD new files needed for implementation — those are documented in commit messages and APP_MAP.md, not in prd.json upfront.
4. **PM may describe what's needed in user terms** ("a new section on the dashboard," "an API to save the vendor") without naming files. The HOW is the engineer's call.

**How to apply:**
- When briefing PM for prd.json authoring: explicitly state "do NOT populate `files_touched` — leave empty. Tech Lead's review will fill these in based on codebase inspection."
- Methodology files (`pm-protocol.md`, `tech-lead-protocol.md`) need updating on next revision: PM's Step 7 should NOT instruct PM to fill files_touched; Tech Lead's Check 5 should explicitly fill it.
- When PM ALREADY populated files_touched and Tech Lead is reviewing: Tech Lead replaces PM's list with the verified list. PM's invented paths get rejected as part of Check 5.
