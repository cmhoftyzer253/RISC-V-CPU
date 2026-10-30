import argparse
import re
import shutil
import subprocess
import sys
from collections import Counter
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

TARGETS = {
    "core": {
        "filelist": "rtl/core.f",
        "top": "core",
    },
}

INCLUDE_DIRS = ["rtl/utils"]

VERILATOR_FILES = [
    "sim/verilator/lint.vlt",
    "sim/verilator/xpm_memory_sdpram.sv",
]

TESTED_VERSION = "5.034"

MESSAGE_RE = re.compile(r"^%(Error|Warning)(?:-(\w+))?:")

def parse_args():
    parser = argparse.ArgumentParser(description="Lint the RTL with Verilator")

    parser.add_argument("target", nargs="?", default="core", choices=sorted(TARGETS), help="override default lint target")
    parser.add_argument("--top", help="override target default module top module")
    parser.add_argument("--strict", action="store_true", help="strict linting")
    parser.add_argument("--verilator", default="verilator", help="override default verilator executable")
    parser.add_argument("extra", nargs="*", help="extra verilator arguments")

    return parser.parse_args()

def check_verilator(exe):
    path = shutil.which(exe)
    if path is None:
        sys.exit(f"lint: verilator not found: ({exe}), install verilator or pass --verilator PATH")

    version = subprocess.run([path, "--version"], capture_output=True, text=True).stdout.strip()
    if TESTED_VERSION not in version:
        print(f"lint note: using {version}, RTL tested with {TESTED_VERSION}", file=sys.stderr)

    return path

def check_files(target):
    filelist = REPO_ROOT / target["filelist"]
    missing = [f for f in [target["filelist"], *VERILATOR_FILES] if not (REPO_ROOT / f).is_file()]
    if missing:
        sys.exit("lint: missing file(s): " + ", ".join(missing))

    stale = []
    for line in filelist.read_text().splitlines():
        entry = line.split("//", 1)[0].strip()
        if entry and not entry.startswith(("-", "+")) and not (REPO_ROOT / entry).is_file():
            stale.append(entry)

    if stale:
        sys.exit(f"lint: {target['filelist']} lists file(s) that don't exist: " + ", ".join(stale))

def main():
    args = parse_args()
    target = TARGETS[args.target]
    top = args.top or target["top"]

    verilator = check_verilator(args.verilator)
    check_files(target)

    cmd = [
        verilator,
        "--lint-only",
        "-Wall",
        "--error-limit", "1000",
        *([] if args.strict else ["-Wno-fatal"]),
        *[f"-I{d}" for d in INCLUDE_DIRS],
        VERILATOR_FILES[0],
        "-f", target["filelist"],
        *VERILATOR_FILES[1:],
        "--top-module", top,
        *args.extra,
    ]

    print(f"lint: {args.target} (top: {top})", file=sys.stderr)
    result = subprocess.run(cmd, cwd=REPO_ROOT, capture_output=True, text=True)
    output = result.stdout + result.stderr
    if output:
        print(output, end="" if output.endswith("\n") else "\n")

    counts = Counter()
    for line in output.splitlines():
        match = MESSAGE_RE.match(line)
        if match and not line.startswith("%Error: Exiting due to"):
            counts[match.group(2) or match.group(1).upper()] += 1

    if counts:
        summary = ", ".join(f"{n} {kind}" for kind, n in sorted(counts.items()))
        print(f"lint: {sum(counts.values())} message(s): {summary}", file=sys.stderr)
    else:
        print("lint: clean", file=sys.stderr)

    return 0 if result.returncode == 0 else 1

if __name__ == "__main__":
    sys.exit(main())