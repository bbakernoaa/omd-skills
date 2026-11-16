"""US2/US3: idempotence, refresh-on-catalog-change, stale pruning, uninstall
semantics, local-edit protection, and mode switching (tasks T020/T021/T022/
T023/T024/T025; quickstart V3/V4/V5/V6 scenarios)."""

from __future__ import annotations

import shutil
from pathlib import Path

from installer_fixtures import InstallerTestCase


class TestIdempotence(InstallerTestCase):
    """SC-003: re-install with no catalog change mutates nothing but ts."""

    def test_t020_reinstall_is_unchanged(self) -> None:
        proj = self.make_project()
        p1 = self.run_installer(proj, "--agents", "all", "--domains", "hpc-skills")
        self.assertIn("created=1", p1.stdout)
        tree1 = self.tree_hash(proj)
        lock1 = self.lock_entries(proj)
        p2 = self.run_installer(proj, "--agents", "all", "--domains", "hpc-skills")
        self.assertNotIn("created=1", p2.stdout)
        self.assertNotIn("refreshed=1", p2.stdout)
        self.assertIn("unchanged=1", p2.stdout)
        self.assertEqual(tree1, self.tree_hash(proj), "tree must not drift")
        lock2 = self.lock_entries(proj)
        self.assertEqual(len(lock1), len(lock2))
        for a, b in zip(lock1, lock2):
            a = {k: v for k, v in a.items() if k != "ts"}
            b = {k: v for k, v in b.items() if k != "ts"}
            self.assertEqual(a, b, "record must only refresh timestamps")


class TestCatalogChange(InstallerTestCase):
    """US2: content of an edited catalog refreshes; deleted leaves prune."""

    def test_instruction_rename_preserves_user_edits_and_uninstall(self) -> None:
        cat = self.make_catalog_copy()
        source = cat / ".github/instructions"
        old = source / "migration-old.instructions.md"
        old.write_text("---\ndescription: migration\napplyTo: '**/*'\n---\nOld content\n")
        proj = self.make_project()
        self.run_installer(proj, "--agents", "copilot", "--domains", "literature-search", install_sh=cat / "install.sh")
        target = Path(proj) / ".github/instructions/migration-old.instructions.md"
        target.write_text(target.read_text() + "user edit\n")
        old.rename(source / "migration-new.instructions.md")
        self.run_installer(proj, "--agents", "copilot", "--domains", "literature-search", install_sh=cat / "install.sh", check_rc=None)
        self.assertIn("user edit", target.read_text())
        self.assertTrue((target.parent / "migration-new.instructions.md").exists())
        self.run_installer(proj, "--agents", "copilot", "--uninstall", install_sh=cat / "install.sh", check_rc=None)
        self.assertIn("user edit", target.read_text())

    def test_instruction_rename_prunes_only_managed_stale_file(self) -> None:
        cat = self.make_catalog_copy()
        source = cat / ".github/instructions"
        old = source / "migration-old.instructions.md"
        old.write_text("---\ndescription: migration\napplyTo: '**/*'\n---\nOld content\n")
        proj = self.make_project()
        self.run_installer(proj, "--agents", "copilot,cursor", "--domains", "literature-search", install_sh=cat / "install.sh")
        target = Path(proj) / ".github/instructions"
        cursor_old = Path(proj) / ".cursor/rules/migration-old.mdc"
        foreign = target / "my-own.instructions.md"
        foreign.write_text("user-owned\n")
        old.rename(source / "migration-new.instructions.md")
        self.run_installer(proj, "--agents", "copilot", "--domains", "literature-search", install_sh=cat / "install.sh")
        self.assertFalse((target / "migration-old.instructions.md").exists())
        self.assertTrue((target / "migration-new.instructions.md").is_file())
        self.assertTrue(cursor_old.is_file(), "unselected adapter must remain untouched")
        self.assertEqual(foreign.read_text(), "user-owned\n")
        self.run_installer(proj, "--agents", "copilot", "--uninstall", install_sh=cat / "install.sh")
        self.assertEqual(foreign.read_text(), "user-owned\n")

    def test_t021_leaf_edit_refreshes_and_deletion_prunes(self) -> None:
        cat = self.make_catalog_copy()
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                            "--domains", "hpc-skills", install_sh=cat / "install.sh")
        before = self.tree_hash(proj)
        # (a) leaf content change -> refresh that path only
        (cat / "skills" / "hpc-skills" / "slurm" / "SKILL.md").write_text(
            "# slurm\n\nedited by catalog\n")
        p2 = self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                                "--domains", "hpc-skills",
                                install_sh=cat / "install.sh")
        self.assertIn("slurm refreshed=1", p2.stdout)
        self.assertNotEqual(before, self.tree_hash(proj))
        # (b) leaf removal -> stale path pruned from project and record
        shutil.rmtree(cat / "skills" / "hpc-skills" / "pbs")
        self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                                "--domains", "hpc-skills",
                                install_sh=cat / "install.sh")
        self.assertFalse((Path(proj) / ".agents" / "skills" / "pbs").exists(),
                         "stale skill must be removed")
        self.assertNotIn(".agents/skills/pbs",
                         {e["path"] for e in self.lock_entries(proj)})
        self.assertTrue((Path(proj) / ".agents" / "skills" / "slurm").is_dir())

    def test_t021_stale_pruning_is_scope_limited(self) -> None:
        cat = self.make_catalog_copy()
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex", "--mode", "copy")
        self.assertIn(".agents/skills/ee2-standards", self.paths_in(proj, "skill"))
        shutil.rmtree(cat / "skills" / "hpc-skills" / "slurm")
        # refresh only hpc-skills: omd entries outside the scope stay put
        p = self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                               "--domains", "hpc-skills",
                               install_sh=cat / "install.sh")
        self.assertTrue((Path(proj) / ".agents" / "skills" / "ee2-standards").exists())
        self.assertFalse((Path(proj) / ".agents" / "skills" / "slurm").exists())
        # and an out-of-scope refresh never prunes the deleted leaf's peers
        self.assertIn(".agents/skills/git-commit", self.paths_in(proj, "skill"))

        del p


class TestUninstall(InstallerTestCase):
    """US3: full clean, shared-path tag pruning, foreign-file survival."""

    def test_t022_full_uninstall_restores_project(self) -> None:
        proj = self.make_project(files={"README.md": "mine\n"})
        baseline = self.tree_hash(proj)
        self.run_installer(proj, "--agents", "all")
        self.run_installer(proj, "--agents", "all", "--uninstall")
        self.assertEqual(baseline, self.tree_hash(proj),
                         "project must be pristine after full uninstall")
        self.assertFalse((Path(proj) / ".ompd").exists(),
                         ".ompd must be torn down when the record empties")
        self.assertTrue((Path(proj) / "README.md").is_file())

    def test_t023_agent_filtered_uninstall_keeps_shared_paths(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex,opencode,gemini",
                           "--mode", "copy", "--domains", "hpc-skills")
        shared = Path(proj) / ".agents" / "skills" / "slurm"
        self.assertTrue(shared.is_dir())
        entry = [e for e in self.lock_entries(proj) if e["path"] == ".agents/skills/slurm"][0]
        self.assertEqual(sorted(entry["agents"]), ["codex", "gemini", "opencode"])
        self.run_installer(proj, "--agents", "codex", "--uninstall")
        self.assertTrue(shared.is_dir(), "shared path survives while other agents use it")
        entry = [e for e in self.lock_entries(proj) if e["path"] == ".agents/skills/slurm"][0]
        self.assertEqual(sorted(entry["agents"]), ["gemini", "opencode"])
        # AGENTS.md (codex+opencode shared) keeps existing until last agent leaves
        self.assertTrue((Path(proj) / "AGENTS.md").is_file())
        # gemini skills live under .agents/skills too; claude none installed
        self.run_installer(proj, "--agents", "gemini", "--uninstall")
        self.assertTrue(shared.is_dir(), "opencode still references it")
        self.run_installer(proj, "--agents", "opencode", "--uninstall")
        self.assertFalse(shared.exists())
        self.assertFalse((Path(proj) / "AGENTS.md").exists())

    def test_t023_rules_block_uninstall_preserves_host_file(self) -> None:
        proj = self.make_project(files={
            "CLAUDE.md": "# My prose\n\nkeep me\n",
        })
        self.run_installer(proj, "--agents", "claude", "--domains", "omd-standards")
        claude_md = Path(proj) / "CLAUDE.md"
        text = claude_md.read_text()
        self.assertIn("# My prose", text)
        self.assertIn("genesis-skills:begin", text)
        self.run_installer(proj, "--agents", "claude", "--uninstall")
        after = claude_md.read_text()
        self.assertIn("# My prose", after, "user prose must survive")
        self.assertNotIn("genesis-skills", after, "managed blocks must be stripped")

    def test_t024_foreign_file_in_skill_dir_survives_uninstall(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                           "--domains", "literature-search")
        d = Path(proj) / ".agents" / "skills" / "literature-search"
        (d / "user-notes.md").write_text("local research\n")
        p = self.run_installer(proj, "--agents", "codex", "--uninstall")
        self.assertTrue((d / "user-notes.md").is_file(),
                        "foreign files force directory retention")
        self.assertIn("files kept", p.stderr, "warn on retained foreign dir")
        lock = Path(proj) / ".ompd" / "genesis.lock"
        kept_paths = ({e["path"] for e in self.lock_entries(proj)}
                      if lock.is_file() else set())
        self.assertNotIn(".agents/skills/literature-search", kept_paths,
                         "record entry is dropped even when dir is kept")


class TestLocalEditProtection(InstallerTestCase):
    """US4: edits after install are never silently clobbered."""

    def _install_copy(self, proj: str) -> Path:
        self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                           "--domains", "literature-search")
        return Path(proj) / ".agents" / "skills" / "literature-search" / "SKILL.md"

    def test_t025_non_interactive_skips_with_exit_3(self) -> None:
        proj = self.make_project()
        skill_md = self._install_copy(proj)
        skill_md.write_text(skill_md.read_text() + "\nlocal edit\n")
        skip = self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                                  "--domains", "literature-search", check_rc=3)
        self.assertIn("skipped-local-edit", skip.stdout + skip.stderr)
        self.assertIn("local edit", skill_md.read_text(),
                      "the local edit must still be there")

    def test_t025_interactive_confirm_refreshes(self) -> None:
        proj = self.make_project()
        skill_md = self._install_copy(proj)
        skill_md.write_text("totally mine\n")
        p = self.run_installer(
            proj, "--agents", "codex", "--mode", "copy",
            "--domains", "literature-search",
            stdin="y\n", env={"GENESIS_FORCE_INTERACTIVE": "1"})
        self.assertIn("refreshed=1", p.stdout)
        self.assertNotIn("totally mine", skill_md.read_text())

    def test_t025_interactive_decline_keeps_edit(self) -> None:
        proj = self.make_project()
        skill_md = self._install_copy(proj)
        skill_md.write_text("totally mine\n")
        self.run_installer(
            proj, "--agents", "codex", "--mode", "copy",
            "--domains", "literature-search",
            stdin="n\n", env={"GENESIS_FORCE_INTERACTIVE": "1"}, check_rc=3)
        self.assertIn("totally mine", skill_md.read_text())


class TestModeSwitch(InstallerTestCase):
    """record mode change rewrites the path in place (contracts §modes)."""

    def test_mode_switch_refreshes_and_reverts(self) -> None:
        proj = self.make_project()
        self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                           "--domains", "literature-search")
        link = Path(proj) / ".agents" / "skills" / "literature-search"
        self.assertTrue(link.is_dir() and not link.is_symlink())
        p2 = self.run_installer(proj, "--agents", "codex", "--mode", "symlink",
                                "--domains", "literature-search")
        self.assertIn("refreshed=1", p2.stdout)
        self.assertTrue(link.is_symlink())
        p3 = self.run_installer(proj, "--agents", "codex", "--mode", "copy",
                                "--domains", "literature-search")
        self.assertIn("refreshed=1", p3.stdout)
        self.assertTrue(link.is_dir() and not link.is_symlink())
        # uninstall works in either recorded mode
        self.run_installer(proj, "--agents", "codex", "--uninstall")
        self.assertFalse(link.exists())


class TestRefusals(InstallerTestCase):
    """FR-010/011 refusals exit 3 leaving the project untouched."""

    def test_collision_with_existing_path_refuses(self) -> None:
        # block a skill destination with a foreign regular file
        proj = self.make_project(files={".agents/skills/git-commit": "mine\n"})
        victim = Path(proj) / ".agents" / "skills" / "git-commit"
        self.assertTrue(victim.is_file() and not victim.is_dir())
        base = self.tree_hash(proj)
        p = self.run_installer(proj, "--agents", "codex", check_rc=3)
        self.assertEqual(base, self.tree_hash(proj))
        self.assertFalse((Path(proj) / ".ompd" / "genesis.lock").exists())
        self.assertIn("exists", p.stdout + p.stderr)

    def test_self_install_refuses(self) -> None:
        p = self.run_installer(str(Path(__file__).resolve().parent.parent),
                               "--agents", "codex", check_rc=3)
        self.assertIn("catalog clone", p.stdout + p.stderr)

    def test_foreign_ompd_refuses(self) -> None:
        proj = self.make_project(files={".ompd/other.lock": "foreign\n"})
        (Path(proj) / ".ompd" / "genesis.lock.d").mkdir(exist_ok=True)
        p = self.run_installer(proj, "--agents", "codex", check_rc=3)
        self.assertIn("was not created by this installer", p.stderr)
        self.assertTrue((Path(proj) / ".ompd" / "other.lock").is_file())
