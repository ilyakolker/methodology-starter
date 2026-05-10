---
name: BE/FE strict separation
description: BE only writes supabase/ files. FE only writes src/ files. No overlap, ever.
type: feedback
originSessionId: ba5aac7a-b068-4d6a-8cd0-9b69b1f500d9
---
BE and FE must never touch each other's domain.

- BE scope: `supabase/` only — migrations, Edge Functions, RLS policies
- FE scope: `src/` only — components, hooks, pages, types, routes

**Why:** User is explicitly unhappy when BE writes frontend code (hooks, pages, App.tsx). Violating this erodes role ownership and trust in the agent pipeline.

**How to apply:** Before spawning BE, strip any mention of `src/` files from the prompt. If FE needs a missing field or endpoint change, FE invokes BE to make it — agents can spawn each other freely. The rule is about file ownership, not communication. Neither agent writes the other's files.
