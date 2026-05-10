---
name: Use Grep tool not Bash for searching — never triggers permission prompts
description: Grep tool is auto-allowed and never prompts. Bash grep/Select-String always prompts. User gets very frustrated by permission prompts.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
Always use the Grep tool (not Bash) for searching files, including transcripts and logs.

**Why:** The Grep tool is auto-allowed by Claude Code and never triggers permission prompts. Any Bash or PowerShell command using grep/Select-String/rg will trigger a permission prompt, which blocks the pipeline and infuriates the user.

**How to apply:** Whenever you need to search file contents — transcripts, source files, config files, anything — use the Grep tool directly. Never use `Bash(grep ...)` or `PowerShell(Select-String ...)` for search tasks.
