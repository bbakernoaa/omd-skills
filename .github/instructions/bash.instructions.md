---
description: Bash and operational shell guidance
applyTo: "**/*.{sh,bash}"
---

# Shell guidance

Follow the project's shell, supported platforms, style, and existing interfaces. Use a Bash shebang only for Bash scripts; preserve POSIX shell where required. Quote expansions, validate inputs and paths, check command failures, and handle temporary files and cleanup safely. Use strict mode only when its semantics are understood and appropriate; do not rely on it as the sole error check.

For NCO/WCOSS delivery, follow the current [NCEP implementation standards](https://nws-hpc-standards.readthedocs.io/en/stable/) for job architecture, paths, logging, and scheduler behavior. Do not impose J-jobs, NCO environment variables, or operational output destinations on research-only scripts. If the target affects the advice and is unknown, ask or state the uncertainty. Follow the target's scheduler and process management rules.

Run the project's shell checks and relevant tests; report unavailable verification. See the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) when consistent with project conventions.
