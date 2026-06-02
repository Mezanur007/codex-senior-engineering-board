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

## Final Ratings

Use final ratings to make the verdict understandable to both technical and non-technical readers. Ratings are judgment aids, not mathematical proof. Every point deduction must reference a finding ID or open question ID.

### Categories

Score applicable categories from `0.0` to `10.0`:

- Security
- Reliability
- Maintainability
- Test Confidence
- Performance
- Observability
- Launch Readiness

If a category does not apply, mark it `N/A` and explain why in one sentence. Do not include `N/A` categories in the overall average.

### Deduction Ranges

Start each applicable category at `10.0`. Deduct points based on evidence-backed issues:

- `BLOCKER`: subtract `2.5` to `4.0`.
- `MAJOR`: subtract `1.0` to `2.5`.
- `MINOR`: subtract `0.25` to `1.0`.
- `NOTE`: subtract `0.0` unless repeated notes show a pattern.
- Relevant open question: subtract `0.25` to `1.5` when missing evidence materially affects confidence.

Cap each category at a minimum of `0.0`. Use one decimal place.

### Deduction Calibration

- Use the high end when the issue affects customer data, payments, auth, tenant isolation, deployment safety, or incident recovery.
- Use the middle when the issue is likely in production but recoverable.
- Use the low end when the issue is localized or the confidence is `Low`.
- Do not double-count the same finding heavily across many categories. If one finding affects multiple categories, apply the largest deduction to the primary category and smaller deductions elsewhere.
- Missing evidence can reduce Test Confidence, Observability, or Launch Readiness, but should not be treated as a confirmed security bug unless code evidence supports it.

### Overall Rating

Calculate the overall rating as the average of applicable category scores, then adjust by release-blocking severity:

- If any `BLOCKER` remains, overall rating must be `6.9` or lower.
- If two or more `BLOCKER` findings remain, overall rating must be `5.9` or lower.
- If there are no `BLOCKER` findings but three or more `MAJOR` findings remain, overall rating must be `7.4` or lower.
- If all findings are `MINOR` or `NOTE`, overall rating can be `8.0` or higher.

Round to one decimal place.

### Recommendation

- `Ready`: no `BLOCKER`, no unresolved high-impact `MAJOR`, and Launch Readiness is at least `8.0` when applicable.
- `Ready with conditions`: no `BLOCKER`, but one or more `MAJOR` findings must be fixed or accepted before release/merge.
- `Not ready`: at least one serious unresolved `MAJOR`, missing critical evidence, or Launch Readiness below `6.0`.
- `Blocked`: any `BLOCKER` that can plausibly cause security, data, payment, migration, or availability harm.

### Required Rating Table

Use this table in `report.md`:

```markdown
| Area | Score | Points Lost | Why Points Were Lost | Related Items |
|---|---:|---:|---|---|
| Security | 7.0/10 | -3.0 | Missing application-level auth rate limits. | F-002 |
```

The `Why Points Were Lost` column must be specific enough that the team knows what to fix to improve the next audit score.

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
