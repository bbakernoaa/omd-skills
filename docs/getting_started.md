# Getting Started

OMD Skills is a collection of reusable Agent Skills for ocean and atmosphere modeling and broader scientific workflows.
There is nothing to compile at the repository root.

## Clone The Repo

```bash
git clone https://github.com/NOAA-EMC/omd-skills.git
cd omd-skills
```

## Use The Skills Catalog

The repository organizes skills under `skills/<domain>/<skill>/`.
Most agent clients expect each skill to be a direct child of a configured skills directory, so you can install the catalog with the repository tooling or expose the bundled `skill-search` helper.

### Option 1: Install Into Your Project (recommended)

Run `install.sh` from the project you want to equip. It flattens skills into
the location each agent reads, adapts the `.github/instructions/` files, and
keeps a record in `.ompd/genesis.lock` so re-runs, updates, and uninstalls stay
safe:

```bash
/path/to/omd-skills/install.sh --agents all --mode copy
/path/to/omd-skills/install.sh --list          # preview the catalog
/path/to/omd-skills/install.sh --uninstall     # remove what was installed
```

See [agent-install.md](agent-install.md) for per-agent paths, modes, and how
refresh/uninstall handle local edits.

### Option 2: Flatten Skills Manually

For a single directory without an install record, the `unpack.sh` helper
copies or symlinks skills into your agent's skills directory.

```bash
export SKILLS_DIR="$HOME/.agents/skills"
./unpack.sh --target "$SKILLS_DIR" --mode copy
```

### Option 3: Use `skill-search`

The `skill-search` helper can expose the catalog through a single symlink:

```bash
mkdir -p "$SKILLS_DIR"
ln -s "$PWD/skill-search" "$SKILLS_DIR/skill-search"
```

It discovers the catalog from a sibling `skills/` directory by default, or you can point it at another root with `--central-root` or the `SKILL_SEARCH_CENTRAL_ROOT` environment variable.

## Next Steps

- Read [Instruction and Catalog Maintenance](instruction-maintenance.md) when changing instructions or reviewing domain guidance.
- Read [Documentation Maintenance](documentation-maintenance.md) to use the OMD documentation skill and connect it to your repository's chosen GitHub Actions agent runner.

- Read the root `README.md` for the full project overview.
- See `CONTRIBUTING.md` for contribution guidelines and issue reporting.
- See `skill-search/README.md` for details on the catalog helper and its JSON output.
- See `docs/agent-install.md` for the installer reference.
- See `.github/instructions/` for the VS Code Copilot code-review and Makefile instructions.
- See `Makefile` for the local lint and test commands (`make lint`, `make test`, and `make test-cov`).
- See `skill-search/search_example/requirements.txt` if you want to run the demo example.
