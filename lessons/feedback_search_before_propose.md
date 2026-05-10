---
name: Search the project before proposing setup work or fresh-state solutions
description: Before proposing setup, regeneration, or fresh-config work, exhaustively search the project for existing artifacts. Sprint 3 (Edge Functions) is shipped, deployed, and the local secrets file existed all along — but I proposed destructive regeneration without searching first. Project state must be read, not assumed.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.** Before proposing any setup, fresh-config, regenerate, or "let's create X" work — exhaustively search the project for existing artifacts. The wedding-app project is past initial setup. Most "setup" questions have an existing answer on disk.

**The failure:** Owner asked "where do I get the Green API secrets?" I said "Supabase dashboard, but secrets are write-only, so you can't retrieve them — let's regenerate SUBMIT_TOKEN_SECRET and update Supabase." All wrong. The values were sitting at `supabase/secrets.local` the entire time, gitignored, fully populated, with the `supabase secrets set ...` commands as comments at the bottom showing exactly how they were originally applied. A 5-second `find . -name "*secret*"` would have surfaced it.

**Why this happened:** I treated the question as "fresh setup" instead of reading project state. Memory says "Sprint 3 complete, Edge Functions deployed." Git log has `ea02918 Sprint 3: Green API integration, Edge Functions`. CLAUDE.md documents `.env.local.secrets`. None of that fit a "first-time setup" framing. I should have known this was a "find existing file and copy it" problem, not a "generate new secrets" problem.

**How to apply:**
- Before proposing setup work, run `find . -type f -name "*<keyword>*"` and `Grep` for variable names mentioned in the question.
- Read the project's current state — git log, CHANGELOG, APP_MAP — before assuming anything is missing.
- The wedding-app is a working product with deployed infra. "Where is X?" usually means "X exists, find it" not "X needs to be created."
- Never propose destructive work (regenerating secrets, dropping config, rewriting tokens) until exhaustive search confirms the existing artifact is genuinely gone.
- "I can't access X" is a claim that needs to be verified by searching, not asserted by default.
