#!/usr/bin/env python3
"""Build a versioned patch archive by overlaying verified replacement files.

The source archive is never modified. The output path must not exist.
"""

from __future__ import annotations

import argparse
import shutil
import zipfile
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-zip", required=True, type=Path)
    parser.add_argument("--replacements", required=True, type=Path)
    parser.add_argument("--output-zip", required=True, type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.output_zip.exists():
        raise FileExistsError(f"Refusing to overwrite {args.output_zip}")
    if not args.source_zip.is_file() or not args.replacements.is_dir():
        raise FileNotFoundError("Source zip or replacement directory is missing")

    replacements = {
        path.relative_to(args.replacements).as_posix(): path
        for path in args.replacements.rglob("*")
        if path.is_file()
    }
    args.output_zip.parent.mkdir(parents=True, exist_ok=True)
    copied = 0
    skipped = 0
    with zipfile.ZipFile(args.source_zip, "r") as source:
        source_names = source.namelist()
        if len(source_names) != len(set(source_names)):
            raise ValueError("Source archive contains duplicate member names")
        with zipfile.ZipFile(
            args.output_zip, "x", compression=zipfile.ZIP_DEFLATED, compresslevel=6,
            allowZip64=True
        ) as output:
            for info in source.infolist():
                if info.filename in replacements:
                    skipped += 1
                    continue
                if info.is_dir():
                    output.writestr(info, b"")
                else:
                    with source.open(info, "r") as src, output.open(info, "w") as dst:
                        shutil.copyfileobj(src, dst, length=1024 * 1024)
                copied += 1
            for arcname, path in sorted(replacements.items()):
                output.write(path, arcname=arcname)

    with zipfile.ZipFile(args.output_zip, "r") as check:
        names = check.namelist()
        if len(names) != len(set(names)):
            raise AssertionError("Built archive contains duplicate member names")
        missing = set(replacements).difference(names)
        if missing:
            raise AssertionError(f"Built archive lacks replacements: {sorted(missing)}")
        bad = check.testzip()
        if bad is not None:
            raise AssertionError(f"CRC verification failed at {bad}")
    print(
        f"Built {args.output_zip} with {copied} inherited members, "
        f"{skipped} replaced members, and {len(replacements)} overlays."
    )


if __name__ == "__main__":
    main()
