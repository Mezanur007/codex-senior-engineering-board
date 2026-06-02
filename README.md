# Senior Engineering Board for Codex

An open-source Codex skill that brings structured senior-engineering audit workflows to GPT/Codex users.

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Codex Skill](https://img.shields.io/badge/Codex-Skill-blue.svg)](skills/senior-engineering-board/SKILL.md)

## Why This Exists

This project is a contribution to the Codex/GPT developer ecosystem: a reusable audit skill for teams that want sharper engineering judgment before merging, launching, or trusting a codebase.

Instead of a single friendly review, it creates an evidence-first board debate with observed facts, inferences, open questions, verdicts, confidence levels, and severity-ranked action items.

Senior Engineering Board convenes four review roles inside Codex:

- **Auditor** gathers evidence and maps the codebase.
- **Defender** argues why the current implementation is reasonable.
- **Challenger** attacks correctness, security, resilience, performance, and maintainability.
- **Judge** issues a verdict and severity.

The skill is designed for teams using GPT/Codex who want a sharper review ritual before merging large changes, launching a system, or trusting a codebase.

## What Makes It Intelligent

- **Evidence-first workflow**: Codex gathers repository facts before making judgments.
- **Project classification**: The skill identifies project type, stage, runtime stack, risk surfaces, and missing evidence.
- **Targeted playbooks**: Web apps, APIs, mobile apps, SaaS systems, AI products, PRs, and launch reviews use different checks.
- **Risk scoring**: Important findings can include impact, likelihood, exploitability, blast radius, reversibility, and confidence.
- **Final rating breakdown**: Reports can score key areas out of 10 and show exactly which findings reduced each rating.
- **No unsupported claims**: Reports separate observed facts, inferences, and open questions.

## What It Produces

By default, the skill writes audit deliverables to:

```text
docs/audit/YYYY-MM-DD/
```

Expected files:

- `report.md` - executive summary, severity-ranked findings, board rulings, action plan
- `inventory.md` - components reviewed and risk notes
- `dependency-map.md` - important dependencies and coupling risks
- `challenge-rounds.md` - deeper debate on the top findings
- `unanswered-questions.md` - open questions and missing evidence

## Install

Copy the skill folder into your Codex skills directory:

```text
skills/senior-engineering-board
```

Typical user-level destination:

```text
C:\Users\<you>\.codex\skills\senior-engineering-board
```

Or, for a project-local install, copy it into a repository-specific skills directory if your Codex setup supports project skills.

## Use

Ask Codex with one of these prompts:

```text
Use $senior-engineering-board to audit this codebase.
```

```text
Run a Senior Engineering Board review on this PR.
```

```text
Use $senior-engineering-board for launch readiness. Is this ready to ship?
```

```text
Find the loopholes in this system with the Senior Engineering Board.
```

For a deeper audit:

```text
Use $senior-engineering-board to run an evidence-first codebase audit. Include risk scores, confidence levels, and open questions.
```

For an executive final verdict:

```text
Use $senior-engineering-board to audit this codebase and include final ratings with point deductions for each issue.
```

For a launch gate:

```text
Use $senior-engineering-board for a pre-launch audit. Focus on rollback, migrations, secrets, load, observability, and security.
```

For a PR:

```text
Use $senior-engineering-board to review this PR as a merge gate. Prioritize regressions, missing tests, and deployment risk.
```

## Optional Repo Snapshot

The skill includes a read-only PowerShell helper that collects project facts before the board reasons over them:

```powershell
.\skills\senior-engineering-board\scripts\repo-snapshot.ps1 -Root .
```

It reports file counts, important manifests, test files, CI/deployment files, large files, TODO/FIXME markers, and possible secret-assignment locations. It intentionally does not print secret values.

## Highlight

This repository is intended to be useful as an open-source contribution:

- A practical Codex skill, not just a prompt.
- A reusable review workflow for GPT/Codex users.
- A structured method for codebase, PR, architecture, and launch-readiness audits.
- A starting point other developers can fork, adapt, and improve.

## Modes

- `codebase-audit`: full repository review
- `pr-review-board`: pull request or diff review
- `launch-readiness`: pre-ship operational and deployment review
- `architecture-board`: idea/spec/skeleton review
- `follow-up-audit`: compare against a previous audit

## Philosophy

This is not a linter and not a vulnerability scanner. It is a structured engineering judgment tool. It forces disagreement onto the record, then turns that disagreement into prioritized decisions.

The audit should be kind in tone, direct in judgment, and specific in evidence.

## License

MIT. See [LICENSE](LICENSE).
