---
name: No graceful degradation in test/setup paths — missing dependency = HARD FAIL
description: When the goal is autonomous local testing (init.sh + ralph.sh + e2e), missing dependencies must HARD FAIL with clear error messages. "Graceful skip" / "warn and continue" is a false positive — the system pretends it's healthy when half of it is unavailable. Reserve graceful degradation for production runtime, never for test setup.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.**

For local testing setup (init.sh, ralph.sh pre-flight, CI smoke tests), every required dependency must be present or the script MUST exit with a clear actionable error. Never "warn + skip" a dependency that's required for the test to be meaningful.

**Owner's pushback (verbatim):** "'Graceful degradation when secrets missing' -> this is playing the system and will 100% fail any test! if the credentials are missing we will not be able to test anything correctly and gracefully say all good."

**The failure pattern:** init.sh was written to "warn and skip Edge Functions if .env.local.secrets is missing." This made the script reach the "ready" banner even when half the stack wasn't running. QA reported PASS because the script reached the banner, but the underlying capability (testing Edge Function flows, sending WhatsApp, vendor quote pipeline) was completely absent.

**The rule:**

- For setup-time scripts: **every dependency that the test suite REQUIRES must be a hard prerequisite.** If `.env.local.secrets` is required for the test surface to be meaningful, missing secrets = exit 1.
- Error messages must be actionable: tell the owner exactly what to install / create / configure.
- "Optional" dependencies are only optional if the test suite explicitly excludes the feature that needs them. If Ralph will run a task that touches Edge Functions, secrets are NOT optional.
- "Graceful degradation" is for PRODUCTION RUNTIME (e.g., service still serves UI when one downstream is down). It has no place in setup verification.

**How to apply:**
- Audit every "graceful skip" branch in setup scripts. Each one needs a justification: "this is genuinely optional because [feature X is excluded from local test suite]." If no justification, convert to hard-fail.
- For init.sh: secrets REQUIRED, supabase CLI REQUIRED, all migrations applied REQUIRED, test data seeded REQUIRED. No half-stack mode.
- For QA setup-validation reports: if any subsystem skipped, report as INCOMPLETE not PASS.
