#!/usr/bin/env python3
"""Write deterministic SHA-256 checksums for a staged release directory."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        while block := handle.read(1024 * 1024):
            hasher.update(block)
    return hasher.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output.resolve()
    if output.exists():
        raise FileExistsError(f"Refusing to overwrite {output}")
    if not root.is_dir() or output.parent != root:
        raise ValueError("Output must be a new file directly under the release root")

    files = sorted(
        (path for path in root.rglob("*") if path.is_file() and path != output),
        key=lambda path: path.relative_to(root).as_posix(),
    )
    lines = [f"{digest(path)}  {path.relative_to(root).as_posix()}" for path in files]
    output.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"Wrote {len(lines)} checksums to {output}")


if __name__ == "__main__":
    main()
