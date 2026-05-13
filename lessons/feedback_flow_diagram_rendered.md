---
name: flow.md requires a rendered PNG, not raw Mermaid
description: flow.md must embed a rendered flow.png at the top. Mermaid source alone is unreadable. Render via npx @mermaid-js/mermaid-cli. Never ask owner which renderer — the methodology has one.
type: feedback
---

**HARD RULE for Designer.**

`flow.md` REQUIRES a rendered `flow.png` alongside it. The diagram must be embedded at the TOP of flow.md as `![flow](flow.png)`. The Mermaid source goes below as the editable representation.

**Render command:**
```bash
npx @mermaid-js/mermaid-cli -i tmp/<feature>-flow.mmd -o docs/features/<feature>/flow.png --backgroundColor transparent --width 2000
```

Extract the Mermaid block from flow.md to a `.mmd` file first. Then render to PNG.

**If mermaid-cli isn't installed:** use `npx` so it installs on demand. Do NOT ask owner whether to install — the methodology has one rendering path; pick it silently.

**Why this matters:** owner reads flow.md at scan-speed. Mermaid text inside a code fence is illegible — they have to mentally parse the syntax. A rendered PNG is instant comprehension. Designer producing Mermaid-only is failing the primary purpose of the document.

**How to apply:**
- After writing flow.md, immediately render the PNG.
- Verify the PNG exists on disk and is non-trivial (>10 KB).
- Verify flow.md embeds it at the top.
- Do NOT report flow.md complete until both exist and are linked.
