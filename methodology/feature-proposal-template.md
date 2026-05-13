# Feature Proposal Template — DRAFT v2

> **Changes from v1:** No functional changes. Added a note about sub-feature decomposition for proposals that turn out to cover multiple deliverables.

> **How this works:** Owner answers these in chat. PM captures the answers, then runs free-form Q&A to fill gaps. The owner does not write files — PM does.
>
> **Trigger:** owner says `feature-plan: <name + idea>` in chat.
>
> **Note on scope:** This template assumes a single deliverable per `feature-plan`. If the proposal turns out to describe work that decomposes into multiple deliverables (different personas, different success metrics, three loosely-related screens), PM may declare sub-feature decomposition during the proposal review — each sub-feature then gets its own `feature-plan` intake and its own folder under `docs/features/`.

---

## 1. Feature name
*One line. Verb-first if possible. Not a feature category — a specific thing.*

> Example: "Send order confirmation emails with tracking link" — not "Email integration".

## 2. The pain
*What's broken or missing today, in user terms — not product terms.*

Answer two things:
- What does the user do today instead? (Manual workaround, a competitor, nothing at all.)
- What does that cost them? (Time, money, mistakes, dropped users.)

> Don't say "we don't have X". Say "the user has to do Y, and it sucks because Z".

## 3. The desired outcome
*What does the user DO after this exists? In user terms.*

- The single sentence the user could say after using it: "I just ___."
- What changes for them in their life / workflow?

> Not "they can use the dashboard". Yes "they submitted a support ticket in under 60 seconds from the app, without switching to email".

## 4. Why now
*Why is this priority over everything else on the list?*

Pick at least one:
- Blocking another feature
- Validating a core hypothesis
- User pain reported / observed N times
- Competitor moved / market signal
- Cheap to build, high signal

## 5. Who it's for
*Specific persona. Not "users". Not "customers". Not "admins".*

- Who exactly? (e.g. "first-time buyer, hasn't completed checkout, on mobile")
- Are they already in the product? New? Returning?
- Roughly what % of total users does this persona represent?

## 6. What success looks like
*Measurable signal. Rough is fine. "I'll know it when I see it" is not enough.*

- Primary metric (e.g. "40% of users who reach screen X click Y")
- Time to validate (e.g. "2 weeks of traffic")
- Kill criterion — at what number do we conclude this didn't work?

## 7. Out of scope
*What this is NOT. Pre-empt scope creep.*

- Adjacent features the owner is intentionally NOT building right now
- Edge cases being deferred
- Things that sound related but aren't

> Example: "Automated refund processing — not in scope. Users click a link and submit a refund request via web form."

---

## After the form

PM asks free-form follow-ups (5-Whys / Job Story / Mom Test discipline) until WHY is resolved, then writes `docs/features/<feature>/why.md`. Owner approves before Designer engages.
