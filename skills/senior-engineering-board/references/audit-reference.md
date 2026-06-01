# Audit Reference

Load this file when the audit needs deeper stage-specific questions, risk catalogs, or report calibration.

## Stage Question Banks

### Blueprint

Use for ideas, specs, and early skeletons.

1. What is the expected user base in 6 months and 2 years?
2. What is the read-to-write ratio?
3. What are the target p95 and p99 latency goals?
4. What data growth is expected in 1, 3, and 5 years?
5. Does the system favor consistency or availability during dependency failure?
6. Why is the chosen architecture appropriate for team size and operational maturity?
7. Which data model is authoritative for each core entity?
8. Which work must be synchronous and which can be asynchronous?
9. What compliance regimes apply?
10. How are authentication and authorization designed?
11. Which data requires encryption, retention limits, or audit logging?

### Development

Use for working code that is still being built.

1. Where is the current bottleneck: CPU, memory, disk, network, database, or external API?
2. What is cached, where, and with what invalidation or eviction policy?
3. What happens under a 10x traffic spike?
4. Which hot queries have been explained or profiled?
5. What happens when each third-party API is slow or unavailable?
6. Where are timeouts, retries, circuit breakers, and rate limits?
7. Are workers and webhook handlers idempotent?
8. How are race conditions handled during concurrent writes?
9. Do logs carry request IDs, user IDs, tenant IDs, and error context?
10. Which alerts indicate critical failure, and who receives them?
11. How quickly can the team roll back a bad deployment?

### Launch

Use for pre-ship or production-bound work.

1. Can deployment be progressive through canary, blue-green, or feature flags?
2. What is the exact rollback plan and measured rollback time?
3. Are migrations backward-compatible with rollback?
4. Did load tests pass at 2x and 3x expected peak?
5. Are autoscaling rules live and tested?
6. Are rate limits enforced per IP, user, tenant, or endpoint as appropriate?
7. Was migration tested on a copy of real production data?
8. Are backups isolated, recent, and restore-tested?
9. What happens to writes during a rollback window?
10. Are dashboards and alerts working now?
11. Who is on call for the first 48 hours?
12. Are secrets rotated and stored outside code?
13. Are known high-severity vulnerabilities fixed or explicitly accepted?
14. Do logs exclude passwords, tokens, payment data, and unnecessary PII?

### Production

Use for live systems.

1. What incidents, support tickets, or flaky jobs have occurred recently?
2. Which code paths are highest traffic or highest revenue?
3. Which alerts are noisy, ignored, or missing?
4. Which dependencies are near end-of-life?
5. Which areas have the worst bus factor?
6. Which findings from prior audits remain unresolved?

## Red-Flag Catalog

### Code Structure

- Functions over 50 lines without clear phases.
- Files over 500 lines with mixed responsibilities.
- Classes over 300 lines or god objects.
- Deep nesting over four levels.
- Public APIs with vague names, unclear ownership, or too many parameters.
- Dead code, stale TODOs, commented-out code, or duplicated constants.
- Shared `utils` modules that hide domain behavior.

### Security

- SQL or shell commands built with string concatenation.
- User input passed to eval, template execution, file paths, redirects, or SSRF-capable URLs.
- Authorization based on client-supplied claims.
- Tenant scoping enforced inconsistently or only in UI.
- Hardcoded secrets or production credentials.
- CORS wildcard on authenticated endpoints.
- Missing CSRF protection for cookie-authenticated state changes.
- File upload without type, size, scanning, and storage controls.
- Webhooks without signature verification and replay protection.
- Logs containing passwords, tokens, payment data, or excessive PII.

### Data Integrity

- Payment, inventory, or entitlement changes without idempotency.
- Multi-step writes without transactions or compensating actions.
- Soft deletes mixed with hard deletes.
- Missing foreign keys or indexes on foreign keys.
- Nullable fields that business logic treats as required.
- Duplicate sources of truth without reconciliation.
- Migrations that cannot be rolled back safely.

### Performance

- N+1 queries on request paths.
- Unbounded queries, loops, pagination, or exports.
- External API calls inside loops.
- Synchronous LLM, email, file, or report generation on request paths.
- Cache without TTL, invalidation, or ownership.
- Connection pools missing, undersized, or leaked.

### Resilience

- External calls without timeouts.
- Retry without exponential backoff and jitter.
- Infinite retry or non-idempotent retry.
- No circuit breaker or fallback for critical dependency failure.
- Background jobs that can duplicate state on retry.
- Race-prone concurrent writes without locks, constraints, or version checks.
- Queue consumers with poison messages that block progress.

### Observability

- Errors swallowed or logged at the wrong level.
- Plain logs without request correlation.
- Metrics that do not map to user-visible failure.
- Dashboards that cannot answer "is the system healthy?"
- Alerts that have never been tested.
- No runbook for the top failure modes.

### AI/LLM Systems

- No per-call, per-user, or per-tenant cost cap.
- Model names hardcoded in business logic.
- Tool calls without an allowlist or schema validation.
- Prompt injection exposure through untrusted content.
- LLM output stored or executed without validation.
- No fallback provider, timeout, or replay capability.
- Sensitive prompts, user data, or tool traces logged without policy.

## Verdict Calibration

- Prefer `REFACTOR` when behavior is conceptually correct but needs safer structure.
- Prefer `REWRITE` when the current approach is fundamentally wrong or dangerous.
- Prefer `SPLIT` when one module owns multiple lifecycles, policies, or deployment risks.
- Prefer `DELETE` when code is unused, misleading, or superseded.
- Prefer `KEEP AS IS` when the Challenger cannot name concrete user harm or operational risk.

## Commendations

Use `COMMEND` sparingly for patterns worth copying elsewhere: clear boundaries, excellent tests around hard behavior, explicit failure handling, good migration safety, or simple code that solves a hard problem cleanly.
