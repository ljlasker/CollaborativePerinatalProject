#!/usr/bin/env python3
"""Convert CPP codebooks to JavaScript files for the codebook browser."""

import csv
import json
import os

CLEAN = os.path.join("..", "..", "clean")

# --- 1. CPPVAR Codebook (1,239 variables) ---
CODEBOOK_CSV = os.path.join(CLEAN, "CPP_Codebook.csv")
rows = []
with open(CODEBOOK_CSV, encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        rows.append({
            "varname": row["varname"],
            "label": row["label"],
            "description": row["description"],
            "type": row["type"],
            "codes": row["codes"],
            "missing_codes": row["missing_codes"],
            "section": row["section"],
            "col_from": row["col_from"],
            "col_to": row["col_to"],
        })

with open(os.path.join("js", "codebook_data.js"), "w", encoding="utf-8") as f:
    f.write("const CODEBOOK_DATA = ")
    json.dump(rows, f, ensure_ascii=False)
    f.write(";\n")
print(f"CPPVAR codebook: {len(rows)} entries")

# --- 2. Unified Manifest (4,862 variables) ---
MANIFEST_CSV = os.path.join(CLEAN, "cpp_unified_manifest.csv")
manifest = []
with open(MANIFEST_CSV, encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        manifest.append({
            "varname": row["variable_name"],
            "source": row["source"],
            "original_name": row["original_name"],
            "label": row["label"],
            "n": int(row["N_nonmissing"]),
            "pct_missing": float(row["pct_missing"]),
            "is_numeric": row["is_numeric"] == "TRUE",
            "mean": row["mean"],
            "sd": row["sd"],
        })

with open(os.path.join("js", "manifest_data.js"), "w", encoding="utf-8") as f:
    f.write("const MANIFEST_DATA = ")
    json.dump(manifest, f, ensure_ascii=False)
    f.write(";\n")
print(f"Unified manifest: {len(manifest)} entries")
