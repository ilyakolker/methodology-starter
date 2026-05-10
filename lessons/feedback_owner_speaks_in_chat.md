---
name: Owner speaks in chat — agents write files
description: Never tell the owner to write a file themselves. Owner brain-dumps in chat (free-form, their voice). Agents (PM, Designer) capture, structure, and write to disk. Owner + PM + Designer align via chat-relay through orchestrator.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.** The owner never writes to project files. Their input is in chat — raw, unstructured, conversational. Agents capture it to the right file in the right structure.

**The failure:** I told the owner "write `docs/NORTH_STAR.md` yourself" and "drop your feature list into `docs/backlog.md`." Both wrong. Owner authors the THOUGHT, agents author the ARTIFACT.

**Correct flow for vision-level docs (North Star, backlog, brand voice, etc.):**
1. Owner says the rough direction in chat — their words, their voice.
2. Orchestrator spawns PM with owner's input. PM drafts a structured version + flags 2-3 clarifying questions.
3. Orchestrator relays PM's draft + questions back to owner in chat.
4. Owner answers / redirects / approves in chat.
5. If a second perspective is needed (Designer for visual, Tech Lead for feasibility, Copywriter for voice), orchestrator spawns them with the current draft + owner's clarifications. Each adds their angle.
6. Orchestrator brings the converged draft back to owner. Approve / modify.
7. Orchestrator instructs the appropriate agent (usually PM) to write the final to disk.

**Why this matters:** Owner's job is taste, vision, and intent. The agents' job is structure, format, and persistence. Mixing the two — having the owner format files OR having agents invent vision — produces misaligned artifacts.

**How to apply:**
- When the owner gives a vague directional input ("I want to focus on X"), don't ask them to write it down. Spawn PM to draft a structured version.
- When the owner has a list ("I want features A, B, C"), don't ask them to format it. Capture verbatim from chat and pass to PM/Designer.
- When alignment requires multiple roles, channel the discussion through the orchestrator. Each agent writes their proposal; orchestrator presents to owner; owner reacts in chat; loop until aligned.
- Files only get written when the owner has explicitly aligned on the content via chat.
