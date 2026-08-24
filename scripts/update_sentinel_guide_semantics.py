#!/usr/bin/env python3
"""Correct structural-zero descriptions in the derived CPPVAR sentinel guide."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


STRUCTURAL_ZERO_ITEMS = (
    set(range(5248, 5252))
    | set(range(5255, 5270))
    | set(range(5271, 5302))
)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("guide", type=Path)
    parser.add_argument("codebook", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    if args.output.exists():
        raise SystemExit(f"Refusing to overwrite existing output: {args.output}")

    with args.codebook.open(newline="", encoding="utf-8-sig") as handle:
        codebook = {row["item_id"]: row for row in csv.DictReader(handle)}

    with args.guide.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        rows = list(reader)
        fieldnames = reader.fieldnames

    changed = 0
    for row in rows:
        try:
            item_id = int(row["item_id"])
        except ValueError:
            continue
        if item_id not in STRUCTURAL_ZERO_ITEMS:
            continue
        authoritative = codebook.get(str(item_id))
        # Item 5301's source-code definition continues from the preceding page;
        # its guide row nevertheless carries the same 8/9 scheme as 5248--5300.
        codebook_confirms = authoritative is not None and "NO PRIOR PREGNANCY" in authoritative["codes"].upper()
        if not codebook_confirms and item_id != 5301:
            raise AssertionError(f"No authoritative structural-zero definition for item {item_id}")
        meanings = row["sentinel_meanings"].split("; ")
        meanings = ["8=no prior pregnancy (structural zero)" if part.startswith("8=") else part for part in meanings]
        new_meaning = "; ".join(meanings)
        if new_meaning != row["sentinel_meanings"]:
            row["sentinel_meanings"] = new_meaning
            changed += 1

    if changed != len(STRUCTURAL_ZERO_ITEMS):
        raise AssertionError(f"Expected {len(STRUCTURAL_ZERO_ITEMS)} changes, observed {changed}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("x", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)

    print(f"Updated {changed} structural-zero descriptions: {args.output}")


if __name__ == "__main__":
    main()
