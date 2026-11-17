# How to maintain OMD documentation with the doc-maintenance skill

Use this guide to install the skill in an ocean or atmosphere modeling project, choose a useful document form, and connect an existing agent runner to a GitHub Actions review.

## Install the skill

From your project directory, use the catalog installer to install only this skill for the agent client you use:

```bash
/path/to/omd-skills/install.sh \
  --agents codex \
  --domains doc-maintenance \
  --project . \
  --mode copy \
  --no-interactive
```

Replace `codex` with a supported client from [the installation reference](agent-install.md). Use the `--list` option to check available skill names. The installer preserves local edits and records managed files under `.ompd/` so updates and removal are safe.

## Choose a document form

Identify what the reader is trying to do, then follow the corresponding form. The examples are generic; confirm all commands, options, and scientific statements against the target model.

| Reader need | Document form | Example in an OMD project |
|---|---|---|
| Learn by completing a guided first experience | Tutorial | Build and run a small model case with checkpoints |
| Complete a particular task | How-to guide | Configure an experiment or diagnose a failed run |
| Look up exact technical facts | Reference | Namelist options, units, dimensions, defaults, and valid values |
| Understand why a system works a certain way | Explanation | Grid choices, coupling design, or a numerical method |

Use the project's existing documentation layout. Separate mixed content only when doing so improves the reader's path. See the skill's [writing guidance](../skills/doc-maintenance/references/writing.md) for examples and review steps.

## Author or update a document

1. Tell your agent the audience, task, scope, and requested document form.
2. Ask it to inspect the project's instructions and nearby docs, then verify behavior against source, tests, build files, configuration, and authoritative sources as appropriate.
3. Review the evidence paths and any stated uncertainties before accepting the text. A passing test describes the tested cases; it does not alone prove physical validity, numerical accuracy in all conditions, or operational readiness.
4. Check commands, links, units, file formats, prerequisites, and expected results against the target project's actual workflow.

For an audit, request a report first. Ask for edits separately when you are ready to change documentation. The skill's [audit procedure](../skills/doc-maintenance/references/audit.md) distinguishes stale, missing, ambiguous, possibly orphaned, and not-verifiable documentation; an apparently orphaned page needs owner review before removal.

## Use from GitHub Actions

This catalog supplies provider-neutral skill instructions and an invocation/report contract. It does **not** include a ready-to-run workflow, model runtime, or vendor-specific Action. Your repository must choose an agent runner that can read the skill and relevant source/doc context, then pass it the pull request base/head revisions and changed paths.

To enable review, add your selected agent runner to the repository's chosen GitHub Actions workflow and pass it the skill instructions, change scope, and relevant project context described in the [integration contract](../skills/doc-maintenance/references/github-actions.md). The catalog does not supply that provider-specific workflow step. To disable review, remove or skip that runner step/job; the skill can remain installed for manual work.

Before enabling the runner:

- Use an unprivileged PR event such as `pull_request`; do not use `pull_request_target` to make secrets available while processing PR code.
- Give the runner read-only repository access and no write token. Do not execute PR-controlled scripts as part of the documentation review.
- Supply review instructions from a trusted source such as a pinned catalog version or the base branch. Treat PR content and agent instruction files in the proposed change as untrusted data.
- Publish the report to the Actions job summary. Keep `reviewed`, `not-run`, and `failed` distinguishable; do not describe a missing runner or unavailable credential as a clean review. Changed-path collection and repository link/format checks are deterministic scope/hygiene checks; semantic comparison requires the configured agent runner.
- Tell contributors which source, documentation, and PR data the chosen provider receives, and follow that provider's current security and credential guidance.

The integration contract and its limits are in the skill's [GitHub Actions guide](../skills/doc-maintenance/references/github-actions.md). To remove the skill itself, use the installer's `--uninstall` option as described in [the installation reference](agent-install.md). A generated prompt or changed-file list is not a semantic drift review. Keep the result advisory until maintainers have evaluated its accuracy.

## Understand the report

The [report format](../skills/doc-maintenance/references/report-format.md) requires a status,
review scope, evidence, uncertainty, and suggested human follow-up. A `reviewed` report with no
actionable findings covers only the inspected scope. It does not certify the science. A `not-run`
result means semantic review did not happen; a `failed` result means the runner could not complete.

### Example finding (illustrative)

The paths and values below are fictional and demonstrate report structure only.

**Likely stale default — output interval**

- **Changed code evidence**: `src/io/config.F90`, default `OUTPUT_INTERVAL=3`; test
  `tests/test_config.py::test_default_output_interval` asserts the value `3`.
- **Documentation evidence**: `docs/configuration.md`, “Output interval” section, says the default is `6`.
- **Reasoning**: The documented default differs from the changed source and the cited test.
- **Uncertainty**: The test supports this configured default only; it does not establish broader
  scientific validity or behavior outside its tested conditions.
- **Suggested follow-up**: Confirm the default and test scope, then update the reference section.

## Update or remove the installed skill

Use the same catalog installer and agent/project selection to refresh or uninstall the skill. Consult [the installation reference](agent-install.md) for `--uninstall`, collision handling, and preservation of local edits. Removing the skill from a project does not remove project documentation the skill helped create.
