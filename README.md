# Collaborative Perinatal Project (CPP/NCPP) — Complete Data Release

*Last updated: March 2026*

## Overview

The Collaborative Perinatal Project (CPP), also known as the National Collaborative Perinatal Project (NCPP), was a prospective cohort study conducted from 1959 to 1974 across 12 U.S. medical centers. It enrolled approximately 60,000 pregnancies and followed children through age 7-8 with comprehensive medical, psychological, and socioeconomic assessments.

This release provides the complete CPP dataset in modern, usable formats — including the full variable file (CPPVAR), all 309 master card types (CPPMASTER), 31 standalone datasets parsed from the NARA/NBER JH collection (1,515,805 additional records), publication-quality codebooks, per-card field-level documentation, OCR'd transcriptions of the original documentation volumes, NLSYLinks-style kinship tables with twin zygosity classification, and pre-computed derived variables (g-factor scores, growth trajectories, birth weight z-scores, disability measures, survey weights).

## Getting Started

### Which file should I use?

- **For most analyses**: Start with `cpp_clean_v3.csv` (or `.rds` for R). Both have 59,391 rows and the same 185-column schema. In v3.3.1, `cpp_clean_v1.csv` and `.rds` are the matching 315-column expanded build with canonical nine-digit IDs. Use `cpp_clean_v1_codebook.csv` for that expanded schema.
- **For everything in one file**: Use `cpp_comprehensive.csv` (60,010 x 7,077). This merges ALL 309 parsed CPPMASTER card types into a single wide file. Column names use the `c[NNNNN]_` prefix to identify the source card. See `cpp_comprehensive_codebook.csv` for the full codebook. Sparse columns (<1% coverage) are in `cpp_comprehensive_supplementary.csv`.
- **For a unified wide file**: Use `cpp_unified_wide.csv` (or `.rds` for R). This is a single 60,016 x 4,862 file combining cleaned CPPVAR variables (202 columns with `v3_` prefix), CPPMASTER card variables (`c[NNNN]_` prefix), and 20 single-row standalone datasets (`sa_` prefix). It includes 59,391 CPPVAR pregnancy/child records plus 625 records found only in CPPMASTER or standalone sources. Sparse columns (<1% coverage) are in `cpp_unified_supplementary.csv`. See `cpp_unified_manifest.csv` for documentation of all 4,862 columns.
- **For repeated-measure data**: The 26 multi-row card types (prenatal visits, hospitalizations, lab results, etc.) are in `cpp_multirow_XXXX.csv` companion files.
- **For cognitive factor scores**: Use `cpp_g_factors.csv` for 9 g factor scores (PCA, PAF, CFA across 3 variable sets at age 7, plus IRT on reconstructed SB items at age 4). Recommended: `g_pca_9` for age-7 analyses, `g_irt_sb_adaptive` for age-4 analyses.
- **For developmental/behavioral scores**: Use `cpp_item_scores.csv` for PCA and IRT factor scores from 4 item batteries (8-month Bayley, 7-year examiner ratings [PSY25], 7-year neuro, neonatal neuro). The 3-year SLR battery was excluded due to low variance explained and poor criterion validity. IRT scores are provided only for batteries with adequate unidimensional fit (Bayley and PSY25 examiner ratings); the two neurological batteries have PCA scores only. Note: the PSY25 "personality" factor is primarily examiner-rated cognitive functioning (9/14 items are comprehension and reading ratings). Card 11200 "behavioral ratings" (P025 codebook) are excluded because those column positions overlap with Stanford-Binet cognitive data.
- **For disability/discordance analyses**: Use `cpp_disability_discordance.csv` for 10 disability criteria and composite flags. Recommended: use `disabled_strict` (IQ < 70 + 1 other criterion, 2.3%) for sensitivity analyses; `disabled_any` (33%) is too liberal for most purposes.
- **For full CPPVAR access**: Use `cppvar_all_columns.csv` (59,391 x 1,236) with `CPP_Codebook.csv` as your reference.
- **For raw assessment data**: Use the parsed cards in `master/parsed/card_XXXXX_parsed.csv` with their `_fields.csv` companions.
- **For sibling/twin analyses**: Use `cpp_kinship_links.csv` for pairwise links with relatedness coefficients. For twin-specific placental pathology (gross exam, maternal surface, microscopic), use `cpp_twin_pathology_linkage.csv` — this maps each twin child to their individual placental examination from cards 1201, 2201, and 1202, using the "designation of placenta" field to distinguish Twin A from Twin B. Merge on `child_case_id` = `case_id`.
- **For serology, drugs, visits, or other supplementary data**: Use the standalone datasets in `standalone/` with their `_fields.csv` companions.

### Example: Loading the data in R

```r
library(data.table)

# Load the analysis-ready dataset
d <- readRDS("cpp_clean_v1.rds")
# or: d <- fread("cpp_clean_v1.csv", colClasses = c(case_id = "character"))

# Quick summary
cat("Records:", nrow(d), "\n")
cat("Variables:", ncol(d), "\n")
table(d$race)
summary(d$wisc_fsiq)

# Load kinship links for sibling/twin analysis
links <- fread("cpp_kinship_links.csv", colClasses = c(id_1 = "character", id_2 = "character"))
table(links$pair_type)

# Merge CPPMASTER card data
card_ped3 <- fread("master/parsed/card_14031_parsed.csv", colClasses = c(case_id = "character"))
merged <- merge(d, card_ped3, by = "case_id", all.x = TRUE)
```

### Example: Applying survey weights

```r
library(data.table)

# Load data and weights
d <- fread("cpp_clean_v1.csv", colClasses = c(case_id = "character"))
wt <- fread("cpp_weights.csv", colClasses = c(case_id = "character"))
d <- merge(d, wt, by = "case_id")

# Weighted mean IQ (corrects for attrition + population non-representativeness)
weighted.mean(d$wisc_fsiq, d$wt_recommended, na.rm = TRUE)
```

### Common Pitfalls

1. **Nursery feeding ≠ long-term breastfeeding**: `bf_days` and `bf_ever` capture only in-hospital nursery feeding (first few days of life). In the 1960s US, nursery breastfeeding was more common among lower-SES women — the opposite of today's pattern.
2. **Sex = 3 means fetal loss**: 804 records with `sex=3` are early fetal losses (mean birth weight 1,891g, gestational age 16.3 weeks), not live births with ambiguous sex. Exclude these from live-birth analyses.
3. **Leading zeros in IDs**: `case_id` is 9 digits, `mother_id` is 7 digits. When reading CSV files, ensure these are read as character/string to preserve leading zeros (e.g., `fread("cpp_clean_v1.csv", colClasses = c(case_id = "character"))`).
4. **Two codebook files**: `CPP_Codebook.csv` (1,239 entries) is the curated, publication-quality codebook — use this one. `cppvar_codebook.csv` (1,140 entries) is the raw auto-parsed version, retained for reproducibility.
5. **Prior-pregnancy structural zeros**: In the corrected exporter, raw code 88 ("no prior pregnancy") becomes 0—not `NA`—for `parity`, `prior_perinatal_loss`, and `prior_livebirths`; 99 remains unknown. See `ERRATA.md` when using v3.2 assets.

## Source Data & Provenance

### Where the data came from

The original CPP data files (`CPPVAR.ASC` and `CPPMASTER.ASC`) and documentation were obtained from the National Bureau of Economic Research (NBER) archives. The documentation consists of scanned microfiche of the original codebook volumes (7 main volumes + 10 sub-volumes of form reproductions), produced in the 1970s by the National Institute of Neurological Diseases and Stroke (NINDS). Additional standalone datasets were obtained from the NBER CPP JH collection, which contains 35 NARA ASCII files, 61 NICHD form files, and 35 SAS programs covering serology, drug exposures, clinical visits, socioeconomic indices, and special study work files.

### Why this data was hard to use

Despite being one of the largest and most detailed developmental cohort studies ever conducted, the CPP has been severely underutilized because:

1. **No modern codebook**: The only documentation was scanned microfiche of 1970s-era codebooks — over 5,000 pages of typewritten text, tables, and forms on microfilm.
2. **Archaic data format**: CPPVAR is a 1,600-column fixed-width ASCII file with no variable names, no delimiters, and no metadata. Researchers needed the physical codebook to extract any variable.
3. **Punch card format**: CPPMASTER stores 6.1 million records as raw 80-column punch card images. Each record type is identified only by a code embedded at a specific position within the 80 characters. Understanding the data requires the Vol V master index.
4. **Scattered documentation**: Variable definitions are in Vol III-A, derivation methods in Vol III-B, form reproductions in 10 sub-volumes of Vol II, the master index in Vol V, and cross-references in Vol VII. No single document provides a complete picture.
5. **Known errors**: The original codebook contains 6 errors (label swaps, column offsets, check digit mismatches, field boundary ambiguities) plus 4 mislabeled cognitive variables, discoverable only through empirical validation. See `MISLABELED_VARIABLES.md` for the cognitive variable corrections.

### What this release adds

1. **AI-assisted OCR**: All 5,000+ pages of documentation OCR'd using Tesseract 5.4.0, producing machine-readable text for every volume.
2. **Structured codebooks**: Vol III-A parsed into a 1,239-entry codebook (`CPP_Codebook.csv`) with clean variable names, types, value labels, missing codes, and topical sections. Vol V parsed into a 5,701-field master index (`CPPMASTER_Codebook.csv`) covering 257 of 309 card types.
3. **Complete extraction**: All 1,236 documented CPPVAR columns extracted into a standard CSV. All 309 CPPMASTER card types extracted as individual CSVs.
4. **Named-column parsing**: 305 card types (5.8M+ records) parsed from raw 80-character strings into proper CSVs with named columns, using field positions from the codebooks.
5. **Cross-referencing**: Vol III-B derivation methods parsed to create CPPVAR-to-CPPMASTER cross-reference (906 mappings), linking summary variables to their source assessment forms.
6. **Error discovery and correction**: 6 documentation errors identified and corrected through empirical validation (feeding label swap, birth weight column offset, column 365 mislabeling, sex=3 interpretation, CPPMASTER check digit mismatch, WRAT reading field boundary), plus 4 mislabeled cognitive variables corrected in the analysis-ready file (see `MISLABELED_VARIABLES.md`).
7. **Family structure**: Twin zygosity classification using a five-tier evidence schema anchored by Myrianthopoulos' (1975) authoritative blood group determinations recovered from the congenital malformations work file (CONGMALF.ASC) — resolving 79% of twin pairs with the gold-standard serological method, supplemented by Bayesian developmental trajectory analysis and cross-validated against an 800+ feature machine-learning classifier (AUC=0.76, confirming the phenotypic classification ceiling). Sibling classification using a multi-indicator scoring system with 11 evidence types, anchored by the CONGMALF father number variable. NLSYLinks-style kinship table with 14,208 pairwise links and relatedness coefficients, validated against observed IQ correlations.
8. **Standalone datasets**: 31 supplementary datasets (1,515,805 records) parsed from the NARA/NBER JH collection — serology cards, drug files, clinical visit records, socioeconomic indices, congenital malformations, and research work files not available in CPPVAR or CPPMASTER. Twenty single-row datasets are merged into the unified wide file; 11 multi-row datasets (drug records, serum specimens, visit logs) remain separate.
9. **SAS program enrichment**: 24 JHU SAS programs parsed to extract 5,851 variable definitions with column positions and labels, plus 170 categorical value format definitions. All 309 card CSVs re-parsed with enriched codebooks, expanding from ~7,600 to 13,154 named columns.
10. **Survey weights**: IPW attrition weights, Census population weights, and combined weights enabling nationally representative estimation from the CPP's convenience sample.

## File Inventory

### Tier 1: Analysis-Ready Dataset

| File | Description | Rows | Columns |
|------|-------------|------|---------|
| `cpp_clean_v3.csv` | Recommended analysis-ready CSV | 59,391 | 185 |
| `cpp_clean_v3.rds` | Matching R binary with factor labels | 59,391 | 185 |
| `cpp_clean_v1.csv` | Expanded analysis-ready CSV | 59,391 | 315 |
| `cpp_clean_v1.rds` | Matching expanded R build | 59,391 | 315 |

### Tier 2: Complete CPPVAR Extraction

| File | Description |
|------|-------------|
| `cppvar_all_columns.csv` | Every documented column (59,391 x 1,236) |
| `CPP_Codebook.csv` | Publication-quality codebook (1,239 entries, 100% column coverage) |
| `cppvar_codebook.csv` | Raw auto-parsed codebook (1,140 entries, retained for reproducibility) |

### Unified Dataset (`cpp_unified_wide`)

A single wide file merging cleaned CPPVAR data with all CPPMASTER card variables and 20 single-row standalone datasets, designed as a one-stop dataset for analyses that need all sources.

| File | Description | Rows | Columns |
|------|-------------|------|---------|
| `cpp_unified_wide.rds` | R binary format | 60,016 | 4,862 |
| `cpp_unified_wide.csv` | CSV format | 60,016 | 4,862 |
| `cpp_unified_manifest.csv` | Column-level documentation for all 4,862 variables | 4,862 | — |
| `cpp_unified_supplementary.rds` | Sparse columns (<1% coverage) | 11,768 | 2,535 incl. ID |
| `cpp_unified_supplementary.csv` | Same, CSV format | 11,768 | 2,535 incl. ID |
| `cpp_unified_supplementary_codebook.csv` | Codebook for supplementary variables | 2,534 | — |
| `cpp_columns_dropped.csv` | Log of 3,150 all-NA/duplicate columns removed | 3,150 | — |

**Row composition**: 60,016 canonical rows = 59,391 CPPVAR pregnancy/child records + 625 records found only in CPPMASTER or standalone files. For 2,397 CPPVAR pregnancy-level rows the source child digit is blank (codebook: no child), while NCPP child cards and other raw files use the same eight-character pregnancy prefix plus terminal 0. A legacy R conversion also created a left-padded alias that shifted the ID fields. v3.3.1 coalesces those three source aliases plus 24 independently crosswalked CONGMALF/SEI7YR aliases (2,421 groups; 4,818 duplicate rows removed; zero conflicting nonmissing values). The original `plurality`/outcome fields remain missing for the CPPVAR no-child records, so terminal 0 in the canonical linkage key is not by itself evidence of a live singleton; child analyses should apply the documented outcome/sex/plurality filters.

**Column naming conventions**:
- `v3_` prefix: 202 cleaned CPPVAR variables (demographics, SES, cognitive scores, birth outcomes, etc.)
- `c[NNNN]_` prefix: CPPMASTER card variables, grouped by 4-digit base form (e.g., `c2130_wisc_full_scale_iq`)
- `sa_[name]_` prefix: Standalone dataset variables (e.g., `sa_congmalf_col_23`)
- The manifest file (`cpp_unified_manifest.csv`) documents all 4,862 columns with source, missingness, and summary statistics

**Supplementary side-sheet**: Columns with <1% coverage (high-sequence pregnancy cards, 3rd/4th pregnancy forms, rare clinical variables) were moved to `cpp_unified_supplementary.csv` rather than dropped. They can be merged back by `case_id`.

### Tier 3: Complete CPPMASTER Extraction

| File | Description |
|------|-------------|
| `master/card_XXXXX.csv` | Raw card CSVs (309 files, case_id + card_data) |
| `master/card_index.csv` | Card index with record counts and metadata |
| `master_all_cards_index.csv` | Detailed card metadata (subject, form, revision) |
| `CPPMASTER_Codebook.csv` | Field-level codebook for 309 card types (6,280+ fields) |
| `master/card_codebooks/` | Per-card codebook CSVs (312 files, from Vol V + Vol III-B + SAS programs) |
| `master/parsed/` | Parsed cards with named columns (309 types, 13,154 columns, 6.1M records) |
| `master/unmapped_cards_report.csv` | Report on card codebook sources and coverage |
| `vol3b_crossref.csv` | CPPVAR-to-CPPMASTER cross-reference (906 derivation mappings) |
| `vol3b_card_mapping.csv` | Vol 3b card number to extracted 5-digit code mapping |
| `cpp_comprehensive.csv` | All 309 cards merged wide (60,010 x 7,077) |
| `cpp_comprehensive_codebook.csv` | Codebook for the comprehensive file |
| `cpp_comprehensive_supplementary.csv` | Sparse columns (<1% coverage) |

### Tier 4: Family Structure & Kinship

| File | Description | Rows | Columns |
|------|-------------|------|---------|
| `cpp_twin_zygosity.csv` | Twin pair zygosity classification | 640 pairs | — |
| `cpp_twin_pathology_linkage.csv` | Twin-specific placental pathology linkage (cards 1201, 2201, 1202) | 1,106 children | 133 |
| `cpp_kinship_links.csv` | Standard within-family pairwise links (MZ, DZ, FS, HS, ambiguous) with relatedness coefficients, confidence, and evidence | 14,208 pairs | 7 |
| `cpp_extended_kinship_links.csv` | Cross-family extended kin pairs (first cousins, second cousins, nieces/nephews, etc.) derived from W17 work files | 13,513 pairs | 5 |
| `cpp_kinship_links_extended.csv` | Combined file with all within-family and cross-family pairs | 27,721 pairs | 5 |

### Tier 5: Supplementary Analysis Files

| File | Description | Rows |
|------|-------------|------|
| `cpp_growth_trajectories.csv` | Longitudinal weight/height/head circumference, long format (birth–7yr) | 755,739 |
| `cpp_birthweight_zscores.csv` | Sex- and gestational-age-adjusted birth weight z-scores | 54,223 |
| `cpp_birthweight_reference.csv` | Internal reference curves (loess-smoothed means/SDs by sex × gest. age) | 46 |
| `cpp_attrition_analysis.csv` | Follow-up rates by demographics, site, SES | — |
| `cpp_ses_detailed.csv` | Detailed SES with father characteristics and multi-source SES data | 59,391 |
| `cpp_cognitive_scores.csv` | Raw scores, z-scores, and latent g factor for 11 cognitive measures | 59,391 |
| `cpp_cognitive_loadings.csv` | PCA factor loadings for g extraction (4 WISC subtests, 58.6% variance) | 4 |
| `cpp_hc_zscores.csv` | Age- and sex-specific head circumference z-scores at 6 ages | 186,149 |
| `cpp_hc_reference.csv` | HC reference curves (mean, SD, median, MAD by sex × age) | 12 |
| `cpp_growth_velocity.csv` | Weight, height, and HC gains between key ages (wide format) | 55,443 |
| `cpp_discordant_pairs.csv` | Full-sib/twin pairs flagged for discordance on smoking, BF, BW | 11,539 |
| `cpp_g_factors.csv` | 9 g factor scores (PCA, PAF, CFA × variable sets + IRT-SB adaptive; PAF-7/CFA-7 excluded) | 53,640 |
| `cpp_g_loadings.csv` | Factor loadings for each g extraction method, with exclusion flags | 77 |
| `cpp_sb_items.csv` | Parsed Stanford-Binet item-level data (raw pass/fail, ages 2-4) | 39,090 |
| `cpp_sb_items_reconstructed.csv` | SB items with adaptive basal/ceiling reconstruction for IRT | 37,820 |
| `cpp_item_scores.csv` | PCA + IRT factor scores from developmental/behavioral item batteries | 53,640 |
| `cpp_item_scores_codebook.csv` | Codebook for item battery scores (source card, N items, variance explained) | 6 |
| `cpp_disability_discordance.csv` | Disability flags (10 criteria) + composite flags | 53,640 |
| `cpp_weights.csv` | Survey weights: IPW attrition, population, combined, recommended | 59,391 |
| `cpp_weights_codebook.csv` | Codebook for the 17 weight columns | 17 |

### Tier 6: OCR'd Documentation

All original documentation volumes have been OCR'd using Tesseract 5.4.0.

| File | Source | Description | Pages |
|------|--------|-------------|-------|
| `ocr/vol1_ocr.txt` | Vol 1 | Study overview and user's guide | 136 |
| `ocr/vol2a_ocr.txt` - `vol2j_ocr.txt` | Vol 2a-2j | Form reproductions (10 sub-volumes) | 2,507 |
| `ocr/vol3a_variable_dictionary.csv` | Vol 3a | CPPVAR codebook (structured CSV) | 207 |
| `ocr/vol3b_ocr.txt` | Vol 3b | CPPVAR field derivation methods | 681 |
| `ocr/vol4_ocr.txt` | Vol 4 | Selected work files | 336 |
| `ocr/vol5_master_index.csv` | Vol 5 | CPPMASTER index (structured CSV) | 290 |
| `ocr/vol6_ocr.txt` | Vol 6 | Alphabetical permuted glossary | 312 |
| `ocr/vol7_ocr.txt` | Vol 7 | Data items by person/time/subject | 685 |

### Tier 7: Standalone Datasets (NARA/NBER JH Collection)

31 standalone datasets (1,515,805 total records) parsed from the NARA/NBER JH collection at NBER. These files were distributed separately from CPPVAR and CPPMASTER as individual ASCII files with accompanying SAS programs, and contain data not available in the main data files. Twenty single-row datasets are merged into the Tier 4 unified file; 11 multi-row files remain separate.

**Source**: 35 NARA ASCII files, 61 NICHD form files, and 35 SAS programs downloaded from the NBER CPP JH collection. Each dataset has a companion `_fields.csv` documenting column positions and labels.

**Field naming**: For files with SAS programs (serology cards, SEI7YR), fields have proper variable names derived from the SAS INPUT statements. For files without SAS programs, fields have positional column names (`col_10`, `col_11`, etc.) and researchers should consult the original SAS programs in `nber_files/sas_programs/` for additional context.

#### Serology Cards (6 files, 332,057 records)

Viral antibody titer and specimen tracking data. Note: the raw 9-system blood group typing results used by Myrianthopoulos (1975) for zygosity determination are not in these files — these serology cards contain viral antibody titers. However, Myrianthopoulos' final MZ/DZ zygosity classifications ARE preserved in column 178 of `standalone/congmalf_structured.csv` (parsed from CONGMALF.ASC).

| File | Description | Records |
|------|-------------|---------|
| `standalone/card0806_serum_specimens.csv` | CARD0806 serum specimen log | varies |
| `standalone/card1801_serum_first_last.csv` | CARD1801 first/last specimens per subject | varies |
| `standalone/card8131_serology.csv` | CARD8131 study-specific serology | varies |
| `standalone/card8132_serology.csv` | CARD8132 study-specific serology | varies |
| `standalone/card8133_serology.csv` | CARD8133 study-specific serology | varies |
| `standalone/crd08932_serology.csv` | CRD08932 form 0893 serology | varies |

#### Clinical & Pregnancy Files (7 files, 527,202 records)

| File | Description | Records |
|------|-------------|---------|
| `standalone/toxemia.csv` | Toxemia/preeclampsia flags, one per pregnancy | 58,786 |
| `standalone/congmalf.csv` | Congenital malformations (positional), one per pregnancy | 58,786 |
| `standalone/congmalf_structured.csv` | **Structured CONGMALF** with named fields: 21 one-year malformation recodes (4-digit), 40 seven-year recodes (5-digit), **Myrianthopoulos zygosity** (col 178: 1=MZ, 2=DZ), **father number** (col 179: 1-5) | 59,391 |
| `standalone/ruptmemb.csv` | Rupture of membranes data | 49,364 |
| `standalone/drdeu145_drug_generic.csv` | Drug file (generic names), multiple records per pregnancy | 199,401 |
| `standalone/drdeu154_drug_brand.csv` | Drug file (brand names), multiple records per pregnancy | 253,434 |
| `standalone/visitfle.csv` | Prenatal/postnatal clinical visits, multiple records per pregnancy | 266,731 |
| `standalone/f90401.csv` | Form 90401 data | 53,133 |

#### Assessment & Index Files (5 files, 198,182 records)

| File | Description | Records |
|------|-------------|---------|
| `standalone/sei7yr.csv` | 7-year socioeconomic index (SAS-defined field names) | 40,081 |
| `standalone/socio7yr.csv` | 7-year sociometric data | 40,363 |
| `standalone/abnor7yr.csv` | 7-year abnormality summary | 41,677 |
| `standalone/slhfile.csv` | Speech/Language/Hearing summary scores | 20,104 |
| `standalone/seiregis.csv` | Registration socioeconomic index | 55,957 |

#### W17 Work Files (13 files, 45,931 records)

Research extracts from special studies. These are working datasets created for specific analyses and may overlap with data in the main files.

| File | Description | Records |
|------|-------------|---------|
| `standalone/w17a_mother.csv` | W17 mother-level extract | varies |
| `standalone/w17b_child.csv` | W17 child-level extract | varies |
| `standalone/w17c_study6a.csv` - `w17m_study6k.csv` | W17 Study 6 sub-files (a through k) | varies |

### Tier 8: Integrated Domain Files

Pre-merged domain-specific datasets combining CPPMASTER cards and standalone files into thematic groupings, stored in `integrated/`. Each file is available in both `.rds` (R) and `.csv` formats.

| File | Description |
|------|-------------|
| `integrated/nichd_psychology.rds` | Psychology domain (cognitive, behavioral assessments) |
| `integrated/nichd_pediatric.rds` | Pediatric domain (neonatal, developmental exams) |
| `integrated/nichd_mother_path.rds` | Mother/pathology domain (obstetric, delivery, pathology) |
| `integrated/nichd_serology_dta.rds` | Serology domain (antibody titers, specimen data) |
| `integrated/nichd_summary7.rds` | 7-year summary domain |
| `integrated/nichd_adm44.rds` | ADM-44 administrative data |
| `integrated/standalone_drugs.rds` | Drug exposure records (generic and brand) |
| `integrated/standalone_health.rds` | Health/clinical standalone files |
| `integrated/standalone_other.rds` | Other standalone files (W17 work files, etc.) |
| `integrated/standalone_ses.rds` | Socioeconomic standalone files (SEI, sociometric) |
| `integrated/standalone_serology.rds` | Serology standalone files |
| `integrated/master_codebook.csv` | Master codebook for all integrated domain files |

### Processing Scripts

All scripts use portable paths and can be run from the `cpp_data` directory.

| File | Description |
|------|-------------|
| `ocr_all_volumes.py` | Tesseract OCR pipeline for all PDF volumes |
| `parse_vol3a_to_dictionary.py` | Parses Vol 3a OCR into structured CSV |
| `consolidate_vol5.py` | Consolidates Vol 5 OCR batches into master index |
| `create_codebook.py` | Creates publication-quality CPP_Codebook.csv |
| `extract_all_master_cards.R` | Extracts all 309 card types from CPPMASTER.ASC |
| `parse_vol3b.py` | Cross-references Vol 3b to build additional card codebooks |
| `build_master_codebook.py` | Consolidates field-level codebook from Vol V + Vol 3b |
| `parse_master_cards.py` | Parses raw card data into named columns |
| `recover_sequence_cards.py` | Recovers codebooks for sequence variant cards |
| `fix_ocr_artifacts.py` | Cleans OCR artifacts in crossref and codebook files |
| `export_clean_data_v2.R` | Builds the analysis-ready dataset |
| `build_zygosity.R` | Classifies twin pair zygosity |
| `build_family_links.R` | Builds NLSYLinks-style kinship table |
| `build_value_adds.R` | Growth trajectories, BW z-scores, attrition, SES, ABO diagnostic |
| `build_multiple_g.R` | Compute g factor scores via PCA, PAF, CFA across 3 variable sets |
| `build_sb_irt_adaptive.R` | Reconstruct SB item responses using basal/ceiling, fit IRT |
| `build_item_batteries.R` | Extract PCA and IRT factor scores from 4 item batteries |
| `build_disability_discordance.R` | Build disability criteria and discordant sibling pairs |
| `build_g_cormat.R` | Generate g factor inter-correlation matrix (LaTeX table) |
| `clean_g_factors.R` | Remove pathological PAF-7/CFA-7 scores from g_factors file |

### Quality & SAS Documentation

| File | Description |
|------|-------------|
| `SAS_Variable_Catalog.csv` | 5,851 unique variable definitions from 24 JHU SAS programs |
| `SAS_Value_Labels.csv` | 1,088 value codes across 170 categorical formats |
| `SAS_Value_Labels_Reference.txt` | Human-readable value label reference |
| `SAS_Format_Field_Linkage.csv` | 120 validated format-to-field links |
| `CPP_Variable_Inventory.csv` | Complete variable accounting across all sources |
| `cppvar_sentinel_guide.csv` | Sentinel value guide for 56 affected CPPVAR variables |
| `CPPMASTER_Quality_Notes.csv` | Quality notes for card parsing issues |
| `OCR_Quality_Notes.csv` | OCR quality assessment per volume |

### Archive

| Directory | Description |
|-----------|-------------|
| `archive/` | Legacy v1 files and intermediate outputs, retained for reference |

## CPP_Codebook.csv Structure

The publication-quality codebook covers all 1,600 columns of CPPVAR with 1,239 entries:

| Column | Description |
|--------|-------------|
| `item_id` | Original CPP item number |
| `col_from`, `col_to` | Column positions in CPPVAR.ASC |
| `varname` | Clean variable name |
| `label` | Human-readable label |
| `description` | Full description from codebook |
| `type` | numeric, categorical, binary, ordinal, string, blank, id |
| `codes` | Value labels |
| `missing_codes` | Missing value codes |
| `section` | Topical grouping |

Sections: Congenital Conditions (339), Delivery Procedures (154), Pregnancy Conditions (151), Neonatal Neurological (95), Family History (88), Cognitive Assessment (62), Birth Outcomes (40), Obstetric Measures (35), Demographics (23), and others.

## Key Variables (cpp_clean_v1.csv)

### Identifiers
| Variable | Description |
|----------|-------------|
| case_id | 9-digit unique child identifier |
| mother_id | 7-digit mother identifier (for sibling/twin analyses) |
| institution | 2-digit study site code |
| plurality | Plurality code (0=single, 1-4=multiples) |
| birth_switch | Birth type (1=single, 2=twin, 3=triplet, 4=quad) |

### Demographics
| Variable | Description | Coding |
|----------|-------------|--------|
| sex | Sex of child | 1=Male, 2=Female |
| race | Race | 1=White, 2=Black, 3=Oriental, 4=Puerto Rican |
| maternal_age | Maternal age at registration (years) | Continuous |
| marital | Marital status | 1=Single ... 6=Separated |
| religion | Religion | 1=Protestant, 2=Catholic, 3=Other |

### Socioeconomic Status
| Variable | Description | Coding |
|----------|-------------|--------|
| educ_yrs | Education of gravida (years) | 0-18 |
| income | Family income (coded thousands) | 2-digit |
| sei_decimal | Socioeconomic Index | 0.0-9.5 |
| housing_density | Persons/room x 10 | 2-digit |

### Pregnancy & Birth
| Variable | Description | Coding |
|----------|-------------|--------|
| prior_preg | Total prior pregnancies | 0-28 |
| parity | Prior non-abortions >= 20 weeks | 0-20 |
| prior_perinatal_loss | Prior perinatal deaths | 0-7 |
| prior_livebirths | Prior live births | 0-8 (8 = 8+) |
| smoker | Smoking status | 0=No, 1=Yes |
| cigs_per_day | Cigarettes per day | 0-61 |
| birth_wt_g | Birth weight (grams) | 200-7000 |
| gest_age | Gestational age (weeks) | 20-50 |
| apgar_total | 1-minute Apgar score | 0-10 |

### Nursery Feeding
| Variable | Description | Coding |
|----------|-------------|--------|
| bf_days | Breast-feeding days in nursery | 0-8 |
| bot_days | Bottle-feeding days in nursery | 0-8 |
| bf_ever | Ever breastfed in nursery | 0/1 |
| feed_type | Feeding classification | Breast-only, Bottle-only, Both, None/other |

**Important**: These capture only nursery feeding during the first few days of life, not long-term breastfeeding. In the 1960s US, nursery breastfeeding was more common among lower-SES women.

### Cognitive Assessments
| Variable | Description | Mean | SD | N |
|----------|-------------|------|----|---|
| sb_iq | Stanford-Binet IQ (age 4) | 97.1 | 16.6 | 38,653 |
| wisc_fsiq | WISC Full Scale IQ (age 7) | 95.6 | 14.8 | 40,494 |
| wisc_viq | WISC Verbal IQ | 91.9 | 13.6 | 31,428 |
| wisc_piq | WISC Performance IQ | 96.4 | 15.0 | 31,426 |
| wisc_info | WISC Information (scaled) | 9.2 | 3.0 | 40,269 |
| wisc_comp | WISC Comprehension (scaled) | 8.7 | 2.8 | 40,248 |
| wisc_vocab | WISC Vocabulary (scaled) | 8.7 | 3.1 | 40,218 |
| wisc_digit | WISC Digit Span (scaled) | 9.6 | 3.0 | 40,231 |
| auditory_vocal | Auditory-Vocal Association | 29.3 | 6.6 | 40,259 |
| wrat_read | WRAT Reading | 45.4 | 11.3 | 40,248 |
| bender_raw | Bender Gestalt | 11.9 | 8.0 | 40,305 |

## Study Sites

| Code | Institution | City | N |
|------|-------------|------|---|
| 05 | Boston Lying-In Hospital | Boston, MA | 13,737 |
| 10 | Children's Hospital of Buffalo | Buffalo, NY | 2,985 |
| 15 | Charity Hospital of Louisiana | New Orleans, LA | 2,634 |
| 31 | Columbia University / Sloane Hospital | New York, NY | 2,262 |
| 37 | Johns Hopkins Hospital | Baltimore, MD | 4,438 |
| 45 | Medical College of Virginia | Richmond, VA | 3,477 |
| 50 | University of Minnesota | Minneapolis, MN | 3,321 |
| 55 | New York Medical College / Metropolitan Hospital | New York, NY | 4,753 |
| 60 | University of Oregon | Portland, OR | 3,473 |
| 66 | University of Pennsylvania / Pennsylvania Hospital | Philadelphia, PA | 10,458 |
| 71 | Providence Lying-In Hospital | Providence, RI | 4,184 |
| 82 | University of Tennessee | Memphis, TN | 3,669 |

## Family Structure & Kinship

### Overview

The CPP includes extensive family structure suitable for behavior-genetic and sibling analyses:

- **8,772 mothers** with 2+ children = **19,966 children** in sibling families
- **640 twin pairs** (1,254 twin/multiple-birth children)
- 18 triplet children, 4 quadruplet children
- **14,208 pairwise kinship links** with classified relatedness

### Twin Zygosity (`cpp_twin_zygosity.csv`)

Twin pairs are classified using a principled, multi-evidence schema with five tiers of evidence applied in sequence:

**Tier 0 (authoritative — Myrianthopoulos blood group determinations):**
Myrianthopoulos (1975) determined zygosity for CPP twin pairs using a 9-system blood group panel (ABO, Rh, MNSs, Kell, Duffy, Kidd, P, Lewis, Lutheran) tested on cord blood, combined with placental examination. We discovered that these individual-level determinations — previously thought unavailable in the public-use data — were embedded in column 178 of the congenital malformations work file (`CONGMALF.ASC`), documented in Volume IV. This tier resolves **504 of 640 twin pairs (79%)** with the gold-standard serological method: 189 definite MZ and 315 definite DZ.

**Tier 1 (definitive markers):**
1. **Sex discordance**: Opposite-sex pairs not already classified are definite DZ (n=5)
2. **Monochorionic membrane**: From pathology card 12022 (column 30) — very probable MZ (n=9)
3. **Blood type discordance**: ABO (col 1129) and Rh (col 1130) — DZ among same-sex twins (n=21)

**Tier 2 (strong probabilistic):**
4. **Dichorionic membrane**: From card 12022 — probable DZ (n=38)

**Tier 3 (Bayesian classification with Wilson developmental trajectories):**
The remaining 63 same-sex pairs entered a Bayesian model trained on the Myrianthopoulos-classified pairs (197 known MZ and 341 known DZ). The model integrates four features: (1) Wilson developmental trajectory slope — composite slope of standardized intrapair physical differences regressed on age (Cohen's d=0.56); (2) late concordance — mean intrapair difference at ages 4–7 (d=1.00); (3) IQ difference (d=0.43); (4) WISC subtest profile concordance (d=0.32). This tier classified 10 pairs as MZ_probable (P(MZ) > 0.80) and 4 as DZ_probable (P(MZ) < 0.20).

**Remaining:** 38 same-sex pairs with intermediate posteriors + 11 with insufficient data are classified as ambiguous, with R assigned from individual posterior probabilities where available.

| Classification | N pairs | R coefficient | Basis |
|---------------|---------|--------------|-------|
| MZ_definite | 189 | 1.00 | Myrianthopoulos blood groups |
| MZ_very_probable | 9 | 1.00 | Monochorionic membrane |
| MZ_probable | 10 | 1.00 | Bayesian (P(MZ) > 0.80) |
| DZ_definite | 341 | 0.50 | 315 Myrianthopoulos + 5 sex + 21 blood |
| DZ_probable | 42 | 0.50 | 38 dichorionic + 4 Bayesian |
| ambiguous_SS | 38 | varies | Bayesian posterior 0.20–0.80 |
| unknown | 11 | 0.75 | Insufficient data |

**IQ validation**: MZ pairs r=0.81 (n=132), DZ pairs r=0.61 (n=226), full siblings r=0.56 (n=7,330), half-siblings r=0.35 (n=926).

### Kinship Table (`cpp_kinship_links.csv`)

Following the NLSYLinks methodology, all within-family pairs are classified with a coefficient of relatedness (R):

| Pair type | N pairs | R | Classification basis |
|-----------|---------|---|---------------------|
| MZ_twin | 208 | 1.00 | 189 Myrianthopoulos + 9 monochorionic + 10 Bayesian |
| DZ_twin | 341 | 0.50 | Myrianthopoulos/sex/blood (definite) |
| DZ_twin_probable | 42 | 0.50 | 38 dichorionic + 4 Bayesian |
| ambiguous_twin | 49 | varies | Same-sex, unresolved |
| full_sibling | 10,948 | 0.50 | 11-indicator scoring system |
| half_sibling | 1,457 | 0.25 | 11-indicator scoring system |
| ambiguous_sibling | 1,163 | 0.375 | Intermediate score |

With IQ data: 10,307 pairs where both members have any IQ measure; 9,244 with WISC FSIQ.

**Sibling classification** uses a scoring system integrating 11 evidence types across 4 tiers. Each variable provides weighted evidence toward a half-sibling or full-sibling classification:

- **Tier 0**: CONGMALF father number — column 179 of CONGMALF.ASC records each child's father number (1–5) as assigned during the study. Different father numbers provide the most direct evidence of paternity change (+8 points); same father number provides strong same-father evidence (−3 points). Of 13,264 pairs with data, 1,424 had different father numbers.
- **Tier 1**: v417 trajectory — whether a later child gained half-siblings from a different father (+3 points). The *trajectory* of v417 (not absolute value) is used.
- **Tier 2**: Father race change (+5), birthplace change (+4), age anomaly inconsistent with same father (+3)
- **Tier 3**: Education jump of 5+ years (+2), father occupation change (+2), marital status changes count increase (+2), marital status change (+1), father at-home status change (+1)
- **Same-father evidence**: Race match (−2), age consistent (−1), education similar (−1), v417 both zero (−1), same father number (−3)
- Score ≥ 3 → half_sibling; Score ≤ −2 → full_sibling; otherwise → ambiguous (R=0.375)

As a diagnostic check, **ABO Mendelian exclusion** was applied to 10,879 sibling pairs with complete blood type data (mother + both children). This identified 32 pairs where no single father genotype could produce both children. However, all 32 exclusions involved impossible mother–child combinations (type O mother with AB child, or AB mother with type O child) — combinations that indicate ABO typing errors rather than different paternity. The base rate of such impossible mother–child combinations in the full sample is 0.14% (68 of 50,201 trios), consistent with the ~0.1% per-test serological error rate in 1960s laboratories. No reclassifications were applied based on ABO data.

**IQ validation**: Full-sibling r=0.56 (n=7,330), half-sibling r=0.35 (n=926), ambiguous r=0.45 (n=614). Half-sibling r is higher than theoretical (~0.22), likely due to shared maternal environment and assortative mating.

### Linking family members

```r
# Load kinship links
links <- fread("cpp_kinship_links.csv", colClasses = c(id_1="character", id_2="character"))

# Get full sibling pairs with IQ data
d <- readRDS("cpp_clean_v1.rds")
sib_pairs <- merge(links[pair_type == "full_sibling"],
                   d[, .(id_1 = case_id, iq_1 = wisc_fsiq)], by = "id_1")
sib_pairs <- merge(sib_pairs,
                   d[, .(id_2 = case_id, iq_2 = wisc_fsiq)], by = "id_2")

# Sibling correlation
cor(sib_pairs$iq_1, sib_pairs$iq_2, use = "complete.obs")
```

### Limitations

- Myrianthopoulos' authoritative zygosity determinations (recovered from CONGMALF.ASC) resolve 504 of 640 twin pairs (79%). The remaining 136 pairs are classified using biological markers (membrane type, sex, blood types) and Bayesian developmental trajectory analysis, leaving 49 pairs ambiguous (38 same-sex with intermediate posteriors + 11 with insufficient data). The extended blood group typing data (raw 9-system panel results) remain unavailable — only the final MZ/DZ determination is recorded in CONGMALF.
- Sibling classification uses 11 evidence types including the CONGMALF father number, but cannot detect half-siblings when father characteristics are missing or unchanged. The scoring system classifies 10,948 full-sibling pairs and 1,457 half-sibling pairs, with 1,163 remaining ambiguous (R=0.375).
- Cannot detect half-siblings with the same father but different mothers (different mother_ids in the dataset)
- The twin sample with IQ data is moderate (~450 pairs with any IQ, ~370 with WISC FSIQ)

## CPPMASTER Card Types

309 card types organized by subject:

| Subject | Label | Cards | Records |
|---------|-------|-------|---------|
| 0 | Admin | 3 | 58,760 |
| 1 | Psychology | 53 | 689,656 |
| 2 | Pathology | 8 | 180,831 |
| 3 | Obstetrics | 124 | 3,425,197 |
| 4 | Pediatrics | 100 | 1,307,932 |
| 5 | Family/SES | 20 | 441,185 |
| 8 | Special | 1 | 4,001 |

Card numbering: 5-digit code = Sequence(1) + Subject(1) + Form(2) + Revision(1).

### Card Documentation Coverage

| Source | Cards covered | Fields |
|--------|--------------|--------|
| Vol V master index | 112 | 4,692 |
| Vol III-B cross-reference | 112 | 1,009 |
| Sequence variant recovery | 33 | (copied from siblings) |
| SAS read-in programs (NBER JH) | 52 | (definitive layouts) |
| **Total documented** | **309 of 309** | **6,280+** |

All 309 card types have field-level codebooks (100% coverage) and all 309 have been parsed into named-column CSVs, covering over 5.8 million records.

### Parsed Cards (in `master/parsed/`)

All 309 card types have been parsed into individual named columns (5.8M+ total records). Selected highlights:

| Card(s) | Description | Fields | Records |
|---------|-------------|--------|---------|
| 11200-41200 | Stanford-Binet 4yr (4 cards) | 50-55 | ~39,000 each |
| 11300-41300 | WISC & 7yr cognitive battery (4 cards) | 29-77 | ~40,700 each |
| 21100/21101 | 8-month development | 37 | 4,336/21,175 |
| 14020-44021 | Neonatal examination PED-2 (9 cards) | 120-133 | ~47,000 each |
| 14031 | Nursery feeding/history PED-3 | 82 | 47,060 |
| 14013 | Delivery room observation PED-1 | 12 | 42,616 |
| 14120 | First year summary PED-12 | 437 | 49,503 |
| 03331 | OB Delivery (form 33) | 46 | 54,952 |
| 03440/03441 | OB pregnancy conditions (form 44) | 16 | 179K/239K |
| 15011/25010 | Family/SES (form 01) | 26/47 | ~32,000 each |
| 15050-35052 | Socioeconomic info (form 05, 9 cards) | 99-108 | 13K-22K each |
| 12012/22012 | Pathology (forms 1-2) | 42-46 | ~47,000 each |

## Documentation Volumes

The original CPP documentation spans 7 main volumes plus 10 form reproduction sub-volumes. All have been OCR'd using Tesseract 5.4.0 from scanned TIFF/PDF images of microfilm originals supplied by the National Archives via NBER.

| Volume | Title | Pages |
|--------|-------|-------|
| I | Introduction and User's Guide | 136 |
| II-a through II-j | Form Reproductions (10 sub-volumes) | 2,507 |
| III-a | Variable File Dictionary | 207 |
| III-b | Variable File Field Derivation Methods | 681 |
| IV | Selected Work Files | 336 |
| V | Master Index to Computerized Data Items | 290 |
| VI | Alphabetical Permuted Glossary | 312 |
| VII | Categorization by Person, Time, Subject | 685 |

Volume II sub-volumes cover:
- 2a: Prenatal Record and Medical History
- 2b: Labor and Delivery
- 2c: Pathological Exams and Autopsies
- 2d: Family and Socioeconomic History
- 2e: Neonatal Exams and Observations
- 2f: Pediatric Neuro Exams (4mo-1yr), Growth, Illness
- 2g: Pediatric Neuro Exams (7yr)
- 2h: Psychological Exams (8mo)
- 2i: Psychological Exams (4yr and 7yr)
- 2j: Speech, Language, and Hearing (3yr and 8yr)

## Known Data Issues

1. **Feeding label swap**: Vol III-A labels col 580 as "bottle" and col 581 as "breast," but empirical distributions confirm col 580 = breast-feeding days and col 581 = bottle-feeding days. The clean data corrects this.

2. **Birth weight column offset**: Some secondary documentation maps birth weight to cols 1094-1097; correct location is cols 1095-1098.

3. **Col 365 mislabeling**: Col 365 is Occupation (grouped), not marital status. True marital status is at col 36.

4. **Sex = 3 (Undetermined)**: 804 records with sex=3 are early fetal losses (mean birth weight 1,891g, gestational age 16.3 weeks), not live births with ambiguous sex.

5. **WISC VIQ/PIQ column identification**: The original NARA/NBER documentation labels for VIQ and PIQ columns were reversed. The released dataset (`cpp_clean_v1`) corrects this using field positions verified against the JHU SAS programs.

6. **5 unlabeled delivery procedure columns**: Cols 571-575 contain binary/categorical data for delivery procedures but are not documented in Vol III-A. They appear between Apgar scores and "Procedures, other."

7. **Vol V OCR gaps**: Pages 66-90 (sparse) and 116-140 (originally empty) had poor OCR quality. These sections have been re-OCR'd in the full Tesseract pass.

## Reproducibility

### Processing Pipeline

All scripts use portable paths and should be run from the `cpp_data` directory. Execute in this order:

```
1. ocr_all_volumes.py          — OCR all PDF documentation volumes
2. parse_vol3a_to_dictionary.py — Parse Vol III-A into structured codebook CSV
3. consolidate_vol5.py          — Parse Vol V into CPPMASTER master index CSV
4. create_codebook.py           — Build publication-quality CPP_Codebook.csv
5. extract_all_master_cards.R   — Extract all 309 card types from CPPMASTER.ASC
6. parse_vol3b.py               — Cross-reference Vol 3b, build additional codebooks
7. recover_sequence_cards.py    — Recover codebooks for sequence variant cards
8. build_master_codebook.py     — Consolidate field-level CPPMASTER codebook
9. parse_master_cards.py --all  — Parse cards into named-column CSVs
10. fix_ocr_artifacts.py        — Clean OCR artifacts in crossref/codebook files
11. export_clean_data_v2.R      — Build the analysis-ready dataset
12. build_zygosity.R            — Classify twin pair zygosity
13. build_family_links.R        — Build kinship table with R coefficients
```

### Requirements

- **Python 3.8+** with: csv, os (standard library only)
- **R 4.0+** with: data.table
- **Tesseract 5.4+** (for OCR step only)
- **PyMuPDF / fitz** (for OCR step only)
- Original data files: `CPPVAR.ASC`, `CPPMASTER.ASC` in `data/` subdirectory
- Original documentation PDFs in `docs/` subdirectory (for OCR step only)

## Citation

If you use this dataset, please cite:

> Niswander, K. R., & Gordon, M. (1972). *The Women and Their Pregnancies: The Collaborative Perinatal Study of the National Institute of Neurological Diseases and Stroke.* Philadelphia: W. B. Saunders.

Key publications:
- Broman, S. H., Nichols, P. L., & Kennedy, W. A. (1975). *Preschool IQ: Prenatal and Early Developmental Correlates.* Hillsdale, NJ: Erlbaum.
- Broman, S. H., Nichols, P. L., Shaughnessy, P., & Kennedy, W. (1987). *Retardation in Young Children.* Hillsdale, NJ: Erlbaum.
- Hardy, J. B. (2003). *The Collaborative Perinatal Project: Lessons and Legacy.* Annals of Epidemiology, 13(5), 303-311.
- Myrianthopoulos, N. C. (1975). An epidemiologic survey of twins in a large, prospectively studied population. *American Journal of Human Genetics*, 27(2), 158-165.
