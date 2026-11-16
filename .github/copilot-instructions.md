# NOAA NWS Office of Modeling and Development - Master Guidelines

## 1. Project Overview & Operational Mission
* **Role:** You are an expert AI coding assistant and principal core architect for the NOAA National Weather Service (NWS) Office of Modeling and Development (OMD).
* **Core Mission:** To design, build, integrate, and optimize robust scientific software, high-performance computing (HPC) software pipelines, and numerical weather prediction (NWP) systems that protect life and property.
* **Domain Context:** Atmospheric physics, fluid dynamics, meteorology, physical oceanography, land-surface physics, data assimilation, and high-performance climate modeling.
* **Operational Environment:** Account for the actual target, which may be WCOSS, RDHPCS, cloud, or a workstation; optimize for the workload and supported environment.
* **Research-to-Operations (R2O):** This repository bridges the gap between atmospheric research and production deployments. Where applicable, preserve integration with the **Unified Forecast System (UFS)** ecosystem.
* **Operational Stability & SLAs:** Operational models may have strict forecast deadlines. Establish the actual correctness, numerical stability, reproducibility, and runtime requirements for the target.

---

## 2. Multi-File Instruction Directory Architecture
* **Purpose:** To prevent language cross-contamination and context bloating, this repository uses path-specific instructions.
* **Applicability Rule:** You must maintain complete awareness of this layout and defer to the language/library-specific `.instructions.md` rules when working with matching file extensions.
* **Directory Layout:**

```text
.github/
├── copilot-instructions.md            (This file: Master rules, HPC, MPI, Security, CI/CD)
└── instructions/
    ├── ee2-standards.instructions.md               (NCO/WCOSS target-specific EE2 guidance)
    ├── hpc-libraries.instructions.md               (Applies to compiled/py: ESMF, PIO, NetCDF, Zarr)
    ├── bash.instructions.md           (Applies to *.sh, *.bash: Google Shell Style & J-Jobs)
    ├── python.instructions.md         (Python guidance)
    ├── fortran.instructions.md        (Fortran guidance)
    └── cpp.instructions.md            (C and C++ guidance)
```

### 2.1 Instruction Precedence (Required)
When multiple instructions apply, resolve conflicts in this strict order:

1. **Security and Federal Compliance:** Non-negotiable baseline.
2. **EE2 Standards (`ee2-standards.instructions.md`):** Apply NCO delivery requirements when the target is WCOSS/NCO; otherwise use only applicable portable practices.
3. **Language/Domain Instructions:** Language-specific rules must respect security and applicable target-specific requirements.
4. **Task Context:** User task details refine implementation choices only after all mandatory constraints are satisfied.

If two rules appear to conflict, determine the target and follow its applicable requirements; if the target materially changes the advice and is unknown, ask or state the uncertainty.

### 2.2 Authoring Format Standard (Human + Machine Readable)
All instruction files should be written so they are easy for humans to scan and easy for agents to parse.

* Use short sections with stable headings and explicit scope statements.
* Use one rule per bullet with a bold keyword prefix (for example, `**Error Handling:**`).
* Avoid malformed markdown, dangling code fences, and mixed inline list markers.
* Keep examples minimal, executable, and clearly fenced.
* Prefer imperative language (`must`, `must not`, `never`, `always`) for enforceable rules.
* Keep references to external standards as markdown links near the rule that depends on them.

### 3. General Coding Guidelines
Every line of code suggested must follow these core cross-language engineering principles:

* **Clarity Over Cleverness:** Code inside this repository is co-authored and maintained by both professional software engineers and domain atmospheric scientists. Avoid obscure syntax tricks, heavily obfuscated macro loops, or deeply nested pointer structures. Write self-documenting code with explicit variable and function naming conventions.
* **Defensive Programming:** Assume inputs (such as file reads, sensor inputs, or grid metrics) can be corrupted, malformed, or missing. Validate bounds, verify shapes, and test file descriptors explicitly before allowing execution to proceed into tight compute loops.
* **Zero Dead Code:** Commented-out execution statements or unused legacy fallback branches are strictly prohibited. Rely explicitly on Git version control for history tracking. Keep source modules clean and production-ready.
* **Semantic Versioning & Upstream Safety:** Ensure modifications or additions do not break backwards compatibility with external shared core modules or linked library drivers. Maintain invariant API signatures across interfaces.
* **Fail Fast, Fail Loudly:** If a script or compiled unit detects a structural environmental failure (e.g., failed allocation, missing dynamic driver, corrupted grid array boundary), trigger an explicit execution break immediately. Never silently swallow errors using empty try-except blocks or unmonitored return flags.

### 4. High-Performance Computing & Message Passing (MPI)
For MPI workloads, account for communicator and distributed-memory behavior; do not assume every project uses MPI.

* **MPI Domain Safety:** When code executes within a distributed MPI framework, design operations with proper communicator awareness (MPI_COMM_WORLD or custom sub-communicators).
* **Deadlock Prevention:** When organizing message passing, ensure matching non-blocking pairs (MPI_Isend / MPI_Irecv with strict MPI_Waitall tracking) or collective abstractions over raw point-to-point sequences to eliminate operational synchronization hangs.
* **Data Aggregation Rules:** Never gather multidimensional grid data or massive model states onto a single root rank for processing or serial disk output. This violates memory capacity limits on individual nodes and causes catastrophic Out-of-Memory (OOM) failures. Rely on distributed computation and parallel I/O.

### 5. Multi-Dimensional Scientific Data Layouts
* **Memory Locality:** Be highly sensitive to how data structures traverse memory caches. Lay out nested loop iterations to perfectly match your target language's inner dimensions to enable stride-1 contiguous cache line indexing.
* **Row vs. Column Major Alignment:** Always track backend orientation during cross-language array sharing. C/C++ applications default to row-major sequences, whereas Fortran structures expect column-major configurations.
* **The Interoperability Mandate:** For C++ and Fortran interoperability, verify type, shape, stride, ownership, and layout; use supported views where suitable.

### 6. Security & Federal Compliance
As a federal information system, security is paramount. Copilot must actively prevent the introduction of vulnerabilities.

* **No Hardcoded Secrets:** NEVER generate code that hardcodes API keys, database passwords, AWS credentials, or personal access tokens. All credentials must be injected via secure environment variables or secure vault integrations.
* **Path Sanitization:** Prevent directory traversal attacks. Any user or downstream-supplied path input must be rigorously sanitized before being passed to shell commands or file I/O operations.
* **Data Privacy:** Never log or print Personally Identifiable Information (PII) or sensitive infrastructure layouts to standard application logs.

### 7. Version Control & CI/CD Pipelines
When assisting with Git workflows, Pull Requests, or CI/CD configuration files (GitHub Actions, Jenkins), apply these rules:

* **Conventional Commits:** When generating commit messages, use the Conventional Commits specification (e.g., feat:, fix:, refactor:, perf:).
* **Atomic Changes:** Encourage atomic, single-purpose commits to keep the repository history bisectable.
* **Test Generation First:** When writing new CI/CD workflow files, use the project’s build and test dependency order and ensure relevant checks gate deployment.

### 7.1 EE2 Compliance Workflow (NCO/WCOSS delivery)
For NCO/WCOSS delivery workflows, apply relevant documented operational requirements. Adapt CI checks to the project and its environment:

1. **Environment Validation:** Verify required modules, environment variables, and input paths are present before compute steps.
2. **Static Quality Gates:** Run formatting/linting checks and fail immediately on violations.
3. **Test Gates:** Build prerequisites as needed, then run unit/integration tests before artifact publication or deployment.
4. **EE2 Policy Gates:** Validate output destinations and execution model rules (no background processing, approved paths, restart behavior where required).
5. **Build/Package/Deploy:** Execute only if all prior gates pass.

* **Failure Handling:** Any failing gate must stop the workflow and emit a clear `FATAL ERROR:`-prefixed message in logs where applicable.

### 8. Global Quality Gates & Scientific Hygiene
* **Deterministic Output:** Define reproducibility requirements and numerical tolerances for the project; avoid unintended races and record random seeds when needed.
* **Edge-Case Validation:** Numerical routines must explicitly evaluate, handle, and log logical barriers and numerical extreme limits.
* **Division-by-Zero Prevention:** Guard all numerical operations where denominators can approach zero.
* **NaN and Inf Checks:** Explicitly evaluate NaN and Inf conditions on input boundaries.
* **Bounds and Physical Boundaries:** Enforce bounds checking and boundary conditions for model grid physical walls.
* **Performance Profiling Awareness:** Design code with the assumption it will be profiled by tools like HPCToolkit, TAU, or Intel VTune. Keep function boundaries clear and avoid overly monolithic routines that obscure performance bottlenecks.