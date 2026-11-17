---
description: Fortran guidance for ocean and atmosphere modeling
applyTo: "**/*.{f90,F90,f,for,ftn}"
---

# Fortran guidance

Follow the project's Fortran standard, compiler support, interfaces, style, and existing build and test workflow. When an OMD project has no established build system and its requirements permit, CMake is the usual default. Do not assume fpm. Apply NCO EE2 requirements only to the relevant NCO/WCOSS delivery; establish the target when it changes the advice.

- Prefer explicit interfaces, `implicit none`, appropriate argument intents, and portable kinds consistent with the project. Avoid unrelated refactoring of legacy code.
- Preserve array shape, bounds, data layout, numerical precision, and interoperability contracts. Validate inputs and errors at the appropriate boundaries.
- Select serial, MPI, OpenMP, OpenACC, GPU, or other approaches according to existing project support and actual targets. Do not introduce an accelerator framework or directives solely because a loop is computationally heavy. Check dependence, reductions, and data movement before parallelization.
- Separate computation from I/O when appropriate to the project architecture. Follow the target's restart and operational conventions rather than assuming a particular environment variable.
- Document public interfaces and scientific assumptions using project conventions. Provide focused numerical tests with appropriate tolerances and edge cases.
- Run the project's documented configure, build, and test commands and report results. If unavailable, give the intended verification and identify it as not run. For a new CMake project, use its documented CMake/CTest workflow rather than assuming a particular test layout.
