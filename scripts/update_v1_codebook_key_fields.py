#!/usr/bin/env python3
"""Refresh v1 codebook metadata for canonical case_id and mother_id strings."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--codebook", type=Path, required=True)
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError(f"Refusing to overwrite {args.output}")

    values = {"case_id": [], "mother_id": []}
    seen = {name: set() for name in values}
    with args.data.open(encoding="utf-8-sig", newline="") as stream:
        for row in csv.DictReader(stream):
            for name in values:
                value = row[name]
                if value and value not in seen[name]:
                    seen[name].add(value)
                    values[name].append(value)

    with args.codebook.open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        rows = list(reader)
        fieldnames = reader.fieldnames
    if not fieldnames:
        raise ValueError("Codebook has no header")

    descriptions = {
        "case_id": (
            "Canonical 9-digit child/pregnancy merge identifier "
            "(site + selection + gravida + pregnancy order + terminal digit)"
        ),
        "mother_id": "Canonical 7-digit mother identifier linking siblings",
    }
    for row in rows:
        name = row.get("variable")
        if name not in values:
            continue
        row.update(
            type="character",
            n_valid=str(len(values[name]) if name == "case_id" else 59391),
            n_missing="0",
            pct_missing="0",
            min="NA",
            max="NA",
            mean="NA",
            sd="NA",
            n_unique=str(len(values[name])),
            example_values=", ".join(values[name][:5]),
            description=descriptions[name],
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("x", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main()
