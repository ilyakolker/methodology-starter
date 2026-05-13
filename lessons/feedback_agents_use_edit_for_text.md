---
name: Agents must use the Edit tool for text edits, not Bash + python/node scripting
description: When editing markdown, code, config, or any text file, agents must default to the Edit (or Write for new files) tool. Reaching for Bash + python3/node/awk/sed heredocs to do a static text replacement is over-engineering and slow. Bash scripting is reserved for actual programmatic logic — JSON parsing, computed substitutions, git operations.
type: feedback
---
**HARD RULE for all agents with Edit/Write access.**

For any text-file change where the source and target strings are known:
- Use **Edit** for in-place replacement (preserve unchanged content)
- Use **Write** when creating a new file or doing a full rewrite
- Do NOT reach for `bash -c "python3 - <<'PYEOF' ... PYEOF"`, `node -e "..."`, `awk ... | tee`, or heredoc shell scripts to do what's essentially a find-and-replace

Bash + scripting tools (python3, node, awk, sed, jq) are appropriate when:
- Parsing JSON with conditional logic (`jq` on prd.json)
- Computing path substitutions with special characters (the bootstrap.sh awk case)
- Running git operations (commit, push, gh pr create)
- File-system operations (mkdir, cp, chmod)

NOT appropriate for:
- Adding a markdown section to a known file
- Replacing one line in a config
- Updating a placeholder in a template

**Why this matters:** owner's verbatim pushback (2026-05-12): "why he needs so many tools to add some data in md file and push?" Agent reached for python3, then node, then shell heredocs, to do what was two Edit tool calls. Owner watched the tool list pile up and called it out as overkill.

**How to apply:**
- Before reaching for Bash to edit a file, ask: "is this find-and-replace?" If yes → Edit tool. If it needs computed logic → Bash is OK.
- For multi-section markdown edits, do N sequential Edit calls (one per section). Not one Bash heredoc that rewrites the whole file.
- For new sections at the top of a file, use Edit with the existing top-of-file anchor as `old_string` and your-new-section-plus-the-anchor as `new_string`. Cleaner than full-file rewrites.
- Reserve full-file `Write` for files that don't exist yet or need wholesale replacement.

**Bonus signal for orchestrator:** if you spawn an agent for a "small text edit" task and see them queueing python3/node/awk, that's a smell — they're misreading the task complexity. Catch it in the dispatch prompt next time by saying "use the Edit tool, not Bash scripting" explicitly when the task is text-only.
