# CPP Data Release Errata

## August 23, 2026: structural zeros and canonical unified IDs (fixed in v3.3.1)

The v3.2 analysis-ready release incorrectly converted source code `88` to
missing in three count variables. In the original CPPVAR documentation, `88`
means **no prior pregnancy**. Because these are counts of events before the
current pregnancy, the implied value is zero. Code `99` remains unknown and
source blanks remain missing.

| Analysis-ready variable | CPPVAR item/columns | Cells corrected from missing to 0 |
|---|---:|---:|
| `parity` | Item 4982, columns 46–47 | 16,054 |
| `prior_perinatal_loss` | Item 4983, columns 48–49 | 16,163 |
| `prior_livebirths` | Item 4984, columns 50–51 | 16,157 |

The untouched `cppvar_all_columns.csv` is not affected: it correctly preserves
the original `88` and `99` codes. Affected derived assets are the Tier-1 CSV/RDS
files and the `v2_`/`v3_` copies of these fields in the unified wide files.
Analyses that did not use these three variables are unaffected.

The expanded 315-column v1 build had the same coding error in related history
fields with variable-specific sentinels. The v3.3.1 expanded CSV and RDS now
decode these fields directly from CPPVAR:

| Expanded variable | Structural-zero code | Structural zeros restored | Cells changed in authoritative rebuild |
|---|---:|---:|---:|
| `prior_preterm_births` | 8 | 16,243 | 16,243 |
| `prior_fetal_deaths` | 8 | 16,153 | 16,984 |
| `prior_stillbirths` | 8 | 16,153 | 16,980 |
| `prior_neonatal_deaths` | 88 | 16,155 | 17,024 |
| `full_sib_total` | 88 | 15,481 | 15,481 |
| `full_sib_fetal_death` | 8 | 15,480 | 15,988 |
| `full_sib_neonatal_death` | 8 | 15,480 | 15,988 |
| `full_sib_death_post28d` | 8 | 15,480 | 15,988 |

The larger changed-cell counts reflect stale nonzero/unknown values as well as
restored structural zeros. These expanded fields are not present in the
185-column v3 core schema.

### Unified-file ID aliases

The initial v3.2 unified build contained 2,421 source-proven alias groups. The
largest component was 2,397 CPPVAR records whose ninth fixed-width character
was blank: the v1 R conversion incorrectly left-padded these IDs, while NCPP
child cards 00011/00012/00013 and other raw sources use the same eight-character
pregnancy prefix plus terminal 0. The wrong conversion shifted institution,
mother, and pregnancy fields (for example, `05100111 ` became `005100111`
instead of the source-linked `051001110`). CONGMALF contributed nine additional
left-padded aliases and SEI7YR contributed fifteen.

v3.3.1 maps only source-verified aliases to their right-completed identifiers,
coalesces 2,421 groups, preserves all populated source cells, and finds zero
conflicting nonmissing values. Because the 2,397 main groups occurred in
three forms (raw blank, left-padded artifact, and right-completed source ID),
4,818 duplicate rows are removed. The unified row count changes from 64,834 to
60,016: all 59,391 CPPVAR records plus 625 records unique to other sources.

The CPPVAR codebook labels a blank ninth character as ``no child'' in that
extract. The terminal 0 is therefore a canonical cross-source linkage key, not
by itself proof of observed singleton status. The original `plurality`, outcome,
and sex fields remain available; child-level analyses should require the
appropriate observed child/outcome fields. All 2,397 prefixes are independently
present in the NCPP child-card files, which is why right-completion is used for
linkage rather than left-padding.

Corrected release candidates have been generated for all Tier-1 CSV/RDS files
and for both unified-wide formats, with a fully refreshed manifest. The
v3.3.1 archive candidate bundles the corrected assets, repair utilities,
audits, checksums, this erratum, and the changelog.

Older v3.2 Tier-1 files differed in whether 2,397 source IDs with a blank ninth
character were preserved or incorrectly left-padded. The v3.3.1 CSV and RDS
assets use the same source-linked nine-digit representation, and `mother_id` is
standardized to seven characters. The repair utilities accept each older alias
and report fallback matches.

### Tier-1 filename and schema policy in v3.3.1

- `cpp_clean_core.csv` and `cpp_clean_core.rds` both have 59,391 rows and 185 columns.
- `cpp_clean_expanded.csv` and `cpp_clean_expanded.rds` are the matching expanded
  315-column build, with canonical nine-digit IDs.
- `cpp_clean_expanded_codebook.csv` is included for the expanded build.

Use `cpp_clean_core` for the stable 185-column schema and `cpp_clean_expanded`
when the additional 130 variables are required. The former names
`cpp_clean_v3` and `cpp_clean_v1` are retained as byte-identical compatibility
aliases; they are not release-version identifiers.

The corrected cleaning rule is:

```text
88 (no prior pregnancy) -> 0
99 (unknown)             -> missing
blank                    -> missing
00–20 / 00–08            -> numeric value as recorded
```

For already-downloaded CSV files, run:

```bash
python scripts/recode_structural_zero_counts.py \
  --clean cpp_clean_expanded.csv \
  --raw cppvar_all_columns.csv \
  --output cpp_clean_expanded_corrected.csv \
  --summary-json structural_zero_repair_summary.json
```

The repair joins on canonicalized `case_id`, applies each field's documented
8/9 or 88/99 rule, refuses to overwrite an existing file, and emits an
auditable count summary.
For RDS assets, `recode_structural_zero_counts_rds.R` performs the same
`case_id`-linked repair natively in R, then reads the result back and verifies
every column value, storage type, factor level, object class, and key.

`parity` is the count of prior pregnancies reaching at least 20 weeks; it is
not the same concept as ordinal birth order. For birth-order analyses,
`prior_livebirths + 1` is the direct live-birth-order construction when the
history is observed, while `prior_preg + 1` is pregnancy order rather than
live-birth order.
