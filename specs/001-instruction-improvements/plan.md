# Implementation Plan: Reliable Instructions and Catalog Maintenance

**Branch**: `spec/instruction-improvements` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)
**Baseline**: `develop` at `0d934976e7a004465e6262822f75aaf6e0481de6`; recheck before implementation.

## Summary

Audit and correct all repository instructions, ensure intended guidance is installed, align operational and research scope, improve skill portability, and align maintenance checks with maintained branches. Preserve OMD's ocean and atmosphere modeling mission; use CMake as the usual default only for OMD projects without an established build system. Existing project conventions take precedence. Do not reproduce Spec Kit.

## Technical Context

- **Repository**: Markdown instructions and skills, Bash installer, Python test and validation tools, GitHub Actions.
- **Verification**: Existing `make verify-new-skill`, focused Python unittest suites, installer fixtures, workflow inspection, and representative instruction/skill scenarios. See [quickstart.md](quickstart.md).
- **Clients**: Installer adapters for Claude, Codex, OpenCode, Gemini, Cursor and Copilot; honor adapter-specific delivery. Other catalog clients are subject to their documented capabilities.
- **Constraints**: Preserve installed user edits, attribution, licenses, and unrelated changes. Do not claim actual client, network, or cluster testing when unavailable.
- **Research**: [research.md](research.md); confirm maintained branches and operational source facts before changing target-specific policy.
- **Constitution**: No project constitution was present in the reviewed baseline. Recheck before implementation; absence is not a blocker.

## Project Structure and Change Boundaries

- `.github/copilot-instructions.md` and every file under `.github/instructions/`: inventory, scope, and reconcile instructions. Maintain a review disposition alongside the change.
- `tools/installer/catalog.sh`, `tools/installer/rules.sh`, `tools/installer/adapters.sh`, `install.sh`: instruction discovery and delivery; change only where needed.
- `tests/test_installer_agents.py`, `tests/test_installer_lifecycle.py`, `tests/installer_fixtures.py`: delivery, update, user-edit and uninstall evidence.
- `skills/omd-standards/ee2-standards/` and `skills/github-*/`: align EE2 routing; audit GitHub skills and correct capability selection.
- `.github/workflows/{lint,repo-policy,tests,validate-skills}.yml`: branch triggers and check behavior.
- `CONTRIBUTING.md`, `README.md`, relevant tests and validation tools: contributor guidance, accurate scope and verification.
- `specs/001-instruction-improvements/`: approved requirements and planning evidence. The existing README correction on `docs/ocean-atmosphere-scope` must be reconciled without overwriting unrelated edits.

## Delivery Design

1. **Inventory and source audit (FR-001, FR-004, FR-006).** Enumerate every instruction file at the implementation revision, including nonstandard names, and the master file. Record each file's intended scope, discovered conflicts, source for operational claims, and disposition (retain, revise, or explicitly defer). Review all language and domain files, not only Fortran. Verify material EE2 and RDHPCS facts against authoritative sources; if unavailable, preserve and flag uncertain claims rather than inventing policy.
2. **Installation contract (FR-002, FR-003, FR-011).** Adopt the existing `*.instructions.md` naming convention for the two currently omitted instruction files, update all references, and preserve their frontmatter. Inspect current install records and migration behavior before choosing the precise transition; ensure updates do not overwrite locally edited files or leave unsafe stale managed copies. Add explicit expected-name tests for Copilot and Cursor and content checks for Claude, Codex, OpenCode, and Gemini blocks, rather than deriving expected names from the same glob under test. Verify reinstall, local edits, scope-limited pruning, and uninstall.
3. **Consistent target and build guidance (FR-004–FR-006).** Make NCO/WCOSS-specific requirements conditional; align the master file, EE2 instructions, and skill. For unknown targets, require clarification where materially necessary or report the uncertainty. Follow existing project build/test and accelerator conventions; otherwise consider CMake the usual OMD default. Remove unconditional fpm, GPU, or multi-paradigm requirements where the audit finds them. Preserve applicable safety and operational controls.
4. **Skill portability (FR-007, FR-009).** Inspect every `skills/github-*/SKILL.md` and relevant references for tool namespace and shell assumptions. Revise `github-issues` and any other affected skills to use available authorized capabilities first, provide an available CLI fallback, and state unavailable operations. Classify writes correctly. Add a small documented scenario set covering available integration, absent integration/CLI, research versus operational targets, and build selection; distinguish manual/model evaluations from static assertions.
5. **Maintenance and catalog (FR-008, FR-010–FR-012).** Verify repository and upstream branch conventions; include `develop` in push triggers for this default branch while retaining `main` where applicable. Keep PR path filtering and nonblocking full-catalog behavior unless a documented decision changes it. Explain coverage and limits in contributor guidance. Reconcile the README correction and assess catalog/index consistency with existing inventory tooling; avoid adding a separate site or workflow engine.
6. **Verification and handoff (FR-009–FR-011).** Run focused tests, then `make verify-new-skill` where dependencies permit. Inspect the actual diff and instruction dispositions, record source checks, and report every missing runtime or client test. Re-run relevant checks after any fix. No tests, jobs, or external sources are represented as verified without evidence.

## Interfaces and Compatibility

Instruction filenames and the generated client destinations are user-visible interfaces. Renames require updated links and migration tests for managed records, including locally modified files. Existing installer options and lock-file semantics remain intact. No new external API or data model is proposed; no separate API contracts or data model are needed.

## Risks and Open Verification

- The actual maintained branch set beyond this fork's `develop` requires confirmation; default to retaining `main` and adding `develop` pending evidence.
- Automatic instruction delivery varies by client; static adapter tests cannot prove model behavior.
- Authoritative standards and cluster policy may change; record source and date and mark unavailable verification explicitly.
- Catalog rename migration may interact with locally edited managed files; test before choosing implementation details.

## Requirements Coverage

FR-001/004/006 → steps 1 and 3; FR-002/003/011 → step 2; FR-005 → step 3; FR-007/009 → step 4; FR-008/010/012 → step 5; verification for all → step 6. Detailed ordered tasks belong to the next stage.
