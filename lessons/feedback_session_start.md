---
name: Session start — read CHANGELOG and git status first
description: At every new session start, immediately read CHANGELOG.md and run git status before doing anything else. This reconstructs project state.
type: feedback
originSessionId: ac2a3c66-4944-46a7-96eb-a89057a698fc
---
At the start of every new session (not after auto-compact within a session — that has a summary), immediately do these two things before any other work:

1. Read `CHANGELOG.md` in the project root — this is the source of truth for what's shipped, what's in-progress, and what's next
2. Run `git status --short` — shows uncommitted changes and new files

**Why:** Memory files contain guidelines and decisions but not real-time sprint state. CHANGELOG.md is the only file that captures "what is currently on disk and what state it's in." Without reading it, the session appears to start from scratch which frustrates the user.

**How to apply:** Make these two reads the very first thing on any new session. Do not ask the user "where were we?" — read the files and reconstruct state autonomously.
