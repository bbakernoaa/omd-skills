"""US1/US5: per-agent placement adapters, parity between interactive and
non-interactive runs, byte-exact deliveries (T015, T026, T027, T030, T031)."""

from __future__ import annotations

import filecmp
import json
import subprocess
from pathlib import Path

from installer_fixtures import INSTALL_SH, REPO, InstallerTestCase

CATALOG = REPO


def path_is_in_domain(skill_md: Path, domains: tuple) -> bool:
    rel = skill_md.relative_to(CATALOG / "skills")
    return rel.parts[0] in domains


class TestAdapterPlacement(InstallerTestCase):
    """Each adapter's skills dir / instruction delivery per the contract."""

    DOM = ("--domains", "omd-standards,literature-search")

    def test_domain_instruction_delivery_all_adapters(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "all", "--mode", "copy", *self.DOM)
        root = Path(proj)
        for stem in ("ee2-standards", "hpc-libraries"):
            self.assertTrue((root / ".github/instructions" / f"{stem}.instructions.md").is_file())
            self.assertTrue((root / ".cursor/rules" / f"{stem}.mdc").is_file())
            for filename in ("AGENTS.md", "CLAUDE.md", "GEMINI.md"):
                self.assertIn(f"Source: .github/instructions/{stem}.instructions.md",
                              (root / filename).read_text())
                self.assertIn("NCEP" if stem == "ee2-standards" else "ESMF",
                              (root / filename).read_text())

    def test_copilot_verbatim_skills_and_instructions(self) -> None:
        proj = self.make_project()
        p = self.run_installer(proj, "--agents", "copilot", "--mode", "copy",
                               *self.DOM)
        dst = Path(proj) / ".github" / "instructions"
        src = CATALOG / ".github" / "instructions"
        # contract: delivery covers the .instructions.md family that VS Code
        # (and install.sh) treat as instruction files
        copied = sorted(x.name for x in dst.glob("*.instructions.md"))
        self.assertEqual(copied, sorted(x.name for x in src.glob("*.instructions.md")))
        for name in copied:
            self.assertTrue(filecmp.cmp(dst / name, src / name, shallow=False),
                            f"copilot delivery must be byte-identical: {name}")
        # Copilot is a first-class skills target: verbatim leaf trees under
        # .github/skills, the native repository skills location.
        self.assertNotIn("skills: skipped", p.stdout)
        skill_paths = sorted(e["path"] for e in self.entries_for(proj, "skill"))
        self.assertTrue(skill_paths)
        for path in skill_paths:
            self.assertTrue(path.startswith(".github/skills/"), path)
        sroot = Path(proj) / ".github" / "skills"
        cat_skills = CATALOG / "skills"
        src_leaves = {
            leaf.parent.name
            for leaf in cat_skills.rglob("SKILL.md")
            if path_is_in_domain(leaf, ("omd-standards", "literature-search"))
        }
        self.assertEqual(sorted(x.name for x in sroot.iterdir()),
                         sorted(src_leaves))
        for name in src_leaves:
            src_md = next(
                leaf.parent
                for leaf in cat_skills.rglob("SKILL.md")
                if leaf.parent.name == name
            ) / "SKILL.md"
            dst_md = sroot / name / "SKILL.md"
            self.assertTrue(dst_md.is_file(), f"missing {name}/SKILL.md")
            self.assertTrue(filecmp.cmp(dst_md, src_md, shallow=False),
                            f"copilot skills must be byte-identical: {name}")


    def test_cursor_mdc_conversion(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "cursor", "--mode", "copy",
                           *self.DOM)
        rules = Path(proj) / ".cursor" / "rules"
        mdc = rules / "python.mdc"
        self.assertTrue(mdc.is_file())
        self.assertEqual(sorted(x.name for x in rules.glob("*.mdc")),
                         sorted(x.name[:-len(".instructions.md")] + ".mdc"
                                for x in
                                (CATALOG / ".github" / "instructions").glob("*.instructions.md")))
        text = mdc.read_text()
        lines = text.splitlines()
        self.assertEqual(lines[0], "---")
        head = "\n".join(lines[1:lines.index("---", 1)])
        body = "\n".join(lines[lines.index("---", 1) + 1:])
        self.assertIn("globs:", head)
        self.assertNotIn("applyTo:", head)
        self.assertIn("alwaysApply: false", head)
        # body bytes pass through untouched relative to source body
        src = (CATALOG / ".github" / "instructions" / "python.instructions.md").read_text()
        srclines = src.splitlines()
        src_body = "\n".join(srclines[srclines.index("---", 1) + 1:])
        self.assertEqual(body.rstrip("\n"), src_body.rstrip("\n"))

    def test_block_agents_get_managed_blocks(self) -> None:
        proj = self.make_project(files={"CLAUDE.md": "# mine\n",
                                        "GEMINI.md": "# gemine\n"})
        self.run_installer(proj, "--agents", "claude,gemini", "--mode", "copy",
                           *self.DOM)
        for fname in ("CLAUDE.md", "GEMINI.md"):
            self.assertFalse((Path(proj) / "AGENTS.md").exists())
            text = (Path(proj) / fname).read_text()
            self.assertIn("genesis-skills:begin", text, fname)
            self.assertIn("Source:", text, fname)
        self.assertIn("# mine", (Path(proj) / "CLAUDE.md").read_text())
        self.assertIn("# gemine", (Path(proj) / "GEMINI.md").read_text())
        # claude skills dir vs shared .agents dir
        self.assertTrue((Path(proj) / ".claude" / "skills" / "ee2-standards").is_dir())
        # gemini shares the vendor-neutral .agents/skills location
        self.assertTrue((Path(proj) / ".agents" / "skills" / "ee2-standards").is_dir())

    def test_agents_all_union_tags(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "all", "--mode", "copy")
        entry = [e for e in self.lock_entries(proj)
                 if e["path"] == ".agents/skills/slurm"][0]
        self.assertEqual(sorted(entry["agents"]),
                         ["codex", "cursor", "gemini", "opencode"])
        c = [e for e in self.lock_entries(proj)
             if e["path"] == ".claude/skills/slurm"][0]
        self.assertEqual(c["agents"], ["claude"])
        ag = [e for e in self.lock_entries(proj) if e["path"] == "AGENTS.md"][0]
        self.assertEqual(sorted(ag["agents"]), ["codex", "opencode"])
        leaves = self.catalog_leaf_count()
        skill_paths = self.paths_in(proj, "skill")
        self.assertEqual(len(skill_paths), 3 * leaves,
                         "one tree each under .agents/, .claude/, .github/skills")


class TestParityAndCompat(InstallerTestCase):
    """T027 SC-005 parity + T031 offline/bash3.2 guards."""

    def test_t027_interactive_noninteractive_parity(self) -> None:
        proj_a = self.make_project()
        proc_a = self.run_installer(proj_a, "--agents", "all", "--mode", "copy")
        proj_b = self.make_project()
        proc_b = self.run_installer(
            proj_b, "--mode", "copy", stdin="all\n",
            env={"GENESIS_FORCE_INTERACTIVE": "1"})
        self.assertEqual(proc_a.returncode, proc_b.returncode)
        # compare trees with the project path stripped out of any file text
        self.assertEqual(self.tree_hash(proj_a), self.tree_hash(proj_b))
        la = [f"{e['path']}|{e['type']}|{','.join(sorted(e['agents']))}"
              for e in self.lock_entries(proj_a)]
        lb = [f"{e['path']}|{e['type']}|{','.join(sorted(e['agents']))}"
              for e in self.lock_entries(proj_b)]
        self.assertEqual(sorted(la), sorted(lb))

    def test_t031_no_network_symbols(self) -> None:
        text = INSTALL_SH.read_text()
        for bad in ("curl", "wget", "git clone", "git fetch", "git pull",
                    "npm install", "pip install"):
            self.assertNotIn(bad, text, f"installer must be offline: {bad}")
        libs = list((REPO / "tools" / "installer").glob("*.sh"))
        self.assertTrue(libs)
        for f in (INSTALL_SH, *libs):
            self.assertIn("install.sh", text)
            subprocess.run(["bash", "-n", str(f)], check=True, timeout=60)

    def test_t031_bash_version_guard(self) -> None:
        p = subprocess.run(["bash", str(INSTALL_SH), "--help"],
                           capture_output=True, text=True, timeout=60, cwd=REPO)
        self.assertEqual(p.returncode, 0)
        self.assertIn("--agents", p.stdout)

    def test_t030_attribution_files_installed(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex", "--mode", "copy")
        for name, leaf in (("slurm", "skills/hpc-skills/slurm"),
                           ("ee2-standards", "skills/omd-standards/ee2-standards"),
                           ("literature-search", "skills/literature-search")):
            d = Path(proj) / ".agents" / "skills" / name
            licenses = [p.name for p in d.iterdir()
                        if p.name.startswith(("LICENSE", "NOTICE", "ATTRIBUTION"))]
            self.assertTrue(licenses, f"FR-014 attribution missing for {name}")
            del leaf


class TestMultiAgentUnion(InstallerTestCase):
    """T026: --agents all places a single shared copy per path, union tags."""

    def test_agents_all_union_tags_and_summary(self) -> None:
        cat = self.make_catalog_copy()
        proj = self.make_project()
        p = self.run_installer(proj, "--agents", "all", "--mode", "copy",
                               "--domains", "omd-standards",
                               install_sh=cat / "install.sh")
        skills = self.entries_for(proj, "skill")
        paths = [e["path"] for e in skills]
        self.assertEqual(len(paths), len(set(paths)), "one entry per destination path")
        shared = [e for e in skills if e["path"] == ".agents/skills/ee2-standards"]
        self.assertEqual(len(shared), 1)
        self.assertEqual(sorted(shared[0]["agents"]),
                         ["codex", "cursor", "gemini", "opencode"])
        claude = [e for e in skills if e["path"] == ".claude/skills/ee2-standards"]
        self.assertEqual(claude[0]["agents"], ["claude"])
        # copilot has its own skills dir; it never shares .agents/skills
        copilot = [e for e in skills if "copilot" in e["agents"]]
        self.assertTrue(copilot)
        for e in copilot:
            self.assertEqual(e["agents"], ["copilot"])
            self.assertTrue(e["path"].startswith(".github/skills/"), e["path"])
        # instruction union: AGENTS.md shared by codex+opencode; copilot files
        agents_md = [e for e in self.lock_entries(proj) if e["path"] == "AGENTS.md"]
        self.assertEqual(sorted(agents_md[0]["agents"]), ["codex", "opencode"])
        self.assertIn(".github/instructions", p.stdout)
        self.assertTrue((Path(proj) / ".github" / "instructions").is_dir())


class TestModeParity(InstallerTestCase):
    """T027 (SC-005): interactive acceptance matches --no-interactive output."""

    def test_interactive_y_parity(self) -> None:
        cat = self.make_catalog_copy()
        proj_a = self.make_project()
        proj_b = self.make_project()
        # scripted interactive run picks agents via the prompt, --agents path
        # for the baseline; trees and records must agree modulo timestamps.
        a = self.run_installer(proj_a, "--agents", "claude,codex", "--mode", "copy",
                               "--domains", "literature-search",
                               install_sh=cat / "install.sh")
        b = self.run_installer(
            proj_b, "--mode", "copy", "--domains", "literature-search",
            stdin="claude,codex\n", env={"GENESIS_FORCE_INTERACTIVE": "1"},
            install_sh=cat / "install.sh")
        self.assertEqual(self.tree_hash(proj_a), self.tree_hash(proj_b))
        la = [json.dumps({k: v for k, v in e.items() if k != "ts"}, sort_keys=True)
              for e in self.lock_entries(proj_a)]
        lb = [json.dumps({k: v for k, v in e.items() if k != "ts"}, sort_keys=True)
              for e in self.lock_entries(proj_b)]
        self.assertEqual(la, lb)
        del a, b


class TestOfflineAndCompat(InstallerTestCase):
    """T031: bash 3.2 syntax gate + no network calls in the installer."""

    def test_bash_n_all_scripts(self) -> None:
        import subprocess
        for script in [REPO / "install.sh", *sorted((REPO / "tools" / "installer").glob("*.sh"))]:
            r = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True)
            self.assertEqual(r.returncode, 0, f"{script.name}: {r.stderr}")

    def test_no_network_commands(self) -> None:
        banned = ("curl", "wget", "git clone", "git fetch", "git pull")
        for script in [REPO / "install.sh", *sorted((REPO / "tools" / "installer").glob("*.sh"))]:
            text = script.read_text()
            for b in banned:
                self.assertNotIn(b, text, f"{script.name} must be offline-only ({b})")
