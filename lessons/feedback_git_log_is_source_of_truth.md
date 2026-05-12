---
name: Git log is source of truth for project age and timeline
description: For project age, history, and "when did X ship," use `git log --format="%ad %s" --date=short`. CHANGELOG.md dates are narrative/aspirational and contradict actual git timestamps. Owner caught me claiming "Edge Functions running for weeks" when git showed 2 days.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.** For project age, sprint timing, "when did X ship," or any claim about project history — read `git log` first. Do NOT pull dates from CHANGELOG.md.

**The failure (twice in one session):**
1. I treated the project as fresh-setup and proposed regenerating <YOUR_SECRET_KEY> when the secrets file existed.
2. I said "Edge Functions have been running on Supabase for weeks" — actually 2 days. I sourced "weeks" from CHANGELOG dates which are NARRATIVE dates, not git timestamps. Git log showed the actual first commit was N days ago — much younger than I had assumed.

**Why this happens:** CHANGELOG.md serves a different purpose (narrative timeline of what shipped) and its dates may not match physical commit dates. Trusting CHANGELOG as ground truth produces confident-sounding claims that the owner sees through immediately.

**How to apply:**
- For "how old is this project?" / "how long has X been deployed?" / "when did Y ship?" — `git log --reverse --format="%ad %s" --date=short | head -1` for project birth, `git log <commit-or-pattern> --format="%ad %s" --date=short` for specific events.
- CHANGELOG.md is for narrative context, not date-checking. Read it for the WHAT, not the WHEN.
- Never make confident statements about elapsed time without checking git timestamps in the same response.
- Most "how long?" questions about a young project have answers in hours-to-days, not weeks. Always verify with git log before asserting elapsed time.
