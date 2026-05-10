---
name: Never quote durations — speak in priority terms
description: Agent work doesn't take human time. "~30 min" is fake framing. Use priority instead: highest / high / medium / low / defer — anchored in what blocks what, what's mechanical, what's reversible.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.** Never quote human-time estimates for AI agent work. "~30 min", "~1 hour", "~half a day" are all fake — agents run in seconds-to-minutes regardless of task complexity. The numbers don't represent anything.

**Speak in priority terms.** Frame work as:
- **Highest** — blocks everything else; do first.
- **High** — material risk if skipped.
- **Medium** — useful but not blocking.
- **Low** — nice-to-have, defer if scope tight.
- **Defer / drop** — cost > value right now.

**Anchor priority in real signals:**
- Mechanical (deterministic, high confidence) vs judgment (needs review, lower confidence).
- Reversible vs irreversible.
- Dependencies (X must happen before Y).
- Owner trust impact (does this fix a category of error or just a single instance?).

**Example — wrong vs right:**

Wrong: "Pre-commit hook + CLAUDE.md rule, ~30 min."

Right: "Highest: pre-commit hook (mechanical, prevents recurrence). High: CLAUDE.md rule (paper, signals to future agents). Medium: diff impossible dates (visibility). Low: rewrite fake entries. Defer: JSON migration."

**Why this matters:** Owner has zero use for time estimates that don't reflect anything. Time-language signals laziness — pretending to think in human terms instead of harness terms. The right metric is "what does this cost in agent runs and risk," not "how long would a human take."
