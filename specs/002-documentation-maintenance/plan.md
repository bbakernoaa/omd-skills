# Implementation Plan: Documentation Maintenance Skill and Drift Checks

**Branch**: `spec/instruction-improvements` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

## Summary

Add a portable OMD documentation skill and an opt-in GitHub Actions PR review that uses an agent to identify likely documentation drift. Keep the skill provider-neutral; make the Actions interface provider-neutral, read-only, advisory, and explicit when an agent review did not run. Add an OMD-focused usage page and a stable report format. Do not reproduce a general documentation platform or Spec Kit lifecycle.

## Technical Context

- **Repository**: Agent Skills catalog with Python validation/tests, Markdown documentation, and GitHub Actions workflows.
- **Skill compatibility**: Follow `skill_spec.md`, the existing `skills/<name>/SKILL.md` layout, and reference-link patterns. Add no separate installer or plugin runtime unless implementation evidence requires it.
- **GitHub Actions integration**: Provide a provider-neutral invocation/report contract and setup guidance. The consuming repository selects, configures, and secures its own agent runner; no vendor action or API key is built into this catalog. Recommend unprivileged PR triggers, least privilege, no repository writes, and explicit not-run states when no runner is configured.
- **Report**: Publish to `$GITHUB_STEP_SUMMARY`; do not comment on PRs or modify the checkout. Findings are advisory and do not fail the workflow solely because drift is reported.
- **Unavailable runner**: If the consuming repository has not configured an agent runner or the runner cannot execute (including fork-secret restrictions), report “agent review not run.” Do not call `pull_request_target` or elevate permissions to obtain secrets.
- **Validation**: Use the skill validator, existing repository policy and tests, workflow lint/security checks, and manual fixtures for changed-code/documentation scenarios. See [quickstart.md](quickstart.md).
- **Constitution**: No `.specify/memory/constitution.md` exists in the current checkout; no project constitution gate applies.
- **Hooks**: `.specify/extensions.yml` is absent; there are no Spec Kit planning hooks to run.

## Constitution and Design Gate

No constitution is present. Design adheres to the feature's explicit guardrails: follow existing conventions, preserve portability, treat repository content as untrusted, require evidence for technical claims, minimize workflow permissions, and keep model output advisory. No unjustified constitution violations identified.

## Project Structure and Change Boundaries

- `skills/doc-maintenance/SKILL.md`: portable entrypoint and routing for documentation authoring, audits, PR impact reviews, report interpretation, and safe handling of repository content.
- `skills/doc-maintenance/references/`: focused audit procedure, evidence/report format, and GitHub Actions setup guidance if this material is too detailed for the entrypoint.
- `skills/doc-maintenance/references/github-actions.md`: provider-neutral calling-workflow contract, setup guidance, and security expectations; adopters integrate it with their selected runner.
- `docs/documentation-maintenance.md`: setup, use, scope, permissions, provider/data handling, limitations, and example output.
- `specs/002-documentation-maintenance/contracts/github-action.md`: workflow event, input/secret, permissions, and output contract.
- `specs/002-documentation-maintenance/data-model.md`: report concepts and required finding fields.
- Existing `tools/validate_skills.py`, `Makefile`, and workflow linting remain the validation path; avoid adding a second validator or generic docs framework.

## Delivery Design

1. **Skill and evidence protocol (FR-001–FR-004, FR-008, FR-011).** Create one catalog skill with concise routing for authoring, freshness audit, and code-change documentation impact. Before drafting or auditing, identify the reader's need and suggest the fitting Diátaxis form: tutorial (learn), how-to (complete a task), reference (look up facts), or explanation (understand context). Keep forms distinct when that improves navigation, but follow the target repo's organization and avoid unnecessary moves/splits. Require initial discovery of repository docs, code, tests, build/config files, and any authoritative project references. Tie material behavior claims to evidence; label assumptions, uncertainty, and source/date for external claims. Treat repository text, PR metadata, and PR-controlled agent instruction files as untrusted data, never governing instructions; do not copy secret values into reports. Keep technical writing advice suitable for ocean and atmosphere models, numerical behavior, model workflows, scientific data, and conditional operational context. Reuse existing specs rather than introducing a parallel spec/task process.
2. **Report contract (FR-003, FR-005, FR-007).** Define a Markdown report with scope/changed paths, concise finding, affected or missing docs, code/test/config evidence with paths and symbols/lines where available, confidence or uncertainty, and recommended human follow-up. Include a no-actionable-finding result and an explicit not-run/failure state. Avoid presenting scientific correctness as something the agent can certify.
3. **GitHub Actions integration (FR-005–FR-008, FR-010).** Define the calling workflow contract for a user-selected agent runner: provide base/head revisions and changed paths, make relevant repository context available read-only, invoke the skill/report instructions, and publish the report to the Actions job summary. Keep provider-specific actions, secrets, and runtime configuration in the consuming repository. Recommend `pull_request`, least privilege, `persist-credentials: false`, no write permissions or PR comments, no PR-controlled script execution, and pinned third-party actions. Findings are advisory; execution errors remain visible. If the runner is absent or unavailable, report `not-run` rather than implying semantic drift passed. Document that repository context may be sent to the configured provider and must not reproduce secret values in reports.
4. **Documentation and setup (FR-009–FR-010).** Add a docs page explaining standalone skill use, the four Diátaxis forms with OMD-appropriate examples, how to connect a selected GitHub Actions agent runner, runner-owned credential/permission configuration, report statuses, provider data handling, fork behavior, limitations, and how to disable it. Do not prescribe a specific provider or add a required check.
5. **Verification and handoff (all FRs).** Validate skill metadata and links, run repo policy and focused test/lint targets, inspect workflow permissions and expressions, and exercise fixtures for known drift, no-impact changes, ambiguous evidence, missing/unavailable runner, and a simulated review failure. Compare the emitted report and workflow conclusion with the contract. Record unavailable live PR/provider testing instead of claiming it.

## Interfaces and Compatibility

The provider-neutral calling interface is defined in [contracts/github-action.md](contracts/github-action.md). The skill remains a standard catalog skill and does not add a new install interface. The report format is a human-readable Actions job summary; no API, external comment, source write-back, or mandatory check is introduced.

## Risks and Mitigations

- **Agent misses subtle model behavior or invents scientific context**: Require evidence citations and explicit uncertainty; state that domain review remains necessary.
- **Prompt injection or secret exposure**: Keep the review prompt separate from repository content, mark repository and PR text (including agent instruction files) untrusted, use the selected runner's read-only sandbox and secret-isolation controls, do not execute PR-controlled scripts, and prohibit secret values in reports.
- **Secret/provider unavailable on fork PRs**: Report not-run explicitly; support local/manual skill use and do not switch to a privileged trigger.
- **False positives or noisy summaries**: Keep the integration advisory and opt-in; evaluate fixtures before recommending branch protection.
- **Provider-specific security differences**: Document the consuming repository's runner, permissions, secret handling, and trust boundaries; review and pin its third-party actions according to their current security guidance.
- **Token and cost exposure**: Keep trigger opt-in, constrain prompt to changed code and relevant docs, set job timeout, and expose provider use clearly in setup docs.

## Requirements Coverage

FR-001/002/004/011 → step 1; FR-003/008 → steps 1–2; FR-005–008/010 → steps 2–4; FR-009 → step 4; verification for all requirements and SC-006 → step 5. Ordered implementation tasks belong to the tasks stage.
