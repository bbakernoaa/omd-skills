# Tasks: Documentation Maintenance Skill and Drift Checks

**Input**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/github-action.md](contracts/github-action.md), [quickstart.md](quickstart.md)
**Tracking**: Mark tasks complete only after their acceptance evidence is checked; record blockers and unrun checks in `verification.md`.

## Phase 1: Setup

- [x] T001 Reconfirm the current branch, repository instructions, `.specify/feature.json`, and approved artifacts under `specs/002-documentation-maintenance/`; record any changed assumptions in `specs/002-documentation-maintenance/verification.md` before editing implementation files.

## Phase 2: Foundational report format

- [x] T002 Define the Markdown documentation-impact report in `skills/doc-maintenance/references/report-format.md`, including `reviewed`, `not-run`, and `failed` states; each finding must include changed-code evidence, affected or missing docs, uncertainty, and human follow-up, and must not claim scientific validation or reproduce secret values.

## Phase 3: User Story 1 — Create and maintain useful OMD documentation (P1)

**Goal**: Let contributors author and audit documentation from evidence while following project conventions and Diátaxis pragmatically.
**Independent test**: Use the skill on a documented feature, an identified documentation gap, and a task with a clear reader need; verify evidence links, uncertainty handling, and tutorial/how-to/reference/explanation guidance without forced restructuring.

- [x] T003 [P] [US1] Write `skills/doc-maintenance/references/writing.md` with OMD-focused writing guidance and examples for tutorials (learning), how-to guides (tasks), reference (technical lookup), and explanation (context); state that Diátaxis guides doc form without imposing directories or unnecessary splits.
- [x] T004 [P] [US1] Write `skills/doc-maintenance/references/audit.md` with documentation discovery and freshness-review steps across source, tests, build/configuration, existing docs, and authoritative sources; require material claims to cite evidence and label assumptions, external claims, conflicts, and unknowns.
- [x] T005 Create `skills/doc-maintenance/SKILL.md` as the portable catalog entrypoint for authoring, audits, and code-change documentation review; link to the writing, audit, and report references, define when to use the skill, preserve repository conventions, treat repository content as untrusted data, and avoid duplicating Spec Kit workflows.

## Phase 4: User Story 2 — Review documentation impact in GitHub Actions (P1)

**Goal**: Let repositories connect their chosen agent runner to the skill through a provider-neutral GitHub Actions contract.
**Independent test**: Assess the invocation contract with a configured runner, an unavailable runner, a change with likely documentation impact, and a change with ambiguous impact; verify that output follows the report format and no provider runtime is implied as bundled.

- [x] T006 Write `skills/doc-maintenance/references/github-actions.md` with the provider-neutral calling contract from `specs/002-documentation-maintenance/contracts/github-action.md`: pass base/head revisions and changed paths, provide relevant repository context read-only, invoke the skill instructions, publish the report to the Actions summary, and clearly report when review did not run; keep runner choice, credentials, and provider-specific permissions with the consuming repository.

## Phase 5: User Story 3 — Trust and maintain the documentation checks (P2)

**Goal**: Make setup, limitations, trust boundaries, and report meaning clear to maintainers.
**Independent test**: Review the setup guide and example reports; confirm a skipped review is distinguishable from a clean review, and repository/PR instructions cannot change review rules.

- [x] T007 Create `docs/documentation-maintenance.md` with OMD examples for the four Diátaxis forms, skill use, provider-neutral Actions integration, setup/disable guidance, report statuses, provider data handling, permissions, fork limitations, and the limits of code-derived scientific claims.
- [x] T008 Exercise the documented/undocumented, no-impact, ambiguous-science, prompt-injection, unavailable-runner, agent-failure, and Diátaxis scenarios from `specs/002-documentation-maintenance/quickstart.md`; record observations, limitations, and unrun live-provider checks in `specs/002-documentation-maintenance/verification.md` without treating model output as scientific validation.

## Phase 6: Polish and cross-cutting verification

- [ ] T009 Run `make verify-new-skill` from the repository root for `skills/doc-maintenance/`; record the exact command, outcome, dependency gaps, and any follow-up in `specs/002-documentation-maintenance/verification.md`.
- [x] T010 Reconcile `README.md` repository structure, `CONTRIBUTING.md` skill inventory, and `docs/getting_started.md` discovery links for the new skill; then review `skills/doc-maintenance/`, `docs/documentation-maintenance.md`, and the feature artifacts against every FR and SC in `specs/002-documentation-maintenance/spec.md`. Verify internal links, provider-neutral wording, trust/report consistency, and no duplicate Spec Kit lifecycle; record the review in `specs/002-documentation-maintenance/verification.md`.

## Dependencies and execution

T001 precedes implementation. T002 precedes the skill and Actions guidance. T003 and T004 are independent after T002 and can be completed in parallel; T005 links to their completed references. T006 depends on T002 and T005. T007 depends on T005 and T006. T008 follows the documented user flows. T009 and T010 follow implementation; T010 includes the final cross-artifact review.

The MVP is User Story 1 (T002–T005): a portable skill that can create and audit OMD documentation with evidence and pragmatic Diátaxis guidance. User Story 2 adds the provider-neutral Actions integration contract. User Story 3 makes trust, setup, and limitations clear. No provider-specific workflow or model runtime is included in the catalog.

## Requirement traceability

FR-001/002/011 → T003–T005, T007; FR-003 → T002, T004; FR-004 → T005, T010; FR-005/006 → T006; FR-007/009/010 → T006–T007; FR-008 → T004–T005, T008. SC-001/006 → T003–T005, T008; SC-002/003 → T002, T006, T008; SC-004 → T007; SC-005 → T005, T010. Final evidence for all requirements and criteria is captured in T008–T010.
