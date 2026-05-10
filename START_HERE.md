# Methodology Starter — Bootstrap Instructions

You are being asked to bootstrap a new project with this methodology. Follow this protocol exactly.

## Step 0 — Ensure global agents are installed (one-time per machine)

Check if `~/.claude/agents/` exists and contains the 7 role files (pm.md, designer.md, fe-engineer.md, be-engineer.md, copywriter.md, tech-lead.md, qa-engineer.md).

If missing or incomplete:
```bash
mkdir -p ~/.claude/agents
cp <starter-path>/agents/*.md ~/.claude/agents/
```

These are GENERIC role definitions and are shared across all projects on this machine. Improvements made here benefit every project.

## Step 1 — Ask the owner for project specifics

In one chat message, ask all of:
1. Project name
2. Project description (one sentence)
3. Stack
4. Language and locale
5. Brand voice (one phrase)
6. Domain terms (key nouns)
7. Required secrets (e.g., "Stripe key + Postgres URL")

Wait for owner answers.

## Step 2 — Render `claude-md-template.md` into the new project's `CLAUDE.md`

Substitute placeholders with owner's answers. Save to `<new-project>/CLAUDE.md`.

## Step 3 — Copy methodology files

```bash
cp -r <starter-path>/methodology/ <new-project>/docs/methodology/
cp <starter-path>/methodology/methodology.md <new-project>/docs/methodology.md
```

## Step 4 — Copy skills (optional, project-by-project)

If the project will use to-prd or to-issues:
```bash
mkdir -p <new-project>/.claude/skills
cp <starter-path>/skills/* <new-project>/.claude/skills/
```

## Skills

This methodology ships with two REQUIRED skills, both already in the `skills/` folder:

- **`to-prd.md`** — PM uses during SPEC phase. Defines the spec template + synthesis process.
- **`to-issues.md`** — PM uses during PRD phase. Vertical-slice decomposition with HITL/AFK distinction.

Per Step 4 (Copy skills), these get copied into `<new-project>/.claude/skills/` for every project that runs this methodology.

### Optional skills (UI work)

The Designer agent benefits from a wireframing skill if available, but the methodology works without one — Designer can produce flow diagrams (Mermaid) and design specs from scratch.

If you want a wireframe generator, install separately from the Claude Code marketplace or your plugin source:
- `wireframe` — generates 5 UX option sets (1 safe + 4 exploratory) as interactive HTML prototypes.

These are NOT bundled because they may have licensing or installation paths specific to the user's Claude Code setup.

## Step 5 — Copy scripts and templates

```bash
cp <starter-path>/scripts/ralph.sh <new-project>/scripts/
cp <starter-path>/scripts/git-hooks/* <new-project>/scripts/git-hooks/
cp <starter-path>/scripts/init.sh.template <new-project>/init.sh
cp <starter-path>/e2e/auth.setup.ts.template <new-project>/e2e/auth.setup.ts
```

Substitute placeholders in init.sh and auth.setup.ts using owner's answers (project name, secrets, test user creds).

## Step 6 — Initialize project folders

```bash
mkdir -p <new-project>/docs/features
mkdir -p <new-project>/e2e/.auth
chmod +x <new-project>/init.sh <new-project>/scripts/ralph.sh <new-project>/scripts/git-hooks/pre-commit
git config core.hooksPath scripts/git-hooks
```

Add to `<new-project>/.gitignore`:
```
e2e/.auth/
e2e/.test-couple.env
.env.local.secrets
```

## Step 7 — Confirm to owner

> "Bootstrap complete. Your team (PM, Designer, FE, BE, Copywriter, Tech Lead, QA) is wired in via global agents at ~/.claude/agents. Project context is in CLAUDE.md. To start your first feature, say `feature-plan: <name + idea>` in chat."

## Lessons folder

The `lessons/` folder has accumulated portable rules from prior projects. Recommend the owner copy them to their personal Claude memory:
```bash
cp <starter-path>/lessons/*.md ~/.claude/projects/<project-slug>/memory/
```

## Adding new lessons over time

When the owner learns something new across any project, append a `feedback_<short>.md` to the starter's `lessons/` folder. Future projects inherit it.
