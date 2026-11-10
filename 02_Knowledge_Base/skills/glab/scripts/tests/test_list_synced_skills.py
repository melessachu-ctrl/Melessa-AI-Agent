"""Tests for scripts/list_synced_skills.sh using throwaway manifests."""

import os
import subprocess
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "list_synced_skills.sh")

MANIFEST = """\
# comment
skills:
  alpha:
    source_project: a/b
    mode: mr
  beta-2:
    source_project: c/d
other:
  gamma:
    x: 1
"""


class ListSyncedSkillsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

    def write(self, text, name="synced-skills.yml"):
        path = os.path.join(self.tmp.name, name)
        with open(path, "w") as f:
            f.write(text)
        return path

    def run_script(self, *args):
        result = subprocess.run(
            [SCRIPT, *args], cwd=self.tmp.name, capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.splitlines()

    def test_default_manifest_in_cwd(self):
        self.write(MANIFEST)
        self.assertEqual(self.run_script(), ["alpha", "beta-2"])

    def test_explicit_manifest_argument(self):
        path = self.write(MANIFEST, "custom.yml")
        self.assertEqual(self.run_script(path), ["alpha", "beta-2"])

    def test_stops_at_next_top_level_key(self):
        self.write(MANIFEST)
        self.assertNotIn("gamma", self.run_script())

    def test_no_skills_section(self):
        self.write("other:\n  gamma:\n    x: 1\n")
        self.assertEqual(self.run_script(), [])

    def test_empty_skills_mapping(self):
        self.write("skills: {}\n")
        self.assertEqual(self.run_script(), [])

    def test_missing_manifest(self):
        self.assertEqual(self.run_script(), [])


if __name__ == "__main__":
    unittest.main()
