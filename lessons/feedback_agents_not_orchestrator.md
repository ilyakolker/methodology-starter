---
name: Agents must do the work, not the orchestrator
description: Never pretend to be agents. Always spawn actual Agent tool calls for each role. The user built a team — use it.
type: feedback
originSessionId: b1e716f5-3be4-40b9-8d56-641f2ee73989
---
NEVER do the work yourself pretending to be an agent. Always spawn actual agents via the Agent tool.

**Why:** The user invested significant time building a team of 8 agents (PM, Tech Lead, Designer, FE Engineer, BE Engineer, QA Engineer, Copywriter, Content Creator) with specific roles, skills, and communication protocols. When the orchestrator writes code directly, it bypasses the entire process — no design specs, no architecture review, no copywriter pass, no QA. The result was bad Hebrew copy, bugs, and hardcoded secrets.

**How to apply:** 
- For every task, spawn the correct agent(s) via the Agent tool
- Each agent reads its own role definition from .claude/agents/
- Follow the flow: PM → Tech Lead → Designer → BE → FE → QA → Copywriter
- The orchestrator coordinates and routes, never implements
- Agent descriptions should clearly show which role is working (e.g., "FE Engineer: implement landing page")
