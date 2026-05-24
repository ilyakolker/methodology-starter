---
name: Backend-only features skip the FLOW phase
description: No-UI features (parsers, pipelines, schema) have no flow.md; ralph treats flow.md/spec.md as optional.
type: feedback
---
Features with no screens — parsers, data pipelines, ingestion, schema, background jobs — skip the Designer FLOW phase. There is no `flow.md`, and `spec.md` carries only the behavior contract (no visual section).

**Why:** Forcing a `flow.md` onto a backend-only feature is friction with no value. The old `ralph.sh` hard-required `flow.md`, which blocked backend-first builds entirely.

**How to apply:** PM routes a no-UI feature straight from `why.md` to SPEC/PRD (all tasks `category: "functional"`) → Tech Lead → build. `ralph.sh` hard-requires only `why.md`, `prd.json`, `prd-review.md`; `spec.md` and `flow.md` are optional (warn if absent). Don't spin up the Designer for a feature that has no screens.
