# Per-Task Context Bundles — Protocol

**Status:** v1. Added 2026-05-12 in response to observed Ralph per-iteration cost.

---

## Why bundles exist

Before this protocol, every Ralph iteration mandatory-read seven files from `docs/features/<f>/` — `why.md`, `spec.md`, `flow.md` (and frequently `flow.png`), `prd-review.md`, `decisions.md`, the full `prd.json`, plus the project-wide `CLAUDE.md`. For a feature with 50+ tasks, that meant the same ~200 KB of context flowed through the model 50+ times. The content did not change between iterations. Most of it had nothing to do with the specific task the loop driver had just picked.

The fix is a one-time slicing pass at Tech Lead review time: for each task in `prd.json`, the Tech Lead pre-bakes a small standalone context file containing only what that task needs. Ralph then reads the bundle and the codebase files the bundle references — nothing else.

Heavy planning, cheap execution. Tech Lead spends a few extra minutes during review; the loop drops most of its redundant input cost across every subsequent iteration.

---

## What a bundle contains

Each task in `prd.json` is paired with a `tasks/<task-id>.context.md` file under the same feature folder. The bundle is self-sufficient: an agent reading only the bundle and the codebase files it lists must be able to do the task end-to-end.

A bundle is a markdown file with these sections, in this order:

1. **Header** — task id, category, feature slug, one-line description.
2. **Task entry** — the task's exact entry from `prd.json` (id, category, description, depends_on, steps, files_touched, spec_ref, passes), pasted verbatim as a fenced JSON block so the agent has the canonical source.
3. **Spec excerpts** — only the sections of `spec.md` referenced by this task's `spec_ref` (and any sibling sections the task explicitly touches). Quoted with the section anchor preserved. Do not paste the full spec.
4. **Flow excerpts** — only the screen(s) / state(s) / transition(s) this task implements or verifies. Quoted from `flow.md`. If the flow has a rendered diagram, do not embed the PNG — describe the relevant slice in prose. Vision tokens are expensive.
5. **Tech Lead notes** — the per-task row from `prd-review.md`: verdict history (APPROVE / REVISE / REJECT), check-by-check notes for THIS task only, files_touched additions Tech Lead made during cascade-impact review, build-time clarifications.
6. **Cross-cutting decisions** — entries from `decisions.md` (e.g. D1, D2...) only if they touch this task. If a decision applies project-wide but is genuinely orthogonal to this task, leave it out. Err on the side of inclusion when the task is in the affected layer.
7. **Project rules that apply** — short, copy-pasted lines from the project's `CLAUDE.md` (or the bootstrapped equivalent) that are relevant to this task category. UI tasks get the visual / icon / RTL rules. Functional tasks get the schema / RLS / Edge Function rules. Do not paste all of `CLAUDE.md`; pick the 3-8 lines that matter for this task.
8. **Files the agent will touch** — the exact paths from `files_touched`, annotated as "existing — edit" or "NEW: — create". This is the agent's WRITING list.
9. **Files the agent must read (then stop)** — explicit READING list, separate from #8. For each entry: file path, optional line range, one-line reason. Include only files that are LOAD-BEARING for understanding (the route being extended, a sibling pattern to mirror, a fixture API to use). Do NOT include CLAUDE.md, why.md, spec.md, flow.md, prd-review.md, or the bundle itself — those are not on disk reads (CLAUDE.md is in the agent's system prompt; the others are not in scope). The agent's discipline is: read every file on this list, then stop. Do not glob the project, do not read package.json unless listed, do not read fixtures.ts unless listed. If something is genuinely unclear after reading the list, the agent should note that in its report so Tech Lead can fix the bundle.
10. **Shared type augmentations / ambient declarations.** If the task uses a global API (e.g., `window.X` in TS) declared in an ambient `.d.ts` file, name the path. The agent must reference the existing declaration, never re-author one inline.

---

## What a bundle does NOT contain

- Other tasks' entries from `prd.json`. The agent only sees its own task.
- `why.md` content. The WHY has already been digested through `spec.md` excerpts. If a build agent needs the why, the methodology failed and the spec needs revising.
- The full `prd.json`. Just this task's entry, fenced.
- Rendered `flow.png` images. Vision tokens are far more expensive than text. Describe the slice in prose instead.
- Project-wide `CLAUDE.md` sections that don't apply to this task's category. Functional schema rules in a UI task is noise.
- Living docs (`APP_MAP.md`, design-system reference, North Star) in full. The bundle may reference specific excerpts when they're load-bearing for this task; otherwise the agent reads them from disk on demand.

---

## Where bundles live

Per feature: `docs/features/<feature>/tasks/<task-id>.context.md`.

Each task entry in `prd.json` carries a `context_path` field pointing at its bundle:

```json
{
  "id": "vendor-form-submission-functional",
  "category": "functional",
  "description": "POST /vendors creates row + triggers WhatsApp send",
  "depends_on": ["add-vendors-table-migration"],
  "files_touched": ["..."],
  "spec_ref": "docs/features/couple-add-vendor/spec.md#submission",
  "context_path": "docs/features/couple-add-vendor/tasks/vendor-form-submission-functional.context.md",
  "passes": false
}
```

Bundles live in markdown, not inline in `prd.json`, because:
- `prd.json` stays small and diffable when bundles change.
- Agents read markdown more cheaply than escaped JSON strings.
- Bundles can be regenerated by Tech Lead during re-review rounds without churning the prd.json structure.
- PR reviewers can read the bundle directly in GitHub's diff view.

---

## Size target

- **Aim:** 3-10 KB per bundle.
- **Hard cap:** 20 KB. A bundle larger than 20 KB is a signal the task is too big — split it before review.
- **Lower bound:** there is none. A trivial `doc-only` task may have a 1 KB bundle. That's fine.

Compared to the old ~200 KB per iteration (seven mandatory reads plus `CLAUDE.md`), a 5 KB bundle is roughly 40x smaller. Over a 50-task feature, that compounds.

---

## How the Tech Lead generates bundles

After every task in `prd.json` is APPROVE and `prd-review.md` has the `## READY` block, Tech Lead does one final pass:

1. Read `prd.json` once. For each task:
2. Open `spec.md` and slice the sections the task's `spec_ref` anchor (and any sibling sections the task description names) point at. Copy them verbatim into the bundle.
3. Open `flow.md`. Identify the screen / state / transition the task implements or verifies. Copy that slice. If a Mermaid diagram is present, copy the relevant nodes only, not the whole diagram.
4. Pull the task's row from `prd-review.md` — every check's verdict for THIS task, plus any build-time clarification Tech Lead recorded. Paste it.
5. Open `decisions.md` (if it exists for this feature). Include each decision only if the task lives in the layer that decision constrains. Skip otherwise.
6. From `CLAUDE.md`, pick the 3-8 lines that matter for this task's category. UI tasks: design tokens, icon rules, RTL conventions, viewport conventions. Functional / schema tasks: RLS-on-every-table, secrets policy, naming conventions, Edge Function patterns. Migration tasks: reversibility / soft-delete / audit-trail rules.
7. Write the file at `docs/features/<f>/tasks/<task-id>.context.md`.
8. Add `context_path` to the task's entry in `prd.json`.

### Validation (Tech Lead must run before declaring bundles ready)

- **Standalone check.** Re-read the bundle pretending you don't have the rest of the feature folder. Could you do the task? If no, the bundle is incomplete — add what is missing.
- **Size check.** Use `wc -c` on the file. Under 20 KB or rework.
- **Scope check.** Does the bundle quote any task other than this one? If yes, remove it. Cross-task references go through `depends_on`, not pasted content.
- **Image check.** If `flow.md` referenced a PNG and the bundle includes it, replace with a prose description.

---

## How Ralph consumes bundles

The Ralph loop driver reads `prd.json` to pick the next task as before. The agent invocation prompt now passes the bundle path. The agent is instructed:

> Your task's full context is in `<bundle path>`. Read it once. Read the files in its "Files the agent will touch" section. Do NOT re-read `why.md`, `spec.md`, `flow.md`, `flow.png`, `prd-review.md`, `decisions.md`, or the full `prd.json` unless the bundle explicitly tells you to.

If the bundle is missing or its `context_path` is empty (legacy `prd.json` from before this protocol existed), Ralph falls back to the old mandatory-reading list. This keeps existing features building without retroactive bundle generation. New features generated under this protocol always have bundles; old features get them only if owner asks Tech Lead to re-review and bundle.

---

## Migration / backward compatibility

`prd.json` files generated before this protocol have no `context_path` field on any task. Ralph detects this and reverts to the legacy mandatory-reading list (`why.md`, `spec.md`, `flow.md`, `prd-review.md`, `decisions.md` if present, full `prd.json`, `CLAUDE.md`).

To upgrade an existing feature to bundles:
1. Owner asks Tech Lead: "generate bundles for feature `<f>`".
2. Tech Lead runs the bundle-generation step against the existing approved `prd.json` and writes the bundles.
3. Tech Lead adds `context_path` to each task entry in `prd.json` and commits.
4. The next Ralph run picks up the bundles automatically.

There is no flag day. Bundles roll out per feature, opt-in.

---

## Anti-patterns

- **Pasting the entire `spec.md` into every bundle.** Defeats the purpose. Slice.
- **Including other tasks' entries** so the agent "has context for the whole feature". The whole point is the agent does not need that context.
- **Embedding `flow.png` in the bundle.** Vision tokens are expensive. Describe the relevant slice in prose.
- **Skipping the standalone validation check.** A bundle that silently relies on the agent re-reading `spec.md` is a bundle that does not work.
- **Bundles over 20 KB.** That is a signal the task is too big. Push back to PM to split before approving.
- **Letting `prd.json` and bundles drift.** When a task is revised, regenerate its bundle in the same commit. Never let `prd.json` describe one thing and the bundle describe another.

---

## Verification mode (UI tasks only)

UI tasks come in two flavors. Tech Lead picks one per task during bundle generation.

Both flavors run the same Playwright .mjs script. The .mjs always captures screenshots to `screenshots/<task-id>/<viewport>.png` for on-disk human review. **The difference is whether the AGENT reads those screenshots back via the Read tool during the Ralph iteration.** Vision tokens on a single 375x812 screenshot Read cost roughly 1500-3000 tokens. Multiplied across every UI task in a feature, this dominates the per-iteration cost — and most of it is wasted when every acceptance criterion is already covered by DOM assertions in the .mjs.

### The two values

- **`dom-only`** (default) — The .mjs script runs all DOM assertions (text content, attributes, computed styles, element counts, focus state, navigation, ARIA roles, getBoundingClientRect dimensions). The .mjs takes screenshots and writes them to disk for human review. **The agent does NOT Read the screenshots back.** If .mjs exits 0 and the screenshot files exist on disk, the task passes. The screenshots are there for the owner to eyeball post-hoc if they choose, not for the agent to interpret.

- **`visual-review`** — Everything `dom-only` does, plus the agent MUST Read every screenshot back via the Read tool and quote one specific visual property per screenshot (e.g., "the success card occupies roughly the upper third of the viewport with the CTA flush to the right edge"). Reserved for tasks whose acceptance criteria genuinely require visual quality judgment that DOM assertions cannot express.

### Decision rule

Pick `dom-only` when every acceptance criterion is expressible as a DOM assertion:

- Text content (`textContent`, `innerText`)
- Attributes (`href`, `src`, `aria-*`, `data-*`, `disabled`, `type`)
- Computed styles via `getComputedStyle` (color, background, font-size, font-weight, display, visibility)
- Element counts (`querySelectorAll('button').length === 1`)
- Focus state (`document.activeElement`)
- Click navigation (URL changes, route landed)
- ARIA role / accessibility tree
- Tab order (focus traversal)
- Layout dimensions via `getBoundingClientRect` (width, height, top, left, overlap checks)
- Element presence / absence (negative checks: "verify Y is ABSENT at this viewport")

Pick `visual-review` only when a criterion genuinely requires visual judgment:

- Composition / layout balance ("the three feature cards form a balanced triptych")
- Design-spec aesthetic match ("matches the warm-Mediterranean direction-B mood")
- Multi-element spacing balance that no single getBoundingClientRect captures
- Pixel rendering quality (anti-aliasing on a custom-rendered chart, RTL number rendering edge case)
- Image quality / cropping (vendor logo respects safe-area, no distortion)
- Font rendering (Hebrew kerning, mixed-script line layout)

### Mixed criteria

If a task has both DOM-checkable and visual criteria, **mark `visual-review`**. The visual-review mode is a strict superset of dom-only — it does both. Splitting one UI task into "the dom-only half" and "the visual half" produces two tasks that ship together; that's noise, not separation.

### Default lean

When in doubt, pick `dom-only`. Visual-review is the opt-in. The acceptance criterion must explicitly reference visual quality (using words like "balanced", "composition", "feel", "mood", "rendering", "aesthetic") for visual-review to be justified. "The header looks right" is not a criterion — push back to Designer for a DOM-assertable version.

### Examples

**`dom-only` — vendor login phone screen at 375px**
- One H1 visible with text "התחברות"
- One phone input with `type="tel"` and `dir="ltr"`
- One submit button labeled "המשך" with the primary variant class
- No back button visible (verify ABSENT)
- Submit disabled while input is empty (`disabled` attribute), enabled after 10 valid digits

Every assertion is DOM. Screenshots go to disk for the owner to scan post-merge if curious. `dom-only`.

**`dom-only` — error toast on network failure**
- Toast container visible with the `destructive` variant class
- Toast text contains "אירעה שגיאה" or the localised network-failure string
- Toast auto-dismisses after the configured ms (timeline assertion)
- Submit CTA remains enabled after toast appears

DOM-only — the toast's visual styling is governed by the variant class, which IS the DOM assertion.

**`visual-review` — landing-page hero at 1280px (Direction B redesign)**
- The three feature cards form a balanced triptych with consistent inter-card spacing AND each card's image-to-text ratio matches the design spec's warm-Mediterranean feel
- Hebrew headline kerns correctly with the latin-mixed sub-headline (no visible tracking artifacts)
- Hero image crops the bride-and-groom safe-area correctly across breakpoints

These criteria require seeing the pixels. Visual-review.

**`visual-review` — onboarding success illustration**
- The illustration's color palette matches the design tokens within JND
- The illustration aligns optically (not just geometrically) with the headline beneath it

Optical alignment is a visual judgment — geometric `getBoundingClientRect` does not capture it. Visual-review.

### Backward compatibility

Tasks written before this protocol existed have no `verification_mode` field. Ralph defaults to `dom-only` when the field is missing — i.e., the cheap path. The previous mandatory-Read-every-screenshot behavior is gone unless a task explicitly sets `verification_mode: "visual-review"`. Existing approved bundles continue to build; tasks that genuinely needed visual review must have their entries updated to opt in.

### What the .mjs does (unchanged)

Regardless of mode, the .mjs:
- Runs at the explicit viewport (e.g., 375px, 1280px) — never "mobile" as a vague label
- Captures screenshots to `screenshots/<task-id>/<viewport>.png`
- Asserts negative checks first-class ("verify ONE submit button — no duplicate")
- Exits 0 on pass, non-zero on fail

The only thing the mode changes is whether the agent calls Read on the screenshot files after the .mjs exits.


---

## File locations (Tech Lead writes these)

| File | When |
|---|---|
| `docs/features/<feature>/tasks/<task-id>.context.md` | Once per task, after the `## READY` block in `prd-review.md`, before declaring bundles ready. |
| `context_path` field in `docs/features/<feature>/prd.json` | Same commit as bundle creation. |
