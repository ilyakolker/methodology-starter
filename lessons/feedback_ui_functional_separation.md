---
name: prd.json — UI and functional verification are separate tasks, never mixed
description: A single prd.json entry must be either category:functional (DB / API / DOM assertions) OR category:ui (Playwright screenshots + visual review). Never both in the same task. One user behavior decomposes into 1 functional task + N UI tasks (one per screen state / viewport).
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for prd.json task authoring.**

Every prd.json entry has a `category` field. The category dictates verification protocol — and entries are ONE category each, never mixed.

- `category: "functional"` — verification via DB queries, API calls, DOM presence assertions, edge function triggers, integration checks across systems. NO screenshots in steps.
- `category: "ui"` — verification via Playwright screenshots + agent visual review. Specific visual assertions (one CTA, deep teal H1, no overflow at 320px, negative-checks for unexpected elements). NO DB writes or API verification in steps.

**Why separate:**
- Failure isolation — when a task fails, you immediately know if the issue is functional or visual. Mixed tasks hide which.
- Different tooling per task — keeps the verification surface clean.
- Iteration cost — UI tasks tend to iterate more (visual tweaks); functional tasks tend to land in one shot. Mixing means a visual bug retries a passing functional verification.
- Parallel-safety — UI tasks for different screens can often run in parallel; functional tasks usually have stricter dependency chains. Separating exposes the right granularity.

**How to author:**
- Take a user behavior. Identify the functional spine: "what changes in DB / API / state."
- Author ONE `category: functional` task with steps that verify the spine end-to-end.
- For every screen / state / viewport that needs visual verification, author a separate `category: ui` task.
- UI tasks usually `depends_on` their functional counterpart (can't screenshot a state that hasn't been created functionally).

**Tech Lead enforcement (Check 8):**
- A `functional` task with screenshot steps → REJECT, split.
- A `ui` task with DB assertions → REJECT, split.
- A `ui` task without negative checks → REVISE (negative checks are first-class).

**Why this matters in our context:** today's Landing redesign had 5 specificity collisions and a duplicate-CTA bug because UI verification got tangled with functional verification mid-loop. Separating them makes each verification scope clean and each failure unambiguous.
