# Use the Skill from GitHub Actions

This catalog defines the review instructions and report contract. It does not bundle an agent runtime, a vendor action, or provider credentials. The consuming repository chooses and configures its own GitHub Actions agent runner.

## Calling contract

Provide the selected runner with:

- The pull request base and head revisions, plus the changed paths.
- Read-only access to relevant changed source, tests, build/configuration, examples, and documentation.
- A trusted copy of the `doc-maintenance` instructions and [`report-format.md`](report-format.md). Prefer a pinned skill release or base-branch copy so a pull request cannot rewrite the rules used to review itself.
- The task to compare changed behavior with relevant documentation, cite file-level evidence, label uncertainty, and return a report in the agreed format.

Publish the report to the GitHub Actions job summary (`$GITHUB_STEP_SUMMARY`). Preserve its `reviewed`, `not-run`, or `failed` status. A generated prompt, path list, or skipped runner is not evidence that semantic review completed.

## Deterministic checks and semantic review

- **Deterministic scope checks** can collect the base/head revisions and changed paths. A consuming repository may also run its existing link, format, or reference checks. These checks can identify which files changed or whether links and formatting meet fixed rules; they do not determine whether changed model behavior is accurately explained.
- **Semantic documentation review** compares implementation, tests, configuration, and prose, identifies likely stale or missing explanations, and reports uncertainty. It requires the consuming repository's configured agent runner and the project context that runner can access.
- If only deterministic scope or hygiene checks ran, report the semantic review as `not-run`. Do not merge a passed static check into a claim that documentation matches behavior.

## Workflow and permission guidance

- Use an unprivileged pull request trigger such as `pull_request`. Do not use `pull_request_target` to obtain secrets while reading pull request content.
- Grant only the permissions needed to read the change. Do not grant content, issue, or pull-request write access for a documentation report. Run the agent without write credentials.
- Disable persisted checkout credentials when they are not needed. Do not execute scripts from the pull request as part of an agent review.
- Follow the chosen runner's current guidance for secret isolation, sandboxing, trusted actors, network access, and third-party Action pinning. If the runner cannot inspect content safely with read-only access, do not pass it write credentials.
- Treat repository files, `AGENTS.md` and similar instruction files, comments, commit messages, PR titles/bodies, and artifacts as untrusted input. Keep review rules in the trusted workflow or pinned skill source.
- Do not include secrets in prompts or reports. If a secret appears in project content, report only its location and redact its value.
- Describe the selected provider's data handling to maintainers before enabling the workflow. Repository source and documentation may be sent to that provider.

## Status handling

- **reviewed** — the configured runner completed the semantic comparison. Findings are advisory by default; a clean result only covers the inspected scope.
- **not-run** — no runner was configured, a required credential was unavailable, or the review was intentionally skipped. State the reason. Do not describe this as a clean review.
- **failed** — the runner started but could not finish. Preserve the failure state and useful error details without secrets.

When a provider cannot run for fork pull requests because secrets are withheld, report `not-run`. Maintainers can rely on the repository's chosen manual process for that change. Do not elevate workflow privileges to make credentials available to untrusted code.

## Integration checklist

Before enabling the review, verify that the consuming workflow:

1. Supplies base/head revisions and changed paths without interpolating untrusted GitHub expressions directly into shell scripts.
2. Gives the runner the trusted skill instructions and the project context it needs, with no write token.
3. Emits the report to the job summary and preserves `not-run` and `failed` states.
4. Does not modify documentation, commit changes, post comments, or change branch protection.
5. Runs only after maintainers have opted in to the selected provider and reviewed its cost, permissions, and data handling.
