"""Tests for scripts/check_pushed_tree.sh using throwaway git repos."""

import os
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "check_pushed_tree.sh")
ZERO = "0" * 40


def hermetic_env():
    env = {k: v for k, v in os.environ.items() if not k.startswith(("GIT_", "CI_", "GITLAB_"))}
    env.update(
        GIT_CONFIG_GLOBAL="/dev/null",
        GIT_CONFIG_NOSYSTEM="1",
        GIT_AUTHOR_NAME="t",
        GIT_AUTHOR_EMAIL="t@t",
        GIT_COMMITTER_NAME="t",
        GIT_COMMITTER_EMAIL="t@t",
    )
    return env


class PushedTreeGuardTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.dir)
        os.makedirs(os.path.join(self.dir, "scripts"))
        shutil.copy(SCRIPT, os.path.join(self.dir, "scripts"))
        os.makedirs(os.path.join(self.dir, "skills", "demo"))
        self.write("skills/demo/SKILL.md", "one\n")
        self.git("init", "-q")
        self.git("add", "-A")
        self.git("commit", "-qm", "first")
        self.first = self.git("rev-parse", "HEAD")
        self.write("skills/demo/SKILL.md", "two\n")
        self.git("commit", "-qam", "second")
        self.head = self.git("rev-parse", "HEAD")

    def write(self, path, content):
        with open(os.path.join(self.dir, path), "w") as f:
            f.write(content)

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.dir, env=hermetic_env(), check=True, capture_output=True, text=True
        ).stdout.strip()

    def run_guard(self, stdin):
        return subprocess.run(
            ["bash", "scripts/check_pushed_tree.sh"],
            cwd=self.dir, env=hermetic_env(), input=stdin, capture_output=True, text=True,
        )

    def run_guard_devnull(self):
        return subprocess.run(
            ["bash", "scripts/check_pushed_tree.sh"], cwd=self.dir, env=hermetic_env(),
            stdin=subprocess.DEVNULL, capture_output=True, text=True,
        )

    def push_line(self, sha):
        return f"refs/heads/topic {sha} refs/heads/topic {ZERO}\n"

    def test_clean_tree_pushing_head_passes(self):
        self.assertEqual(self.run_guard(self.push_line(self.head)).returncode, 0)

    def test_dirty_tracked_file_fails(self):
        self.write("skills/demo/SKILL.md", "edited\n")
        result = self.run_guard(self.push_line(self.head))
        self.assertEqual(result.returncode, 1)
        self.assertIn("Commit or stash", result.stderr)

    def test_untracked_file_is_ignored(self):
        self.write("skills/demo/new.md", "new\n")
        self.assertEqual(self.run_guard(self.push_line(self.head)).returncode, 0)

    def test_pushing_non_head_sha_fails(self):
        result = self.run_guard(self.push_line(self.first))
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"Pushing refs/heads/topic ({self.first}) but HEAD is {self.head}", result.stderr)

    def test_no_stdin_is_a_manual_run_and_skips_both_checks(self):
        self.write("skills/demo/SKILL.md", "edited\n")
        for stdin in ("", None):
            result = self.run_guard(stdin) if stdin is not None else self.run_guard_devnull()
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_dirty_file_anywhere_tracked_fails(self):
        self.write("notes.txt", "x\n")
        self.git("add", "notes.txt")
        self.git("commit", "-qm", "notes")
        self.write("notes.txt", "y\n")
        result = self.run_guard(self.push_line(self.git("rev-parse", "HEAD")))
        self.assertEqual(result.returncode, 1)
        self.assertIn("Commit or stash", result.stderr)

    def test_annotated_tag_at_head_passes(self):
        self.git("tag", "-a", "v1", "-m", "v1")
        tag_sha = self.git("rev-parse", "v1")
        self.assertNotEqual(tag_sha, self.head)
        result = self.run_guard(f"refs/tags/v1 {tag_sha} refs/tags/v1 {ZERO}\n")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_multi_ref_push_with_one_bad_ref_fails(self):
        result = self.run_guard(self.push_line(self.head) + f"refs/heads/old {self.first} refs/heads/old {ZERO}\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"Pushing refs/heads/old ({self.first}) but HEAD is {self.head}", result.stderr)
        self.assertNotIn("refs/heads/topic (", result.stderr)

    def test_unterminated_last_line_is_still_checked(self):
        result = self.run_guard(self.push_line(self.first).rstrip("\n"))
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"Pushing refs/heads/topic ({self.first}) but HEAD is {self.head}", result.stderr)

    def test_deletion_only_push_skips_dirty_check(self):
        self.write("skills/demo/SKILL.md", "edited\n")
        result = self.run_guard(f"(delete) {ZERO} refs/heads/topic {self.head}\n")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_branch_deletion_passes(self):
        self.assertEqual(self.run_guard(f"(delete) {ZERO} refs/heads/topic {self.head}\n").returncode, 0)


if __name__ == "__main__":
    unittest.main()
