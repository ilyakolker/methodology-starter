---
name: PM always writes specs to files
description: PM output must always be saved as files in docs/ — never left only in conversation
type: feedback
originSessionId: ba5aac7a-b068-4d6a-8cd0-9b69b1f500d9
---
PM must always write his deliverables to files. Never leave specs, user stories, or flow definitions only in the conversation text.

**Why:** User explicitly said PM is "lazy" when specs were returned as conversation text only. Work that isn't in a file doesn't exist.

**How to apply:**
- Every PM session produces at least one file in `docs/`
- User stories → `docs/STORIES_<feature>.md`
- Screen specs → `docs/SPEC_<feature>.md`
- Sprint plans → `docs/SPRINT_<n>.md`
- PM agent should write files directly, or orchestrator writes PM output to file immediately after
- File must be thorough — not a summary, the full spec a Designer and FE can build from without asking questions
