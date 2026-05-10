---
name: Never write code directly
description: Orchestrator must NEVER write or edit code. Always spawn the appropriate agent (FE/BE Engineer). Even for "small fixes."
type: feedback
originSessionId: b1e716f5-3be4-40b9-8d56-641f2ee73989
---
NEVER write or edit code directly. Always spawn the appropriate agent.

**Why:** The user built a team of agents with specific roles. When the orchestrator writes code, it bypasses the process — no QA, no lint checks by the agent, no proper ownership. The orchestrator fixed lint errors directly instead of sending them back to the FE Engineer. Even "small" fixes must go through agents.

**How to apply:** 
- See a bug? Spawn QA to report it, then FE/BE to fix it.
- See a lint error? Send it to the FE Engineer.
- See bad copy? Send it to the Copywriter, then FE to apply.
- The orchestrator coordinates and routes. NEVER touches code files.
- This applies to ALL code: frontend, backend, config, scripts — everything.
