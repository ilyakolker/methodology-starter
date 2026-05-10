---
name: Git log is source of truth for project age and timeline
description: For project age, history, and "when did X ship," use `git log --format="%ad %s" --date=short`. CHANGELOG.md dates are narrative/aspirational and contradict actual git timestamps. Owner caught me claiming "Edge Functions running for weeks" when git showed 2 days.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.** For project age, sprint timing, "when did X ship," or any claim about project history — read `git log` first. Do NOT pull dates from CHANGELOG.md.

**The failure (twice in one session):**
1. I treated the project as fresh-setup and proposed regenerating SUBMIT_TOKEN_SECRET when the secrets file existed.
2. I said "Edge Functions have been running on Supabase for weeks" — actually 2 days. I sourced "weeks" from CHANGELOG dates (2026-04-21 Sprint 1, 2026-04-28 Sprint 2) which are NARRATIVE dates, not git timestamps. Git log shows the project's first commit was 2026-05-04 — 3 days old total.

**Why this happens:** CHANGELOG.md serves a different purpose (narrative timeline of what shipped) and its dates may not match physical commit dates. Trusting CHANGELOG as ground truth produces confident-sounding claims that the owner sees through immediately.

**How to apply:**
- For "how old is this project?" / "how long has X been deployed?" / "when did Y ship?" — `git log --reverse --format="%ad %s" --date=short | head -1` for project birth, `git log <commit-or-pattern> --format="%ad %s" --date=short` for specific events.
- CHANGELOG.md is for narrative context, not date-checking. Read it for the WHAT, not the WHEN.
- Never make confident statements about elapsed time without checking git timestamps in the same response.
- The wedding-app project is 3 days old as of 2026-05-07. Most "how long?" questions about it have answers in hours-to-days, not weeks.
