---
description: C and C++ guidance for scientific computing
applyTo: "**/*.{cpp,hpp,c,h,cc,hh,cxx,hxx}"
---

# C and C++ guidance

Follow the project's language standard, compiler support, dependencies, APIs, build system, and style. Do not require C++23, Kokkos, mdspan, or a particular test framework unless the project supports and needs it.

- Make ownership, lifetimes, bounds, and error handling explicit; use appropriate RAII and const-correctness in C++.
- Preserve interfaces and numerical behavior. For C/Fortran interoperability, verify types, strides, array layout, ownership, and lifetime; use compatible views when available.
- Select parallel and accelerator techniques for the actual target. Measure performance and check data races, synchronization, and numerical tolerances.
- Follow project conventions for documentation, logging, build configuration, and tests. For NCO/WCOSS delivery, apply relevant current NCEP requirements; do not impose those mechanisms on unrelated research projects.
- Run the documented build and relevant tests with supported diagnostics; identify any checks not run. When a new OMD project needs a build system, CMake is the usual default if suitable.
