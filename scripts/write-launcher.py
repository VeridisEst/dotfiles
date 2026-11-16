import datetime
import pathlib
import shlex
import sys

release = pathlib.Path(sys.argv[1]).resolve()
launcher = pathlib.Path(sys.argv[2])
tools = sys.argv[3] == "1"
q = shlex.quote
body = "#!/usr/bin/env bash\nset -e\nexport NVIM_APPNAME=veridis-nvim\n"
body += f"export VERIDIS_RELEASE={q(str(release))}\n"
body += f'export PATH={q(str(release / "python/bin"))}:{q(str(release / "gems/bin"))}:"$PATH"\n'
if tools:
    body += f"export GEM_HOME={q(str(release / 'gems'))}\nexport GEM_PATH={q(str(release / 'gems'))}\n"
body += f'exec {q(str(release / "neovim/bin/nvim"))} "$@"\n'
if launcher.exists() or launcher.is_symlink():
    suffix = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    launcher.rename(launcher.with_name(launcher.name + ".backup." + suffix))
launcher.write_text(body, encoding="utf-8")
launcher.chmod(0o755)
