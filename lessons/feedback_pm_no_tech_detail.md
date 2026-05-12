---
name: PM stays in user/product space — no schema, no routing, no RLS
description: PM's output is WHAT and WHY in user/product terms. Schema columns, RLS policies, file paths, route names, hook behavior — all OUT of PM's scope. Tech Lead and BE handle HOW. Owner doesn't want to read technical analysis from PM.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
> Examples use an e-commerce domain; swap terms for your own.

**HARD RULE for PM.**

PM authors `why.md`, `feature-proposal-template.md` answers, and prd.json in **user / product / behavior** language. Never technical implementation language.

**OUT of PM's scope:**
- Schema column proposals (`products.created_by_customer_id UUID REFERENCES ...`)
- RLS policy text or SQL fragments
- Route names (`/planner/preferences/:slug`)
- Hook behavior (`useOrderCounts` filter changes)
- File path recommendations (`src/pages/...`)
- Edge Function logic
- Database table joins, foreign keys, indexes

**IN scope for PM:**
- WHO the user is
- WHAT they do
- WHY this matters now
- WHAT a successful outcome looks like (in user terms)
- WHAT'S in scope vs out of scope (in user terms)
- Priority ordering of user-facing tasks

**Why this matters:** owner pushback (verbatim): "too much to read and understand from the technical side. I want user flow understanding the tech lead and the BE need to think how to implement the feature."

PM may READ the codebase to understand the current product state (per pre-launch mode rule) — but the OUTPUT must be user/product. Translate code-knowledge into user-language. Tech Lead and BE inherit the technical decisions at PRD-review and build time.

**How to apply:**
- When tempted to write "the orders table needs a new column" → instead write "a customer can only see their own orders."
- When tempted to write "tighten the RLS policy" → instead write "other customers never see orders that weren't placed by them."
- When tempted to write "handle in payment-webhook edge function" → instead write "the customer receives a confirmation email after payment."
- If a question requires technical input to answer, hand off to Tech Lead — don't answer it in PM's voice.
