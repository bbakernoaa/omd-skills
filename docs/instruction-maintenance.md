# Instruction and catalog maintenance

This page explains how to keep OMD Skills instructions useful across ocean and atmosphere modeling projects, research work, and operational delivery.

## Choose guidance for the target

Start with the project’s own conventions: supported compiler and libraries, build and test commands, scheduler, and deployment target. Existing project requirements take precedence. For an OMD project without an established build system, CMake is the usual default when it fits. Fortran instructions do not assume fpm, a GPU framework, or a particular parallel model.

Apply NCO/WCOSS requirements only when preparing that delivery. The [NCEP WCOSS implementation standards](https://nws-hpc-standards.readthedocs.io/en/stable/) describe production requirements; RDHPCS and research environments have their own systems and rules. Do not describe work as EE2-compliant without checking the target requirements. When the target materially changes the advice and is unknown, ask or state the uncertainty.

## Add or revise an instruction

Place installable instruction files in `.github/instructions/` and name them `*.instructions.md`. Include a short `description` and an `applyTo` glob that matches intended files. Keep rules focused, distinguish required rules from recommendations, and make environment-specific instructions explicit. Link volatile operational details to authoritative sources and verify them before changing advice.

Update references and tests when changing filenames or scope. Installer tests should assert expected filenames explicitly; deriving expectations from the same discovery glob can hide a missing file. For rename/removal behavior, verify that only selected adapters are pruned, locally edited managed files survive, and user-owned files remain untouched.

## Review unused or stale material

Before deleting a file, search tracked references, installer discovery, package data, tests, documentation links, and generated catalogs. Check whether the file is bundled or installed even when it has no direct import. Remove it only when those references and distribution paths are understood. Record the reason for deletion in the change description. For guidance, distinguish genuinely obsolete content from specialized content that remains useful to a smaller audience.

Review source dates, software versions, host names, queue names, and branch assumptions against primary documentation. Mark facts with sources and review dates where they change over time. Do not copy assumptions between WCOSS and RDHPCS systems.

## Validate changes

Run focused installer or content tests, then `make verify-new-skill`. This runs skill validation, repository policy checks, tests, and lint. Static compatibility validation does not run an agent client or model. If a behavior scenario is checked by inspection, label it static; if it is run in a client, record the client and result. Record unavailable cluster, client, or external service checks as not run.

See [Getting Started](getting_started.md), [Agent Install](agent-install.md), and [Contributing](../CONTRIBUTING.md) for related workflows.
