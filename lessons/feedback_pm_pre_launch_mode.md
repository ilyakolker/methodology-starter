---
name: PM protocol — pre-launch mode vs live mode
description: PM Q&A discipline differs depending on product stage. Pre-launch / WIP / no-real-users — ground questions in CURRENT PRODUCT STATE, not hypothetical user behavior. Live product — Mom-Test discipline (past behavior, real users) applies. Mismatch = irrelevant questions, frustrated owner.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE for PM intake.**

Before running the PROPOSAL phase Q&A, PM determines product stage:

- **Pre-launch / WIP / no-real-users mode** — owner is the builder, adding features as they come to mind. No real-user history exists. Mom-Test questions ("tell me about the last user who hit this," "what did they do instead") are USELESS and feel disconnected. Owner gets frustrated when asked them.

- **Live mode** — real users exist. Mom-Test discipline applies (focus on observed past behavior, not hypotheticals or opinions).

**Pre-launch PM Q&A protocol:**

1. **Read the existing project state first.** PM examines current code, schema, screens, flows BEFORE asking the owner questions. The "ground truth" is the product as it exists today, not a fictional user.

2. **Questions are integration-grounded, not user-grounded.** Examples:
   - "Where in the current UI does the entry point live?"
   - "Which existing tables / components does this touch?"
   - "How does this fit with the [existing flow X]?"
   - "What's missing in the current product that this fills?"
   NOT: "Tell me about a real user who hit this."

3. **WHY for pre-launch features = owner's product intent.** Frame the WHY as "the owner anticipates this gap because the current product covers X but not Y." Don't fake "observed user pain."

4. **Success metric stays valid** — but framed as a hypothesis ("if 30% of test couples use this when piloting, we keep it") not as a measured signal.

5. **Out-of-scope is sharper in pre-launch** — owner is in WIP mode and easily over-scopes. PM's job is still to cut.

**How to apply:**
- Default mode for wedding-app today is pre-launch. The product is on Vercel but no real users.
- Switch to live mode when owner says "we have N real users" or similar signal.
- The methodology files (`pm-protocol.md`, `feature-proposal-template.md`) need to add this mode-distinction in a future revision pass.
