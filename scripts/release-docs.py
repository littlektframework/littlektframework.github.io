import argparse
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERSIONS = os.path.join(ROOT, "_data", "versions.yml")
VERSION = re.compile(r"^\d+(\.\d+)*$")


def read_versions():
    values = {}
    with open(VERSIONS, encoding="utf-8") as file:
        for line in file:
            match = re.match(r'^(latest|next):\s*"?([^"\s]*)"?\s*$', line)
            if match:
                values[match.group(1)] = match.group(2)
    return values


def write_versions(latest, upcoming):
    with open(VERSIONS, "w", encoding="utf-8", newline="\n") as file:
        file.write(f'latest: "{latest}"\n')
        if upcoming:
            file.write(f'next: "{upcoming}"\n')


def start(version, start_from):
    src = os.path.join(ROOT, "_docs", start_from)
    dst = os.path.join(ROOT, "_docs", version)
    if os.path.exists(dst):
        sys.exit(f"_docs/{version} already exists!")
    old = f"/docs/{start_from}/"
    new = f"/docs/{version}/"
    for dirpath, _, filenames in os.walk(src):
        for name in filenames:
            path = os.path.join(dirpath, name)
            target = os.path.join(dst, os.path.relpath(path, src))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            if name.endswith((".md", ".markdown", ".html")):
                with open(path, encoding="utf-8", newline="") as file:
                    text = file.read()
                with open(target, "w", encoding="utf-8", newline="") as file:
                    file.write(text.replace(old, new))
            else:
                shutil.copy2(path, target)
    nav_src = os.path.join(ROOT, "_data", "docs", start_from.replace(".", "_") + ".yml")
    nav_dst = os.path.join(ROOT, "_data", "docs", version.replace(".", "_") + ".yml")
    with open(nav_src, encoding="utf-8", newline="") as file:
        nav = file.read()
    with open(nav_dst, "w", encoding="utf-8", newline="") as file:
        file.write(nav.replace(old, new))


def main():
    parser = argparse.ArgumentParser(
        description="Makes a docs version the latest release & optionally starts the next version."
    )
    parser.add_argument("version", help="the version being released, e.g. 0.12.0")
    parser.add_argument("--next", dest="upcoming", help="the next version to start, e.g. 0.13.0")
    args = parser.parse_args()

    for version in filter(None, [args.version, args.upcoming]):
        if not VERSION.match(version):
            sys.exit(f"'{version}' is not a version number, e.g. 0.12.0")
    if not os.path.isdir(os.path.join(ROOT, "_docs", args.version)):
        sys.exit(f"_docs/{args.version} does not exist!")

    if args.upcoming:
        start(args.upcoming, args.version)
    write_versions(args.version, args.upcoming)
    print(f"Released docs {args.version} at /docs/ & /docs/{args.version}/")
    if args.upcoming:
        print(f"Started docs {args.upcoming} at /docs/next/ & /docs/{args.upcoming}/")


if __name__ == "__main__":
    main()
