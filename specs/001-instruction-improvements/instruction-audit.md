# Instruction audit

Reviewed 2026-11-16 against baseline 0d934976. NCEP's [WCOSS implementation standards](https://nws-hpc-standards.readthedocs.io/en/stable/) explicitly scope their requirements to NCEP production on WCOSS; the [Hera guide](https://docs.rdhpcs.noaa.gov/systems/hera_user_guide.html) describes RDHPCS Slurm operation. These sources establish the environmental distinction, not verification of every individual claim. Specific operational rules not independently checked remain subject to their linked authoritative source and target owner review.

| File | Intended scope | Finding and disposition |
| --- | --- | --- |
| .github/copilot-instructions.md | Master | Revise: universal operational, MPI, mdspan and workflow assumptions conflict with research and project choices. |
| bash.instructions.md | Shell | Revise: scope NCO job architecture and paths; preserve safe shell guidance. |
| code-review-generic.instructions.md | Code review | Revise: condition specialized tools and parallel checks on applicability; prefer project build. |
| cpp.instructions.md | C++ | Revise: C++23, Kokkos, mdspan and operational assumptions should follow the project. |
| ee2-standards.md | NCO/WCOSS | Rename and scope to target; source-check policies when used. |
| fortran.instructions.md | Fortran | Revise fpm, compiler, accelerator and restart conventions to follow project. |
| hpc-libraries.md | Scientific libraries | Rename and make API-specific rules conditional on actual libraries and access patterns. |
| makefile.instructions.md | Makefiles | Revise overly general build assumptions; retain applicable Make guidance. |
| oop-design-patterns.instructions.md | Design | Revise universal abstraction and dependency-injection mandates; favor appropriate design. |
| python.instructions.md | Python | Revise universal NCO, Pangeo, module-system and ML assumptions; follow project. |

Baseline branch: fork and NOAA-EMC default to develop; upstream develop at 0d934976; no upstream main ref observed. Retain main push trigger for compatibility while adding develop. All existing target-specific detailed requirements remain subject to current authoritative standards; no live cluster behavior was tested.

Scenario review: existing non-CMake builds retain their documented commands; an unspecified new OMD build may use CMake; research scripts do not inherit WCOSS J-job paths; NCO delivery uses current NCEP standards. These are static reviews, not model executions. Library API details were not independently verified against every installed version; follow linked version-specific documentation.

## GitHub skill audit

- github-issues: revise specific MCP namespace and mandatory CLI writes; references contain namespace-specific examples and need a capability-selection caveat.
- github-release: retain git/release workflow but replace fixed main branch example with the repository's actual default branch and state CLI availability.
- github-actions-efficiency: revise unavailable CLI fallback to use an available integration. github-actions-hardening and github-actions-runtime-upgrade-conventions: retain as workflow-analysis guidance; no required MCP namespace found in inspected entry points and references.

GitHub skill scenarios (static review): with a supported connected integration, use the authorized operation; if neither an integration nor authenticated CLI can perform it, state the limitation without claiming success. No agent or live write was executed.

## Dead-file and stale-guidance review

A repository scan found an outdated Getting Started summary (ocean-only) and a stale fpm testing reference in the broad code-review guide. The former is updated and now links to a new maintenance guide. The latter remains as an explicitly optional alternative under the project-first testing rule. No tracked source file was deleted: the inspected tree does not establish a dead file solely from lack of visible references, and installer/package reachability must be considered. A complete history-based dead-code determination is not made in this pass.
