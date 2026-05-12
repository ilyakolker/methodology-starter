#!/usr/bin/env bash
# bootstrap.sh -- one-command project scaffolding for the methodology-starter
# Usage: bash bootstrap.sh <project-folder-name>

set -euo pipefail

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "bootstrap.sh -- scaffold a new project with the methodology-starter"
  echo ""
  echo "Usage: bash bootstrap.sh <project-folder-name>"
  echo ""
  echo "Steps: 0=global agents, 1=folders, 2=git init, 3-5=copy files,"
  echo "       5=chmod+hooks, 6=.gitignore, 7=seed lessons to memory"
  echo ""
  echo "Requirements: git, cp, mkdir, chmod"
  exit 0
fi

SCRIPT_PATH="$(realpath "$0")"
STARTER_DIR="$(dirname "$SCRIPT_PATH")"

if ! command -v git &>/dev/null; then
  echo "[bootstrap] ERROR: git not found on PATH. Install git and retry." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "[bootstrap] ERROR: no project folder name given." >&2
  echo "[bootstrap] Usage: bash bootstrap.sh <project-folder-name>" >&2
  exit 1
fi

PROJECT_NAME="$1"

if [[ -e "$PROJECT_NAME" ]]; then
  echo "[bootstrap] ERROR: '$PROJECT_NAME' already exists. Remove it first." >&2
  exit 1
fi

echo "[bootstrap] Starting scaffold for project: $PROJECT_NAME"
echo "[bootstrap] Starter directory: $STARTER_DIR"

echo ""
echo "[bootstrap] Step 0 -- Installing global agents to ~/.claude/agents/"
mkdir -p ~/.claude/agents

AGENTS_INSTALLED=()
AGENTS_SKIPPED=()

if [[ -d "$STARTER_DIR/agents" ]]; then
  for agent_file in "$STARTER_DIR/agents/"*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name="$(basename "$agent_file")"
    dest="$HOME/.claude/agents/$agent_name"
    if [[ -e "$dest" ]]; then
      AGENTS_SKIPPED+=("$agent_name")
    else
      cp "$agent_file" "$dest"
      AGENTS_INSTALLED+=("$agent_name")
    fi
  done
fi

for a in "${AGENTS_INSTALLED[@]+"${AGENTS_INSTALLED[@]}"}"; do
  echo "[bootstrap]   installed: $a"
done
for a in "${AGENTS_SKIPPED[@]+"${AGENTS_SKIPPED[@]}"}"; do
  echo "[bootstrap]   skipped (already present): $a"
done

echo ""
echo "[bootstrap] Step 1 -- Creating project folder structure"
mkdir -p "$PROJECT_NAME/docs/features"
mkdir -p "$PROJECT_NAME/docs/methodology"
mkdir -p "$PROJECT_NAME/e2e/.auth"
mkdir -p "$PROJECT_NAME/scripts/git-hooks"
mkdir -p "$PROJECT_NAME/.claude/skills"
echo "[bootstrap]   folders created"

echo ""
echo "[bootstrap] Step 2 -- Initialising git"
git -C "$PROJECT_NAME" init --quiet
echo "[bootstrap]   git init done"

echo ""
echo "[bootstrap] Steps 3-5 -- Copying methodology, skills, scripts, templates"

if [[ -d "$STARTER_DIR/methodology" ]]; then
  cp -r "$STARTER_DIR/methodology/"* "$PROJECT_NAME/docs/methodology/"
  cp "$STARTER_DIR/methodology/methodology.md" "$PROJECT_NAME/docs/methodology.md"
  echo "[bootstrap]   methodology docs copied"
fi

SKILLS_COPIED=()
if [[ -d "$STARTER_DIR/skills" ]]; then
  for skill_file in "$STARTER_DIR/skills/"*.md; do
    [[ -f "$skill_file" ]] || continue
    cp "$skill_file" "$PROJECT_NAME/.claude/skills/"
    SKILLS_COPIED+=("$(basename "$skill_file")")
  done
fi
if [[ ${#SKILLS_COPIED[@]} -gt 0 ]]; then
  echo "[bootstrap]   skills copied: ${SKILLS_COPIED[*]}"
else
  echo "[bootstrap]   no skills to copy (skills/ empty or absent)"
fi

if [[ -f "$STARTER_DIR/scripts/ralph.sh" ]]; then
  cp "$STARTER_DIR/scripts/ralph.sh" "$PROJECT_NAME/scripts/"
  echo "[bootstrap]   scripts/ralph.sh copied"
fi

if [[ -d "$STARTER_DIR/scripts/git-hooks" ]]; then
  for hook_file in "$STARTER_DIR/scripts/git-hooks/"*; do
    [[ -f "$hook_file" ]] || continue
    cp "$hook_file" "$PROJECT_NAME/scripts/git-hooks/"
  done
  echo "[bootstrap]   scripts/git-hooks/* copied"
fi

if [[ -f "$STARTER_DIR/scripts/init.sh.template" ]]; then
  cp "$STARTER_DIR/scripts/init.sh.template" "$PROJECT_NAME/init.sh"
  echo "[bootstrap]   init.sh.template -> init.sh"
fi

if [[ -f "$STARTER_DIR/e2e/auth.setup.ts.template" ]]; then
  cp "$STARTER_DIR/e2e/auth.setup.ts.template" "$PROJECT_NAME/e2e/auth.setup.ts"
  echo "[bootstrap]   e2e/auth.setup.ts.template -> e2e/auth.setup.ts"
fi

if [[ -f "$STARTER_DIR/BACKLOG.md.template" ]]; then
  cp "$STARTER_DIR/BACKLOG.md.template" "$PROJECT_NAME/docs/BACKLOG.md"
  echo "[bootstrap]   BACKLOG.md.template -> docs/BACKLOG.md"
fi

if [[ -f "$STARTER_DIR/claude-md-template.md" ]]; then
  awk -v pname="$PROJECT_NAME" '{ gsub(/<PROJECT_NAME>/, pname); print }' "$STARTER_DIR/claude-md-template.md" > "$PROJECT_NAME/CLAUDE.md"
  echo "[bootstrap]   claude-md-template.md -> CLAUDE.md (PROJECT_NAME substituted)"
fi

echo ""
echo "[bootstrap] Step 5 -- Setting permissions and git hooks"
[[ -f "$PROJECT_NAME/init.sh" ]] && chmod +x "$PROJECT_NAME/init.sh"
[[ -f "$PROJECT_NAME/scripts/ralph.sh" ]] && chmod +x "$PROJECT_NAME/scripts/ralph.sh"
[[ -f "$PROJECT_NAME/scripts/git-hooks/pre-commit" ]] && chmod +x "$PROJECT_NAME/scripts/git-hooks/pre-commit"
git -C "$PROJECT_NAME" config core.hooksPath scripts/git-hooks
echo "[bootstrap]   chmod +x done, core.hooksPath = scripts/git-hooks"

echo ""
echo "[bootstrap] Step 6 -- Writing .gitignore"
GITIGNORE="$PROJECT_NAME/.gitignore"

append_if_missing() {
  local entry="$1"
  local file="$2"
  if [[ -f "$file" ]] && grep -qxF "$entry" "$file" 2>/dev/null; then
    return 0
  fi
  echo "$entry" >> "$file"
}

append_if_missing "e2e/.auth/" "$GITIGNORE"
append_if_missing "e2e/.test-couple.env" "$GITIGNORE"
append_if_missing ".env.local.secrets" "$GITIGNORE"
append_if_missing "node_modules/" "$GITIGNORE"
echo "[bootstrap]   .gitignore written"

echo ""
echo "[bootstrap] Step 7 -- Seeding lessons to ~/.claude/projects memory"

PROJECT_ABS="$(cd "$PROJECT_NAME" && pwd)"
CLAUDE_SLUG="$(echo "$PROJECT_ABS" | sed 's|^/||; s|/|-|g')"
MEMORY_DIR="$HOME/.claude/projects/$CLAUDE_SLUG/memory"
mkdir -p "$MEMORY_DIR"

LESSONS_COPIED=()
if [[ -d "$STARTER_DIR/lessons" ]]; then
  for lesson_file in "$STARTER_DIR/lessons/"*.md; do
    [[ -f "$lesson_file" ]] || continue
    lesson_name="$(basename "$lesson_file")"
    dest="$MEMORY_DIR/$lesson_name"
    if [[ ! -e "$dest" ]]; then
      cp "$lesson_file" "$dest"
      LESSONS_COPIED+=("$lesson_name")
    fi
  done
fi

MEMORY_INDEX="$MEMORY_DIR/MEMORY.md"
if [[ ! -f "$MEMORY_INDEX" ]]; then
  printf "# Project Memory -- %s\n\n" "$PROJECT_NAME" > "$MEMORY_INDEX"
  printf "Portable lessons copied from methodology-starter.\n\n" >> "$MEMORY_INDEX"
  if [[ -d "$STARTER_DIR/lessons" ]]; then
    for lesson_file in "$STARTER_DIR/lessons/"*.md; do
      [[ -f "$lesson_file" ]] || continue
      lesson_name="$(basename "$lesson_file" .md)"
      printf -- "- [%s](%s.md)\n" "$lesson_name" "$lesson_name" >> "$MEMORY_INDEX"
    done
  fi
  echo "[bootstrap]   MEMORY.md index created at $MEMORY_INDEX"
fi

if [[ ${#LESSONS_COPIED[@]} -gt 0 ]]; then
  echo "[bootstrap]   ${#LESSONS_COPIED[@]} lessons copied to $MEMORY_DIR"
else
  echo "[bootstrap]   memory dir already populated, skipped"
fi

echo ""
echo "========================================================================"
echo "[bootstrap] DONE"
echo "========================================================================"
echo ""
echo "  Project path : $PROJECT_ABS"
echo "  CLAUDE.md    : <PROJECT_NAME> filled; other placeholders need intake"
echo ""
printf "  Global agents installed : %d\n" "${#AGENTS_INSTALLED[@]}"
printf "  Global agents skipped   : %d\n" "${#AGENTS_SKIPPED[@]}"
if [[ ${#SKILLS_COPIED[@]} -gt 0 ]]; then
  echo "  Skills in .claude/skills: ${SKILLS_COPIED[*]}"
else
  echo "  Skills in .claude/skills: (none -- add from Claude Code marketplace)"
fi
echo "  Lessons in memory       : $MEMORY_DIR"
echo ""
echo "  NEXT STEPS:"
echo ""
echo "  1. Open Claude Code in '$PROJECT_NAME'"
echo "  2. Say: 'Read CLAUDE.md and fill in the remaining placeholders"
echo "     by asking me the intake questions.'"
echo "  3. Then: 'feature-plan: <name + idea>' to start your first feature."
echo ""
