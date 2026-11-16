# Verification record

Date: 2026-11-16

- Installer regression before fix: explicit domain instruction delivery test failed because Copilot destination was missing; after rename it passed.
- Installer lifecycle rename test passed: a user-edited stale managed instruction survives refresh and uninstall and the renamed instruction is installed. An additional test reproduced stale instruction files remaining after a rename; after the fix it confirms pruning of unchanged selected-adapter files while preserving unselected-adapter and user-owned files.
- `python3 -m unittest discover -s tests -p 'test_installer_*.py' -q`: 41 tests passed on a stable tree. An earlier concurrent run failed parity while source files were being edited; the isolated parity rerun and stable full rerun passed. Existing fixture code emitted ResourceWarnings about unclosed process streams.
- `make verify-new-skill`: passed with isolated local installations of pre-commit, actionlint, shellcheck, ruff, and markdownlint. Validator reported warnings about client catalog description budgets and other informational findings. An earlier invocation stopped at lint because pre-commit was absent.
- The full run above preceded the stale-instruction pruning fix; post-fix `make verify-new-skill` passed (80 root tests, 32 skill-search tests, repo policy, and four lint hooks); installer-only rerun passed 42 tests.
- `make lint`: passed with the tools above; rerun after final documentation edits.
- Repository policy check passed. `git diff --check` passed before final record updates.
- NCEP WCOSS standards and RDHPCS Hera documentation inspected for target distinction on 2026-11-16; individual operational rules and every machine fact were not reverified.
- Research/NCO, build selection, and GitHub available/unavailable scenarios were reviewed statically. Live agent/model behavior, client CLIs, cluster jobs, and GitHub Actions runs were not run.

The maintenance guide and Getting Started changes were included before the post-fix verification.

## Review and remaining limitations

All FR-001 through FR-012 and SC-001 through SC-005 were compared against the task artifacts and changes. The checklist verifies requirements quality, not behavior. Explicit adapter tests include two renamed files and managed-block content, while actual client interpretation is not proven. Maintained branch verification found both fork and NOAA-EMC default to develop; main was retained for compatibility. Current policy and installed-library documentation must be checked for any target-specific operational decision.
