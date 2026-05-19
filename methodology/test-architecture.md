# Test Architecture Standard

**Status:** v1 — 2026-05-19. Living doc.

## Why this exists

This standard codifies how end-to-end tests are written in projects using this methodology. It replaces the v0 pattern (`.mjs` standalone Node scripts that re-implemented browser launch + env parsing + auth + DB cleanup inline) which produced 500+ line spec files, sequential-only execution, accidental full-table DELETEs, and no clear scenario boundaries.

The v0 pattern was an honest first try. The v1 standard below is the post-shipped pattern proven across one full migration (~31 `.mjs` files → ~26 focused `.spec.ts` files, ~85 new tests passing, ~3-5× wall-clock speedup, zero full-table DELETEs).

This doc is **what to require**, not what to discover. Tech Lead, FE, and BE engineers consume these rules. Test files that violate them get rejected at review.

---

## The seven locked rules

### 1. One shared `e2e/fixtures.ts` module

A single file that extends Playwright's `test` with project-wide fixtures. Every spec imports from it. **NEVER** re-implement env parsing, Supabase/DB client construction, JWT signing, image bytes, or auth-cookie attach inside a spec file. The fixtures handle these once.

Minimum exports:

- `test` — `base.extend<Fixtures>(...)`
- `expect` — re-exported from `@playwright/test`
- `BASE_URL` — the dev server URL
- `testTag` fixture — per-test unique prefix (UUID-based); seeded data MUST start with it
- `trustedPage` fixture — Playwright `Page` with the project's auth cookie pre-attached
- Domain seed helpers — `seedItem`, `seedEntry`, etc. — that auto-prefix identifiers with `testTag`
- Domain-specific bytes (e.g., a minimal valid JPEG buffer for image-upload tests)
- `afterEach` cleanup hook that deletes ONLY rows where the identifier `LIKE testTag || '%'`

### 2. testTag isolation contract (absolute — NEVER full-table DELETE)

Every test that seeds data MUST prefix every seeded row's identifier (title, description, or test-marker field) with the `testTag` fixture value. The afterEach cleanup MUST delete ONLY rows where the identifier matches `testTag || '%'`.

This is what makes `workers: N > 1` safe. Two specs running in parallel use different `testTag` values, operate on different rows, can't trip over each other.

**Forbidden:**
- `DELETE FROM <table>` (no WHERE clause)
- `.delete().not("id", "is", null)` (matches everything)
- `TRUNCATE <table>`
- Any cleanup that doesn't filter by `testTag`

If a scenario fundamentally requires "empty table" (e.g., "the list is empty" UI state), construct an empty filtered view (filter by a guaranteed-no-match string like `testTag`) instead of emptying the real table.

### 3. `fullyParallel: true` + explicit `workers: N`

`playwright.config.ts` MUST set `fullyParallel: true` and an explicit `workers: N` (typically 4 on a 4+ core dev machine; tune per CPU). Tests in the same file CAN run concurrently; specs ARE dispatched across workers.

Sequential execution is the v0 anti-pattern. Tests that can't run in parallel signal a missing testTag isolation contract — fix the test, don't disable parallelism.

### 4. File-splitting rule — one scenario cluster per file

Each `.spec.ts` file MUST hold ONE clearly-named scenario cluster — 1 to 4 `test()` blocks max. A reader opening any file should answer "what does this test?" in 5 seconds without scrolling.

**Forbidden:**
- Mega-files with 10+ `test()` blocks across unrelated scenarios
- File names like `*-cross-screen-*` or `*-everything-*` that bundle scenarios under one umbrella
- Spec files over ~150 lines (signal: you're bundling)

**Required:**
- Each test file ≤ ~150 lines
- Each `test()` block ≤ ~25 lines
- Scenario-specific file names (kebab-case, describes the scenario, not the surface)

Example split: a single 554-line `catalog-toasts-cross-screen-ui-mobile.spec.mjs` with 14 unrelated toast scenarios → 9 focused files (`catalog-toast-create.spec.ts`, `catalog-toast-delete.spec.ts`, `catalog-toast-image-upload.spec.ts`, …) of ~60-100 lines each, 1-3 tests per file.

### 5. Naming convention

Kebab-case, scenario-specific, no surface-mega-buckets. Pattern: `<feature>-<scenario>.spec.ts` or `<feature>-<scenario>-ui.spec.ts` when distinguishing functional from visual.

- ✅ `catalog-toast-create.spec.ts`
- ✅ `pin-ui.spec.ts` (UI-specific assertions for the PIN screens)
- ✅ `entry-form-expense.spec.ts`
- ❌ `catalog-toasts-cross-screen-ui-mobile.spec.mjs` (the v0 mega-name)
- ❌ `everything-related-to-images.spec.ts`

### 6. Dedup precedes split (audit before migrating or adding tests)

Before adding a new spec OR migrating an old one, audit existing specs that cover the same area.

- If existing specs ALREADY cover all the scenarios you'd add → don't add the new file. Add focused `test()` blocks to the existing file (if it fits the splitting rule) OR drop the proposed new file entirely.
- If existing specs cover PART → add only the unique scenarios as a focused new file (`<base>-ui.spec.ts` or similar).
- If no overlap → write per the splitting rule.

**During a `.mjs` → `.spec.ts` migration**: if a `.mjs` duplicates its sibling `.spec.ts` (same scenarios, just with screenshots), DELETE the `.mjs` outright. Do NOT create a target file. Migration is for moving forward, not preserving duplicates.

### 7. Ralph / agent dispatch via Playwright runner, never via `node`

Build agents and Ralph dispatch UI verification via:

```
npx playwright test e2e/<spec>.spec.ts --grep "<test-name>" --reporter=line
```

NEVER `node e2e/<spec>.mjs`. The Playwright runner provides the parallelism + isolation guarantees the standard depends on. `node` invocations bypass the project config entirely and re-introduce v0 problems.

---

## Anatomy of a good spec file

```ts
import { test, expect } from "./fixtures";

test.describe("catalog item delete — modal", () => {
  test("modal opens; body shows item.title; confirm disabled on empty input", async ({
    trustedPage,
    testTag,
    seedItem,
  }) => {
    const item = await seedItem({ title: `${testTag} chocolate cake` });
    await trustedPage.goto(`/management/items/${item.id}`);
    await trustedPage.getByRole("button", { name: "מחיקה" }).click();

    const modal = trustedPage.getByRole("dialog");
    await expect(modal).toBeVisible();
    await expect(modal.locator("strong")).toHaveText(item.title);
    await expect(modal.getByRole("button", { name: /אישור/ })).toBeDisabled();
  });

  test("exact-title match enables confirm", async ({ trustedPage, testTag, seedItem }) => {
    const item = await seedItem({ title: `${testTag} chocolate cake` });
    await trustedPage.goto(`/management/items/${item.id}`);
    await trustedPage.getByRole("button", { name: "מחיקה" }).click();
    await trustedPage.getByPlaceholder("הקלידי את שם הפריט").fill(item.title);
    await expect(trustedPage.getByRole("button", { name: /אישור/ })).toBeEnabled();
  });
});
```

Notes:
- ~30 lines for 2 tests.
- No env parsing, no Supabase client, no JWT mint, no JPEG bytes, no cleanup boilerplate.
- `trustedPage` and `seedItem` come from `fixtures.ts`.
- `testTag` prefixes the seeded title so cleanup is automatic and parallel-safe.
- Hebrew copy strings come VERBATIM from the project's locked `spec.md` §7 (or equivalent). NEVER retranslate.

## Anatomy of `e2e/fixtures.ts`

```ts
import { test as base, expect } from "@playwright/test";
import { randomUUID } from "node:crypto";
import { createClient } from "@supabase/supabase-js";

export { expect };
export const BASE_URL = "http://127.0.0.1:3000";

type Fixtures = {
  testTag: string;
  trustedPage: import("@playwright/test").Page;
  seedItem: (overrides?: Partial<Item>) => Promise<Item>;
};

export const test = base.extend<Fixtures>({
  testTag: async ({}, use) => {
    const tag = `__test_${randomUUID().slice(0, 8)}`;
    await use(tag);
    // cleanup runs ONCE per test, ONLY for this test's rows
    const supabase = createAdminClient();
    await supabase.from("catalog_items").delete().like("title", `${tag}%`);
    // ... other tables follow the same pattern
  },

  trustedPage: async ({ page, context }, use) => {
    await context.addCookies([{ name: COOKIE_NAME, value: await mintToken(), domain: "127.0.0.1", path: "/" }]);
    await use(page);
  },

  seedItem: async ({ testTag }, use) => {
    await use(async (overrides = {}) => {
      const supabase = createAdminClient();
      const { data } = await supabase
        .from("catalog_items")
        .insert({ title: `${testTag} item`, ...overrides })
        .select()
        .single();
      return data!;
    });
  },
});
```

Patterns to mirror per project; never invent parallel modules.

---

## Forbidden patterns (auto-reject at review)

- `.mjs` standalone Playwright scripts
- Per-spec `chromium.launch()` calls
- Per-spec env parsing or Supabase client construction
- `DELETE FROM <table>` without `WHERE` (or equivalent unscoped delete)
- Any spec file over ~150 lines
- `test()` blocks over ~25 lines
- File names that bundle scenarios (`*cross-screen*`, `*everything*`, `*states*`)
- `node e2e/<spec>.mjs` in Ralph dispatch or developer docs
- Per-test `chromium.launch()` or `browser.newContext()` from within the spec (use `trustedPage` / `page` fixtures)

## End-to-end / smoke / lifecycle "tasks" — no exceptions

When a task in prd.json reads as "end-to-end smoke" or "lifecycle verification," its work is:
- Run the full feature test suite via `npx playwright test e2e/<feature>-*.spec.ts --reporter=line`
- If exit 0: flip passes:true and commit.
- If failures: fix the individual failing scenario test (under its testTag isolation). NEVER create a new aggregate / mega-test file.

The 25-line-per-test and 150-line-per-file rules apply to EVERY spec file, with NO exceptions for "smoke" or "end-to-end" scenarios. If a test scenario doesn't fit, split it. Period.

## Required at review

When Tech Lead reviews a feature's `prd.json` and per-task bundles, every UI task brief MUST specify:

- The spec file name following the naming convention
- Which fixtures are used (`trustedPage`, `seedItem`, etc.)
- The exact `test()` block names (these become the `--grep` argument for Ralph dispatch)
- The testTag-prefixing pattern for any seeded data

When FE/BE engineers implement UI verification, they MUST follow these rules. Bundles that violate them get sent back to Tech Lead for revision.

---

## Methodology routing — what is this doc, what is it not

This is **infrastructure / engineering convention**, not a product feature. Changes to this standard happen directly via this doc (and the agent files that reference it). They do **not** flow through the PM → Designer → Copywriter → Tech Lead → Ralph chain — that chain is for shipping user-facing product features.

Related: see `methodology.md` for the chain that DOES apply to features.

---

## Status

v1 — 2026-05-19. Bootstrapped from the orleys project's `.mjs` → `.spec.ts` migration. Living doc; revisions land here as the standard accumulates lessons.
