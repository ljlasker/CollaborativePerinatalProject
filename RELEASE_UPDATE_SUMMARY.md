# Public v2.0 release summary

## Primary data correction

The public v1.0 cleaning pipeline (internal build v3.2) treated raw code 88 as
missing in three prior-pregnancy count fields. The CPPVAR codebook defines 88
as "no prior
pregnancy," which implies a structural count of zero. Code 99 remains unknown.

| Variable | Missing cells restored to 0 | Corrected remaining missing |
|---|---:|---:|
| `parity` | 16,054 | 1,118 |
| `prior_perinatal_loss` | 16,163 | 2,587 |
| `prior_livebirths` | 16,157 | 2,015 |

The remaining missing counts equal source blanks plus raw code 99 exactly.

## Public v2.0 release assets

Public v2.0 (internal build 3.3.1) contains:

- `cpp_clean_expanded.csv` and `.rds` (59,391 x 315; matching expanded schema)
- `cpp_clean_core.csv` and `.rds` (59,391 x 185; matching core schema)
- `cpp_unified_wide.csv` and `.rds` (60,016 x 4,862; corrected and ID-deduplicated)
- `cpp_unified_supplementary.csv` and `.rds` (11,768 x 2,535,
  including `case_id`; 2,534 supplementary data fields)
- `cpp_unified_manifest.csv` (statistics refreshed for all six corrected fields)
- Per-asset repair summaries and `SHA256SUMS.txt`

## Verification completed

- The repair matched all 59,391 CPPVAR rows by `case_id`. The three core
  fields changed only where raw code 88 documents a structural zero. The eight
  expanded fields were authoritatively reconstructed from raw CPPVAR so that
  documented structural zeros, unknowns, and valid high counts are all handled
  by their variable-specific rules.
- The RDS repair was run natively in R. Each output was read back and compared
  column-by-column for values, storage type, factors, class, and key.
- Every core-schema copy contains exactly 16,054 + 16,163 + 16,157 = 48,374
  intended structural-zero corrections and no unmatched CPPVAR case IDs.
- The unified RDS contains those same corrections in both its `v2_` and `v3_`
  copies. After source-aware canonical-ID coalescence it contains all 59,391
  CPPVAR records plus 625 records unique to other sources.
- Python unit tests cover the 88/99/blank distinction and prefixed unified-file
  column names.

## Additional corrections found in the surge audit

- Eight expanded obstetric/sibling-history fields had the same structural-zero
  coding class with variable-specific 8/9 or 88/99 schemes. Both expanded
  formats are now rebuilt from raw CPPVAR for these fields.
- The public v1.0 unified files (internal build v3.2) had 2,397 three-row alias
  groups: the CPPVAR form with
  a blank ninth child digit, an erroneous left-padded form, and the right-
  completed identifier used in other raw sources. Nine additional CONGMALF
  aliases and fifteen SEI7YR aliases were independently crosswalked to existing
  child IDs. Coalescing all 2,421 groups removes 4,818 duplicate rows with zero
  conflicting nonmissing values and reduces the unified row count from 64,834
  to 60,016.
- The paper pipeline now fails fast, reconstructs the affected fields from raw,
  clusters mother-FE uncertainty by mother, and writes machine-readable output
  for the corrected death, GDM, head-circumference, Flynn, and pair-reuse checks.

## Additional public v1.0 inconsistencies resolved in v2.0

- In public v1.0 (Git tag/internal build v3.2), the file then named
  `cpp_clean_v1.csv` was byte-identical to
  `cpp_clean_v3.csv` (185 columns), while the later `cpp_clean_v1.rds` had 315
  columns. The current semantic names remove that ambiguity:
  `cpp_clean_expanded` is the matching 315-column CSV/RDS pair and
  `cpp_clean_core` is the matching 185-column pair.
- The public v1.0 expanded RDS left-padded 2,397 IDs with a blank ninth
  character, shifting the institution/mother fields. Public v2.0
  right-completes those linkage
  IDs with 0, as independently observed in TOXEMIA and W17 source files, and
  standardizes `mother_id` to seven characters. The original blank plurality
  remains missing and must not be interpreted as observed singleton status.
- The downloads page linked to the former `cpp_clean_v1_codebook.csv` name, but
  that asset was absent from the GitHub public v1.0 release (tag v3.2). The
  current asset is
  `cpp_clean_expanded_codebook.csv`.
- The public repository did not version the release-building scripts; the
  correction adds the relevant exporter, repair tools, tests, and errata.

## Publication and provenance

Public v2.0 is published separately rather than silently replacing the public
v1.0 assets under Git tag v3.2. The release includes the corrected Tier-1
assets, unified RDS/manifest, `ERRATA.md`, updated documentation, and
`SHA256SUMS.txt`. Internal build 3.3.1 remains recorded solely as technical
provenance. The release contains the rebuilt unified CSV/RDS, standardized core
and expanded schemas, canonical IDs, a dedicated expanded codebook, checksums,
and a dated changelog.
