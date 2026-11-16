# Research: Documentation Maintenance Skill and Drift Checks

**Date**: 2026-11-16
**Spec**: [spec.md](spec.md)

## Findings and Decisions

### 1. Reuse the repository's existing skill format and validation path

**Decision**: Add a normal catalog skill under `skills/doc-maintenance/`, following the Agent Skills format and the existing catalog's portable, reference-linked structure. Validate it through the repository's existing `make verify-new-skill` workflow during implementation.

**Rationale**: This repository already has skill discovery, compatibility checks, installation, attribution policy, and a documented validation target. A separate plugin framework or duplicated skill runtime would increase maintenance burden.

**Evidence**: `skill_spec.md`, `Makefile`, `tools/validate_skills.py`, `.github/workflows/validate-skills.yml`, and existing skill directories. The catalog CI already runs static compatibility and repo checks; it does not run a model.

**Alternatives considered**: A large bundled documentation tool suite like doc-superpowers. Rejected for this feature because the user asked for an OMD documentation skill and drift review, not a general documentation platform with release notes, ledgers, search, hooks, and spec lifecycle tooling.

### 2. Use Diátaxis as a pragmatic documentation design guide

**Decision**: Teach the skill to identify the reader need and recommend the corresponding Diátaxis form: tutorial (learning-oriented), how-to guide (goal-oriented), reference (information-oriented), or explanation (understanding-oriented). Apply this as guidance, not a required directory layout; respect project conventions and recommend splitting or reorganizing only when it helps readers.

**Rationale**: Documentation work includes onboarding, operational tasks, technical lookup, and scientific/design context. Those needs benefit from different document forms, but a catalog skill should not impose a taxonomy or migration on every target project.

**Evidence**: Official Diátaxis guidance identifies four distinct documentation needs and forms, and presents the framework as a pragmatic approach that can be applied iteratively. See [Applying Diátaxis](https://www.diataxis.fr/application/) and [Diátaxis in five minutes](https://www.diataxis.fr/start-here/).

**Alternatives considered**: Treating Diátaxis as mandatory folder names or a full documentation migration. Rejected because the feature should guide doc quality without overriding repository structure.

### 3. Keep the GitHub Actions interface provider-neutral

**Decision**: Do not bundle or select a model provider/action in the catalog. Define a provider-neutral invocation contract and setup guide that a consuming repository can use with its chosen GitHub Actions agent runner. The skill supplies review instructions and report format; the caller supplies the runner, credentials, and provider-specific security controls.

**Rationale**: The request was for a documentation skill usable from GitHub Actions, not for a Codex-specific workflow. Choosing one vendor would make the catalog less portable and force a credential/service decision on adopters.

**Evidence**: This repository distributes portable Agent Skills and supports multiple clients (`skill_spec.md`, `.github/workflows/validate-skills.yml`). Semantic code-to-doc review needs an agent, but no generic, provider-independent GitHub Action can run an arbitrary skill without a provider adapter. The interface should specify inputs, outputs, evidence, permissions, and unavailable-run status without claiming a turnkey model runtime.

**Alternatives considered**:
- Bundle `openai/codex-action`: evaluated as a concrete example, then rejected as the default because it fixes a provider and requires provider-specific credentials and security configuration.
- Bundle multiple provider implementations: rejected because it expands the support matrix and couples this skill to several external Action lifecycles.
- Deterministic path mapping alone: rejected as a semantic drift check; it may identify changed paths but cannot establish that documentation still matches behavior.

### 4. Keep the report evidence-based, advisory, and read-only

**Decision**: Use a stable Markdown report with changed paths, findings, documentation references, evidence locations, confidence/uncertainty, and suggested human follow-up. Findings are advisory; the consuming workflow should not edit files, commit changes, or post comments by default. Use unprivileged PR triggers and least-privilege permissions.

**Rationale**: OMD documentation may describe scientific behavior that cannot be proven from code alone. A traceable report lets model developers validate claims without treating model output as scientific validation. Read-only output also limits risk from untrusted PR content.

**Evidence**: Feature requirements FR-002/003/006/008 and local `skills/github-actions-hardening/references/permissions-and-tokens.md` and `triggers-and-privilege.md`. doc-superpowers' audit/report separation and explicit trust boundary informed the report approach without importing its broad command set.

**Alternatives considered**: Posting a PR comment requires write permission; running under `pull_request_target` to obtain secrets creates an unsafe privilege boundary. Blocking merges on findings before signal quality is known is inconsistent with the advisory scope.

## Sources

- Local repository: `skill_spec.md`, `Makefile`, `tools/validate_skills.py`, `.github/workflows/validate-skills.yml`, `skills/github-actions-hardening/references/permissions-and-tokens.md`, `skills/github-actions-hardening/references/triggers-and-privilege.md`.
- GitHub reference: [`woodrowpearson/doc-superpowers` skill](https://github.com/woodrowpearson/doc-superpowers/blob/main/skills/doc-superpowers/SKILL.md) and [README](https://github.com/woodrowpearson/doc-superpowers/blob/main/README.md), consulted for audit/report separation and untrusted repository-input handling.
- Official framework references: [Applying Diátaxis](https://www.diataxis.fr/application/) and [Diátaxis in five minutes](https://www.diataxis.fr/start-here/), consulted for the four documentation forms and iterative, pragmatic application.
- Provider evaluation: [`openai/codex-action` README](https://github.com/openai/codex-action/blob/main/README.md) and [security guide](https://github.com/openai/codex-action/blob/main/docs/security.md), consulted as one concrete runner example and rejected as a catalog dependency.

External references were consulted on 2026-11-16. Any provider Action added by a consuming repository must be independently reviewed and pinned according to that provider's current guidance.
