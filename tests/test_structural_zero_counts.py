import csv
import io
import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from recode_structural_zero_counts import (  # noqa: E402
    RAW_RULES,
    canonical_case_id,
    corrected_value,
    load_raw_values,
    rewrite_csv,
)


class StructuralZeroTests(unittest.TestCase):
    def test_case_id_completion_is_right_sided(self):
        self.assertEqual(canonical_case_id("05100111 "), "051001110")
        self.assertEqual(canonical_case_id("051000110"), "051000110")

    def test_corrected_value_variable_specific_rules(self):
        self.assertEqual(corrected_value("88", "", "88", "99", False), "0")
        self.assertEqual(corrected_value("99", "", "88", "99", False), "")
        self.assertEqual(corrected_value("8", "", "8", "9", True), "0")
        self.assertEqual(corrected_value("9", "7", "8", "9", True), "")
        self.assertEqual(corrected_value("02", "", "8", "9", True), "2")

    def test_rewrite_repairs_unprefixed_and_prefixed_columns(self):
        headers = ["case_id", *(rule[0] for rule in RAW_RULES.values())]
        rows_raw = []
        for case_id, core, extended in (
            ("000000001", "88", "8"),
            ("000000002", "99", "9"),
            ("000000003", "02", "2"),
        ):
            values = [case_id]
            for _, zero, unknown, authoritative in RAW_RULES.values():
                values.append(extended if authoritative else core)
            rows_raw.append(",".join(values))
        raw = io.StringIO(",".join(headers) + "\n" + "\n".join(rows_raw) + "\n")
        clean = io.StringIO(
            "case_id,parity,prior_perinatal_loss,prior_livebirths,v3_parity\n"
            "000000001,,,,\n"
            "000000002,,,,\n"
            "000000003,2,1,1,2\n"
        )
        output = io.StringIO()
        exact, normalized = load_raw_values(raw)
        summary = rewrite_csv(clean, output, exact, normalized)
        rows = list(csv.DictReader(io.StringIO(output.getvalue())))

        self.assertEqual(rows[0]["parity"], "0")
        self.assertEqual(rows[0]["prior_perinatal_loss"], "0")
        self.assertEqual(rows[0]["prior_livebirths"], "0")
        self.assertEqual(rows[0]["v3_parity"], "0")
        self.assertEqual(rows[1]["parity"], "")
        self.assertEqual(rows[2]["parity"], "2")
        self.assertEqual(summary["rows"], 3)
        self.assertEqual(summary["changed"]["parity"], 1)
        self.assertEqual(summary["changed"]["v3_parity"], 1)

    def test_legacy_left_padded_id_is_an_input_alias(self):
        headers = ["case_id", *(rule[0] for rule in RAW_RULES.values())]
        values = ["05100111 "]
        for _, _, _, authoritative in RAW_RULES.values():
            values.append("8" if authoritative else "88")
        raw = io.StringIO(",".join(headers) + "\n" + ",".join(values) + "\n")
        exact, aliases = load_raw_values(raw)
        self.assertIn("051001110", aliases)
        self.assertIn("005100111", aliases)

        clean = io.StringIO("case_id,parity\n005100111,\n")
        output = io.StringIO()
        summary = rewrite_csv(clean, output, exact, aliases)
        row = next(csv.DictReader(io.StringIO(output.getvalue())))
        self.assertEqual(row["parity"], "0")
        self.assertEqual(summary["normalized_fallback_matches"], 1)


if __name__ == "__main__":
    unittest.main()
