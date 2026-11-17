# GitHub Actions Integration Contract: Documentation Drift Review

**Feature**: [spec.md](../spec.md)
**Design**: [plan.md](../plan.md)

## Trigger

- Opt-in workflow listens to `pull_request` events for opened, synchronized, and reopened PRs. It may also support `workflow_dispatch` for manual review.
- Do not use `pull_request_target` or a privileged follow-up workflow.

## Inputs and Agent Runner

- Pull request base/head revisions and changed paths come from the GitHub event and checkout/fetch context.
- The consuming repository chooses and configures its agent runner. This catalog supplies no provider action, runtime, API key, or universal secret name.
- The caller makes relevant code, tests, configuration, and documentation available to the runner as read-only context and supplies the skill review instructions.
- If the runner or its required credential is unavailable, the report status is `not-run` with a reason. Fork PRs may not receive repository secrets; do not use a privileged trigger to bypass that restriction.

## Permissions and Execution

- Prefer `pull_request` with empty default token permissions and only `contents: read` where checkout/history access is needed.
- Do not grant `pull-requests: write`, `issues: write`, or other write scopes for this review. Do not persist checkout credentials or execute PR-controlled scripts.
- Treat PR-controlled agent instructions and all repository content as untrusted data. Follow the selected runner’s security guidance for sandboxing, secrets, trusted actors, and unprivileged execution.
- If report publication requires a follow-up job, pass report data only; do not check out or execute PR content in that job. Review and pin third-party Actions according to the provider’s current security guidance.

## Output

- Write a Markdown Documentation Impact Report to `$GITHUB_STEP_SUMMARY`.
- Report status is `reviewed`, `not-run`, or `failed`, following [data-model.md](../data-model.md).
- Findings themselves are advisory and do not make the workflow fail. Review execution errors remain visible as failures.
- The workflow does not edit files, commit, merge, post comments, or make branch protection changes.

## Data Handling

When enabled, the configured runner may send the review prompt and repository context to its provider. The consuming repository must document this data flow and opt in. Do not claim that merely generating a prompt or changed-file list completed semantic review.
