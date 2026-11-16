import pathlib
import shlex
import sys

release = pathlib.Path(sys.argv[1]).resolve()
q = shlex.quote
for name in ("solargraph", "rubocop"):
    body = "#!/usr/bin/env bash\nset -e\n"
    body += f"export GEM_HOME={q(str(release / 'gems'))}\nexport GEM_PATH={q(str(release / 'gems'))}\n"
    body += f"export BUNDLE_GEMFILE={q(str(release / 'ruby/Gemfile'))}\nexport BUNDLE_PATH={q(str(release / 'gems'))}\n"
    body += f'exec {q(str(release / "gems/bin/bundle"))} _2.5.23_ exec {name} "$@"\n'
    output = release / "ruby-bin" / name
    output.write_text(body, encoding="utf-8")
    output.chmod(0o755)
