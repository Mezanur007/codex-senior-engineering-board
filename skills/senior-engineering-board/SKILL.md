---
name: senior-engineering-board
description: Run a Codex-native adversarial engineering audit of a codebase, pull request, feature, or launch candidate. Use when the user asks for a senior review, board audit, codebase audit, PR risk review, launch readiness check, architecture review, security/performance/resilience review, finding loopholes, "is this ready to ship?", or a report that ranks risks by severity. Produces audit deliverables rather than source-code changes unless the user explicitly asks for follow-up implementation after the audit.
---

# Senior Engineering Board

Use this skill to convene a four-role engineering board inside Codex. The board gathers repository facts first, separates evidence from inference, records disagreement, and issues written rulings.

Default posture: audit first, do not edit source files. Write audit deliverables under `docs/audit/{YYYY-MM-DD}/` unless the user asks for a different output path.

## Modes

Choose the narrowest mode that satisfies the request.

- `codebase-audit`: full repository review.
- `pr-review-board`: review a pull request or diff; prioritize regressions, missing tests, and merge risk.
- `launch-readiness`: pre-ship gate; include deployment, rollback, observability, security, and data-migration risks.
- `architecture-board`: review an idea, spec, or early skeleton before significant code exists.
- `follow-up-audit`: compare current state against a prior audit and track resolved, unresolved, and new findings.

If the user asks for fixes during an audit, record the fix as an action item. Only implement after the audit if the user explicitly switches from audit to implementation.

## Board Roles

Use these roles explicitly in reports when evaluating important components.

- **Auditor**: frames scope, gathers evidence, catalogs components, maps dependencies, and keeps the process moving.
- **Defender**: explains why the current design or implementation is reasonable, including constraints and tradeoffs.
- **Challenger**: attacks correctness, security, resilience, maintainability, performance, and unnecessary complexity with code-level evidence.
- **Judge**: decides. Verdicts are `KEEP AS IS`, `REFACTOR`, `REWRITE`, `DELETE`, or `SPLIT`. Severities are `BLOCKER`, `MAJOR`, `MINOR`, or `NOTE`.

The board must be direct, specific, and fair. Avoid vague praise, vague criticism, and equal-weight lists of nits.

## Workflow

1. **Confirm scope**
   - Identify mode, target paths, branch/PR if relevant, and deadline/stage.
   - Ask at most three clarifying questions only when the answer changes the audit materially.
   - Lock configuration at the start: ignored paths, generated files, size thresholds, and whether to include tests/docs.

2. **Build a repo snapshot**
   - Gather facts before judgment. Do not begin board rulings until the snapshot exists.
   - Classify project type, runtime stack, frameworks, package managers, storage layers, external integrations, CI/deployment shape, test presence, and generated/ignored paths.
   - Identify risk surfaces: auth, authorization, tenant boundaries, payments, file upload, webhooks, background jobs, migrations, external APIs, LLM/tool calls, secrets, and deployment rollback.
   - Record missing evidence explicitly. Missing evidence can become a finding only when it materially affects risk.
   - If available, run `scripts/repo-snapshot.ps1` from this skill as an optional read-only helper. The helper is not required; manual inspection is acceptable.

3. **Gather evidence**
   - Inspect repository structure with fast search tools such as `rg --files`.
   - Read README, package manifests, dependency manifests, routing/config files, CI, deployment files, tests, and representative core modules.
   - For PRs, inspect metadata, diff, changed files, review comments, and CI status when available.
   - Prefer read-only commands during the audit.
   - Label material statements as `Observed fact`, `Inference`, or `Open question`.

4. **Classify project and stage**
   - Project type: web app, API/backend, mobile app, SaaS/business app, AI/LLM product, library/tooling, data pipeline, or mixed.
   - `Blueprint`: mostly idea/spec/skeleton.
   - `Development`: working code, incomplete production hardening.
   - `Launch`: feature-complete or production-bound.
   - `Production`: already live; focus on incident risk and maintainability.
   - If the user says the stage conflicts with code evidence, note the conflict and use the user's stage as authoritative.
   - Read `references/audit-playbooks.md` when the project type or mode needs targeted checks.

5. **Inventory**
   - Catalog meaningful components: services, routes, jobs, screens, data models, migrations, integrations, scripts, and shared utilities.
   - Record path, purpose, dependencies, dependents, and risk notes.
   - Skip vendored, generated, and build-output files unless they are the subject of the request.

6. **Dependency map**
   - Map important dependency direction.
   - Flag circular dependencies, god modules, orphaned code, hidden runtime coupling, and long chains.
   - Use Mermaid when helpful; use a table for small scopes.

7. **Score risk**
   - Read `references/report-rubric.md` for scoring and severity calibration.
   - For each `BLOCKER` or `MAJOR`, assign confidence: `High`, `Medium`, or `Low`.
   - Use risk score components when useful: impact, likelihood, exploitability, blast radius, and reversibility.
   - Do not file unsupported claims. If evidence is incomplete, either lower confidence or move the item to open questions.

8. **Board review**
   - For each high-value component, run Defender, Challenger, and Judge.
   - For low-risk boilerplate, summarize in inventory instead of spending full board prose.
   - Ground every important finding in file paths, line references when available, observed behavior, or explicit uncertainty.
   - Include confidence for every `BLOCKER` and `MAJOR`.

9. **Challenge round**
   - Select the top three to five `BLOCKER` or `MAJOR` findings.
   - For each, describe the current failure mode, Defender's best objection, Challenger's proposed alternative, and Judge's chosen path.

10. **Final verdict and ratings**
   - Produce an overall rating from `0.0` to `10.0`.
   - Produce category ratings for Security, Reliability, Maintainability, Test Confidence, Performance, Observability, and Launch Readiness when applicable.
   - For each category, explain points lost and link deductions to finding IDs or open question IDs.
   - State launch or merge recommendation: `Ready`, `Ready with conditions`, `Not ready`, or `Blocked`.
   - Read `references/report-rubric.md` for rating deductions and recommendation rules.

11. **Write deliverables**
   - Create:
     - `report.md`
     - `inventory.md`
     - `dependency-map.md`
     - `challenge-rounds.md`
     - `unanswered-questions.md`
   - Keep `report.md` readable on its own and link to the supporting files.

## Severity Rules

- `BLOCKER`: likely data loss, security breach, financial/customer harm, launch rollback failure, or merge risk that should stop the release.
- `MAJOR`: likely production bug, serious maintenance trap, performance bottleneck, missing critical test, or resilience gap that should be fixed soon.
- `MINOR`: cleanup or localized risk with limited blast radius.
- `NOTE`: observation, commendation, accepted tradeoff, or low-priority follow-up.

When uncertain between two severities, choose the higher severity and explain what evidence would downgrade it.

## Default Questions

Use only the relevant questions. Keep unanswered but relevant questions in `unanswered-questions.md`.

For full stage question banks and red-flag catalogs, read `references/audit-reference.md` when the audit needs more depth.

Core questions:

- What breaks if this component is disabled?
- What input can a hostile or careless user control?
- What state can become inconsistent after retries, timeouts, concurrent writes, or partial failures?
- Where are authorization, validation, rate limits, and tenant scoping enforced?
- Where are external calls made, and do they have timeouts, retries, idempotency, and fallbacks?
- What work happens synchronously on a user-facing path?
- Which assumptions are undocumented or contradicted by code?
- Which tests prove the risky behavior, and which risky behavior is untested?
- How would the team roll back this change or release?

## Output Format

Use this structure for `report.md`:

```markdown
# Senior Engineering Board Audit

Project:
Date:
Mode:
Stage:
Scope:

## Executive Summary

## Final Verdict And Rating

## Findings By Severity

### Blockers

### Major

### Minor

### Notes

## Board Rulings

## Challenge Round Summary

## Recommended Action Plan

## Open Questions

## Supporting Files
```

For each finding include:

- Stable ID such as `F-001`
- Title
- Severity
- Verdict
- Evidence, separated into observed facts and inferences
- Confidence: `High`, `Medium`, or `Low` for all `BLOCKER` and `MAJOR` findings
- Risk score when scoring is useful
- Impact
- Recommended action
- Owner or follow-up area when inferable

For the final rating include:

- Overall rating: `0.0/10`
- Recommendation: `Ready`, `Ready with conditions`, `Not ready`, or `Blocked`
- Rating breakdown table with area, score, points lost, reason for deduction, and related finding/open-question IDs

## Guardrails

- Do not modify source code during an audit unless the user explicitly asks to switch to implementation.
- Do not run mutating commands during evidence gathering unless the user approves and the command is necessary.
- Do not claim a clean audit until checking security, data integrity, resilience, tests, and deployment/rollback risk.
- Do not bury `BLOCKER` or `MAJOR` findings below style commentary.
- Do not invent runtime facts. Mark unknowns as open questions.
- Do not let the Defender win by comfort alone or the Challenger win by perfectionism alone. The Judge rules on user harm, operational risk, and maintenance cost.
