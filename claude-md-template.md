# <PROJECT_NAME> — Project Guide

## Project Overview
<PROJECT_DESCRIPTION>

- **Stack**: <STACK>
- **Language**: <LANGUAGE_AND_LOCALE>
- **Brand voice**: <BRAND_VOICE>

## Domain Terms
<DOMAIN_TERMS> — list the key nouns this product uses (e.g. "users / orders / products / reviews" for e-commerce, "patients / appointments / providers / notes" for healthcare, "accounts / transactions / invoices / payouts" for fintech).

## Required Secrets
<REQUIRED_SECRETS>

## Methodology
This project follows the methodology defined in `docs/methodology.md`. PM, Designer, FE, BE, Copywriter, Tech Lead, QA agents are global at `~/.claude/agents/` — they read this CLAUDE.md to understand THIS project's context.

## Tool Rules
- **Web access — Brightdata MCP only.** All web fetching MUST use `mcp__brightdata__*` tools. WebFetch is forbidden.
- **Search — Grep tool, not Bash grep.**

## Code Shape Rules

- **No duplicated type augmentations** (TypeScript projects). If a global like `Window.X`, a module shape, or an ambient declaration is needed in more than one place, hoist it to a single shared `.d.ts` file (e.g. `<suite>/types/<feature>.d.ts`). Never re-declare the same `declare global` block across sibling spec files — they will drift, and the next agent who forgets to copy it ships type errors.
- **Shared utilities live in shared files.** Test seed helpers, auth helpers, env loaders that appear in 2+ spec files: extract to `<suite>/_helpers/` or similar. The agent generating the N+1th spec should import, not re-author.

## Local Dev
Run `./init.sh` to boot the local stack. See `init.sh` for required services.

## Production gates
Both `git push` AND remote infrastructure changes (Supabase, Vercel, etc.) require explicit owner approval.
