#!/usr/bin/env bash
# ralph.sh — autonomous build loop for a feature's prd.json.
# Picks the next passes:false task whose deps are satisfied, fires one `claude` CLI
# invocation per iteration, repeats until done / max iterations / stuck.
#
# SCOPE: LOCAL autonomous build only. The loop runs entirely against the local
# stack (local Supabase, local Edge Functions, local migrations). Owner approval
# for REMOTE deploy (remote Supabase migrations, remote Edge Function deploy,
# git push) is a SEPARATE concern handled outside this loop — e.g., a future
# `ralph-deploy.sh` or a manual step after the local loop ships.
#
# Usage:
#   ./scripts/ralph.sh [--discard-partial] <feature-slug> [max-iterations]
# Example:
#   ./scripts/ralph.sh couple-add-vendor 30
#   ./scripts/ralph.sh --discard-partial couple-add-vendor 30
#
# Flags:
#   --discard-partial  Discard any uncommitted/untracked work before starting
#                      (recovery from interrupted runs). Reverts modified tracked
#                      files to HEAD and removes untracked files/dirs (keeps
#                      gitignored content).

set -euo pipefail

# ---------- args ----------
DISCARD_PARTIAL=false
SHOW_HELP=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --discard-partial) DISCARD_PARTIAL=true ;;
    --help|-h) SHOW_HELP=true ;;
    *) ARGS+=("$arg") ;;
  esac
done
set -- "${ARGS[@]}"

if [[ "$SHOW_HELP" == "true" ]]; then
  cat <<'HELP'
ralph.sh -- autonomous build loop for a feature's prd.json

USAGE
  ./scripts/ralph.sh [--discard-partial] <feature-slug> [max-iterations]
  ./scripts/ralph.sh --help

EXAMPLES
  ./scripts/ralph.sh couple-add-vendor 30
  ./scripts/ralph.sh --discard-partial couple-add-vendor 30

FLAGS
  --discard-partial  Wipe uncommitted/untracked work before starting (recovery from interrupted runs).
  --help, -h         Show this help.

WHAT IT DOES
  1. Reads docs/features/<feature>/prd.json.
  2. Picks the next passes:false task whose depends_on are all passes:true.
  3. Reads each task's `agent` and `model` fields, then invokes the specialist
     directly: `claude --agent <agent> --model <model>
     --exclude-dynamic-system-prompt-sections --permission-mode acceptEdits --print`.
     No generic-orchestrator wrapper, no subagent spawning — one hop, one specialist.
  4. Loops until all tasks passed, or max-iterations, or stuck.

PRE-FLIGHT REQUIREMENTS
  - node on PATH
  - claude CLI on PATH
  - Working tree clean (use --discard-partial if dirty from a previous interrupt)
  - docs/features/<feature>/{why,flow,spec,prd.json,prd-review}.md exists
  - Every task in prd.json (except doc-only) must have `agent` and `model` set.
    Tech Lead populates these in Step 7.6 of the PRD review. Ralph fails fast
    (exit 14) on the first task missing either field.

STOP CONDITIONS
  - All tasks passes:true              -> exit 0 (success)
  - Max iterations reached             -> exit 3 (some tasks pending)
  - Agent reports STUCK                -> exit 2 (manual triage needed)
  - Dependency cycle / unmet deps      -> exit 4 (inspect prd.json)
  - Task missing agent/model fields    -> exit 14 (Tech Lead must populate Step 7.6)

MODEL
  Each task carries its own `model` field set by Tech Lead in Step 7.6.
  Valid values: opus | sonnet | haiku. The field is required — Ralph does not fall
  back to a default. Cost tier is a per-task decision: schema/RLS judgment → opus,
  routine functional → sonnet, dom-only UI → haiku, visual-review UI → sonnet.

ARTIFACTS PER UI TASK
  screenshots/<task-id>/<viewport>.png -- always captured to disk for human review.
  verification_mode on the task (UI tasks only):
    dom-only      (default) .mjs DOM assertions are the gate. Agent does NOT Read the screenshots back. Cheap.
    visual-review              .mjs runs + agent Reads each screenshot and quotes one specific visual property. Opt-in, vision-token cost.
  Missing field on a task -> defaults to dom-only (backward-compatible).

PRE-FLIGHT REQUIREMENTS (env vars)
  RALPH_HEALTHCHECK_URLS     (optional) Comma-separated list of URLs that must return HTTP 200 within 3s
                             before each iteration's agent is dispatched. If unset, the check is skipped
                             entirely — projects without a dev server are unaffected.
  RALPH_HEALTHCHECK_RECOVER  (optional, only meaningful when RALPH_HEALTHCHECK_URLS is set) Shell snippet
                             to execute once on health-check failure (e.g., restart the dev server). If
                             unset, Ralph exits 16 immediately on health-check failure.

DEV-SERVER HEALTH CHECK (optional)
  Before each iteration Ralph curls every URL in RALPH_HEALTHCHECK_URLS (comma-separated).
  Each URL must return HTTP 200 within 3 seconds. On any failure:
    1. Ralph runs the RALPH_HEALTHCHECK_RECOVER shell snippet once (if set).
    2. Re-checks all URLs.
    3. If still failing -> exit 16 with a remediation hint.
    4. If RALPH_HEALTHCHECK_RECOVER is unset -> exit 16 immediately.
  If RALPH_HEALTHCHECK_URLS is unset -> check is skipped (fully backward-compatible).

  Worked example for a Next.js project:
    export RALPH_HEALTHCHECK_URLS="http://localhost:3000/owner,http://localhost:3000/owner/entries"
    export RALPH_HEALTHCHECK_RECOVER='pkill -f "next dev" ; rm -rf .next ; (npm run dev > /tmp/devserver.log 2>&1 &) ; sleep 10'

EXIT CODES
  0   All tasks passed
  2   Agent reported STUCK
  3   Max iterations reached
  4   Dependency cycle / unmet deps
  10  node not on PATH
  11  claude CLI not on PATH
  12  Missing required feature file
  13  Working tree not clean
  14  Task missing agent/model fields
  16  Dev-server health check failed (and recovery did not restore it)
HELP
  exit 0
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 [--discard-partial] <feature-slug> [max-iterations]" >&2
  echo "  --discard-partial: discard any uncommitted/untracked work before starting (recovery from interrupted runs)" >&2
  echo "  --help, -h: show detailed help" >&2
  exit 64
fi

FEATURE="$1"
MAX_ITER="${2:-30}"

# Auto-detect feature tree: user-facing features live under docs/features/;
# cross-cutting infrastructure (test architecture, build tooling, etc.) lives
# under docs/infrastructure/. Both follow the same prd.json + tasks/ contract.
if [[ -d "docs/features/${FEATURE}" ]]; then
  FEATURE_TREE="features"
elif [[ -d "docs/infrastructure/${FEATURE}" ]]; then
  FEATURE_TREE="infrastructure"
else
  echo "ERROR: Feature '${FEATURE}' not found under docs/features/ or docs/infrastructure/" >&2
  exit 12
fi
PRD="docs/${FEATURE_TREE}/${FEATURE}/prd.json"
FEATURE_DIR="docs/${FEATURE_TREE}/${FEATURE}"

# ---------- logging ----------
ITER=0
ts() { date -u +%Y-%m-%dT%H:%M:%S; }
log() { echo "[$(ts) i=${ITER}] $*"; }
warn() { echo "[$(ts) i=${ITER}] WARN: $*" >&2; }
err() { echo "[$(ts) i=${ITER}] ERROR: $*" >&2; }

# ---------- health check ----------
# Returns 0 if all URLs return HTTP 200 within 3s, 1 otherwise.
# Honors RALPH_HEALTHCHECK_URLS (comma-separated). If unset, returns 0 (skip).
health_check() {
  if [[ -z "${RALPH_HEALTHCHECK_URLS:-}" ]]; then
    return 0
  fi
  local urls failed url code
  IFS=',' read -ra urls <<< "$RALPH_HEALTHCHECK_URLS"
  failed=()
  for url in "${urls[@]}"; do
    url="${url// /}"  # trim whitespace
    [[ -z "$url" ]] && continue
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" 2>/dev/null || echo "000")
    if [[ "$code" != "200" ]]; then
      failed+=("$url=$code")
    fi
  done
  if [[ ${#failed[@]} -gt 0 ]]; then
    warn "health check FAILED: ${failed[*]}"
    return 1
  fi
  return 0
}

# Returns 0 if recovery ran AND health check passes after, 1 otherwise.
attempt_recovery() {
  if [[ -z "${RALPH_HEALTHCHECK_RECOVER:-}" ]]; then
    warn "no RALPH_HEALTHCHECK_RECOVER hook configured — cannot auto-recover"
    return 1
  fi
  log "running recovery hook: ${RALPH_HEALTHCHECK_RECOVER}"
  bash -c "$RALPH_HEALTHCHECK_RECOVER"
  log "recovery hook finished — re-checking health"
  if health_check; then
    log "recovery SUCCEEDED"
    return 0
  else
    err "recovery FAILED — health still bad after running hook"
    return 1
  fi
}

# ---------- pre-flight ----------
log "Pre-flight checks for feature='${FEATURE}', max_iter=${MAX_ITER}"

if ! command -v node >/dev/null 2>&1; then
  err "node not on PATH. Install: https://nodejs.org/"
  exit 10
fi

if ! command -v claude >/dev/null 2>&1; then
  err "claude CLI not on PATH. Install: https://docs.claude.com/en/docs/claude-code/setup"
  exit 11
fi

for f in "prd.json" "spec.md" "why.md" "flow.md" "prd-review.md"; do
  if [[ ! -f "${FEATURE_DIR}/${f}" ]]; then
    err "Missing required file: ${FEATURE_DIR}/${f}"
    exit 12
  fi
done

if [[ "$DISCARD_PARTIAL" == "true" ]] && [[ -n "$(git status --porcelain)" ]]; then
  log "[discard-partial] dirty tree — restoring tracked files and removing untracked..."
  git restore .
  git clean -fd
  log "[discard-partial] tree wiped to last commit. Proceeding."
fi

if [[ -n "$(git status --porcelain)" ]]; then
  err "Working tree is not clean. Commit or stash before running Ralph (auto-commits would mix with your unstaged work)."
  echo "----- git status --porcelain -----" >&2
  git status --porcelain >&2
  exit 13
fi

log "Pre-flight OK."

# ---------- main loop ----------
for ((ITER=1; ITER<=MAX_ITER; ITER++)); do

  PENDING=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    console.log(tasks.filter(t => t.passes === false && (t.category || "") !== "doc-only").length);
  ' "$PRD")

  if [[ "$PENDING" -eq 0 ]]; then
    log "SUCCESS — all functional/ui tasks pass. Iterations used: $((ITER-1))/${MAX_ITER}."
    exit 0
  fi

  NEXT_ID=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const passed = new Set(tasks.filter(t => t.passes === true).map(t => t.id));
    const next = tasks.find(t =>
      t.passes === false &&
      (t.category || "") !== "doc-only" &&
      (t.depends_on || []).every(d => passed.has(d))
    );
    console.log(next ? next.id : "");
  ' "$PRD")

  if [[ -z "$NEXT_ID" ]]; then
    err "PENDING=${PENDING} but no eligible task — dependency cycle or unmet dep on a doc-only / future entry. Inspect ${PRD}."
    exit 4
  fi

  log "Iteration ${ITER}/${MAX_ITER} — pending=${PENDING} — picked task: ${NEXT_ID}"

  # Extract context_path for this task (empty string if not present -> legacy fallback)
  CONTEXT_PATH=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    console.log((t && t.context_path) ? t.context_path : "");
  ' "$PRD" "$NEXT_ID")

  if [[ -z "$CONTEXT_PATH" ]]; then
    err "Task ${NEXT_ID}: context_path is empty in prd.json. Per methodology, every task brief is a complete contract — Tech Lead must generate a per-task bundle (Step 7) and wire context_path before Ralph runs."
    exit 15
  fi
  if [[ ! -f "$CONTEXT_PATH" ]]; then
    err "Task ${NEXT_ID}: context_path=${CONTEXT_PATH} but the bundle file is missing on disk. Tech Lead must regenerate it (Step 7)."
    exit 15
  fi
  log "Bundle: ${CONTEXT_PATH}"

  # Extract category + verification_mode (UI-only). Default verification_mode -> dom-only when missing.
  TASK_CATEGORY=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    console.log((t && t.category) ? t.category : "");
  ' "$PRD" "$NEXT_ID")

  VERIFICATION_MODE=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    if (!t) { console.log(""); process.exit(0); }
    if ((t.category || "") !== "ui") { console.log("n/a"); process.exit(0); }
    const mode = t.verification_mode;
    if (mode === "visual-review") { console.log("visual-review"); }
    else if (mode === "dom-only" || !mode) { console.log("dom-only"); }
    else { console.error("WARN: unknown verification_mode=" + mode + " on task " + t.id + " — defaulting to dom-only"); console.log("dom-only"); }
  ' "$PRD" "$NEXT_ID")

  if [[ "$TASK_CATEGORY" == "ui" ]]; then
    log "Task category=ui  verification_mode=${VERIFICATION_MODE}"
  fi

  TASK_AGENT=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    console.log((t && t.agent) ? t.agent : "");
  ' "$PRD" "$NEXT_ID")

  TASK_MODEL=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    console.log((t && t.model) ? t.model : "");
  ' "$PRD" "$NEXT_ID")

  if [[ -z "$TASK_AGENT" || -z "$TASK_MODEL" ]]; then
    err "Task ${NEXT_ID} missing required field(s): agent='${TASK_AGENT}' model='${TASK_MODEL}'. Tech Lead must populate these in Step 7.6 before Ralph runs."
    exit 14
  fi

  log "Task agent=${TASK_AGENT}  model=${TASK_MODEL}"

  # Build the UI-verification instructions block.
  # For non-UI tasks (functional, doc-only), the block is a no-op blank line.
  if [[ "$TASK_CATEGORY" != "ui" ]]; then
    UI_VERIFY_BLOCK=''
  elif [[ "$VERIFICATION_MODE" == "visual-review" ]]; then
    UI_VERIFY_BLOCK='   - category:ui (verification_mode=visual-review) — Playwright at the specified viewport via the .mjs script. The .mjs MUST capture screenshots to screenshots/<task-id>/<viewport>.png AND run DOM assertions. After .mjs exits 0, you MUST Read every screenshot file via the Read tool and quote ONE specific visual property per screenshot in your report (e.g., "the success card occupies the upper third of the viewport with the CTA flush to the right edge"). NEGATIVE checks ("verify X is ABSENT at this viewport") are first-class — do not skip.'
  else
    # dom-only is the default for UI tasks when verification_mode is missing or set to "dom-only".
    UI_VERIFY_BLOCK='   - category:ui (verification_mode=dom-only) — Playwright at the specified viewport via the .mjs script. The .mjs MUST run DOM assertions (text content, attributes, computed styles, element counts, focus state, navigation, getBoundingClientRect, ARIA roles, presence/absence). The .mjs captures screenshots to screenshots/<task-id>/<viewport>.png for on-disk human review. You DO NOT Read the screenshots back via the Read tool — that step is intentionally skipped to save vision tokens. The gate is: .mjs exits 0 AND every screenshot file exists on disk AND every DOM assertion in the steps array fires. NEGATIVE checks ("verify X is ABSENT at this viewport") are first-class — encode them as DOM assertions in the .mjs.'
  fi

  PROMPT=$(cat <<EOF
RALPH ITERATION — feature ${FEATURE}, task ${NEXT_ID}

The loop driver (shell) picked this task — it is the highest-priority passes:false task whose depends_on are satisfied. Execute, do not question priority order.

CONTEXT BUNDLE: ${CONTEXT_PATH}
Read this once. Do NOT re-read why.md / spec.md / flow.md / prd-review.md / decisions.md / CLAUDE.md — the bundle has the relevant slices. Only fall back to upstream docs if the bundle is explicitly incomplete; if you do, note exactly what was missing in your final report so Tech Lead can fix the slicing rule.

YOUR JOB
1. Read the bundle. Implement the task using files_touched as authoritative (existing = edit, NEW: prefix = create).
2. Verify every step in steps[]:
   - category:functional — DB / API / Edge Function / integration assertions via Supabase CLI, curl, or test scripts.
${UI_VERIFY_BLOCK}
3. Set passes:true on YOUR task ONLY in prd.json (never touch other tasks' entries).
4. git add the implementation files + prd.json. Commit: feat(${FEATURE}/${NEXT_ID}): <one-line description from task>
5. Exit cleanly.

SCOPE — LOCAL ONLY
- Apply local migrations, regen local types, run local Playwright.
- Local Edge Function serve is already running via init.sh — if you write a new function, it picks up automatically.
- DO NOT push to remote Supabase. DO NOT deploy Edge Functions to remote. DO NOT git push.

STUCK SIGNAL
If you genuinely cannot finish (>5 internal retries on the same verification step): print "STUCK: ${NEXT_ID} — <one-line reason>" to stderr and exit 1.

Report at the end (1–3 lines): what you did, what you verified, status. If the bundle was incomplete, note exactly what was missing.
EOF
)

  # Pre-iteration dev-server health check (no-op if RALPH_HEALTHCHECK_URLS unset)
  if ! health_check; then
    if ! attempt_recovery; then
      err "dev-server health check failed and recovery did not restore it. Stopping."
      err "Manual fix: reset your dev environment (e.g. rm -rf .next && restart npm run dev), then re-run ralph."
      exit 16
    fi
  fi

  log "Invoking claude --agent ${TASK_AGENT} --model ${TASK_MODEL} for ${NEXT_ID}..."
  set +e
  claude --agent "$TASK_AGENT" --model "$TASK_MODEL" \
         --exclude-dynamic-system-prompt-sections \
         --permission-mode acceptEdits --print "$PROMPT"
  RC=$?
  set -e

  if [[ "$RC" -eq 0 ]]; then
    log "claude returned RC=0 for ${NEXT_ID}."
  elif [[ "$RC" -eq 1 ]]; then
    err "STUCK signal from agent on task ${NEXT_ID} (RC=1). Stopping. Owner: read the agent's STUCK message above."
    exit 2
  else
    warn "claude returned non-zero RC=${RC} on task ${NEXT_ID}. Continuing — could be transient. Will re-verify pass-flip below."
  fi

  # Verify the task actually flipped to passes:true.
  FLIPPED=$(node -e '
    const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
    const t = tasks.find(t => t.id === process.argv[2]);
    console.log(t ? String(t.passes) : "not-found");
  ' "$PRD" "$NEXT_ID")
  if [[ "$FLIPPED" != "true" ]]; then
    warn "Task ${NEXT_ID} did NOT flip to passes:true after invocation (still '${FLIPPED}'). Loop will re-pick it next iteration unless deps re-arrange."
  else
    log "Verified ${NEXT_ID} flipped to passes:true."
  fi

done

# ---------- after loop ----------
SUMMARY=$(node -e '
  const tasks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"));
  const pending = tasks.filter(t => t.passes === false && (t.category || "") !== "doc-only");
  console.log(pending.length);
  console.log(pending.map(t => t.id).join(", "));
' "$PRD")
PENDING_FINAL=$(echo "$SUMMARY" | sed -n '1p')
PENDING_IDS=$(echo "$SUMMARY" | sed -n '2p')

err "Max iterations (${MAX_ITER}) reached. ${PENDING_FINAL} task(s) still pending: ${PENDING_IDS}"
err "Owner: triage. Re-run with a higher cap, or inspect the stuck task(s) manually."
exit 3
