# OMD Skills

**Portable AI-agent workflows for science and engineering**

OMD Skills is a collection of reusable [Agent Skills](https://agentskills.io) for ocean and atmosphere modeling and
broader scientific and engineering workflows, maintained by the NOAA Ocean Modeling Division (OMD).
The catalog can be used with Claude Code, Codex, Cursor, OpenCode, Gemini CLI, and LangChain Deep
Agents. Individual skills may still depend on client-specific features or external tools.

Skills encode domain expertise, connect to scientific data sources, and provide reproducible patterns for computational research.

---

## What Are Skills?

Skills are markdown files (`SKILL.md`) with YAML frontmatter that teach an AI agent how to handle domain-specific tasks. Each skill provides:

- **Domain expertise** — Specialized knowledge for NOAA RDHPCS HPC systems, scientific literature search, and common repository workflows
- **Tool access** — Permissions to use specific tools (Bash commands, file operations, web APIs)
- **Structured workflows** — Step-by-step instructions for complex scientific tasks
- **Supporting resources** — Scripts, templates, and reference materials the agent can use

Agents can select a skill from a natural-language request. Client-specific menus and explicit invocation shortcuts vary by agent.

> **Code review guidance.** OMD's language-aware review checklist for C, C++, Fortran, Python,
> and Bash lives in [.github/instructions/code-review-generic.instructions.md](.github/instructions/code-review-generic.instructions.md).
> VS Code loads it automatically for matching files.

---

## Quick Start

There's nothing to compile: clone the repo, then install the skills into the
projects your agent works in. The repository groups skills by domain
(`skills/<domain>/<skill>/`), while agent clients generally expect each skill
to be a direct child of a configured skills directory; `install.sh` flattens
that layout, also adapts the `.github/instructions/` files to each agent, and
records what it placed so it can update or remove it later. LangChain Deep
Agents receive a catalog path in code instead of discovering a user-level
directory automatically.

```bash
git clone https://github.com/NOAA-EMC/omd-skills.git
cd omd-skills
```

> This catalog is derived in part from the DOE/ModCon **Genesis Skills** collection; see
> [NOTICE](NOTICE) for the upstream provenance of the retained subtrees.

### Method 1 — Install into a project (`install.sh`)

From inside any project (or with `--project`), place the skills and
instructions for your agents:

```bash
/path/to/omd-skills/install.sh --agents all --mode copy
# or target one client:
/path/to/omd-skills/install.sh --agents claude --domains hpc-skills
```

Or install the same command as a CLI (it bundles the catalog; no clone needed):

```bash
pipx install git+https://github.com/NOAA-EMC/omd-skills.git
# or one-off without installing:
uvx --from git+https://github.com/NOAA-EMC/omd-skills.git omd-skills --list
# then, from inside your project:
omd-skills --agents all --mode copy
```

Interactive runs detect which agents a project uses and ask before placing
anything; `--agents`, `--domains`, and `--no-interactive` cover scripting.
`install.sh --list` previews the catalog. Installs are recorded in the
project's `.ompd/genesis.lock`, so a later re-run refreshes only changed
material, protects files you edited locally, and `--uninstall` removes (or
partially removes) exactly what was installed. See
[docs/agent-install.md](docs/agent-install.md) for the per-agent layout, the
`copy` vs `symlink` modes, and uninstall behavior.

### Method 2 — Flatten manually for one directory (`unpack.sh`)

For a quick manual placement without an install record, `unpack.sh` remains
the advanced path: choose the skills directory documented by your client and
flatten every skill into it:

```bash
export SKILLS_DIR="$HOME/.agents/skills"  # Codex, Cursor, OpenCode, Gemini CLI
# export SKILLS_DIR="$HOME/.claude/skills"  # Claude Code
./unpack.sh --target "$SKILLS_DIR" --mode copy
```

Use `--mode symlink` for live links back to the clone, `./unpack.sh hpc-skills`
for one domain, `./unpack.sh --list` to preview, or `./unpack.sh --help` for all
options. The legacy default remains `.claude/skills`; an explicit `--target` is
the client-neutral choice. Existing same-named destination entries are replaced;
`unpack.sh` keeps no record, so prefer `install.sh` for managed projects.

### Method 3 — Point the `skill-search` skill at the catalog

Expose just the bundled `skill-search` skill; it discovers the whole nested catalog
on demand, either via standard progressive disclosure or a keyword search tool:

```bash
mkdir -p "$SKILLS_DIR"
ln -s "$PWD/skill-search" "$SKILLS_DIR/skill-search"
```

`skill-search` finds the catalog automatically (sibling `skills/`), or set
`SKILL_SEARCH_CENTRAL_ROOT` / pass `--central-root` to point at a shared clone.

### Use a Skill

Ask naturally, for example: “Find recent papers on ocean model data assimilation”
or “Draft a Slurm script for four GPUs on Hera.” Your client can select the
matching skill from its description. If a newly installed skill is not noticed
immediately, follow the client's documented refresh behavior.


### Discovery Helper
- `skill-search` — Discover and explore available skills by capability

---



## Repository Structure

```
omd-skills/
├── install.sh                 # install skills + instructions into a project, with a record (Method 1)
├── unpack.sh                  # flatten skills into an agent's skills dir (Method 2, manual)
├── skill-search/              # the upper-level discovery skill (Method 3)
│   ├── SKILL.md
│   └── scripts/skill_search.py
├── skills/
│   ├── git-commit/SKILL.md
│   ├── git-flow-branch-creator/SKILL.md
│   ├── github-actions-efficiency/SKILL.md
│   ├── github-actions-hardening/SKILL.md
│   ├── github-actions-runtime-upgrade-conventions/SKILL.md
│   ├── github-issues/SKILL.md
│   ├── github-release/SKILL.md
│   ├── hpc-skills/  # pbs, rdhpcs-cloud, rdhpcs-gaea, rdhpcs-hera, rdhpcs-hercules, rdhpcs-mercury, rdhpcs-orion, rdhpcs-ppan, rdhpcs-ursa, slurm (10)
│   ├── literature-search/SKILL.md
│   ├── omd-standards/  # ee2-standards (1)
│   └── prompt-optimizer/SKILL.md
├── CONTRIBUTING.md
├── LICENSE
├── NOTICE                     # third-party licensing and attribution inventory
├── README.md
└── skill_spec.md              # Agent Skills format specification
```

Each skill is a directory containing:
- `SKILL.md` — Required entry point with frontmatter and instructions
- Supporting files — Optional templates, scripts, and reference docs

---

## About OMD

The NOAA Ocean Modeling Division (OMD) develops and sustains operational and research
ocean, wave, and coupled Earth-system models used by the National Weather Service and the
global forecasting community. This catalog collects the AI-agent workflows OMD uses day to
day, with goals that mirror how the division works:

1. **Make HPC reproducible** — Capture RDHPCS queue, storage, and job-script practice in
   skills so runs are repeatable across Hera, Orion, Hercules, Mercury, Gaea, PPAN, and Ursa
2. **Accelerate model development** — Reduce time from hypothesis to validated forecast
   change through documented agent workflows
3. **Ensure reproducibility** — Prefer skills that produce reliable, reviewed, and
   version-controlled results
4. **Foster collaboration** — Share a common catalog that each OMD project contributes to
   rather than re-inventing local agent setup

---

## Contributing

We welcome contributions from the scientific community. See the [Contributing Guide](CONTRIBUTING.md) for details on:
- Skill specification format
- Testing guidelines
- Review process

If you are adding a new skill, use the checklist in [CONTRIBUTING.md](CONTRIBUTING.md) and the pull request template in [.github/pull_request_template.md](.github/pull_request_template.md) before opening the PR.

## Contributors

Individual skills and their directories contain specific attribution details. The catalog-level and skill contributors include the following:

- Barry Baker
- OMD - Modeling Division

---

## License
This product is licensed under the root [LICENSE](LICENSE) found at the root of
this repository. OMD-authored content is a work of the United States Government
and is in the public domain; see the root `LICENSE` for the exact statement.
Some skills under `skills/` are sourced from third parties. Where a `LICENSE`
(or `LICENSE.txt`) file is present in a subdirectory, that license governs the
contents of that subdirectory and supersedes the root license for that subtree.
The repository-level summary of individual skill and third-party licensing
details is in [NOTICE](NOTICE); see the attribution file in each identified
subtree for the licensing information supplied with that content.

## Acknowledgment
This work was supported by the National Oceanic and Atmospheric Administration (NOAA), Ocean Modeling Division.

## Disclaimer
The United States Department of Commerce (DOC) GitHub project code is provided
on an "as is" basis and the user assumes responsibility for its use. See the
full statement in [DISCLAIMER](DISCLAIMER). Parts of this code was generated by agentic AI agents. All changes are verified by OMD employees.
