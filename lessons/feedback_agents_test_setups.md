---
name: Agents test setups, not the owner
description: When the orchestrator/agents produce setup scripts (init.sh, ralph.sh, build tooling, install steps), agents must TEST them end-to-end before declaring them ready. Owner should never need to be the first one to run a setup script. Syntax check (bash -n) is necessary but NOT sufficient.
type: feedback
originSessionId: 225600c9-5d1d-44ac-b879-c88a5d462a66
---
**HARD RULE.**

The orchestrator and agents own setup verification. The owner observes. Never push test responsibility to the owner with phrases like "owner runs locally" or "owner verifies."

**Owner's directive (verbatim):** "I expect all tests will be done by you - I don't need to test setups you need and you need to make sure the setup works for testing."

**Why this matters:** the owner caught that init.sh was only syntax-checked (`bash -n`), never actually run. PM agent's brief said "owner runs locally" — that was orchestrator framing, not owner intent. If the script doesn't actually work, the owner discovers that the hard way.

**The rule:**

When an agent produces an executable setup artifact (bash script, install command, deploy step):
1. **Syntax check** — `bash -n` or equivalent. Necessary but NOT sufficient.
2. **Real run** — spawn a QA / test agent to actually execute the script end-to-end. Capture stdout/stderr. Verify the success state matches the script's promise (services up, ports listening, files present, exit code 0).
3. **Idempotency check** — run the script twice if it claims to be idempotent. Verify it doesn't break on the second run.
4. **Failure-mode coverage** — if the script has pre-flight checks (missing files, missing CLIs), trigger them deliberately and verify the error messages are useful.
5. **Cleanup** — kill any background processes the script started before declaring done.

**For long-running scripts** (init.sh which runs vite + supabase + functions and never exits):
- Run in background.
- Wait for the "ready" banner OR a timeout.
- Verify health checks pass (curl, port checks, status commands).
- Kill the process group cleanly.
- Report.

**For destructive scripts** (anything that mutates remote state, writes secrets, force-applies migrations):
- Don't run without owner approval. Different from local-test scripts.

**How to apply:**
- Every time an agent produces a `scripts/X.sh` or `init.sh` or similar — spawn a follow-up QA agent to run it.
- Don't ship scripts that haven't been observed working.
- "owner runs locally" is the wrong handoff — replace with "agent ran it, verified, here's the output."
