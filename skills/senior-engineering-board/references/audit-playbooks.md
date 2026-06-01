# Audit Playbooks

Load the playbook that matches the project type or requested mode. Use these checks to focus the board; do not treat every item as mandatory for every project.

## Web App

- Trace user-controlled input from forms, route params, query params, cookies, local storage, and file uploads.
- Check authentication boundaries, server actions/API calls, CSRF protection, session handling, and role-based UI assumptions.
- Review client/server data ownership: sensitive data must not rely on client-side hiding.
- Inspect route protection, redirects, cache headers, hydration assumptions, and error handling.
- Verify tests cover critical user flows, permission failures, and validation errors.

## API / Backend

- Inventory public endpoints, internal endpoints, workers, scheduled jobs, and webhook handlers.
- Check validation at boundaries, auth and authorization inside service logic, tenant scoping at query layer, and consistent error responses.
- Review database transactions, idempotency, retries, timeouts, pagination, rate limits, and slow query risk.
- Verify external integrations have timeouts, retries with backoff, circuit breakers where needed, and clear failure behavior.
- Check observability: structured logs, request IDs, metrics, alertable failure modes, and runbooks.

## Mobile App

- Identify offline behavior, local persistence, sync conflicts, push notifications, and version compatibility risks.
- Check secrets are not embedded in the app bundle and privileged operations stay server-side.
- Review auth token storage, refresh behavior, deep links, biometric flows, and PII handling.
- Verify app update compatibility with backend changes and migration paths for local data.
- Check crash reporting and user-impact telemetry for critical screens.

## SaaS / Business App

- Treat tenant isolation, roles, billing, entitlements, audit logs, exports, and admin tools as primary risk surfaces.
- Verify every tenant-scoped query is enforced server-side and cannot be bypassed through UI state or client claims.
- Check plan limits, feature flags, subscription transitions, invoices, refunds, and permission changes for race conditions.
- Review bulk import/export paths for PII leakage, authorization gaps, and unbounded work.
- Confirm support/admin actions are logged and constrained.

## AI / LLM Product

- Inventory prompts, models, tool calls, retrieval sources, memory, stored outputs, and provider fallbacks.
- Check prompt injection exposure from user content, documents, web pages, retrieval results, and tool output.
- Verify tool calls use explicit allowlists, schemas, and authorization checks.
- Check cost controls: per-call, daily, per-user, and per-tenant caps.
- Review validation before writing LLM output to databases or using it in code, SQL, shell commands, emails, or user-visible decisions.
- Confirm logs and traces do not expose unnecessary sensitive input or output.

## Pre-Launch

- Require evidence for deploy strategy, rollback timing, migration safety, backup restore, load testing, alerting, and on-call ownership.
- Treat "we can roll back manually" as insufficient unless the steps and timing are documented.
- Check migrations are backward-compatible with rollback or have a documented forward-only recovery plan.
- Verify production secrets are outside code and rotation is complete.
- Escalate missing load test, backup restore test, or alert test to at least `MAJOR`; use `BLOCKER` when customer data, payments, or regulated data are involved.

## PR / Diff Review

- Start from changed files, then inspect callers, callees, tests, migrations, configs, and generated artifacts affected by the diff.
- Prioritize behavioral regressions, missing tests, security boundary changes, migration compatibility, and deployment risk.
- Treat unrelated pre-existing issues as notes unless the PR makes them worse.
- Require a merge recommendation: `APPROVE`, `COMMENT`, or `REQUEST CHANGES`.
- For requested changes, state the smallest acceptable fix.
