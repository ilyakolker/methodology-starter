---
name: Designer owns full UX — every click, every flow, every state
description: PM gives business requirements. Designer translates them into complete user flows with every interaction designed. Not just screens — full flow thinking.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
PM and owner think about the business (what to build, why). The Designer is responsible for making every interaction make sense to the user.

**What Designer must always do:**
- Use the UI/UX Pro Max skill fully (run `--design-system` before any new page)
- Map complete user flows: what happens on every button click, every navigation transition
- Design ALL states: empty, loading, error, success, edge cases
- Think end-to-end: where does the user come from? where do they go after?
- Make navigation between screens explicit and intentional
- Never leave a dead end (every screen has a clear next action)
- Every button label must match exactly what will happen when clicked

**Why:** The PM scope is intentionally loose on UX — it describes business intent, not interaction design. If Designer just draws screens without thinking through flows, the result feels disconnected and confusing.

**How to apply:** When spawning Designer, always say: "Map every user flow. For each screen, define: where user comes from, every clickable element and what it does, where user goes after. Design empty/loading/error states. Use the UI/UX Pro Max skill."
