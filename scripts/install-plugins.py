"""Install immutable plugin revisions; no plugin bootstrap inside Neovim."""
import json
import pathlib
import subprocess
import sys

manifest, site = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
for repo, commit in json.loads(manifest.read_text(encoding="utf-8")).items():
    destination = site / "pack" / "veridis" / "start" / repo.split("/")[-1]
    destination.mkdir(parents=True, exist_ok=True)
    def git(*args):
        return subprocess.check_output(["git", "-C", str(destination), *args], text=True).strip()
    git("init", "--quiet")
    git("fetch", "--quiet", "--depth=1", "https://github.com/" + repo + ".git", commit)
    git("checkout", "--quiet", "--detach", "FETCH_HEAD")
    assert git("rev-parse", "HEAD") == commit, repo
    print(f"Installed {repo} at {commit[:12]}", flush=True)
