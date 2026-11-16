# Feature Specification: Reliable Instructions and Catalog Maintenance

**Feature Branch**: `spec/instruction-improvements`
**Created**: 2026-11-16
**Status**: Draft
**Input**: Review and improve all repository instructions, skills, and maintenance based on the GitHub review, for ocean and atmosphere modeling. Use CMake as the usual OMD default and avoid duplicating Spec Kit.

## User Scenarios & Testing

### User Story 1 - Receive the right instructions (Priority: P1)

A developer installs the catalog and receives the intended guidance for their agent and project, including the relevant operational and scientific-library guidance.

**Why this priority**: Missing or contradictory instructions can misdirect work.
**Independent Test**: Install into representative supported clients and inspect the delivered guidance.

1. **Given** a supported client, **When** instructions are installed, **Then** every intended instruction is delivered in the client-appropriate form.
2. **Given** a research project and an NCO delivery project, **When** guidance is selected, **Then** each receives rules applicable to its target and neither receives contradictory scope instructions.

### User Story 2 - Work within the project’s actual environment (Priority: P1)

A scientist or engineer working on ocean or atmosphere models receives guidance that respects the existing build system, compiler, target platform, and parallelization choices.

**Why this priority**: Rigid assumptions can produce unusable or inappropriate changes.
**Independent Test**: Review representative existing-build, new-project, research, and operational scenarios against the revised guidance.

1. **Given** a project with an established build system, **When** an agent proposes verification, **Then** it follows the project’s documented build and test workflow.
2. **Given** an OMD project without an established build system, **When** a default is needed, **Then** guidance treats CMake as the usual default, subject to project requirements.
3. **Given** an unknown operational target, **When** target-specific requirements would change the advice, **Then** the agent establishes the target or identifies the uncertainty.

### User Story 3 - Maintain a portable and trustworthy catalog (Priority: P2)

A contributor can update skills and instructions with clear discovery rules, useful validation, and an accurate understanding of what has been tested.

**Why this priority**: Changes must remain usable across supported clients and maintainable over time.
**Independent Test**: Exercise contribution checks and representative tool-availability and branch scenarios.

1. **Given** an available authorized GitHub integration, **When** an issue skill is used, **Then** its guidance can use that integration without requiring a particular tool namespace.
2. **Given** an unavailable integration or CLI, **When** a capability is requested, **Then** the guidance identifies the limitation and uses an available authorized alternative when appropriate.
3. **Given** a change to a maintained branch, **When** applicable checks run, **Then** their coverage and blocking behavior are documented and observable.

### Edge Cases

- Preserve client-specific behavior where genuinely required and label it.
- Do not apply WCOSS-only delivery mechanics to research-only work; do not claim research guidance establishes full EE2 compliance.
- Preserve existing user-managed content during installation and updates.
- Report unavailable client, cluster, or external-service checks as not run.
- Treat changing external operational facts as requiring source verification, not assumptions.

## Requirements

### Functional Requirements

- **FR-001**: Audit the master instructions and every repository instruction file for scope, applicability, internal contradictions, portability, and unsupported mandatory assumptions; record dispositions for findings.
- **FR-002**: Deliver every intended instruction to supported client adapters and identify any client-specific limitations.
- **FR-003**: Align instruction naming, references, discovery, and contributor guidance so intended instructions cannot silently be omitted.
- **FR-004**: Distinguish NCO/WCOSS delivery requirements from guidance applicable to RDHPCS and research; make the master, domain, and EE2 skill guidance consistent.
- **FR-005**: Respect existing project build, compiler, library, and parallelization conventions; use CMake as the usual OMD default only when no project build system is established and requirements permit.
- **FR-006**: Review all language and domain instructions, including Fortran, C/C++, Python, Bash, Makefile, HPC libraries, review guidance, and design patterns; retain justified target-specific rules.
- **FR-007**: Update GitHub-related skills to choose available authorized capabilities and provide a workable fallback or a clear limitation; identify write operations accurately.
- **FR-008**: Align maintenance checks with the repository's maintained branches and document triggers, blocking behavior, and the difference between static and behavioral validation.
- **FR-009**: Verify instruction delivery, target routing, and representative skill behavior with meaningful checks; explicitly report checks that cannot be executed.
- **FR-010**: Describe the catalog as supporting ocean and atmosphere modeling and broader scientific and engineering workflows.
- **FR-011**: Maintain existing attribution, licensing, supported-client intent, and user-managed installation content.
- **FR-012**: Use guidance from awesome-copilot and Spec Kit where useful without adding a duplicate specification workflow or expanding the catalog merely to match either project.

## Success Criteria

### Measurable Outcomes

- **SC-001**: All instruction files in the audited inventory have a recorded disposition, and no unresolved contradiction remains between the master guidance and revised EE2 routing.
- **SC-002**: Every intended instruction appears in each applicable supported-client installation scenario; regression checks detect omission.
- **SC-003**: Representative research, NCO delivery, existing-build, and new-project scenarios produce guidance consistent with the requirements above.
- **SC-004**: Changes to each confirmed maintained branch have an observable, documented validation path; all executed checks and unrun checks are reported.
- **SC-005**: At least one available-tool and one unavailable-tool scenario are assessed for GitHub issue guidance.

## Assumptions and Scope

- The review covers the catalog and repository maintenance, not a new specification platform.
- The existing README correction on `docs/ocean-atmosphere-scope` is a candidate to integrate, subject to checking its current state.
- The branch strategy and authoritative operational facts will be verified during planning; no unverified policy will be asserted as fact.
- Full live client and cluster testing depends on available environments; missing access is reported rather than simulated as success.
