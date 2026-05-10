---
name: APP_MAP ownership and update timing
description: APP_MAP updated right before commit+push, not during development. CHANGELOG is the living doc during dev.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
**APP_MAP = production truth.** Updated right before commit+push as part of commit preparation.
- BE updates BE sections (migrations, edge functions, DB tables)
- FE updates FE sections (routes, pages, hooks, components, types)
- Commit only AFTER APP_MAP is current

**CHANGELOG = living local state.** Updated during development. New sessions read this first to know where we are.

**Specs must be thorough before build starts.** Like OrKey's spec documents — every screen, every state, every edge case written in `docs/sprint*-scope-draft.md` and `docs/sprint*-architecture.md` before BE or FE touch any code.

**Why:** Web iteration is fast and local — we don't update APP_MAP on every file edit. The natural "approved" gate is when owner checks locally and says push. That's when APP_MAP gets updated, same as OrKey's test-runner-pass moment.

**Agreed:** Testing this approach over a few sessions to validate it works.
