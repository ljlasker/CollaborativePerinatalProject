#!/usr/bin/env python3
"""Convert CPP_Codebook.csv to a JavaScript file for the codebook browser."""

import csv
import json
import os

CODEBOOK_CSV = os.path.join("..", "..", "clean", "CPP_Codebook.csv")
OUTPUT_JS = os.path.join("js", "codebook_data.js")

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

with open(OUTPUT_JS, "w", encoding="utf-8") as f:
    f.write("const CODEBOOK_DATA = ")
    json.dump(rows, f, ensure_ascii=False)
    f.write(";\n")

print(f"Wrote {len(rows)} entries to {OUTPUT_JS}")
