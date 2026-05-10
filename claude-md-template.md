# <PROJECT_NAME> — Project Guide

## Project Overview
<PROJECT_DESCRIPTION>

- **Stack**: <STACK>
- **Language**: <LANGUAGE_AND_LOCALE>
- **Brand voice**: <BRAND_VOICE>

## Domain Terms
<DOMAIN_TERMS> — list the key nouns this product uses (e.g. "couples / vendors / categories / quotes" for a wedding app, "users / accounts / transactions" for finance).

## Required Secrets
<REQUIRED_SECRETS>

## Methodology
This project follows the methodology defined in `docs/methodology.md`. PM, Designer, FE, BE, Copywriter, Tech Lead, QA agents are global at `~/.claude/agents/` — they read this CLAUDE.md to understand THIS project's context.

## Tool Rules
- **Web access — Brightdata MCP only.** All web fetching MUST use `mcp__brightdata__*` tools. WebFetch is forbidden.
- **Search — Grep tool, not Bash grep.**

## Local Dev
Run `./init.sh` to boot the local stack. See `init.sh` for required services.

## Production gates
Both `git push` AND remote infrastructure changes (Supabase, Vercel, etc.) require explicit owner approval.
