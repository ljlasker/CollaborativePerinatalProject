# Changelog

## v2.0 — 2026-08-24

Public release v2.0 was produced from internal data build 3.3.1. Internal build
numbers are retained only for technical provenance; the preceding public
release was v1.0 (Git tag/internal build v3.2).

### Data corrections

- Corrected `parity`, `prior_perinatal_loss`, and `prior_livebirths`: raw 88
  means no prior pregnancy and is now zero; 99 remains unknown. Restored
  16,054, 16,163, and 16,157 structural zeros, respectively.
- Rebuilt eight related expanded obstetric and sibling-history count fields
  using their documented 8/9 or 88/99 schemes. See `ERRATA.md` for exact counts.
- Corrected left-padding of source IDs with a blank ninth character. Source-
  verified CPPVAR, CONGMALF, and SEI7YR aliases are now right-completed without
  shifting institution/mother fields; `mother_id` is standardized to seven
  characters in the analysis-ready pairs.
- Coalesced 2,421 unified ID-alias groups (4,818 duplicate rows). No conflicting
  nonmissing values were found. Unified files now contain 60,016 canonical IDs
  (59,391 CPPVAR records plus 625 source-only records), and 120 historical
  `v3_` fields are re-overlaid for every CPPVAR record after ID correction.
- Standardized the public Tier-1 names by purpose: `cpp_clean_core.csv` and
  `.rds` are the matching 185-column core build, while
  `cpp_clean_expanded.csv` and `.rds` are the matching 315-column expanded
  build. The older `cpp_clean_v3` and `cpp_clean_v1` names remain compatibility
  aliases only.

### Analysis and reproducibility

- Re-ran every paper analysis affected by live-birth order and the corrected
  death-history fields. Birth-order, breastfeeding, birthweight, maternal-age,
  smoking, resource-dilution, paternal-age, GDM, HC, and cohort/Flynn outputs
  were regenerated.
- Corrected mother-FE inference to cluster by mother in the HC and GDM analyses.
- Added a reproducible birth-cohort/Flynn script, connected-pedigree bootstrap
  inference, and one-pair-per-component pathway-model tests.
- Made the master analysis runner fail fast and write a per-script status log.
- Rebuilt the data paper from source for cross-viewer font compatibility,
  normalized embedded figure PDFs without changing their rendered content,
  synchronized the dated and canonical script bundles plus the direct-download
  metadata files, and removed machine-local paths from archive audit metadata.

### Interpretation

- The restored firstborn observations explain the larger sibling-analysis
  sample; no child rows were duplicated in the analysis-ready data.
- The WISC sibling-FE birth-order coefficient is +0.032 SD/rank (SE 0.008), but
  its causal sign is not identified after allowing for maternal age/calendar
  time. The birth-cohort sibling estimate with sex and live-birth rank is +0.074
  SD/decade (95% CI −0.136, +0.283), providing no clear NCPP Flynn effect.
- Connected-pedigree block bootstraps leave WISC correlations nearly unchanged.
  A one-pair-per-documented-pedigree refit strongly favors the IP over the CP
  for the full 12-measure battery, and 100 WISC refits plus 100 connected-family
  bootstraps confirm that the model ordering and loading pattern do not depend
  on dyad reuse.

The public v1.0 assets (Git tag/internal build v3.2) remain available for
provenance and are not silently replaced.
