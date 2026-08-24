# Public v2.0 release validation

Internal data build: 3.3.1

Validation date: 2026-08-23

| Asset | Rows | Columns | Unique IDs | CPPVAR IDs matched | Source-semantic checks |
|---|---:|---:|---:|---:|---:|
| `cpp_clean_expanded.rds` | 59,391 | 315 | 59,391 | 59,391 | 11/11 passed |
| `cpp_clean_core.rds` | 59,391 | 185 | 59,391 | 59,391 | 3/3 passed |
| `cpp_unified_wide.rds` | 60,016 | 4,862 | 60,016 | 59,391 | 6/6 passed |
| `cpp_unified_supplementary.rds` | 11,768 | 2,535 | 11,768 | 11,538 | schema/uniqueness passed |

The semantic validator decodes the eleven corrected count fields directly from
raw CPPVAR using their variable-specific structural-zero and unknown sentinels.
It verifies every matched value in the expanded RDS, the three core values in
the core RDS, and both the `v2_` and `v3_` copies in the unified RDS.

The CSV and RDS unified alias audits each report 2,421 source-proven groups,
4,818 rows coalesced, 64,834 input rows, 60,016 output rows, and zero conflicting
nonmissing cells. The final unified CSV is a streamed export of the validated
RDS; a second structural-zero pass made no value changes and found exactly 625
non-CPPVAR IDs.

Four unit tests cover right-sided ID completion, acceptance of the legacy
left-padded alias as input only, variable-specific 8/9 and 88/99 rules, and
prefixed unified columns. All pass. The staged R repair/build scripts parse
under R 4.3.1. Archive CRCs and every checksum listed in `SHA256SUMS.txt` are
verified after the final archive is built.
