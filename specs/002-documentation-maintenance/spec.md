# Feature Specification: Documentation Maintenance Skill and Drift Checks

**Feature Branch**: `spec/instruction-improvements`
**Created**: 2026-11-16
**Status**: Draft
**Input**: Create an OMD-focused documentation skill, informed by doc-superpowers, that helps author and audit project documentation and can be used in GitHub Actions to identify documentation drift from code. Keep the scope distinct from Spec Kit.

## User Scenarios & Testing

### User Story 1 - Create and maintain useful OMD documentation (Priority: P1)

An ocean or atmosphere model developer can use a repository skill to discover existing documentation conventions and source evidence, then create or update documentation that explains the actual software and its workflows.

**Why this priority**: Documentation needs to reflect real model behavior, build workflows, data flows, and operational constraints to be useful.
**Independent Test**: Use the skill on a representative OMD code area with existing documentation and on one with a documented gap; review its proposed work against repository evidence.

1. **Given** an OMD project with documentation conventions, **When** the skill is asked to document a change, **Then** it discovers and follows those conventions and links material claims to relevant code, tests, configuration, or authoritative external sources.
2. **Given** incomplete or conflicting evidence, **When** documentation is drafted, **Then** uncertainties and unresolved claims are identified instead of presented as facts.
3. **Given** an audit finds stale or missing documentation, **When** the user requests changes, **Then** the skill proposes focused edits and identifies the evidence supporting them.
4. **Given** a documentation task has a clear reader need, **When** the skill recommends a document or edit, **Then** it tries to use the matching Diátaxis form: tutorial for learning, how-to for completing a task, reference for lookup, or explanation for understanding.

### User Story 2 - Review documentation impact in GitHub Actions (Priority: P1)

A maintainer can opt a repository into an automated review that compares a code change with relevant documentation and reports likely documentation drift before merge.

**Why this priority**: A repeatable review catches documentation impact while the implementation context is available.
**Independent Test**: Run the workflow on changes with known documentation impact, no documentation impact, and ambiguous impact; inspect the reported evidence and workflow result.

1. **Given** a pull request changes code covered by documentation, **When** the review runs, **Then** it identifies affected documentation or missing coverage and provides file-level evidence.
2. **Given** the relationship between changed code and documentation is unclear, **When** the review runs, **Then** it reports uncertainty rather than asserting drift as fact.
3. **Given** a change has no relevant documentation impact, **When** the review runs, **Then** it reports no actionable finding without requiring unrelated documentation edits.
4. **Given** a repository has not opted into the workflow, **When** ordinary CI runs, **Then** documentation review does not add a required service, credential, or workflow permission.

### User Story 3 - Trust and maintain the documentation checks (Priority: P2)

A contributor can understand what the skill and workflow inspect, what evidence supports a finding, and what permissions or external services are involved.

**Why this priority**: A false or opaque gate can erode trust and create unsafe automation.
**Independent Test**: Review setup guidance, workflow permissions, and sample findings; verify that repository content cannot alter the reviewer's governing instructions.

1. **Given** repository files, pull-request text, or documentation contain instructions, **When** an audit or workflow processes them, **Then** they are treated as untrusted project data and cannot override the review instructions.
2. **Given** the workflow runs on a pull request, **When** it reports findings, **Then** it does not modify project documentation or source files.
3. **Given** external model or service access is unavailable or not configured, **When** the review runs, **Then** it follows its documented fallback or reports that the agent review was not run; it does not claim equivalent coverage.
4. **Given** workflow permissions are reviewed, **When** the feature is enabled, **Then** permissions are limited to those required to read the change and publish the configured report.

## Requirements

### Functional Requirements

- **FR-001**: Provide a portable documentation skill for OMD repositories that covers documentation discovery, authoring, freshness audits, and review of documentation impact from code changes.
- **FR-002**: Focus guidance on ocean and atmosphere modeling software, including scientific behavior, build and test workflows, data formats and flows, and operational context when applicable; follow the target repository's established conventions.
- **FR-003**: Require evidence for technical claims, distinguish code-derived facts from assumptions and externally sourced claims, and surface unresolved or conflicting evidence.
- **FR-004**: Keep the skill complementary to Spec Kit: it may link to or summarize existing specifications but does not introduce a competing feature-specification, task-tracking, or implementation lifecycle.
- **FR-005**: Provide provider-neutral guidance and an invocation/report contract for using the skill from GitHub Actions with an agent runner selected by the consuming repository. The integration must supply change context and emit a reviewable report with file-level evidence and uncertainty.
- **FR-006**: Make the workflow read-only with respect to repository content; it must not automatically edit, commit, or merge documentation changes.
- **FR-007**: Document which checks are deterministic and which require a configured agent runner or external service, along with the runner-specific credentials and permissions maintainers must evaluate, and the unavailable-service behavior.
- **FR-008**: Treat repository code, docs, comments, PR metadata, and generated reports as untrusted inputs; keep their content from changing governing review instructions.
- **FR-009**: Provide setup, usage, supported inputs and outputs, limitations, and example findings in an OMD-focused documentation page.
- **FR-010**: Keep GitHub Actions use opt-in and avoid bundling a vendor-specific runner, provider credential, write permission, or required check into the skill catalog.
- **FR-011**: Apply Diátaxis principles pragmatically when creating or reviewing docs: identify whether the reader needs to learn, perform a task, look up technical facts, or understand context, then guide toward the matching tutorial, how-to, reference, or explanation form. Respect existing repository conventions and do not force a directory reorganization or split documents when it would not help readers.

### Key Entities

- **Documentation evidence**: A source, test, configuration, specification, or authoritative external reference supporting a statement in project docs.
- **Documentation impact report**: Findings tied to changed files and relevant documentation, including evidence, uncertainty, and suggested human follow-up.
- **Drift review**: An opt-in check over a proposed change that assesses whether current documentation still matches supported behavior.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A contributor can use the skill to draft or audit documentation for an OMD code area and trace each material behavior claim to evidence or an explicit uncertainty.
- **SC-002**: The workflow reports affected documentation, missing coverage, or uncertainty with file-level evidence for representative code changes.
- **SC-003**: The workflow produces no repository content writes and requires no credentials or write permissions when configured for its credential-free mode.
- **SC-004**: Setup documentation lets a maintainer enable, disable, and interpret the review, including distinguishing skipped/unavailable agent checks from successful checks.
- **SC-005**: The feature adds no duplicate specification and task lifecycle alongside Spec Kit.
- **SC-006**: In representative doc-authoring and audit scenarios, the skill identifies the intended reader need and recommends a suitable Diátaxis form, while preserving existing project structure unless a change is justified.

## Assumptions and Scope

- The skill is intended for maintainers and contributors working on ocean and atmosphere modeling repositories.
- GitHub Actions use is opt-in and invokes the agent runner selected by the consuming repository; the catalog provides the provider-neutral contract, not a bundled model runtime.
- Reports are advisory by default; maintainers may configure whether findings affect check status after evaluating signal quality.
- The feature reviews documentation against observable repository evidence; it cannot establish scientific validity or replace domain review.
- The comparison with doc-superpowers is for useful design guidance only. This feature does not aim to reproduce its broader documentation platform.
- Diátaxis is a pragmatic guide for choosing and improving document forms, not a mandate to reorganize every repository into a fixed directory hierarchy.
