# Senior Engineering Board Audit

Project: example-api
Date: 2026-06-01
Mode: codebase-audit
Stage: Development
Scope: API routes, service layer, worker queue, deployment config

## Executive Summary

The board found one blocker and two major risks. The main issue is data integrity: order creation and payment confirmation can diverge during retries. The codebase has a clear service layout and readable route handlers, but it lacks idempotency, structured logging, and deployment rollback evidence.

## Findings By Severity

### Blockers

#### Checkout can charge without a durable order

Severity: BLOCKER  
Verdict: REFACTOR  
Evidence: `api/routes/checkout.ts` calls payment before the order state is committed.

Impact: A timeout or retry can charge the customer twice or leave support without a reliable order record.

Recommended action: Create a pending order first, use an idempotency key, finalize payment and order state transactionally, and move email delivery to a worker.

### Major

#### Public auth endpoints lack application rate limits

Severity: MAJOR  
Verdict: REFACTOR  
Evidence: Edge-level limits exist, but the application does not track attempts per account or tenant.

Impact: Credential stuffing and noisy automated attacks can reach the auth layer.

Recommended action: Add per-IP and per-account limits, log failed attempts, and alert on spikes.

#### Logs cannot trace a request across services

Severity: MAJOR  
Verdict: REWRITE  
Evidence: Services use plain log lines without request IDs.

Impact: Incident response will rely on manual correlation during failures.

Recommended action: Add request IDs at the edge and include them in every service log line.

## Board Rulings

### `api/routes/checkout.ts`

**Defender:** The route reflects the real business flow and is readable from top to bottom. Keeping payment close to order creation avoids spreading checkout logic across multiple files.

**Challenger:** The order of operations is unsafe under partial failure. Payment is an external irreversible action, but the durable local state is not established first.

**Judge:** REFACTOR, BLOCKER. The shape can remain familiar, but the transaction boundary and idempotency model must change before release.

## Challenge Round Summary

The Judge selected the pending-order pattern because it gives support and automation a durable state to reconcile, while preserving the current user-facing checkout flow.

## Recommended Action Plan

1. Fix checkout idempotency and order/payment state transitions.
2. Add auth rate limits and failed-login telemetry.
3. Add structured logs with request IDs.
4. Run a rollback drill before launch.

## Open Questions

- What is the expected peak traffic for launch week?
- Has the rollback process been timed?
- Which compliance requirements apply to stored customer data?
