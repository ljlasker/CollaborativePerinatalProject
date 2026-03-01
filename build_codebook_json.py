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

# --- 3. Supplementary Codebook (2,534 sparse variables) ---
SUPP_CSV = os.path.join(CLEAN, "cpp_unified_supplementary_codebook.csv")
supp = []
with open(SUPP_CSV, encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        supp.append({
            "varname": row["variable_name"],
            "source": row["source_card"],
            "original_name": row["original_name"],
            "label": row["item_name"],
            "n": int(row["n_nonmissing"]),
            "pct_coverage": float(row["pct_coverage_full"]),
            "reason": row["reason_sparse"],
            "related": row["related_main_column"],
        })

with open(os.path.join("js", "supplementary_data.js"), "w", encoding="utf-8") as f:
    f.write("const SUPPLEMENTARY_DATA = ")
    json.dump(supp, f, ensure_ascii=False)
    f.write(";\n")
print(f"Supplementary codebook: {len(supp)} entries")
