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
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --discard-partial) DISCARD_PARTIAL=true ;;
    *) ARGS+=("$arg") ;;
  esac
done
set -- "${ARGS[@]}"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 [--discard-partial] <feature-slug> [max-iterations]" >&2
  echo "  --discard-partial: discard any uncommitted/untracked work before starting (recovery from interrupted runs)" >&2
  exit 64
fi

FEATURE="$1"
MAX_ITER="${2:-30}"
PRD="docs/features/${FEATURE}/prd.json"
FEATURE_DIR="docs/features/${FEATURE}"

# ---------- logging ----------
ITER=0
ts() { date -u +%Y-%m-%dT%H:%M:%S; }
log() { echo "[$(ts) i=${ITER}] $*"; }
warn() { echo "[$(ts) i=${ITER}] WARN: $*" >&2; }
err() { echo "[$(ts) i=${ITER}] ERROR: $*" >&2; }

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

  PROMPT=$(cat <<EOF
You are a build agent in a Ralph Wiggum loop. ONE task per invocation. Strict rules below.

Feature: ${FEATURE}
Task assigned to you (priority-picked by the shell): ${NEXT_ID}

You did NOT pick this task — the loop driver picked it for you because it's the highest-priority passes:false task whose depends_on are all satisfied. Your job is to do this task, NOT to question the priority order.

MANDATORY READING (every invocation, every time):
1. docs/features/${FEATURE}/why.md
2. docs/features/${FEATURE}/spec.md
3. docs/features/${FEATURE}/flow.md (and flow.png if relevant)
4. docs/features/${FEATURE}/prd-review.md — find your task's section. Tech Lead populated files_touched (existing + NEW:) and noted any build-time clarifications. These are AUTHORITATIVE — use them.
5. docs/features/${FEATURE}/decisions.md — cross-cutting decisions (D1-D5 etc.). Honor them.
6. docs/features/${FEATURE}/prd.json — find your task by id="${NEXT_ID}".
7. CLAUDE.md — project rules.

DELEGATION (use the right specialist for the task):
This task's category and nature determine which subagent to spawn. Read the task in prd.json, then:

- category:functional + schema/RLS/migration work:
  → spawn \`be-engineer\`. Brief: read why.md + spec.md + prd-review.md + this task's entry; do migration + RLS work; verify via DB queries; flip passes:true; commit.

- category:functional + Edge Function:
  → spawn \`be-engineer\`. Brief: write supabase/functions/<name>/index.ts; deploy locally (init.sh has it serving); verify via curl + DB queries.

- category:functional + shared util (e.g. phone-normalization-util):
  → spawn \`fe-engineer\`. Brief: write util in src/utils/; verify with assertions; flip passes:true.

- category:functional + FE end-to-end (form, mutation hook, route):
  → spawn \`fe-engineer\`. Brief: implement against spec; verify via Playwright + DB queries.

- category:ui:
  → spawn \`fe-engineer\`. Brief: implement JSX + CSS per spec; run Playwright at specified viewport; take screenshots; verify visual assertions + NEGATIVE checks; flip passes:true.

- category:doc-only:
  → no subagent. Verify manually by reading the file. Flip passes:true.

You (parent claude) orchestrate. Subagent does domain work. After subagent returns, verify the commit was made, then exit cleanly. If subagent reports STUCK, propagate the signal.

YOUR JOB:
1. Locate the task with id "${NEXT_ID}" in prd.json. Read its steps array — these are what you must verify.
2. Implement the work using Tech Lead's files_touched as authoritative. Existing files = edit. NEW: prefixed files = create.
3. Verify EVERY step in the steps array passes:
   - For category:functional — DB / API / Edge Function / integration assertions. Run via Supabase CLI, curl, or test scripts.
   - For category:ui — Playwright at the specified viewport. Take screenshots, READ them with the Read tool, verify visual assertions. NEGATIVE checks ("verify X is ABSENT") are first-class — do not skip.
4. AFTER every step passes: edit prd.json to set passes:true on YOUR task ONLY.
5. git add the changed code/migration files (NOT just prd.json — the actual implementation must be staged too).
6. git commit with message: "feat(${FEATURE}/${NEXT_ID}): <one-line description from task>"
7. Exit cleanly.

LOCAL-AUTONOMOUS RULES:
- LOCAL migration apply is YOURS to do. Run \`supabase migration up\` or \`supabase db reset\` as needed. Local DB is reversible.
- LOCAL Edge Function serve is already running via init.sh. If you write a new function, the serving picks it up automatically.
- LOCAL types regeneration: if your task touches schema, regenerate types and commit.
- DO NOT push to remote Supabase. DO NOT deploy Edge Functions to remote. DO NOT git push. The loop runs entirely against the local stack — remote concerns are for a separate workflow after the loop ships.

STRICT RULES:
- It is UNACCEPTABLE to skip a verification step. If a step fails, debug the code, fix it, retry.
- It is UNACCEPTABLE to flip passes:true without genuine end-to-end verification.
- It is UNACCEPTABLE to remove, edit, or reorder OTHER tasks' entries in prd.json. Edit ONLY your task's passes field.
- It is UNACCEPTABLE to ship code with TODO/temporary/hardcoded "for now" comments.
- It is UNACCEPTABLE to question the priority order. The shell decided. You execute.
- If you genuinely cannot finish in this invocation (>5 internal retries on the same verification step): print on stderr "STUCK: ${NEXT_ID} — <one-line reason>" and exit 1.

Report at the end (1-3 lines): what you did, what you verified, status.
EOF
)

  log "Invoking claude (acceptEdits, print mode) for ${NEXT_ID}..."
  set +e
  claude --permission-mode acceptEdits --print "$PROMPT"
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
