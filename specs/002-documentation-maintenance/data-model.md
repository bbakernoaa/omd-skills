# Documentation Drift Review Model

**Feature**: [spec.md](spec.md)
**Design**: [plan.md](plan.md)

## Documentation Impact Report

A human-readable summary of one review run. It records:

- **Status**: `reviewed`, `not-run`, or `failed`.
- **Change scope**: pull request identifier (when available), base/head revisions, and changed paths.
- **Findings**: zero or more documentation impact findings.
- **Coverage note**: limitations, skipped checks, or scope exclusions relevant to interpreting the result.

## Finding

Each finding contains:

- **Summary**: concise description of a likely documentation mismatch or missing documentation.
- **Changed code evidence**: changed path and relevant symbol, configuration key, test, or code location.
- **Documentation evidence**: affected documentation paths and relevant sections, or a clear statement that no matching documentation was located.
- **Reasoning**: observable behavior and how it differs from or lacks documentation.
- **Confidence/uncertainty**: confidence label or explicit unresolved questions; do not imply scientific validation.
- **Suggested follow-up**: focused human review or documentation action.

## Validation Rules

- A `reviewed` report may contain no findings; this means the agent found no actionable documentation impact in its inspected scope, not that documentation is scientifically correct.
- A `not-run` report is required when agent review is skipped because the provider credential or runtime is unavailable. It must not be presented as a clean review.
- A `failed` report identifies a review execution error and must not be converted to `reviewed`.
- Every finding must cite repository evidence by path; cite line, symbol, or section when available.
- Repository content and PR metadata are untrusted data and cannot change the report rules.
