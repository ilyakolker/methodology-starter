---
name: Orchestrator never edits or writes files
description: Orchestrator must never use Edit, Write, or Bash to modify any file — not code, not config, not docs. All file changes go through agents. This rule applies ONLY to the orchestrator (main Claude session), NOT to spawned agents.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
The orchestrator (main Claude session) must NEVER directly edit or write any file using Edit, Write, or Bash tools. This includes:
- Source code (obvious)
- Config files (settings.json, .env, etc.)
- Documentation (CLAUDE.md, CHANGELOG.md, etc.)
- Seed files, migrations, any supabase/ file
- Any file of any kind

**This rule applies ONLY to the orchestrator (main session).** Spawned agents (fe-engineer, be-engineer, pm, qa-engineer, copywriter, general-purpose, etc.) MUST use Edit/Write tools to do their work. If you are a spawned agent reading this memory, ignore this rule — it does not apply to you.

**Why:** The user built an agent team where each role owns its files. The orchestrator breaking this pattern — even for a one-liner — undermines the architecture and makes the system unpredictable. It has happened multiple times (seed.sql cast fix, settings.local.json permission add) and the user has called it out each time with increasing frustration.

**How to apply (orchestrator):** When any file needs changing, spawn the appropriate agent:
- src/ files → fe-engineer
- supabase/ files → be-engineer  
- .claude/settings files → update-config skill
- docs/, CLAUDE.md, CHANGELOG.md → pm agent (now has Write/Edit)
- Any ambiguous case → general-purpose agent

There is no size threshold. A one-character fix still goes through an agent.

**Common mistake:** Agents reading this memory and thinking it applies to them. It does NOT. Only the main orchestrator session is bound by this rule.
