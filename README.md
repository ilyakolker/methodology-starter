# Methodology Starter

A portable agent + protocol kit for running multi-agent product engineering sessions in [Claude Code](https://claude.com/product/claude-code).

Built around a small core team — **PM, Designer, FE, BE, Copywriter, Tech Lead, QA** — operating under a shared protocol that turns a feature idea into shipped code with one orchestrator session and one autonomous build loop.

## What's inside

```
agents/                 7 generic role definitions (install once at ~/.claude/agents/)
methodology/            Protocols (PM, Designer, Tech Lead, Copywriter) + the master methodology doc
skills/                 Bundled skills used by PM (to-prd, to-issues — Matt Pocock-adapted)
scripts/                ralph.sh (autonomous build loop), init.sh.template, git-hooks/pre-commit
e2e/                    auth.setup.ts.template (Playwright auth scaffold)
lessons/                ~30 portable feedback rules accumulated across projects
claude-md-template.md   Per-project context template
START_HERE.md           Bootstrap instructions for a new project
```

## Getting started

### 1. Install global agents (one-time per machine)
```bash
mkdir -p ~/.claude/agents
cp agents/*.md ~/.claude/agents/
```

### 2. Bootstrap a new project
Open Claude Code in your new project folder and say:

> "Read METHODOLOGY-STARTER/START_HERE.md and bootstrap this project."

The orchestrator will ask for project specifics, fill in `CLAUDE.md`, copy the right files into your project, and confirm when ready.

### 3. Build features
Once bootstrapped, say in chat:

> `feature-plan: <name + rough idea>`

PM picks it up. Cascade runs through WHY → FLOW → SPEC → PRD → Tech Lead review → autonomous build via `scripts/ralph.sh`.

## Origin

Extracted from a real-world project (a Hebrew RTL wedding-vendor matching platform) where the methodology was developed and refined across many sessions. The agents and protocols are de-projectified — they make no assumptions about stack, language, domain, or brand. Project-specific context lives in each project's `CLAUDE.md`.

## License

MIT — use, fork, adapt freely.
