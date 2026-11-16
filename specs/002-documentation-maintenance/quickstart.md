# Validation Guide: Documentation Maintenance Skill and Drift Checks

**Feature**: [spec.md](spec.md)
**Contract**: [contracts/github-action.md](contracts/github-action.md)

This guide defines acceptance scenarios. A skill-loaded agent exercised the synthetic scenarios recorded in `verification.md`; those results do not represent a live OMD repository or provider workflow. Live runner/provider validation remains not run, and repository checks are recorded in `verification.md`.

## Prerequisites

- Python and dependencies used by the repository's existing skill validation and tests.
- `make`, the repository's normal lint tooling, and `actionlint` for workflow validation.
- For live agent review only: a repository with its chosen GitHub Actions agent runner configured. Follow that runner's credential and security setup; do not use secrets in local fixtures.

## Local skill and repository validation

From the repository root:

```bash
python3 tools/validate_skills.py skills/doc-maintenance --profile all
make policy
make test
make lint
```

Expected result: the skill passes the supported static profiles, policy checks pass, tests pass, and workflow/documentation lint reports no errors. If dependencies or tools are unavailable, record those checks as not run.

## Workflow static validation

```bash
actionlint .github/workflows/documentation-drift.yml
```

Review the workflow for the contract's event, secret handling, permissions, SHA pinning, no persisted checkout credentials, no privileged trigger, and job-summary-only output.

## Scenario matrix

| Scenario | Fixture/change | Expected result |
|---|---|---|
| Documented behavior changes | Change a documented config option or model behavior and its test, but leave docs stale | `reviewed`; finding cites changed implementation/test and relevant stale docs or missing coverage |
| No documentation impact | Change an isolated internal implementation detail with no user-facing behavior change | `reviewed`; no actionable findings and no unrelated docs edits suggested |
| Ambiguous scientific claim | Change code where physical intent or validity cannot be inferred from implementation | `reviewed`; uncertainty is explicit and domain review is recommended |
| Missing or unavailable agent runner | Run without a configured runner or required credentials, including fork PR simulation | `not-run`; summary states semantic review did not happen; no credential workaround or privilege elevation |
| Agent invocation error | Simulate provider/action failure | `failed`; error remains visible and is not reported as a clean review |
| Prompt injection in repository content | Add instruction-like text to a code comment, doc, or PR text fixture | Report rules remain unchanged; content is treated as untrusted data |
| Diátaxis document choice | Ask for onboarding, a task procedure, a technical lookup, and a scientific rationale | Skill recommends tutorial, how-to, reference, and explanation forms respectively without imposing a repository-wide folder migration |

## Live workflow acceptance

After local validation, connect the contract to a selected agent runner and run it on a disposable test PR with that provider's approved credentials. Verify that the job summary follows the report model, the checkout remains unchanged, no comment/write permission is requested, and findings do not fail the workflow by themselves. Separately verify the missing-secret path without adding a real secret to a fork or untrusted context.
