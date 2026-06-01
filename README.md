# Senior Engineering Board for Codex

A Codex-native adversarial engineering audit skill.

Senior Engineering Board convenes four review roles inside Codex:

- **Auditor** gathers evidence and maps the codebase.
- **Defender** argues why the current implementation is reasonable.
- **Challenger** attacks correctness, security, resilience, performance, and maintainability.
- **Judge** issues a verdict and severity.

The skill is designed for teams using GPT/Codex who want a sharper review ritual before merging large changes, launching a system, or trusting a codebase.

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
