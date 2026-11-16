---
description: Python guidance for scientific and engineering workflows
applyTo: "**/*.py"
---

# Python guidance

Follow the project's supported Python versions, environment, dependencies, style, and test commands. Use the target's module system when required, not as a universal assumption. Do not introduce Pangeo, Dask, machine-learning frameworks, or suppress warnings without a task-specific reason.

- Validate inputs and errors; preserve numerical precision, dimensions, units, coordinates, and provenance where relevant. Use project documentation and typing conventions.
- For Xarray/Dask code, respect the documented eager or lazy contract, chunking, memory budget, and supported backends. Avoid unexpected materialization; test both backends when both are supported.
- For ML, check tensor shapes, device placement, and memory use. Use compilation or accelerator-specific techniques only when supported and justified.
- Follow current NCO/WCOSS standards for that delivery target; do not apply its operational paths or environment assumptions to unrelated research projects.
- Run the project's documented tests and checks; report commands and any verification not run. Avoid automatic formatting or fixes outside the requested scope.
