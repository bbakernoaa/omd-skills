# Writing OMD Documentation

Use this guide when creating or revising documentation for an ocean or atmosphere model, its tools, or its workflows.

## Choose the reader's need

Start with the reader's goal, then choose a document form. Diátaxis is a practical guide; follow the repository's existing navigation and naming conventions. Do not reorganize a documentation tree just to match a framework.

| Reader needs to… | Use… | OMD example |
|---|---|---|
| Learn through a guided first experience | **Tutorial** | Build and run a small ocean or atmosphere model case, with checkpoints that confirm the learner is progressing. |
| Complete a specific real task | **How-to guide** | Configure a model experiment, select a supported input dataset, or diagnose a failed run. |
| Look up exact technical details | **Reference** | Namelist fields, command options, file formats, units, valid values, and defaults. |
| Understand a concept or design choice | **Explanation** | Grid layout, a coupling approach, numerical method, or the scientific context for a model component. |

When one page mixes several needs, separate the material only when readers would benefit. Link related forms so a tutorial can point to reference details and an explanation can provide context for a how-to.

## Authoring workflow

1. **Identify the audience and task.** State who needs the information, what they need to accomplish or understand, and what they need to know first.
2. **Choose the document form.** Use the table above. If the need is mixed, choose the primary purpose and link to supporting material.
3. **Discover project conventions.** Check the existing documentation index, nearby docs, contribution guidance, and applicable repository instructions. Follow the project's established build, test, data, and runtime workflows.
4. **Gather evidence.** Inspect the implementation, tests, build/configuration files, examples, and authoritative sources that support each material claim. Prefer facts visible in the target project over generic examples.
5. **Draft for the chosen form.** A tutorial guides a learner through a successful experience; a how-to guide gets a task done; reference describes exact facts; explanation develops understanding. Keep those purposes clear in headings and prose.
6. **Make claims traceable.** Link behavior claims to relevant source, test, configuration, or authoritative documentation where useful. Distinguish observed behavior from inference. Record source and date for external operational or scientific facts that may change.
7. **Check the reader path.** Verify navigation, cross-links, prerequisites, command names, units, file paths, and expected results. Do not invent commands or defaults when evidence is missing.
8. **Report uncertainty.** If evidence conflicts or cannot establish a claim, say what remains unknown and what source or domain review would resolve it.

## OMD-specific considerations

- Respect the target project's language, build system, compiler, test, scheduler, and data conventions. If a new OMD project's build system is not established, CMake is the usual default; an established project convention takes precedence.
- Explain model inputs and outputs with their formats, dimensions, units, temporal coverage, and assumptions when those details are relevant and evidenced.
- Separate instructions that apply to research workflows from requirements that apply to a named operational target. Verify time-sensitive cluster and delivery guidance against authoritative sources.
- Describe a test as evidence for the cases and conditions it covers. A passing test does not by itself establish physical validity, numerical accuracy across all conditions, or operational readiness.
- Keep tutorials runnable on the intended supported environment. For unavailable clusters, datasets, or proprietary services, identify prerequisites and mark the steps that require them.

## Example: deciding how to improve a mixed quickstart

If an existing quickstart combines a first build, a full option table, and a rationale for an ocean-atmosphere coupling design:

- Keep the first build as a tutorial, with prerequisites, steps, and observable checkpoints.
- Put the complete option table in a reference page and link to it from the tutorial.
- Put the coupling rationale in an explanation page and link to it where it helps the learner.
- Preserve the current documentation layout unless the new links or a small move materially improve navigation.

## Common mistakes

- Writing one long page that alternates between learning steps, task procedures, parameter reference, and design rationale.
- Turning a passing test into a broad scientific claim.
- Copying defaults, scheduler commands, or cluster rules from another project without checking applicability.
- Splitting or renaming docs to satisfy a framework while making navigation harder.
- Hiding uncertainty behind authoritative-sounding prose.
