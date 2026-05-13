---
name: When multiple repos are in scope, name the repo in every action line
description: Orchestrator must explicitly disambiguate which repo a state-change applies to whenever a conversation has touched 2+ repos in the same session. "Push" / "merge" / "approve" alone is ambiguous when the project repo and methodology-starter (or other external repos) have both been discussed. Owner has been confused twice in this pattern.
type: feedback
---
**HARD RULE for orchestrator.** When a session has touched more than one repo, every action proposal MUST name the repo explicitly:

- "Approve push?" — wrong, ambiguous
- "Approve push of 2 [project-name] commits to origin/main?" — correct

- "PR is open." — wrong, ambiguous
- "methodology-starter PR #N is open." — correct

**Why this matters:** owner's verbatim pushback (twice in five minutes): "these are 2 different repos" and "we were fixing the methodology repo not the [project] one." Owner was reasoning about the methodology-starter cleanup; orchestrator slipped the project's unrelated unpushed commits into the same approval flow. Owner gave a yes thinking it applied to one repo; orchestrator interpreted it as the other.

**How to apply:**
- When more than one repo is in scope, give a status line at the top of any state report that lists each repo + its state separately. Never merge them into one "ready to push?" question.
- When two separate approval actions are warranted (one per repo), space them out across messages — don't surface both at once.
- If owner approves an action with one word ("push", "yes", "do it"), and there's potential ambiguity, re-confirm the scope BEFORE dispatching: "Push the 2 [project] commits, correct? (methodology-starter PR is separate, you merge on GitHub.)"
- Different repos may have different workflows (e.g. one uses trunk-based direct commits, another uses PRs/branches). Name both the repo AND the expected workflow when proposing actions.
