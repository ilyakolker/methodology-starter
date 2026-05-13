---
name: Task brief is a self-contained contract — engineer reads ONLY that, no mandatory upstream docs
description: Planning is heavy on purpose; PM + Tech Lead invest there. The output is a series of self-contained task briefs. Each is a complete contract. The engineer (Ralph iteration) reads ONLY their task brief — never why.md, flow.md, spec.md, decisions.md, full prd.json. Iteration loop is code → test → fix → code → test → done.
type: feedback
---
**HARD RULE for PM, Tech Lead, and Ralph.**

The methodology is structured around an asymmetric cost-of-thinking tradeoff:
- **Planning is expensive on purpose.** PM + Tech Lead read everything, debate every decision, and distill the result.
- **Execution is cheap on purpose.** Engineers (Ralph iterations, fired per task via `claude` CLI) read ONLY the task brief. No detours.

## What this means for PM and Tech Lead

The task brief that lands in prd.json (or a sidecar file referenced by it) MUST be a complete contract on its own. After reading the brief, the engineer should never need to ask:
- "What is the user trying to accomplish?" — bake the relevant user story INTO the brief
- "What does this screen look like?" — bake the visual contract INTO the brief
- "How is this related to the rest of the feature?" — irrelevant; bake the dep contract INTO the brief
- "What's the broader architecture?" — irrelevant; bake the files_touched + any cross-cutting decision INTO the brief

The brief includes:
- The exact thing to build (code-level if it's code, DOM-level if it's UI, schema-level if it's a migration)
- The exact verification (what assertion / what query / what screenshot, what specific values)
- The exact files (existing files to edit + NEW files to create, with paths)
- Any cross-cutting constraint that affects THIS task (RLS rule, naming convention, design token to use, etc.)

The brief does NOT include:
- Pointers like "see flow.md note 13" or "as decided in decisions.md D4"
- Generic project context ("this is a [project name]")
- Other tasks' info
- The user's why or the product's strategy

If a cross-cutting decision affects the task, INLINE it. Repeat it across every affected task's brief. Repetition is cheaper than detours.

## What this means for ralph.sh

The mandatory-reading list (why.md + spec.md + flow.md + prd-review.md + decisions.md + full prd.json + CLAUDE.md) is a design bug, not a feature. Engineers should NOT be re-learning the project on every iteration.

The Ralph prompt should give the engineer:
- The task brief (full contract)
- The codebase files in `files_touched` (only the ones they need to edit)
- CLAUDE.md ONLY for the rules that apply to this task category (e.g. RLS rules for migrations, design token rules for UI)
- Nothing else

The fallback / sanity check: if the engineer reads ONLY their brief and can't do the task, the brief is incomplete — that's a PM/Tech Lead failure, not an engineer failure.

## What this means for the iteration loop

Engineer's loop is mechanical:
1. Read the brief
2. Code per the brief
3. Run the verification per the brief
4. Fix until verification passes
5. Commit + exit

No "now let me check if there's anything in flow.md that affects this." No "let me consult prd-review.md for context." If something matters to this task, it's IN the brief. If it's not in the brief, it doesn't matter.

## Why this matters

Owner's verbatim framing (2026-05-12):
> "I don't mind spending time on planning but I want to make sure when the engineers come to do a task they read exactly what they need and that is it. everything we are preparing is for the pm and tech lead to create the specific tasks. the iterations should be quick - code - test - fix - code - test - done."

Cost impact: each Ralph iteration re-reads a large volume of unchanged context across many tasks. The fix is structural: brief contains everything, engineer reads only the brief.

## How to apply

- **PM:** when decomposing spec.md into prd.json, each task's description must already feel like a complete brief. If it feels like "see X for details," expand X inline.
- **Tech Lead:** during PRD review, populate each task's brief with: files_touched, cross-cutting constraints relevant to this task, locked decisions affecting this task. Do NOT just write "see decisions.md D4" — inline D4.
- **Ralph dispatch prompt:** drop the mandatory-reading list. Replace with "your full context is in the task brief below; do NOT read why.md / spec.md / flow.md / decisions.md / prd-review.md."
- **Orchestrator:** when dispatching engineering subagents (be-engineer, fe-engineer), give them the task brief + the relevant codebase paths. Do NOT cc them upstream docs by reflex.
