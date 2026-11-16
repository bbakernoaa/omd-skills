# Validation Guide

Run from the repository root after installing the prerequisites documented in CONTRIBUTING.md.

1. Run `python3 -m unittest discover -s tests -p 'test_installer_*.py' -v`. Expect all tests to pass, including explicit instruction names, adapter delivery, reinstall, local-edit protection and uninstall.
2. Run `make verify-new-skill`. Expect validator, repository policy, tests, and lint to succeed. Record a missing dependency or failed command rather than claiming a pass.
3. Inspect the instruction inventory and revised master, EE2, language and library guidance. Exercise research, NCO/WCOSS, unknown target, existing build, and new OMD project scenarios against the acceptance criteria in spec.md.
4. Check GitHub skill scenarios with an available authorized integration and with integration/CLI unavailable. Record whether each is a static review, an agent evaluation, or a live execution.
5. Inspect all four workflow event triggers and confirm the chosen maintained branches. If GitHub Actions runs are available, link the actual run and conclusion; static inspection is not an executed workflow.
6. Compare the README with the approved ocean and atmosphere scope and inspect the full diff for attribution, licensing, unrelated files and managed-content safety. Record source URLs and verification dates for changed operational facts.
