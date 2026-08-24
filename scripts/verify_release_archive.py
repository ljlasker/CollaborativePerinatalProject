#!/usr/bin/env python3
"""Verify archive CRCs and every entry listed in its SHA256SUMS.txt."""

from __future__ import annotations

import argparse
import hashlib
import zipfile
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    args = parser.parse_args()
    with zipfile.ZipFile(args.archive, "r") as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise AssertionError("Archive contains duplicate member names")
        bad = archive.testzip()
        if bad is not None:
            raise AssertionError(f"CRC failure: {bad}")
        lines = archive.read("SHA256SUMS.txt").decode("utf-8").splitlines()
        checked = 0
        for line in lines:
            expected, member = line.split("  ", 1)
            actual = hashlib.sha256(archive.read(member)).hexdigest()
            if actual != expected:
                raise AssertionError(f"SHA-256 mismatch: {member}")
            checked += 1
    print(
        f"PASS: {args.archive.name} has {len(names)} unique members, valid CRCs, "
        f"and {checked} matching internal SHA-256 checksums."
    )


if __name__ == "__main__":
    main()
