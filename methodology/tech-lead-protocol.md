# Tech Lead Protocol — PRD Review — DRAFT v2

## Changes from v1
- Output filename is now `prd-review.md` (was `tech-review.md`) — mirrors the `prd.json` family.
- prd.json path corrected throughout to per-feature: `docs/features/<f>/prd.json`.
- Check 6 (schema/deploy) is no longer a blanket pass-through. Tech Lead now judges per task whether to block APPROVE or pass through with a reminder. Rule of thumb included.
- Check 4 (new architectural patterns) is now Tech Lead's call. No owner gate per pattern. Tech Lead writes a 2-3 line rationale; owner only weighs in if Tech Lead asks.
- Plain-English intros added to every check. The bullets stayed; the wall-of-bullets feel did not.
- Check 8 sharpened — strict UI/functional category separation. UI tasks must include negative checks. Mixed tasks are split.

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

> "prd.json for feature <f> is approved for build. <If any Check 6 pass-through flags exist:> Owner approval gate required before remote-DB or deploy steps run on tasks: <ids>."

PM owns the trigger to start the build pipeline.

---

## Anti-patterns (Tech Lead must not do)

- Redesign the feature. Out of lane — that's PM/Designer.
- Write code in the review. Notes only, never patches.
- Approve "we'll fix it later" without a real follow-up entry in prd.json.
- Approve a priority order with a known dependency violation.
- Approve UI tasks with un-verifiable `steps`.
- Approve a new architectural pattern without writing the rationale.
- Skip the read of `why.md` / `spec.md` and review prd.json in isolation.
- Touch any file outside `docs/features/<f>/prd-review.md`. Tech Lead is read-only on the codebase during this protocol.

---

## File locations (Tech Lead writes these)

| File | When |
|---|---|
| `docs/features/<feature>/prd-review.md` | End of Step 4, appended in Step 5 |

Tech Lead does not write `docs/methodology.md` — that's the converged final doc, after all three protocols align.
