# Tech Lead Protocol — PRD Review — DRAFT v2

## Changes from v1
- Output filename is now `prd-review.md` (was `tech-review.md`) — mirrors the `prd.json` family.
- prd.json path corrected throughout to per-feature: `docs/features/<f>/prd.json`.
- Check 6 (schema/deploy) is no longer a blanket pass-through. Tech Lead now judges per task whether to block APPROVE or pass through with a reminder. Rule of thumb included.
- Check 4 (new architectural patterns) is now Tech Lead's call. No owner gate per pattern. Tech Lead writes a 2-3 line rationale; owner only weighs in if Tech Lead asks.
- Plain-English intros added to every check. The bullets stayed; the wall-of-bullets feel did not.
- Check 8 sharpened — strict UI/functional category separation. UI tasks must include negative checks. Mixed tasks are split.
- **NEW Step 7 (BUNDLE)** — after every entry is APPROVE, Tech Lead pre-bakes a per-task context bundle so Ralph reads ~5 KB per iteration instead of the full feature corpus. See `methodology/per-task-context-bundles.md` for the bundle spec.
- **NEW Step 7.5 (VERIFICATION MODE)** — for each UI task, Tech Lead sets `verification_mode` to `dom-only` (default, cheap) or `visual-review` (opt-in, screenshot Read). Saves vision tokens on tasks where every acceptance criterion is DOM-assertable. See `methodology/per-task-context-bundles.md#verification-mode-ui-tasks-only`.
- **NEW Step 7.6 (AGENT + MODEL)** — per-task specialist + cost-tier model selection. Tech Lead sets `agent` (`fe-engineer` / `be-engineer`) and `model` (`opus` / `sonnet` / `haiku`) on every task. Ralph fails fast on any task missing either field. Wrong model = paying 10× more for the same work.

---

## What this protocol is, in plain English

When PM finishes the build plan (`prd.json`) for a feature, Tech Lead reads it and asks one question: **can we actually build this, in this order, without creating a mess?**

Tech Lead is not redesigning the feature. PM owns the *what*, Designer owns the *flow*, engineers own the *code*. Tech Lead owns *how* and *whether-it's-safe* — making sure the plan is buildable, dependencies are honest, no shortcuts have been smuggled in, and we don't quietly invent a new architectural pattern that future-us will regret.

The output is a review file with three possible verdicts per task: APPROVE, REVISE, REJECT. PM iterates until everything is APPROVE, then build starts.

---

## Step 1 — TRIGGER

PM hands you a populated `docs/features/<f>/prd.json` (or new entries appended to one mid-build) with the message:

```
ready for Tech Lead review of feature <f>
```

No other trigger starts this protocol. If owner asks you to review code or architecture mid-build, that is a different (informal) review, not this protocol.

---

## Step 2 — INTAKE

Before reviewing entries, read in this order:

1. `docs/features/<f>/why.md` — so you know what success looks like and what's out of scope.
2. `docs/features/<f>/spec.md` — the source of truth every entry's `spec_ref` must point at.
3. `docs/features/<f>/prd.json` — the entries themselves.
4. The `files_touched` paths on each entry — open enough of each to verify the entry's claim.

If `why.md` or `spec.md` is missing, halt. Reply to PM: "spec.md missing — cannot review without it." Do not infer scope from prd.json alone.

---

## Step 3 — REVIEW (per entry)

For every new or changed entry in prd.json, run all 8 checks. Record the result against each check.

### Check 1 — Dependency correctness

*Why this matters:* If a task quietly depends on something that hasn't been built yet, the engineer hits a wall mid-build. We catch that here, not there.

- Does `depends_on` capture every real dependency? (UI tasks consuming an API → API task must be listed. Tasks reading a new column → migration task must be listed.)
- Is there a hidden runtime dependency (env var, secret, deployed Edge Function) not represented as a task at all? If yes, flag the missing task.

### Check 2 — Priority vs tech reality

*Why this matters:* The order of entries in `prd.json` is the order engineers build them. If entry 5 needs entry 7 to exist first, the build breaks. Walk the list and check.

- Is the linear order of entries in the array executable? Walk it top-to-bottom and ask: "if I built only entries 1..N, would entry N+1 have everything it needs?"
- If not, name the exact swap. Example: "swap entries 2 and 5 — entry 5 (`add_phone_column`) is a dependency of entry 2 (`vendor_form_phone_input`)."

### Check 3 — Tech-debt risk

*Why this matters:* Every shortcut we ship lives in the codebase forever unless someone deliberately rips it out. This check forces us to either avoid the shortcut or commit to a follow-up task — never just hope.

Does the entry, as specced, push the codebase toward any of these:

- God components (>200 lines, multiple responsibilities)
- Parallel data sources (a second way to read the same data — drift hazard)
- Hardcoded values that should be config or DB-driven
- Magic strings / numbers without a constant
- Type casts (`as any`, `as unknown as X`) used to bypass typing
- Logic duplicated across FE and BE that will drift
- New pattern that competes with an existing one in the codebase
- Per-spec / per-file type augmentations or ambient declarations that exist or will exist in sibling files (TS projects) — hoist to a shared `.d.ts` before the build agent re-invents it

If yes: either propose the refactor scope inline, or flag it as `ship-with-debt + follow-up task: <id>`. Never approve "we'll fix it later" without an actual follow-up entry being added to prd.json.

### Check 4 — Architectural fit

*Why this matters:* Patterns are how a codebase stays understandable. A second way to do auth, or a third way to fetch data, doubles the cognitive load forever. Tech Lead is the one who decides when a new pattern is justified — that's the role. Owner doesn't get pulled in for every pattern call. If a pattern feels big enough to warrant owner input, Tech Lead explicitly says so in the review; otherwise Tech Lead approves or rejects on the spot with a 2-3 line rationale recorded in `prd-review.md`.

- Does the entry slot into existing patterns (data fetching, mutation, auth, error handling)? If yes, approve.
- Does it invent a new pattern? Tech Lead approves or rejects, writing a 2-3 line rationale in the review (what the pattern is, why it's needed, where it will live). No owner gate by default.
- Reject silent pattern divergence — patterns that sneak in without acknowledgement.

### Check 5 — Cascade impact

*Why this matters:* PM lists `files_touched` from a feature-author's view. Tech Lead's job is to spot the things PM didn't think of — generated types, RLS policies, seed data, downstream consumers — and add them to the list before the engineer inherits the gap.

List concrete files / components / tests that need updating but are missing from `files_touched`. Examples:

- Schema change → types regenerate, RLS policies update, seed data update
- New route → router config, breadcrumbs, sitemap if any, e2e nav tests
- Renamed prop → every consumer

### Check 6 — Schema / data implications

*Why this matters:* Some changes are reversible and low-risk. Others (destructive migrations, RLS policy rewrites) can break production data or open security holes. Tech Lead now judges per task: pass it through with an owner-approval reminder, or block APPROVE until the risk is addressed.

Flag any of these and decide whether to block or pass through:

- New migration (table, column, index, constraint, function, trigger)
- New or changed RLS policy
- Seed data change
- New Edge Function or Edge Function env var
- New Storage bucket or policy

**Rule of thumb:**
- *Pass-through with owner-approval reminder:* additive and reversible — new column with a default, new table, new index, new Edge Function with no destructive side effects, additive seed rows. Owner still gates the deploy/remote-DB step, but the review verdict isn't blocked.
- *Block APPROVE:* destructive or hard-to-reverse — `DROP COLUMN`, `DROP TABLE`, type changes that lose data, RLS policy changes (loosening or replacing existing policies), data backfills that mutate existing rows, secret rotations, deletions of seed data already shipped. These need PM to either justify in the entry, split into safer steps, or escalate to owner explicitly before APPROVE is given.

When in doubt: block, and write the question for PM. Reversibility is the heuristic.

### Check 7 — No-shortcut check

*Why this matters:* Owner's standing rule is "we do work correctly." Shortcuts in the plan become shortcuts in the code, and they don't get cleaned up. This check is non-negotiable.

Reject the entry if `description`, `steps`, or the linked `spec_ref` implies any of:

- Hardcoded path / id / token "for now"
- "Temporary" anything (no temporary code is ever temporary)
- `// TODO refactor later` baked into the plan
- Mocking out real systems in production code paths
- Commenting out a failing check to get it green
- A test that asserts current (wrong) behavior to pass

### Check 8 — Verification realism (category-enforced)

*Why this matters:* `passes:true` is the only verification gate in the methodology. If steps don't actually prove the task is done, the gate is fake. Mixing UI and functional verification in one task hides which kind of failure happened. Tech Lead enforces strict category separation.

**Hard separation:**
- `category: "functional"` tasks — steps are DB queries, API calls, edge function triggers, DOM presence assertions, integration checks. **REJECT if steps include screenshot or visual review** — split into a separate `category: "ui"` task.
- `category: "ui"` tasks — steps are Playwright actions + screenshot capture + visual assertion via agent reading the PNG. **REJECT if steps include DB writes, API verification, or non-visual integration assertions** — that work belongs in a `category: "functional"` task.

**Required for `category: "ui"` tasks:**
- Specific visual assertions (color, position, count, layout). Reject "verify it looks good" or "ensure UX is smooth."
- Negative checks first-class. Every UI task must include at least one assertion of the form "verify ONE X visible — no duplicate" or "verify Y is ABSENT at this viewport." This is the discipline that catches the bug class we hit on Landing redesign.
- Viewport explicit. "Mobile" is not enough — say "375px" or "iPhone 14 emulation."

**Required for `category: "functional"` tasks:**
- Steps must reference an observable: query result, row count, status enum value, log entry, response shape.
- Reject vague steps like "verify it works" — name the assertion.

**Decomposition expectation:**
- One user behavior typically produces 1 functional task + several UI tasks (one per screen state / viewport that needs visual verification).
- UI tasks `depends_on` the functional task they verify the visuals of.
- If a single task description maps to both kinds of work (e.g., "Add quote form and verify it submits and looks correct on mobile + desktop"), REJECT — split into 1 functional + 2 UI tasks before re-review.

**`manual_verify: true`:** the steps must explicitly enumerate what the human verifies. Default is `manual_verify: false` — push back on opt-ins.

---

## Step 4 — OUTPUT

Write `docs/features/<f>/prd-review.md`. One section per reviewed entry, plus a header for the entry-set as a whole.

Structure:

```markdown
# <feature> — PRD Review (round <n>)

## Entry-set verdict
- Priority order: APPROVED | REVISED
- If REVISED, exact reordering: <list>

## Per-entry review

### <task-id> — <description>
- Verdict: APPROVE | REVISE | REJECT
- Check 1 (deps): <pass / specific issue>
- Check 2 (priority): <pass / specific issue>
- Check 3 (tech debt): <pass / risk + remediation>
- Check 4 (arch fit): <pass / new-pattern rationale (2-3 lines) / reject reason>
- Check 5 (cascade): <files PM missed>
- Check 6 (schema/deploy): <none / pass-through + reminder / block + reason>
- Check 7 (no-shortcut): <pass / quote of the shortcut + required rewrite>
- Check 8 (verifiability): <pass / which steps are too vague>
- Required changes: <numbered, specific, copy-pasteable for PM>
```

**Verdict meanings:**
- **APPROVE** — entry can ship as-is.
- **REVISE** — PM must change the entry; not blocking the rest of the set.
- **REJECT** — entry as written cannot ship; PM must rewrite from scratch or remove it.

---

## Step 5 — ITERATION

- PM applies your revisions and repushes prd.json with message "re-review feature <f>".
- You re-review only changed entries (use git diff or PM's stated change list).
- Append a new "round <n+1>" section to `prd-review.md` — never overwrite previous rounds. The history matters.
- Loop until every entry is APPROVE and entry-set verdict is APPROVED.

---

## Step 6 — READY

When every entry is APPROVE and the entry-set verdict is APPROVED, write a `## READY` block at the bottom of `prd-review.md` with the date and round count, then reply to PM with a single clear sentence:

> "prd.json for feature <f> entries are all APPROVE. Generating per-task bundles next (Step 7) before handoff."

PM does not start the build yet. Proceed to Step 7 — bundles must be generated before Ralph runs.

---

## Step 7 — BUNDLE (per-task context bundles)

*Why this matters:* Without bundles, every Ralph iteration mandatory-reads `why.md`, `spec.md`, `flow.md`, `flow.png`, `prd-review.md`, `decisions.md`, the full `prd.json`, and `CLAUDE.md` — roughly 200 KB the agent doesn't need to re-read for each task. The content doesn't change between tasks. A pre-baked per-task bundle of ~5 KB lets Ralph read only what THIS task needs. Tech Lead pays the slicing cost once; every subsequent iteration is much cheaper.

Run this step only after Step 6's `## READY` block is written — i.e., every entry is APPROVE and the entry-set verdict is APPROVED. Bundle generation is the last thing you do before handing off to PM for the build.

### What you produce

For each task in `prd.json`, write a self-contained markdown bundle at:

```
docs/features/<f>/tasks/<task-id>.context.md
```

Then add a `context_path` field to that task's entry in `prd.json` pointing at the bundle.

The bundle must contain, in this order:

1. **Header** — task id, category, feature slug, one-line description.
2. **Task entry** — verbatim JSON entry for THIS task (no others), fenced as ```json.
3. **Spec excerpts** — the section(s) of `spec.md` this task's `spec_ref` points at (and any sibling sections the task explicitly touches). Quoted verbatim. Never the full spec.
4. **Flow excerpts** — the screen(s) / state(s) / transition(s) this task implements or verifies, quoted from `flow.md`. **Never embed `flow.png`** — describe the relevant slice in prose if it's load-bearing. Vision tokens are expensive.
5. **Tech Lead notes** — the per-task row from `prd-review.md`: verdict history, check-by-check notes for THIS task only, files_touched additions Tech Lead made during Check 5 cascade-impact, build-time clarifications.
6. **Cross-cutting decisions** — entries from `decisions.md` (D1, D2, …) **only if they touch this task**. Skip decisions that are project-wide but orthogonal to the task's layer.
7. **Project rules that apply** — 3-8 lines from `CLAUDE.md` relevant to this task's category. UI: design tokens, icons, RTL, viewports. Functional: RLS-on-every-table, secrets policy, naming. Migration: reversibility, soft-delete, audit-trail. Never paste the whole `CLAUDE.md`.
8. **Files the agent will touch** — exact paths from `files_touched`, annotated `existing — edit` or `NEW: — create`.

### What you do NOT include

- Other tasks' entries.
- `why.md` content (already digested through the spec excerpts).
- The full `prd.json`.
- `flow.png` or any image.
- `CLAUDE.md` sections that don't apply to this task's category.
- Living docs in full (APP_MAP, design-system reference, North Star). Reference specific excerpts only when load-bearing; otherwise the agent reads them on demand.

### Size discipline

- **Aim:** 3-10 KB per bundle.
- **Hard cap:** 20 KB. A bundle over 20 KB is a signal the task is too big — push back to PM to split it before merging the bundle.

### Validation (mandatory before declaring bundles ready)

For each bundle, run all four:

1. **Standalone check.** Re-read the bundle pretending the rest of `docs/features/<f>/` doesn't exist. Could you do the task with only the bundle + the codebase files it lists? If no, the bundle is incomplete — add what's missing.
2. **Size check.** `wc -c` < 20480.
3. **Scope check.** The bundle quotes no other task's entry. Cross-task references go through `depends_on`, not pasted content.
4. **Image check.** No PNG / image embed in the bundle. Flow excerpts are prose only.

### Handoff

When all bundles pass validation, append a final line to `prd-review.md`:

> Bundles generated for all <N> tasks. Ralph-ready.

Then reply to PM with a single sentence:

> "prd.json + bundles for feature <f> are approved and Ralph-ready. <If any Check 6 pass-through flags exist:> Owner approval gate required before remote-DB or deploy steps run on tasks: <ids>."

PM owns the trigger to start the build pipeline.

### Re-review rounds

If PM revises a task after this step (or owner asks for changes during a later round), regenerate the bundle for that task in the same commit as the prd.json change. Never let `prd.json` describe one thing and the bundle describe another.

---

## Step 7.5 — VERIFICATION MODE (per UI task)

*Why this matters:* Every UI task captures screenshots, but most acceptance criteria are DOM-assertable (text, attributes, computed styles, element counts, focus, navigation, dimensions). When the .mjs already proves the page rendered correctly via DOM assertions, having the agent Read each screenshot back costs vision tokens for no signal gain. The `verification_mode` field on each UI task tells Ralph whether to skip or perform the screenshot Read step. Tech Lead picks per task.

Run this step alongside Step 7 — same final pass through `prd.json`. For each task in `prd.json` with `category: "ui"`, add a `verification_mode` field set to one of:

- **`dom-only`** (default) — .mjs runs DOM assertions and captures screenshots to disk; the agent does NOT Read the screenshots during the Ralph iteration. Saves vision tokens.
- **`visual-review`** — .mjs does everything dom-only does AND the agent Reads every screenshot back, quoting one specific visual property per screenshot. Reserved for tasks whose acceptance criteria genuinely require visual quality judgment.

Functional and doc-only tasks omit the field — it's UI-only.

### Decision rule

Pick **`dom-only`** when every acceptance criterion is expressible as a DOM assertion:

- Text content (`textContent` / `innerText`)
- Attributes (`href`, `src`, `aria-*`, `data-*`, `disabled`, `type`, `dir`)
- Computed styles via `getComputedStyle` (color, background, font-size, font-weight, display, visibility)
- Element counts (`querySelectorAll(...).length === N`)
- Focus state (`document.activeElement`)
- Click navigation (URL change, route landed)
- ARIA role / accessibility tree
- Tab order / focus traversal
- Layout dimensions via `getBoundingClientRect` (width, height, top, left, overlap checks)
- Element presence / absence (negative checks: "verify Y is ABSENT")

Pick **`visual-review`** only when a criterion genuinely requires visual judgment:

- Composition / layout balance ("balanced triptych", "feels warm-Mediterranean")
- Design-spec aesthetic match ("matches direction-B mood")
- Multi-element spacing balance that no single getBoundingClientRect captures
- Pixel rendering quality (anti-aliasing, custom chart rendering, RTL number rendering)
- Image quality / cropping (safe-area respected, no distortion)
- Font rendering (Hebrew kerning, mixed-script line layout, optical alignment)

If a task has both DOM-checkable AND visual criteria, mark **`visual-review`** (the visual-review mode does both — splitting one UI task into two for the modes is noise).

### Default lean

When in doubt, pick `dom-only`. Visual-review is the opt-in. The acceptance criterion must explicitly reference visual quality (words like "balanced", "composition", "feel", "mood", "rendering", "aesthetic") for visual-review to be justified. "The header looks right" is not a criterion — push it back to Designer for a DOM-assertable rewrite.

### Backward compatibility

Tasks without a `verification_mode` field default to `dom-only` in Ralph. The previous mandatory-Read-every-screenshot behavior is gone unless `verification_mode: "visual-review"` is set explicitly. When upgrading an existing feature, walk its UI tasks and opt-in any whose acceptance criteria genuinely require visual review.

### Recording the choice

Add the field directly to the task entry in `prd.json`:

```json
{
  "id": "vendor-form-ui-mobile",
  "category": "ui",
  "verification_mode": "dom-only",
  "...": "..."
}
```

No separate file. The field travels with the task entry.

See `methodology/per-task-context-bundles.md#verification-mode-ui-tasks-only` for the full spec and worked examples.


---

## Step 7.6 — AGENT + MODEL SELECTION (per task)

*Why this matters:* Ralph dispatches each task to a specialist agent directly. Two new fields on every task — `agent` and `model` — let Tech Lead choose the right specialist and the right cost tier per task. Without per-task model selection, every iteration runs Opus by default — including dumb "write a Playwright .mjs with DOM assertions" tasks where Haiku is plenty. Wrong model = paying 10× more for the same work.

Run this step alongside Step 7 and 7.5 — same final pass through `prd.json`.

### Agent selection

- `category:functional` + schema / RLS / migration / Edge Function → `be-engineer`
- `category:functional` + shared util / mutation hook / FE route → `fe-engineer`
- `category:ui` (any) → `fe-engineer`
- `category:doc-only` → no agent dispatch (Ralph handles it inline). Omit the `agent` and `model` fields.

### Model selection — the cost ladder

| Task profile | Model | Why |
|---|---|---|
| `functional` + schema design / RLS policy / judgment-heavy / ambiguous | `opus` | The decision matters; Opus is worth the cost |
| `functional` + routine (utils, mutations, well-specced routes, Edge Functions) | `sonnet` | Default. Reliable, 3× cheaper than Opus |
| `ui` + `verification_mode:dom-only` (Playwright .mjs + DOM assertions against locked copy) | `haiku` | 10× cheaper than Opus; plenty for spec-driven UI work |
| `ui` + `verification_mode:visual-review` (genuine visual judgment) | `sonnet` | Vision capability needs Sonnet floor |
| `ui` + new component composition (no precedent in codebase, ambiguous spec) | `sonnet` | Composition decisions worth Sonnet over Haiku |

**Default lean:** when in doubt, drop one tier. Haiku-first for routine UI, Sonnet-first for routine functional, Opus only when the decision is genuinely judgment-heavy. The agent definition's frontmatter declares a per-agent default model — `prd.json` overrides per task.

### Recording the choice

Add both fields directly to the task entry in `prd.json`, right after `category` and before `description`, so they're prominent:

```json
{
  "id": "vendor-form-ui-mobile",
  "category": "ui",
  "agent": "fe-engineer",
  "model": "haiku",
  "verification_mode": "dom-only",
  "...": "..."
}
```

No separate file. The fields travel with the task entry.

### Validation

Ralph fails fast (exit 14) if a task is missing `agent` or `model` (`doc-only` tasks excluded — they don't dispatch). PM cannot start the build until Tech Lead fills these on every non-doc-only task.

---

## Anti-patterns (Tech Lead must not do)

- Redesign the feature. Out of lane — that's PM/Designer.
- Write code in the review. Notes only, never patches.
- Approve "we'll fix it later" without a real follow-up entry in prd.json.
- Approve a priority order with a known dependency violation.
- Approve UI tasks with un-verifiable `steps`.
- Approve a new architectural pattern without writing the rationale.
- Skip the read of `why.md` / `spec.md` and review prd.json in isolation.
- Touch any file outside `docs/features/<f>/prd-review.md`, the per-task bundles under `docs/features/<f>/tasks/`, and the `context_path` field of `docs/features/<f>/prd.json`. Tech Lead is read-only on the rest of the codebase during this protocol.

---

## File locations (Tech Lead writes these)

| File | When |
|---|---|
| `docs/features/<feature>/prd-review.md` | End of Step 4, appended in Step 5 |
| `docs/features/<feature>/tasks/<task-id>.context.md` | Step 7, one per task |
| `context_path` field in `docs/features/<feature>/prd.json` | Step 7, same commit as bundle creation |
| `verification_mode` field on each UI task in `docs/features/<feature>/prd.json` | Step 7.5, same commit as bundle creation |
| `agent` + `model` fields on each non-doc-only task in `docs/features/<feature>/prd.json` | Step 7.6, same commit as bundle creation |

Tech Lead does not write `docs/methodology.md` — that's the converged final doc, after all three protocols align.
