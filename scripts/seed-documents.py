"""Create missing template files. Never replace user files or follow symlinks."""
import pathlib
import sys

source, target = map(pathlib.Path, sys.argv[1:3])
target = target.expanduser().absolute()
for item in sorted(source.rglob("*")):
    if not item.is_file():
        continue
    destination = target / item.relative_to(source)
    if any(p.is_symlink() for p in [destination, *destination.parents]):
        raise SystemExit(f"Refusing to seed through a symlink: {destination}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        with destination.open("xb") as stream:
            stream.write(item.read_bytes())
    except FileExistsError:
        pass
print(f"Document structure ready: {target}")
