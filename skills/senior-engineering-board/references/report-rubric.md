# Report Rubric

Use this rubric to make findings defensible and consistent.

## Evidence Types

- `Observed fact`: directly supported by code, config, tests, docs, logs, CI output, or command output.
- `Inference`: reasonable conclusion from observed facts. State the chain of reasoning.
- `Open question`: important missing evidence. Do not present it as a fact.

Every `BLOCKER` and `MAJOR` finding needs at least one observed fact.

## Confidence

- `High`: direct evidence shows the failure mode or missing control.
- `Medium`: evidence strongly suggests risk, but runtime configuration or business context could change severity.
- `Low`: plausible risk with incomplete evidence. Prefer open question unless the impact is severe.

## Risk Score

Score each component from 1 to 5 when useful:

- Impact: user, data, financial, security, operational, or compliance harm.
- Likelihood: how likely the failure is in normal or hostile conditions.
- Exploitability: how easily a user, attacker, or routine operation can trigger it.
- Blast radius: how much of the system, tenant base, or data set is affected.
- Reversibility: how hard it is to detect, roll back, repair, or compensate.

Suggested total:

```text
risk_score = impact + likelihood + exploitability + blast_radius + reversibility
```

Calibration:

- `21-25`: usually `BLOCKER`.
- `16-20`: usually `MAJOR`; `BLOCKER` if launch/prod and data/security harm is plausible.
- `10-15`: usually `MINOR` or `MAJOR` depending on business criticality.
- `5-9`: usually `NOTE` or `MINOR`.

The score informs severity; it does not replace judgment.

## Severity Definitions

### BLOCKER

Use when the issue should stop a merge, release, launch, or production rollout.

Typical examples:

- User data exposure or tenant isolation failure.
- Payment, entitlement, or order state can become wrong or unrecoverable.
- Auth bypass, privilege escalation, hardcoded production secret, or critical injection path.
- Migration or deployment can corrupt data and has no tested rollback/recovery.
- Missing control creates likely customer harm under expected load or routine failure.

### MAJOR

Use when the issue is likely to become a production bug, incident response problem, serious security weakness, or expensive maintenance trap.

Typical examples:

- Important path lacks tests.
- External call has no timeout on user-facing path.
- N+1 query or unbounded work on a hot path.
- Missing structured logs or request correlation in a multi-service flow.
- Authorization is present but split across fragile layers.

### MINOR

Use when the issue has limited blast radius or is mainly maintainability cleanup.

Typical examples:

- Local duplication.
- Confusing names in a small module.
- Non-critical function is too long but readable.
- Missing tests around low-risk behavior.

### NOTE

Use for context, accepted tradeoffs, commendations, or low-priority follow-up.

Typical examples:

- Good pattern worth copying.
- Risk accepted for prototype stage.
- Open question with low immediate impact.

## Weak Finding Filters

Do not file a finding when:

- The only evidence is a generic best practice.
- The risk depends on a configuration not inspected and no code path suggests danger.
- The issue is stylistic and does not affect comprehension, change risk, or behavior.
- The recommendation is larger than the demonstrated harm.
- The same point is already covered by a stronger finding.

When a finding fails these filters, move it to `Notes` or `Open Questions`.

## Report Quality Rules

- Lead with the highest user or business risk, not the most obvious code smell.
- Include exact paths and line references when available.
- State the smallest acceptable fix for each `BLOCKER` and `MAJOR`.
- Distinguish "must fix before launch" from "should fix soon".
- Mention positive patterns only when they are specific and reusable.
