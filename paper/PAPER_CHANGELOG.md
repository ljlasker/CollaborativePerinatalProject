# Analysis paper changelog

## August 2026 update — 2026-08-23

This update addresses two distinct data-engineering issues and strengthens
the manuscript's family-based inference.

### Structural-zero correction

- Restored documented "no prior pregnancy" codes to zero rather than missing for
  parity, prior perinatal loss, prior live births, prior preterm births, prior fetal
  deaths, prior stillbirths, prior neonatal deaths, and the corresponding full-sibling
  history counts.
- Re-ran every analysis that directly or indirectly uses those fields. The main
  consequence is a larger within-mother sample because previously excluded firstborn
  children are now retained. Later-born observations were unchanged.
- Updated all affected estimates, tables, and prose. The largest interpretive change is
  that the breastfeeding fixed-effect estimate moves from a small, imprecise positive
  coefficient to essentially zero; most other point estimates are similar with improved
  precision.

### Identifier correction in the public data release

- Corrected a separate case-ID normalization error for records whose ninth CPPVAR
  character was blank. The valid source-linked form appends `0`; integer left-padding
  shifted the site and family components and created aliases.
- Collapsed only source-proven aliases and preserved pregnancy records with an explicit
  no-child/linkage flag. The corrected unified release contains 60,016 unique canonical
  IDs.
- None of the 2,397 affected CPPVAR records appears in the paper's 53,640-record
  prepared analysis sample, so this correction changes the public release structure but
  not the manuscript estimates.

### Inference and sensitivity improvements

- Clustered child-level sibling regressions by mother and verified unique child IDs.
- Replaced pair-row resampling with connected-pedigree block resampling and added
  one-pair-per-documented-pedigree refits, because dyads can share mothers or belong to
  the same extended family.
- Verified the multi-level behavior-genetic result under pedigree dependence. The raw
  kinship-correlation ordering is stable, the 12-measure IP remains strongly preferred
  to the CP with one dyad per component, and 100 WISC refits plus 100 component
  bootstraps preserve the model ordering and loading pattern.
- Added sibling and first-cousin cohort-trend analyses. The within-mother WISC estimate
  is imprecise and near zero; cousin estimates vary with weighting and therefore do not
  establish a uniform null across every design.
- Separated the sibling-rank estimand from secular cohort change throughout the text.
  The equal-family cousin design now reports a maternal-age-adjusted 95% upper limit
  together with the identifying and one-sided selection assumptions required to read
  it as a bound.
- Added a maternal-age-adjusted birth-rank sensitivity estimate and an approximate 95%
  sensitivity interval. It is reported as a model-dependent range, not a design-based
  causal bound, because birth rank, maternal age, and calendar time are nearly collinear
  within mother.
- Re-estimated age-4 and age-7 low-birth-weight penalties on the identical longitudinal
  sample, including mother fixed effects and a formal change-score contrast. Reported
  the head-growth mediation models as exact coefficients rather than an unstable
  attenuation ratio.

### Reproducibility

- Forced case IDs to character type at raw-data ingestion and added fail-fast checks for
  malformed IDs, duplicate children, clustering identifiers, and expected sample sizes.
- Added a targeted correction suite covering 31 affected scripts and a final invariant
  validator. The suite and validator pass on the staged release inputs.
- Added a dated analysis-code archive with an internal SHA-256 manifest.

## Publication assets — 2026-08-24

- Refreshed `cpp_data_paper.pdf` so its release dimensions, canonical-ID description,
  pregnancy-history sentinel semantics, download examples, and codebook counts match the
  public data files.
- Added `cpp_analysis_scripts.zip` as the primary production-code bundle. It contains the
  declared analysis pipeline and an internal SHA-256 manifest; version-comparison and
  correction-audit materials remain outside the primary reproducibility package.
- Refreshed the analysis manuscript and primary code bundle with the pedigree-robust
  inference.
- Corrected Figure 4's cross-platform rendering so the age-30-to-34 series and its
  legend key are visible. The underlying observations, estimates, confidence
  intervals, manuscript text, and substantive conclusions are unchanged.
- Standardized analysis-ready filenames by contents rather than legacy schema labels:
  `cpp_clean_core` is the 185-column dataset and `cpp_clean_expanded` is the
  315-column dataset. Updated both papers, the production scripts, documentation,
  download links, and the complete release archive; legacy names remain byte-identical
  compatibility aliases.
