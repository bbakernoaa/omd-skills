# Tasks: Reliable Instructions and Catalog Maintenance

**Input**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [quickstart.md](quickstart.md)
**Baseline**: `develop` at `0d934976e7a004465e6262822f75aaf6e0481de6`; recheck before implementation.
**Tracking**: Mark a task complete only after its listed evidence passes; record blockers and unrun checks. Preserve existing task states.

## Phase 1: Setup and foundational audit

- [ ] T001 Check branch head, repository instructions, `.specify/feature.json`, and current `specs/001-instruction-improvements/tasks.md`; record changed assumptions and confirm the maintained branch set before editing.
- [ ] T002 Inventory `.github/copilot-instructions.md` and every file in `.github/instructions/` in `specs/001-instruction-improvements/instruction-audit.md`; for each record intended scope, conflicts, unsupported assumptions, authoritative source and review date when applicable, and retain/revise/defer disposition. Verify relevant NCO/RDHPCS facts; record inaccessible sources and do not invent policy.

## Phase 2: User Story 1 — Receive the right instructions (P1)

**Goal**: Deliver the intended guidance and align operational scope.
**Independent test**: Install into fixture projects for each applicable adapter; inspect expected instructions and compare research and NCO/WCOSS routing.

- [ ] T003 [US1] Add explicit expected-name and content regression cases to `tests/test_installer_agents.py` for EE2 and HPC library guidance through Copilot, Cursor, Claude, Codex, OpenCode, and Gemini; demonstrate the omission before the fix.
- [ ] T004 [US1] Add rename/update, local-edit preservation, scope-limited stale pruning, and uninstall regression cases to `tests/test_installer_lifecycle.py` and `tests/installer_fixtures.py`; verify no user-managed content is overwritten or removed.
- [ ] T005 [US1] Rename `.github/instructions/ee2-standards.md` and `.github/instructions/hpc-libraries.md` to the existing `*.instructions.md` convention; update references and, only if needed for safe migration, `tools/installer/catalog.sh`, `tools/installer/rules.sh`, and `install.sh`. Run the focused installer suites from T003–T004.
- [ ] T006 [US1] Reconcile target scope across `.github/copilot-instructions.md`, `.github/instructions/ee2-standards.instructions.md`, and `skills/omd-standards/ee2-standards/SKILL.md`: distinguish NCO/WCOSS delivery from research/RDHPCS and identify unknown targets without claiming full compliance. Review representative target scenarios and record source evidence in `instruction-audit.md`.

## Phase 3: User Story 2 — Work within the project’s actual environment (P1)

**Goal**: Preserve existing project conventions and make CMake the usual OMD default when an otherwise unspecified build is needed.
**Independent test**: Inspect scenarios for an established non-CMake build, an unspecified OMD build, and projects with differing compiler and accelerator constraints.

- [ ] T007 [US2] Revise `.github/instructions/fortran.instructions.md` to follow the existing build and test workflow; use CMake as the usual OMD default only where no project build system exists and requirements permit. Remove unconditional fpm and unsupported universal compiler, GPU, or parallelization mandates; assess the independent scenarios.
- [ ] T008 [US2] Apply T002 dispositions to `.github/instructions/bash.instructions.md`, `cpp.instructions.md`, `python.instructions.md`, and `makefile.instructions.md`; preserve justified target-specific rules and document scenario evidence in `specs/001-instruction-improvements/instruction-audit.md`.
- [ ] T009 [US2] Apply T002 dispositions to `.github/instructions/hpc-libraries.instructions.md`, `code-review-generic.instructions.md`, and `oop-design-patterns.instructions.md`; reconcile with the master and language guidance and document remaining source uncertainties in `instruction-audit.md`.
- [ ] T010 [US2] Reconcile any remaining master-instruction conflicts in `.github/copilot-instructions.md` identified by T002, T008, and T009; confirm every inventoried file has a disposition and no unresolved master/EE2 routing contradiction remains.

## Phase 4: User Story 3 — Maintain a portable and trustworthy catalog (P2)

**Goal**: Make GitHub skills portable and make validation coverage understandable.
**Independent test**: Assess available and unavailable GitHub tools, inspect maintained-branch workflow triggers, and run documented checks.

- [ ] T011 [US3] Audit `skills/github-issues/SKILL.md`, `skills/github-release/SKILL.md`, `skills/github-actions-efficiency/SKILL.md`, `skills/github-actions-hardening/SKILL.md`, `skills/github-actions-runtime-upgrade-conventions/SKILL.md`, and their references for integration assumptions; record dispositions in `specs/001-instruction-improvements/instruction-audit.md`.
- [ ] T012 [US3] Revise `skills/github-issues/SKILL.md` and affected `skills/github-*/` references identified by T011 to prefer available authorized GitHub capabilities, use an available CLI fallback, state unavailable operations, and classify writes accurately; assess one integration-available and one integration/CLI-unavailable scenario.
- [ ] T013 [US3] Update `.github/workflows/lint.yml`, `repo-policy.yml`, `tests.yml`, and `validate-skills.yml` to cover confirmed maintained push branches, including `develop`, while retaining `main` unless evidence establishes otherwise; preserve PR filtering and existing blocking behavior and inspect event configuration.
- [ ] T014 [US3] Update `CONTRIBUTING.md` with instruction naming, client delivery, branch triggers, blocking behavior, and the distinction between static checks and client/model evaluations; document representative behavior scenarios and their evidence type.
- [ ] T015 [US3] Reconcile `README.md` with the correction on `docs/ocean-atmosphere-scope`, stating ocean and atmosphere modeling and broader workflows; check catalog/index consistency using `tools/repo_inventory.py` and preserve attribution and licensing.

## Phase 5: Cross-cutting verification

- [ ] T016 Run `python3 -m unittest discover -s tests -p 'test_installer_*.py' -v` and `make verify-new-skill` using `specs/001-instruction-improvements/quickstart.md`; record commands, outcomes, and missing dependencies in `specs/001-instruction-improvements/verification.md`.
- [ ] T017 Review the actual diff and `specs/001-instruction-improvements/instruction-audit.md` against every FR and SC in `specs/001-instruction-improvements/spec.md`; record live source, client, cluster, and GitHub Actions checks separately from static reviews and mark unavailable checks not run in `verification.md`.

## Dependencies and execution

T001 precedes T002; T002 precedes all story work. T003–T004 precede T005; T005 precedes T006–T010 where renamed paths are needed. T006 precedes T010; T007–T009 precede T010. T011 precedes T012. T013 depends on T001's branch review; T014 follows T005, T012, and T013. T015 is independent after T002. T016 follows implementation and T017 follows T016.

The delivery and routing work in US1 is the MVP; US2 and US3 complete the requested scope. Independent work after the foundation can be scheduled separately only where it does not edit shared files: for example T011 and T013 can be performed independently, and T015 can be reviewed separately. Integrate and verify shared files sequentially. No delegation is required.
