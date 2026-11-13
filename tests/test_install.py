"""Tests for install.py.

Each test copies the installer and its sources into a temporary directory and
runs that copy with HOME set to a temporary home, so the real home directory is
never read or written.
"""

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SOURCES = ("install.py", "rules", "roles", "claude-agents", "bin")
STATE = ".config/vaibes/install-state.json"
BEGIN_PREFIX = "<!-- BEGIN vaibes rules"
END_LINE = "<!-- END vaibes rules -->"


class InstallTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.src = self.root / "vaibes"
        self.home = self.root / "home"

        temp_root = Path(tempfile.gettempdir()).resolve()
        self.assertTrue(
            self.home.resolve().is_relative_to(temp_root),
            f"test HOME {self.home} is outside {temp_root}",
        )

        self.home.mkdir()
        self.src.mkdir()
        for name in SOURCES:
            source = REPO / name
            if source.is_dir():
                shutil.copytree(source, self.src / name)
            else:
                shutil.copy2(source, self.src / name)

    def install(self, *args):
        env = dict(os.environ, HOME=str(self.home))
        return subprocess.run(
            [sys.executable, str(self.src / "install.py"), *args],
            env=env,
            capture_output=True,
            text=True,
        )

    def assertExit(self, result, code):
        self.assertEqual(result.returncode, code, f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}")

    def source(self, rel):
        return (self.src / rel).read_text()

    def rules(self, with_delegation=True):
        shared = self.source("rules/global.md")
        return shared + "\n" + self.source("rules/delegation.md") if with_delegation else shared

    def block(self, rel):
        lines = (self.home / rel).read_text().splitlines(keepends=True)
        begin = next(i for i, line in enumerate(lines) if line.startswith(BEGIN_PREFIX))
        end = lines.index(END_LINE + "\n")
        return "".join(lines[begin + 1 : end])

    def snapshot(self):
        return {
            path.relative_to(self.home): (os.readlink(path) if path.is_symlink() else path.read_bytes())
            for path in self.home.rglob("*")
            if path.is_file() or path.is_symlink()
        }

    def test_fresh_install_creates_all_targets(self):
        self.assertExit(self.install("claude", "grok"), 0)

        copies = {
            ".local/bin/agent-role": "bin/agent-role",
            ".config/agent-roles/scout.md": "roles/scout.md",
            ".config/agent-roles/reviewer.md": "roles/reviewer.md",
            ".claude/agents/scout.md": "claude-agents/scout.md",
            ".claude/agents/worker.md": "claude-agents/worker.md",
        }
        for target, source in copies.items():
            self.assertEqual((self.home / target).read_bytes(), (self.src / source).read_bytes(), target)
        self.assertTrue(os.access(self.home / ".local/bin/agent-role", os.X_OK))

        for target in (".claude/CLAUDE.md", ".grok/AGENTS.md"):
            text = (self.home / target).read_text()
            self.assertTrue(text.startswith(BEGIN_PREFIX), target)
            self.assertTrue(text.endswith(END_LINE + "\n"), target)
            self.assertEqual(self.block(target), self.rules(), target)
        self.assertFalse((self.home / ".codex").exists())
        self.assertFalse((self.home / ".pi").exists())
        self.assertTrue((self.home / STATE).is_file())

        self.assertExit(self.install("claude", "grok"), 0)
        self.assertExit(self.install("--check", "claude", "grok"), 0)

    def test_keeps_machine_text_outside_block(self):
        claude_md = self.home / ".claude/CLAUDE.md"
        claude_md.parent.mkdir(parents=True)
        claude_md.write_text("@machine-guide.md\n")
        self.assertExit(self.install("claude"), 0)

        global_md = self.src / "rules/global.md"
        global_md.write_text(global_md.read_text() + "- A new shared rule.\n")
        self.assertExit(self.install("claude"), 0)

        text = claude_md.read_text()
        self.assertEqual(text.splitlines()[0], "@machine-guide.md")
        self.assertEqual(self.block(".claude/CLAUDE.md"), self.rules())
        self.assertIn("- A new shared rule.", text)
        self.assertEqual(text.count(BEGIN_PREFIX), 1)
        self.assertEqual(text.count(END_LINE), 1)

    def test_pi_gets_rules_without_delegation(self):
        self.assertExit(self.install("pi"), 0)

        self.assertEqual(self.block(".pi/agent/AGENTS.md"), self.rules(with_delegation=False))
        self.assertNotIn("## Delegation", (self.home / ".pi/agent/AGENTS.md").read_text())

    def test_refuses_symlink_and_writes_nothing(self):
        # A stow-style link to an identical file, so only the symlink rule can
        # refuse it. It comes after agent-role in install order.
        linked = self.root / "dotfiles/scout.md"
        linked.parent.mkdir()
        shutil.copy2(self.src / "claude-agents/scout.md", linked)
        link = self.home / ".claude/agents/scout.md"
        link.parent.mkdir(parents=True)
        link.symlink_to(linked)

        result = self.install("claude")

        self.assertExit(result, 1)
        self.assertIn("symlink", result.stderr)
        self.assertFalse((self.home / ".local/bin/agent-role").exists())
        self.assertFalse((self.home / ".claude/CLAUDE.md").exists())
        self.assertFalse((self.home / STATE).exists())
        self.assertTrue(link.is_symlink())

    def test_refuses_local_edit(self):
        self.assertExit(self.install("claude"), 0)
        target = self.home / ".config/agent-roles/scout.md"
        target.write_text(target.read_text() + "A local edit.\n")
        edited = target.read_bytes()
        role = self.src / "roles/scout.md"
        role.write_text(role.read_text() + "A new upstream line.\n")

        result = self.install("claude")

        self.assertExit(result, 1)
        self.assertIn("changed since the last install", result.stderr)
        self.assertEqual(target.read_bytes(), edited)

    def test_refuses_malformed_markers(self):
        claude_md = self.home / ".claude/CLAUDE.md"
        claude_md.parent.mkdir(parents=True)
        claude_md.write_text(
            "@machine-guide.md\n\n"
            f"{BEGIN_PREFIX} -->\nold rules\n"
            f"{BEGIN_PREFIX} -->\nmore rules\n"
            f"{END_LINE}\n"
        )
        before = claude_md.read_bytes()

        result = self.install("claude")

        self.assertExit(result, 1)
        self.assertIn("markers", result.stderr)
        self.assertEqual(claude_md.read_bytes(), before)

    def test_check_reports_drift_without_writing(self):
        self.assertExit(self.install("claude"), 0)
        worker = self.home / ".claude/agents/worker.md"
        worker.write_text(worker.read_text() + "A local edit.\n")
        before = self.snapshot()

        result = self.install("--check", "claude")

        self.assertExit(result, 1)
        self.assertIn("changed locally  ~/.claude/agents/worker.md", result.stdout)
        self.assertEqual(self.snapshot(), before)

    def test_unknown_agent_is_usage_error(self):
        self.assertExit(self.install("foo"), 2)
        self.assertFalse((self.home / ".local").exists())


if __name__ == "__main__":
    unittest.main()
