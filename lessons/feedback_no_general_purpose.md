---
name: Never use general-purpose agent for file writing
description: Never spawn general-purpose for any task that involves writing files. Use the right specialized agent.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
Never spawn the general-purpose agent for tasks that involve writing files of any kind. It uses Bash for directory checks (`ls 2>$null`, `Test-Path`) which trigger permission prompts.

Use the right agent for each file type:
- `supabase/` files, edge functions, DB migrations → **be-engineer**
- `src/` files, React components, hooks → **fe-engineer**
- `docs/`, specs, CHANGELOG → **pm**
- Hebrew copy review → **copywriter**
- QA validation reports → **qa-engineer**

**Why:** General-purpose was used to write `tmp/whatsapp-variations.txt` (a task that belonged to be-engineer since it reads from `supabase/functions/`) and triggered `ls 2>$null` and `Test-Path` Bash permission prompts twice. User stopped the session.

**How to apply:** When the task is "write a file with content X", ask which domain owns X and spawn that agent. If it's a content/report file with no clear owner, use be-engineer (they have Write access and don't tend to run directory checks).
