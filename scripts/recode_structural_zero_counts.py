#!/usr/bin/env python3
"""Repair structural-zero pregnancy-history counts in released CPP CSV files.

CPPVAR uses variable-specific codes to mean "no prior pregnancy" for several
count variables. In a count field, that state implies zero; it is not missing. This
utility joins an analysis-ready CSV to the untouched CPPVAR extraction by
``case_id`` and reconstructs the documented count values from source.

It supports unprefixed Tier-1 names as well as ``v2_`` and ``v3_`` names in
the unified release. The output path must be new, preserving the original
release asset for auditability.
"""

from __future__ import annotations

import argparse
import csv
import json
from collections import Counter
from pathlib import Path
from typing import Iterable, Mapping, TextIO


RAW_RULES = {
    "parity": ("v46_parity_pregnancies_total_number", "88", "99", False),
    "prior_perinatal_loss": ("v48_deaths_total_number_prior", "88", "99", False),
    "prior_livebirths": ("v50_livebirths_total_number_prior", "88", "99", False),
    "prior_preterm_births": ("v388_premature_births_total_number", "8", "9", True),
    "prior_fetal_deaths": ("v389_fetal_deaths_abortion_less", "8", "9", True),
    "prior_stillbirths": ("v391_stillbirths_deaths_20_weeks", "8", "9", True),
    "prior_neonatal_deaths": ("v392_deaths_neonatal_stillbirths_total", "88", "99", True),
    "full_sib_total": ("v396_siblings_full_total_number", "88", "99", True),
    "full_sib_fetal_death": ("v399_siblings_full_stillborn_fetal", "8", "9", True),
    "full_sib_neonatal_death": ("v405_siblings_full_death_neonatal", "8", "9", True),
    "full_sib_death_post28d": ("v406_siblings_full_death_28", "8", "9", True),
}
PREFIXES = ("", "v2_", "v3_")


def corrected_value(
    raw_value: str, clean_value: str, zero: str, unknown: str, authoritative: bool
) -> str:
    """Decode a structural zero; optionally rebuild the complete clean count."""
    raw_value = raw_value.strip()
    if raw_value == zero:
        return "0"
    if not authoritative:
        return clean_value
    if not raw_value or raw_value == unknown:
        return ""
    return str(int(raw_value)) if raw_value.isdigit() else raw_value


def canonical_case_id(value: str) -> str:
    """Complete a blank ninth child digit on the right, preserving ID layout."""
    value = value.rstrip()
    if value.isdigit() and len(value) == 8:
        return f"{value}0"
    return value


def load_raw_values(raw_stream: TextIO) -> tuple[
    dict[str, dict[str, str]], dict[str, dict[str, str]]
]:
    reader = csv.DictReader(raw_stream)
    required = {"case_id", *(rule[0] for rule in RAW_RULES.values())}
    missing = required.difference(reader.fieldnames or ())
    if missing:
        raise ValueError(f"Raw CPPVAR CSV is missing columns: {sorted(missing)}")

    values: dict[str, dict[str, str]] = {}
    aliases: dict[str, dict[str, str]] = {}
    for row in reader:
        case_id = row["case_id"]
        if case_id in values:
            raise ValueError(f"Duplicate case_id in raw CPPVAR CSV: {case_id}")
        row_values = {
            clean_name: row[rule[0]] for clean_name, rule in RAW_RULES.items()
        }
        values[case_id] = row_values
        trimmed = case_id.rstrip()
        row_aliases = {trimmed, canonical_case_id(trimmed)}
        # v3.2's RDS exporter incorrectly left-padded these eight-character IDs.
        # Retain that form as an input alias only so already-downloaded files can
        # be repaired, but never emit it as the canonical identifier.
        if trimmed.isdigit() and len(trimmed) == 8:
            row_aliases.add(trimmed.zfill(9))
        for alias in row_aliases:
            if alias in aliases and aliases[alias] is not row_values:
                raise ValueError(f"Ambiguous CPPVAR case_id alias: {alias}")
            aliases[alias] = row_values
    return values, aliases


def target_columns(fieldnames: Iterable[str]) -> dict[str, str]:
    available = set(fieldnames)
    targets: dict[str, str] = {}
    for prefix in PREFIXES:
        for clean_name in RAW_RULES:
            column = f"{prefix}{clean_name}"
            if column in available:
                targets[column] = clean_name
    if not targets:
        expected = [f"{prefix}{name}" for prefix in PREFIXES for name in RAW_RULES]
        raise ValueError(f"No repairable columns found; expected one of: {expected}")
    return targets


def rewrite_csv(
    clean_stream: TextIO,
    output_stream: TextIO,
    raw_values: Mapping[str, Mapping[str, str]],
    raw_aliases: Mapping[str, Mapping[str, str]],
) -> dict[str, object]:
    reader = csv.DictReader(clean_stream)
    if not reader.fieldnames or "case_id" not in reader.fieldnames:
        raise ValueError("Analysis-ready CSV must contain case_id")
    targets = target_columns(reader.fieldnames)
    writer = csv.DictWriter(output_stream, fieldnames=reader.fieldnames, lineterminator="\n")
    writer.writeheader()

    changed: Counter[str] = Counter()
    raw_88: Counter[str] = Counter()
    unmatched = 0
    normalized_fallback = 0
    rows = 0
    for row in reader:
        rows += 1
        source = raw_values.get(row["case_id"])
        if source is None:
            source = raw_aliases.get(row["case_id"].rstrip())
            if source is None:
                unmatched += 1
                writer.writerow(row)
                continue
            normalized_fallback += 1
        for target, clean_name in targets.items():
            raw_value = source[clean_name]
            _, zero, unknown, authoritative = RAW_RULES[clean_name]
            if raw_value.strip() == zero:
                raw_88[target] += 1
            repaired = corrected_value(
                raw_value, row[target], zero, unknown, authoritative
            )
            if raw_value.strip() == zero and repaired != "0":
                raise AssertionError(f"{target}: structural zero did not decode to 0")
            if repaired != row[target]:
                changed[target] += 1
                row[target] = repaired
        writer.writerow(row)

    # Unified assets contain records outside CPPVAR. They have no authoritative
    # source row for these fields and are preserved unchanged. Tier-1 assets
    # should still report zero unmatched rows in their audit summaries.
    return {
        "rows": rows,
        "unmatched_case_ids": unmatched,
        "normalized_fallback_matches": normalized_fallback,
        "changed": dict(sorted(changed.items())),
        "raw_88": dict(sorted(raw_88.items())),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--clean", required=True, type=Path, help="Released clean/unified CSV")
    parser.add_argument("--raw", required=True, type=Path, help="Untouched cppvar_all_columns.csv")
    parser.add_argument("--output", required=True, type=Path, help="New corrected CSV path")
    parser.add_argument("--summary-json", type=Path, help="Optional new JSON audit summary path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    for output in (args.output, args.summary_json):
        if output is not None and output.exists():
            raise FileExistsError(f"Refusing to overwrite existing file: {output}")
    args.output.parent.mkdir(parents=True, exist_ok=True)

    with args.raw.open(encoding="utf-8-sig", newline="") as raw_stream:
        raw_values, raw_aliases = load_raw_values(raw_stream)
    with args.clean.open(encoding="utf-8-sig", newline="") as clean_stream:
        with args.output.open("x", encoding="utf-8", newline="") as output_stream:
            summary = rewrite_csv(
                clean_stream, output_stream, raw_values, raw_aliases
            )

    summary.update(
        {
            "clean_input": str(args.clean.resolve()),
            "raw_input": str(args.raw.resolve()),
            "corrected_output": str(args.output.resolve()),
        }
    )
    if args.summary_json is not None:
        args.summary_json.parent.mkdir(parents=True, exist_ok=True)
        with args.summary_json.open("x", encoding="utf-8", newline="\n") as stream:
            json.dump(summary, stream, indent=2, sort_keys=True)
            stream.write("\n")
    print(json.dumps(summary, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
