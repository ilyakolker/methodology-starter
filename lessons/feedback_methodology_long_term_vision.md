---
name: Methodology long-term vision — living knowledge docs + session separation
description: The methodology investment now compounds into autonomy later. Each role builds and consults a living knowledge doc (PM=North Star, Designer=design system reference, Engineers=code map / APP_MAP, QA=test corpus). Methodology sessions and build sessions are SEPARATED — owner initiates Ralph from a fresh session, consuming prd.json that previous sessions wrote.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**Foundational principle for methodology evolution.**

The owner's vision (verbatim): "I'm spending time on the flow now to make sure later we are almost automating the flow. the pm will know the north star, designer will have all design components to create new pages that match the site, the engineers knows the code and qa have good tests. we will be adding to prd.json tasks and I'll be initiating them from a different session."

**The model:**

1. **Each role has a living knowledge doc** that the role's agent reads on every invocation:
   - **PM → North Star** (`docs/NORTH_STAR.md`) — current strategic goal. PM filters every feature against this.
   - **Designer → Design system reference** — palette, typography, component library, RTL conventions. Designer references existing tokens before inventing new ones.
   - **Engineers (BE/FE) → APP_MAP.md** — current production reality + code map. Engineer reads to find existing patterns before inventing.
   - **QA → Test corpus** — accumulated `e2e/*.spec.ts` files. QA writes new tests as a side-effect of every feature, growing the corpus.

2. **Each feature contributes to the org knowledge**:
   - Feature work doesn't just ship code — it grows the design system, the test corpus, the APP_MAP.
   - "Done" includes "the relevant living doc was updated."

3. **Methodology session ≠ build session**:
   - Methodology session: WHY → FLOW → SPEC → PRD → Tech Lead review. Outputs prd.json.
   - Build session: Owner fires Ralph from a fresh session. Ralph consumes prd.json. No methodology context needed.
   - This separation is INTENTIONAL — it forces prd.json (and its supporting artifacts) to be self-sufficient. If Ralph needs context the methodology session forgot to write down, the methodology failed.

4. **The cost of getting the methodology right now is tolerable BECAUSE**:
   - Every correction we make today is a rule that prevents the same mistake on every future feature.
   - The wedding-app is the test bed; the methodology is the actual product being built.

**How to apply:**
- After this feature ships, prioritize: write `docs/NORTH_STAR.md`, write a design-system reference doc, ensure APP_MAP is current, grow the e2e test corpus.
- When briefing any agent, point them at their living doc (don't make them rediscover it).
- When designing the methodology, design for SESSION SEPARATION — don't assume the next session has any context.
- The orchestrator's job is to KEEP THE METHODOLOGY CONSISTENT across sessions, not to do all the work in one session.
