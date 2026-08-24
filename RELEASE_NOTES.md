# Collaborative Perinatal Project (CPP/NCPP) -- Complete Data Release

**Version 3.3.1 correction candidate** | August 23, 2026

---

## 1. Overview

### What Is the CPP?

The Collaborative Perinatal Project (CPP), also known as the National Collaborative Perinatal Project (NCPP), was a landmark prospective birth cohort study conducted from 1959 to 1974 under the auspices of the National Institute of Neurological Diseases and Stroke (NINDS). Twelve university-affiliated medical centers across the United States enrolled approximately 60,000 pregnancies and followed children from the prenatal period through age 7-8, producing one of the most comprehensive developmental datasets ever assembled. The study collected detailed information on maternal health, prenatal care, labor and delivery, neonatal outcomes, and child development. Its cognitive testing battery was exceptionally thorough: children received the Stanford-Binet IQ test at age 4 and the full Wechsler Intelligence Scale for Children (WISC) at age 7, along with the Wide Range Achievement Test (WRAT), Bender Gestalt, and Auditory-Vocal Association tests. The dataset also includes extensive family structure, with 8,772 mothers contributing two or more children, yielding 19,966 children in sibling families and 640 twin pairs suitable for behavior-genetic and within-family designs.

The CPP produced foundational publications in developmental psychology and perinatal epidemiology, including Niswander and Gordon's *The Women and Their Pregnancies* (1972), Broman, Nichols, and Kennedy's *Preschool IQ: Prenatal and Early Developmental Correlates* (1975), and Broman, Nichols, Shaughnessy, and Kennedy's *Retardation in Young Children* (1987). It has been called a "national treasure" for perinatal epidemiology (Hardy, 2003).

### Why This Release Matters

Despite its extraordinary scope, the CPP has been severely underutilized in modern research because of five compounding accessibility barriers:

1. **No modern codebook.** The only documentation was scanned microfiche of 1970s-era typewritten codebooks -- over 5,000 pages across 19 volumes, with no text layer and no digital index.

2. **Archaic data format.** The primary analysis file (CPPVAR) is a 1,600-column fixed-width ASCII file with no variable names, no delimiters, and no metadata. Extracting even a single variable requires identifying its column positions from the physical codebook.

3. **Punch card storage.** The master file (CPPMASTER) stores 6.1 million records as raw 80-column punch card images. Each record type is identified by a 5-digit code embedded at a specific position within the 80 characters. Understanding the data requires cross-referencing the Vol V master index.

4. **Scattered documentation.** Variable definitions are in Vol III-A, derivation methods in Vol III-B, form reproductions spread across 10 sub-volumes of Vol II, the master index in Vol V, cross-references in Vols VI and VII, and work file documentation in Vol IV. No single document provides a complete picture.

5. **Known errors.** The original codebook contains at least five errors (label swaps, column offsets, mislabeling, IQ variable misidentification) that are discoverable only through empirical validation against expected distributions.

The practical consequence has been that researchers wishing to use the CPP typically extracted only the handful of variables needed for a single analysis, often without access to the full documentation suite. Large portions of the dataset -- particularly the CPPMASTER card-level data, the item-level cognitive test data, and the family linkage structure -- have gone almost entirely unexploited.

### What This Release Provides

This release is a comprehensive rescue and modernization of the CPP dataset. It provides:

- Machine-readable versions of every documented variable from both source files
- Named-column CSVs for all 309 master card types (6.1 million records)
- 31 standalone datasets (1,515,805 records) parsed from the NARA/NBER Johns Hopkins collection
- Publication-quality codebooks at the variable and field level
- OCR transcriptions of all 19 documentation volumes (approximately 5,000 pages)
- NLSYLinks-style kinship tables with twin zygosity classification anchored by gold-standard serological determinations
- Pre-computed derived variables for common analytical tasks (g-factor scores, growth trajectories, birth weight z-scores, disability measures, discordant sibling pairs)
- Discovery and correction of five errors in the original codebook
- Complete processing scripts for full reproducibility

---

## 2. What's Included

The release is organized into seven tiers, from the most immediately usable to the most complete.

### Tier 1: Analysis-Ready Core

The starting point for most analyses. Key demographics, IQ scores, breastfeeding, birth outcomes, and SES variables, cleaned and labeled, ready for immediate analysis with no further processing.

| File | Description | Rows | Columns | Size |
|------|-------------|------|---------|------|
| `cpp_clean_core.csv` | Recommended analysis-ready core | 59,391 | 185 | 34 MB |
| `cpp_clean_core.rds` | Matching core R binary with factor labels | 59,391 | 185 | 5.6 MB |
| `cpp_clean_expanded.csv` | Expanded analysis-ready CSV | 59,391 | 315 | 53 MB |
| `cpp_clean_expanded.rds` | Matching expanded R binary | 59,391 | 315 | 8.7 MB |
| `cpp_clean_expanded_codebook.csv` | Codebook for the expanded schema | 315 entries | -- | 37 KB |
| `cpp_clean_v2.csv` | Legacy v2 (uncorrected WISC VIQ/PIQ) | 59,391 | 107 | 20 MB |
| `cpp_clean_v2_full.csv` | Legacy v2, full version with raw values | 59,391 | 132 | 23 MB |
| `cpp_clean_v2.rds` | Legacy v2, R binary with factor labels | 59,391 | 132 | 4.2 MB |
| `cpp_clean_v2_codebook.csv` | Codebook for the v2 variables | 107 | -- | 10 KB |

**v3 is the recommended starting point.** It corrects the WISC VIQ/PIQ mislabeling found in v2 (see Section 4, Error #5) and adds 51 new variables from the 7-year psychological assessment battery.

Variables include: case and mother identifiers, study site, sex, race, maternal age, education, income, socioeconomic index, marital status, religion, smoking status, cigarettes per day, prenatal visits, prior pregnancies, parity, gestational age, birth weight, Apgar scores, placental weight, pregnancy outcome, nursery feeding (breast/bottle days, feeding type), Stanford-Binet IQ (age 4), WISC Full Scale/Verbal/Performance IQ and all subtest raw + scaled scores (age 7), WRAT Reading/Spelling/Arithmetic, Bender Gestalt, Auditory-Vocal Association, Goodenough-Harris Draw-a-Person (raw + standard), 15 behavioral ratings (separation anxiety, fearfulness, rapport, cooperation, attention span, hostility, and 9 others), school variables (type, grade, repeating, special class), handedness, examiner global ratings, and family linkage variables (mother ID, pregnancy order, plurality, birth switch).

**New in v3 (51 variables added):**
- Corrected WISC Verbal IQ and Performance IQ (the v2 labels were swapped; see Error #5)
- WISC Performance subtests: Picture Arrangement, Block Design, Coding (raw + scaled)
- WISC scaled score sums (verbal, performance) and scaled scores (verbal, performance)
- WISC Full Scale Scaled Score and adequacy of exam rating
- All WISC subtest raw scores (Information, Comprehension, Vocabulary/Similarities, Digit Span)
- Goodenough-Harris Draw-a-Person (raw + standard scores)
- WRAT Spelling and Arithmetic raw scores
- School variables: type, current grade, repeating status, special class
- 15 behavioral ratings from the 7-year psychological exam
- Handedness, examiner's intelligence/behavior ratings, muscular movement observations

### Tier 2: Full CPPVAR

Every documented variable from the CPPVAR summary file, with complete codebook documentation.

| File | Description | Rows | Columns | Size |
|------|-------------|------|---------|------|
| `cppvar_all_columns.csv` | Every documented column from CPPVAR.ASC | 59,391 | 1,236 | 164 MB |
| `CPP_Codebook.csv` | Publication-quality codebook with clean names, types, value labels, missing codes, and topical sections | 1,239 entries | -- | 278 KB |
| `cppvar_codebook.csv` | Raw auto-parsed codebook, retained for reproducibility | 1,140 entries | -- | 208 KB |

The codebook covers 100% of the 1,600-column CPPVAR record. Variables span: identifiers and administrative flags (21), demographics and SES (33), pregnancy history (30), pregnancy conditions by trimester (151), family medical history (88), obstetric measures (40), birth outcomes and Apgar scores (45), nursery and feeding (15), congenital conditions (339), placental pathology (51), cognitive assessment (62), growth and anthropometrics (30), delivery procedures (154), neonatal neurological (95), disease summary counts (13), consanguinity (7), and miscellaneous derived variables (65).

### Tier 3: Complete CPPMASTER

All 309 punch card types from the 6.1-million-record master file, parsed into named-column CSVs with per-card codebooks.

| File | Description | Size |
|------|-------------|------|
| `master/parsed/card_XXXXX_parsed.csv` | 309 individual parsed card CSVs with named columns (13,154 total columns) | varies |
| `master/parsed/card_XXXXX_fields.csv` | 309 companion field documentation files | varies |
| `master/card_codebooks/codebook_XXXXX.csv` | 312 per-card field-level codebooks | varies |
| `CPPMASTER_Data_Dictionary.csv` | Complete field-level data dictionary (16,295 fields) | 2.5 MB |
| `CPPMASTER_Form_Guide.csv` | Form-level guide mapping card IDs to subjects and descriptions (52 forms) | 23 KB |
| `CPPMASTER_Codebook.csv` | Consolidated field-level codebook (6,280+ fields) | 588 KB |
| `SAS_Variable_Catalog.csv` | Authoritative field definitions from 24 JHU SAS programs (5,851 unique) | 1.1 MB |
| `SAS_Value_Labels.csv` | 1,088 value code definitions across 170 categorical formats | 32 KB |
| `SAS_Value_Labels_Reference.txt` | Human-readable value label reference | 28 KB |
| `SAS_Format_Field_Linkage.csv` | 120 validated links from value formats to specific card fields | 14 KB |
| `master_all_cards_index.csv` | Detailed card metadata (subject, form, revision, record counts) | 9 KB |
| `vol3b_crossref.csv` | CPPVAR-to-CPPMASTER cross-reference (906 derivation mappings) | 70 KB |
| `vol3b_card_mapping.csv` | Vol 3b card number to 5-digit code mapping | 3 KB |
| `cpp_comprehensive.csv` | All 309 card types merged into one wide file | 1.4 GB |
| `cpp_comprehensive_codebook.csv` | Codebook for the comprehensive file | 886 KB |
| `cpp_comprehensive_supplementary.csv` | Supplementary columns (<1% coverage) | -- |

The CPPMASTER card types cover the full scope of the CPP assessment battery:

- **Administrative** (3 cards): Registration and identifiers
- **Psychology** (53 cards): 8-month Bayley scales; 4-year Stanford-Binet (item-level pass/fail); 7-year WISC, WRAT, Bender Gestalt, Auditory-Vocal Association; preschool battery; adolescent testing
- **Pathology** (8 cards): Placental pathology (gross and microscopic), autopsy, pathology summaries
- **Obstetrics** (124 cards): Prenatal history, past and family history, present pregnancy, labor and delivery, conditions of newborn, prenatal visits, prenatal labs, anesthesia and complications, prenatal medications, supplemental records, nursery/newborn care, prenatal summaries, demographic codes, prenatal computed variables, hospital discharge, smoking data
- **Pediatrics** (100 cards): Neonatal neurological exam, neonatal summary, 4-month exam and nursery history, 8-month exam, 1-year exam, pediatric history, lab and growth data, 4-year exam, 4-year speech/language/hearing, first-year summary, 7-year neurological exam, anthropometric data, growth measurements, growth computed variables
- **Family/SES** (20 cards): Socioeconomic interview at registration, 4-year follow-up, and 7-year follow-up
- **Special** (1 card): Birth weight, sex, outcome, gestational age

Multi-row card types (26 types representing prenatal visits, hospitalizations, lab results, medication records, and similar repeated-measure data) are provided as companion files (`cpp_multirow_XXXX.csv`).

### Tier 4: Unified Wide Dataset

Every child crossed with every variable from every card, merged into a single wide table.

| File | Description | Rows | Columns | Size |
|------|-------------|------|---------|------|
| `cpp_unified_wide.rds` | All card + standalone data merged per linkage ID (R binary) | 60,016 | 4,862 | 114 MB |
| `cpp_unified_wide.csv` | Same as above, CSV format | 60,016 | 4,862 | see checksums |
| `cpp_unified_manifest.csv` | Variable manifest with missingness, summary statistics | 4,862 entries | -- | 288 KB |
| `cpp_unified_supplementary.rds` | Supplementary columns (<1% coverage, R binary) | 11,768 | 2,535 incl. ID | 2.9 MB |
| `cpp_unified_supplementary.csv` | Same as above, CSV format | 11,768 | 2,535 incl. ID | 90 MB |
| `cpp_unified_supplementary_codebook.csv` | Codebook for supplementary variables | 2,534 entries | -- | -- |
| `cpp_columns_dropped.csv` | Log of all-NA and confirmed duplicate columns removed | 3,150 entries | -- | -- |

This file provides the complete union of all single-row CPPMASTER cards, 20 single-row standalone datasets (abnormalities, serology, congenital malformations, rupture of membranes, SES indices, toxemia, socio-7yr, speech/language/hearing, and 11 W17 cognitive research extracts), plus the 202 curated analysis variables from the Tier 1 cleaning pipeline. Column names use the `c[NNNN]_` prefix for master card sources (e.g., `c2130_wisc_full_scale_iq`), `sa_[name]_` for standalone sources (e.g., `sa_congmalf_col_23`), `v3_` for Tier 1 analysis variables, and `v2_` for legacy v2 variables.

The corrected unified dataset contains 59,391 CPPVAR records plus 625 records found only in CPPMASTER or standalone files. The original 64,834-row build contained 2,421 source-proven alias groups. The main 2,397 groups appeared three times: a CPPVAR blank-ninth-character form, an erroneous left-padded form that shifted the identifier fields, and the right-completed identifier used by NCPP child cards and other raw sources. Nine CONGMALF aliases and fifteen SEI7YR aliases were also crosswalked. v3.3.1 removes 4,818 duplicate rows with zero conflicting nonmissing values, re-overlays 120 historical `v3_` fields for all CPPVAR records, and standardizes the analysis-ready `mother_id` to seven characters. The terminal 0 is a cross-source linkage key; the original CPPVAR `plurality`/outcome fields still distinguish records whose child digit was blank.

**Column slimming.** Columns with <1% coverage (fewer than 649 non-missing values) were moved to the supplementary side-sheet rather than the main file. These include: high-sequence pregnancy cards (5th+ pregnancy, affecting <17 cases), duplicate codebook entries at overlapping byte positions, 3rd/4th pregnancy forms, and rare clinical variables (e.g., neonatal molding N=514, cervical culture N=524). All supplementary columns are documented in the supplementary codebook with their sparsity reason and can be merged back into the main dataset by `case_id`. An additional 1,036 confirmed byte-position duplicate columns (same card, same byte range, different names) were removed and logged. All-NA columns (2,114) were also removed and logged. The dropped-columns log records every removed column with its reason.

**Column accounting:** 4,861 main columns + 2,534 supplementary + 3,150 dropped = 10,545 total (6,959 original + 3,586 standalone).

**Case ID check digit.** The 9th digit of the case_id is a check digit whose value depends on the source file: CPPVAR uses 0 for singletons, CPPMASTER clinical cards use 9, and multiple births use digits 1-4 to distinguish siblings. The unified dataset normalizes all case identifiers to the CPPVAR convention (digit 0 for singletons) before merging.

### Tier 5: Family Structure

Pairwise kinship links with relatedness coefficients and twin zygosity classification.

| File | Description | Rows | Size |
|------|-------------|------|------|
| `cpp_kinship_links.csv` | Pairwise kinship links with R coefficients | 14,208 pairs | 1.8 MB |
| `cpp_twin_zygosity.csv` | Twin pair zygosity classification (5-tier evidence schema) | 640 pairs | 115 KB |

**Twin zygosity** is classified using a principled five-tier schema:

| Classification | N Pairs | R | Basis |
|---------------|---------|---|-------|
| MZ_definite | 189 | 1.00 | Myrianthopoulos blood groups (9-system panel) |
| MZ_very_probable | 9 | 1.00 | Monochorionic membrane (pathology card 12022) |
| MZ_probable | 10 | 1.00 | Bayesian developmental trajectory model (P(MZ) > 0.80) |
| DZ_definite | 341 | 0.50 | 315 Myrianthopoulos + 5 sex-discordant + 21 blood-discordant |
| DZ_probable | 42 | 0.50 | 38 dichorionic membrane + 4 Bayesian |
| ambiguous_SS | 38 | varies | Same-sex, Bayesian posterior 0.20-0.80 |
| unknown | 11 | 0.75 | Insufficient data |

The gold-standard tier uses Myrianthopoulos' (1975) blood group determinations from a 9-system serological panel, recovered from column 178 of the congenital malformations work file (CONGMALF.ASC). This resolves 504 of 640 pairs (79%) with definitive serological evidence.

**Sibling classification** uses an 11-indicator scoring system anchored by the CONGMALF father number variable (column 179), classifying 10,948 full-sibling pairs (R = 0.50), 1,457 half-sibling pairs (R = 0.25), and 1,163 ambiguous pairs (R = 0.375).

IQ validation: MZ r = 0.81 (n=132), DZ r = 0.61 (n=226), full siblings r = 0.56 (n=7,330), half-siblings r = 0.35 (n=926).

### Tier 6: Derived and Supplementary Files

Pre-computed derived variables for common analytical tasks.

| File | Description | Rows | Size |
|------|-------------|------|------|
| `cpp_growth_trajectories.csv` | Longitudinal weight/height/HC, long format (birth through 7yr) | 755,739 | 24 MB |
| `cpp_growth_velocity.csv` | Weight, height, HC gains between key ages (wide format) | 55,443 | 5.6 MB |
| `cpp_birthweight_zscores.csv` | Sex- and gestational-age-adjusted birth weight z-scores | 54,223 | 2.1 MB |
| `cpp_birthweight_reference.csv` | Internal reference curves (loess means/SDs by sex and GA) | 46 | 2 KB |
| `cpp_hc_zscores.csv` | Age- and sex-specific head circumference z-scores at 6 ages | 186,149 | 9.0 MB |
| `cpp_hc_reference.csv` | HC reference curves (mean, SD, median, MAD) | 12 | 700 B |
| `cpp_g_factors.csv` | 10 g-factor scores (PCA, PAF, CFA across variable sets + IRT-SB) | 53,640 | 14 MB |
| `cpp_g_loadings.csv` | Factor loadings for each g extraction method, with exclusion flags | 77 | 5.4 KB |
| `cpp_cognitive_scores.csv` | Raw scores, z-scores, and latent g-factor for 11 measures | 59,391 | 11 MB |
| `cpp_cognitive_loadings.csv` | PCA loadings for WISC g extraction | 4 | 179 B |
| `cpp_sb_items.csv` | Parsed Stanford-Binet item-level data (raw pass/fail, ages 2-4) | 39,090 | 1.7 MB |
| `cpp_sb_items_reconstructed.csv` | SB items with adaptive basal/ceiling reconstruction for IRT | 37,820 | 2.1 MB |
| `cpp_item_scores.csv` | PCA + IRT factor scores from 6 developmental item batteries | 53,640 | 3.3 MB |
| `cpp_item_scores_codebook.csv` | Codebook for item battery scores | 11 | 1 KB |
| `cpp_ses_detailed.csv` | Detailed SES with father characteristics | 59,391 | 4.0 MB |
| `cpp_attrition_analysis.csv` | Follow-up rates by demographics, site, SES | -- | 3 KB |
| `cpp_disability_discordance.csv` | 10 disability criteria + composite flags | 53,640 | 5.0 MB |
| `cpp_discordant_pairs.csv` | Sibling/twin pairs discordant on key exposures | 11,539 | 1.1 MB |

**g-factor scores** are provided via 10 extraction methods:
- PCA, PAF, and CFA on 4 WISC scaled subtests (Set A: Information, Comprehension, Vocabulary, Digit Span)
- PCA on 5 WISC subtests (Set B: Set A + Similarities raw)
- PCA, PAF, and CFA on 7 age-7 measures (Set C: Set A + WRAT Reading, Bender, Auditory-Vocal)
- PCA on 10 broad battery measures (Set D: Set C + Similarities, WRAT Spelling, Conceptual Style, Embedded Figures)
- IRT-based theta on reconstructed Stanford-Binet items at age 4 (with adaptive basal/ceiling logic)

Recommended: `g_pca_7` for age-7 analyses, `g_irt_sb_adaptive` for age-4 analyses. PAF-7 and CFA-7 scores are excluded due to Heywood cases.

**Note:** The existing g-factor extractions use WISC subtest scaled scores (Information, Comprehension, Vocabulary, Digit Span), not VIQ/PIQ, so they are unaffected by the v3 VIQ/PIQ correction. The v3 dataset adds three Performance subtests (Picture Arrangement, Block Design, Coding) which enable researchers to construct enhanced g-factors incorporating both Verbal and Performance batteries.

**Stanford-Binet item data** includes item-level pass/fail responses from Year II through Year IV subtests. The reconstructed version applies the adaptive basal/ceiling logic used in administration: items below the child's basal level are imputed as passes, items above the ceiling as fails, making the data suitable for item response theory (IRT) analysis.

**Disability measures** include 10 criteria (IQ < 70, CNS defect, congenital malformation, neuromuscular condition, seizures, and five additional clinical indicators) with composite flags. The recommended measure for analyses is `disabled_strict` (IQ < 70 plus at least one other criterion; prevalence 2.3%).

**Discordant pairs** identify sibling and twin pairs discordant on maternal smoking, nursery breastfeeding, and birth weight, enabling natural-experiment designs.

### Survey Weights

| File | Description | Rows | Size |
|------|-------------|------|------|
| `cpp_weights.csv` | 17 weight columns across 4 schemes | 59,391 | -- |
| `cpp_weights_codebook.csv` | Codebook for weight variables | 17 | -- |

The CPP was a convenience sample enrolled at 12 university hospitals with no probability-based sampling design. Two sources of bias affect naive estimates: (1) **differential attrition**, because follow-up rates vary from 28% to 91% across sites, and (2) **population non-representativeness**, because site-specific enrollment over-represents urban, hospital-affiliated populations relative to the national birth cohort.

The weights file provides 17 columns organized into four schemes:

1. **IPW attrition weights (6 columns).** Inverse-probability-of-follow-up weights estimated via logistic regression, defined by follow-up **age/wave** (not by specific test). The CPP release contains far more than IQ data at each follow-up -- age-4 data includes developmental exams, growth, and SEI interviews; age-7 data includes neurological exams, growth, speech/hearing, achievement tests, and behavioral ratings. Three waves (age 4, age 7, any follow-up) x two model specifications (parsimonious 6-predictor and full 12-predictor).

2. **Census population weights (3 columns).** Raking weights that align CPP sample margins to 1960-65 U.S. birth demographics across 6-7 dimensions: cross-classified race x education (8 cells), maternal age (5 categories), child sex, birth order (4 categories), marital status, and optionally Census region. Three versions:
   - `popwt_national`: 7 dimensions including region (N_eff = 24.8%)
   - `popwt_national_noregion`: 6 dimensions without region (N_eff = 58.2%)
   - `popwt_urban`: 6 dimensions raked to urban/SMSA birth demographics (N_eff = 59.6%). **Recommended for most analyses** because all 12 CPP sites are urban hospitals with zero rural births.

3. **Combined weights (4 columns).** Product of IPW(full) x population weight, for age-4 and age-7 follow-up analyses. Use these when analyzing follow-up outcomes to correct for both attrition and non-representativeness.

4. **Follow-up indicators (3 columns).** Binary indicators (`in_age4`, `in_age7`, `in_anyfollowup`) flagging follow-up data availability at each wave.

**Recommended usage:**
- Baseline (full-sample) analyses: use `popwt_urban`
- Age-7 follow-up outcome analyses: use `combined_age7_urban`
- Age-4 follow-up outcome analyses: use `combined_age4_urban`
- National representativeness needed: use `popwt_national` or `combined_*_national`

**Birth order note:** The August 2026 correction maps raw code 88 ("no prior pregnancy") to zero in `parity`, `prior_perinatal_loss`, and `prior_livebirths`; code 99 remains unknown. These are distinct constructs: `parity` counts prior pregnancies reaching at least 20 weeks, `prior_livebirths + 1` gives observed live-birth order, and `prior_preg + 1` gives pregnancy order. See `ERRATA.md` for affected v3.2 assets and exact counts.

### Tier 7: Documentation

OCR transcriptions of the complete original documentation suite.

| File | Source | Description | Pages |
|------|--------|-------------|-------|
| `ocr/vol1_ocr.txt` | Vol I | Study overview and user's guide | 136 |
| `ocr/vol2a_ocr.txt` through `vol2j_ocr.txt` | Vol II-a through II-j | Form reproductions (10 sub-volumes) | 2,507 |
| `ocr/vol3a_variable_dictionary.csv` | Vol III-A | CPPVAR codebook (structured CSV) | 207 |
| `ocr/vol3b_ocr.txt` | Vol III-B | CPPVAR field derivation methods | 681 |
| `ocr/vol4_ocr.txt` | Vol IV | Selected work files | 336 |
| `ocr/vol5_master_index.csv` | Vol V | CPPMASTER index (structured CSV) | 290 |
| `ocr/vol6_ocr.txt` | Vol VI | Alphabetical permuted glossary | 312 |
| `ocr/vol7_ocr.txt` | Vol VII | Data items by person/time/subject | 685 |
| `ocr/bibliog_ocr.txt` | Bibliography | CPP bibliography | 93 |
| `ocr/index_ocr.txt` | Index | General index | 49 |

Volumes III-A and V were processed with AI-assisted OCR and converted to structured CSV format. All other volumes were processed with Tesseract 5.4.0. The structured codebooks are the basis for all extraction pipelines.

Additionally, 31 standalone datasets (1,515,805 total records) parsed from the NARA/NBER Johns Hopkins collection are provided in `standalone/`, each with a companion `_fields.csv` file documenting column positions and labels. Twenty of these (single-row-per-case files) are merged into the Tier 4 unified dataset; the remaining 11 (multi-row files like drug records, serum specimens, and visit logs) are provided as separate files. These include:

- **Serology cards** (6 files, 332,057 records): Viral antibody titer and specimen tracking data
- **Clinical and pregnancy files** (8 files, 527,202 records): Toxemia flags, congenital malformations (including structured CONGMALF with Myrianthopoulos zygosity and father number), rupture of membranes, drug files (generic and brand name), clinical visit records
- **Assessment and index files** (5 files, 198,182 records): 7-year socioeconomic index, 7-year sociometric, 7-year abnormality summary, speech/language/hearing summary, registration SEI
- **W17 work files** (13 files, 45,931 records): Research extracts from special studies

---

## 3. Data Processing Methodology

### Source Data

Two fixed-width ASCII files were obtained from the National Bureau of Economic Research (NBER) CPP archive at `https://www2.nber.org/CPP/`:

| File | Size | Format | Description |
|------|------|--------|-------------|
| `CPPVAR.ASC` | 91 MB | 59,391 rows, 1,600 chars each | One row per child: summary variables derived from assessment forms |
| `CPPMASTER.ASC` | 478 MB | 6,107,562 rows, 80 chars each | Raw assessment-level data in punch card format |

Additional source data: 35 NARA ASCII files, 61 NICHD form files, and 24 SAS programs (with duplicates totaling 35 files) from the NBER CPP JH collection, plus 19 documentation volume PDFs (scanned microfiche). The SAS programs were systematically parsed in v3.1 to extract 5,851 unique variable definitions with column positions and labels, plus 170 categorical value format definitions (1,088 value codes).

### Processing Pipeline

1. **OCR.** All documentation PDFs were rendered to 200-DPI images and processed with Tesseract 5.4.0 (page segmentation mode 6). Volumes III-A and V received additional AI-assisted OCR to produce structured, machine-readable codebooks.

2. **CPPVAR extraction.** The structured Vol III-A codebook was used to programmatically extract all 1,236 documented columns from the 1,600-character ASCII records in a single R pass. Variable names were automatically generated from codebook descriptions.

3. **CPPMASTER card extraction.** A single-pass scan of the 6.1-million-record master file routed each record to the appropriate card-type CSV based on its 5-digit card number (columns 1-5). This produced 309 individual card CSVs, each containing the case identifier (columns 6-14) and the raw 66-character data payload (columns 15-80).

4. **Card codebook construction.** Per-card field-level codebooks were assembled from four sources: Vol V master index (112 card types, 4,692 fields), Vol III-B cross-reference (112 card types, 1,009 fields), sequence variant recovery (33 card types, copied from sibling cards), and SAS read-in programs from the NBER JH collection (52 card types, definitive layouts). This achieved 100% coverage: all 309 card types have field-level documentation. In v3.1, the codebooks were further enriched with 5,222 new field entries extracted from 24 JHU SAS programs, bringing the total codebook documentation from ~8,050 to ~13,400 fields across 312 codebook files. All 309 card CSVs were then re-parsed using the enriched codebooks, expanding from ~7,600 to 13,154 named columns.

5. **Card parsing.** Each raw card CSV was parsed into a proper CSV with named columns using the per-card codebook. Fields were extracted from the fixed-width data string using column-position offsets from the codebook. Overlapping fields (from multi-revision cards) were deduplicated. In v3.1, all 309 cards were re-parsed using the SAS-enriched codebooks, expanding from ~7,600 to 13,154 named columns across 6,107,562 total records. Cards that previously had only 1-4 columns (due to sparse OCR-derived codebooks) now have 28-66+ columns of extracted data.

6. **Standalone dataset parsing.** Thirty standalone ASCII datasets from the NARA/NBER JH collection were parsed using column layouts from accompanying SAS programs (where available) or positional extraction.

7. **Analysis-ready dataset construction.** The Tier 1 dataset was built by combining variables from CPPVAR (demographics, SES, birth outcomes, cognitive scores, feeding) with selected CPPMASTER card-level data (WISC subtests from card 21300, WRAT and behavioral ratings from card 31300, observations from card 41300, nursery feeding from card 14031), applying value labels, handling missing codes, and performing empirical validation. The v3 dataset was cross-validated against the JHU SAS extraction with perfect agreement (r = 1.000, 100% exact match) on all 39 verified variables.

8. **Value-add construction.** Growth trajectories, birth weight z-scores, head circumference z-scores, g-factor scores, Stanford-Binet item reconstruction, item battery scores, kinship links, twin zygosity classification, attrition analysis, detailed SES, disability measures, and discordant pairs were computed from the Tier 1-3 data using dedicated R scripts.

### Software

- **Python 3.12**: OCR processing, codebook parsing, card parsing, standalone dataset parsing
- **R 4.3.1**: Data extraction, analysis-ready dataset construction, value-add computation
- **Tesseract 5.4.0**: OCR engine for documentation volumes
- **R packages**: data.table, psych, lavaan, mirt (for g-factor and IRT analyses)

---

## 4. Value-Adds Over Raw Data

This release provides the following capabilities that the raw NARA/NBER files do not:

1. **Parsability.** Raw data files are 80-character or 1,600-character fixed-width ASCII records with no headers, no delimiters, and no metadata. We provide named-column CSVs with full documentation.

2. **Documentation.** Original codebooks exist only as scanned microfiche images. We OCR'd and structured all 5,000+ pages into machine-readable text, structured codebook CSVs, and a comprehensive data dictionary.

3. **Error corrections.** Five codebook errors were discovered and corrected through empirical validation:
   - **Feeding label swap:** Vol III-A labels col 580 as "bottle-feeding days" and col 581 as "breast-feeding days." Empirical distributions and cross-validation against the PED-3 nursery card confirmed the labels are reversed. The clean data corrects this.
   - **Birth weight column offset:** Some secondary documentation maps birth weight to cols 1094-1097; the correct position is cols 1095-1098 (Item 5918), confirmed by verifying the expected sex difference at both candidate positions.
   - **Occupation mislabeling:** Col 365 has been referenced as "marital status" in some analyses. OCR of the original codebook revealed it is "Occupation, grouped" (Item 5233). True marital status is at col 36 (Item 4977).
   - **Sex=3 clarification:** The 804 records with sex coded as 3 ("undetermined") have a mean birth weight of 1,891g and gestational age of 16.3 weeks. These represent early fetal losses, not live births with ambiguous sex.
   - **WISC VIQ/PIQ column misidentification (v3 correction):** Cross-referencing the card 21300 extraction against the definitive JHU SAS program (`psforms_allobs_nops26.sas`) revealed that what v2 labeled `wisc_viq` (card cols 54-56) is actually **Performance IQ**, and what v2 labeled `wisc_piq` (card cols 57-59) is actually **Full Scale Scaled Score** (the raw sum converted to FSIQ, hence the r = 0.999 correlation with FSIQ). The true Verbal IQ (card cols 49-51) was never extracted in v2. This was confirmed empirically: the corrected VIQ correlates r = 0.995 with the verbal subtest sum (expected ~0.95), the corrected PIQ correlates r = 0.888 with FSIQ (expected ~0.80-0.90), and the corrected VIQ-PIQ correlation is r = 0.585 (expected ~0.55-0.65). All corrections were cross-validated against the JHU SAS dataset with r = 1.000 exact match on all 23 WISC variables.

4. **WRAT field boundary verification.** On card 31300, the WRAT Reading field at columns 41-42 is a coded grade rating (r approximately 0 with WISC FSIQ), not a raw score. The cognitively-loaded WRAT Reading score is at columns 43-44 (r approximately 0.55 with WISC FSIQ). The correct field was identified through OCR-verified column positions and empirical correlation analysis.

5. **WISC-derived variable detection.** Multiple variables on card 21300 that appeared to be independent cognitive tests were identified as linear functions of WISC subtests:
   - "Auditory-Vocal Association" (cols 33-34): r = 0.996 with WISC Verbal IQ -- essentially a prorated verbal score, not an independent measure.
   - "Bender Gestalt" (cols 35-36): Correlates *positively* with IQ (r approximately +0.70). Standard Bender scoring counts errors (negative correlation). This is a developmental/accuracy score, not an error count.
   - "Tactile Finger Recognition" (cols 33-34): Identical data to WRAT Reading Raw (r = 1.000) -- same column positions under different documentation labels.
   - Several additional fields (WRAT Arithmetic, Graham-Ernhart Block Sort, Goodenough Draw-a-Person) had near-zero correlations with all cognitive variables (r < 0.05), indicating administrative or coding artifacts rather than substantive cognitive measures.

6. **Family linkage.** Constructed an NLSYLinks-style kinship table from mother IDs, pregnancy orders, and blood group serology, providing 14,208 classified pairwise links.

7. **Twin zygosity.** Five-tier classification using Myrianthopoulos' gold-standard 9-system blood group determinations (recovered from the CONGMALF work file), supplemented by placental membrane type, sex concordance, blood type concordance, and Bayesian developmental trajectory analysis trained on the known MZ/DZ pairs.

8. **g-factor extraction.** Ten methods for extracting latent cognitive ability, spanning multiple variable sets, methods (PCA, PAF, CFA, IRT), and ages (4 and 7), enabling sensitivity analysis across extraction approaches.

9. **Growth compilation.** Longitudinal growth trajectories compiled from scattered card-level measurements across multiple pediatric assessment forms, harmonized to consistent units (grams, centimeters), spanning birth through age 7.

10. **Stanford-Binet item reconstruction.** Parsed item-level pass/fail data from the Stanford-Binet adaptive test, with reconstruction of the basal/ceiling logic (items below basal imputed as passes, above ceiling as fails), making the data suitable for IRT analysis.

11. **Cross-validation against JHU SAS datasets.** The complete 7-year psychological battery (WISC, WRAT, behavioral ratings, observations) was cross-validated against the pre-made SAS datasets from the Johns Hopkins University modernization project. Results: all 23 WISC variables (card 2130), all 15 WRAT and behavioral variables (card 3130), and handedness (card 4130) achieved r = 1.000000 with 100% exact match across all matched cases. This confirms that our card parsing produces identical values to the JHU extraction.

12. **Comprehensive CPPVAR audit.** All 1,236 CPPVAR summary variables were audited for sentinel value contamination, range plausibility, distributional anomalies, and cross-variable consistency. The audit identified 56 variables with >5% unhandled sentinel values, 16 variables with extreme max values from uncleaned sentinel codes, 12 constant columns (mostly cohort presence flags), and 6 all-NA columns (blank placeholders). Disease summary counts were cross-checked against detailed pregnancy condition flags and found consistent. Full audit results are documented in `analysis_paper/17b_full_cppvar_audit.R`.

13. **SAS program enrichment (v3.1).** All 24 SAS programs from the NBER JH collection were systematically parsed to extract 5,851 unique variable definitions (with column positions, labels, and comments) across 164 card codes. These were matched to the existing 312 card codebooks, adding 5,222 new field entries that were previously undocumented in the OCR-derived codebooks. All 309 card CSVs were then re-parsed using the enriched codebooks, expanding from ~7,600 to 13,154 named columns across 6,107,562 total records. For example, card 03041 (OB4 Menstrual History, 56,797 records) went from 1 extracted field to 30 named columns (age at menarche, menstrual duration/interval, LMP/PMP dates, dysmenorrhea, contraception methods); card 14060 went from 1 to 45 columns; card 24111 went from 3 to 65 columns. Additionally, 170 categorical value format definitions (1,088 value codes) were extracted from `formatses.sas` and linked to specific card fields where possible (120 validated format-to-field links). The SAS enrichment was validated against the existing data: zero duplicate rows were introduced, and initial false-positive value code assignments (from naive substring matching) were identified and corrected using word-boundary matching.

---

## 5. Known Limitations and Caveats

### Data Scope

- **Breastfeeding is NURSERY feeding only.** The variables `bf_days` and `bf_ever` capture feeding during the first 0-8 days of life in the hospital nursery, not long-term breastfeeding duration. In the 1960s United States, nursery breastfeeding was more common among lower-SES and Black mothers -- the opposite of modern patterns. This creates a reversed confounding structure where the raw breastfeeding-IQ association is negative.

- **No maternal IQ.** Unlike the CNLSY (which provides maternal AFQT), the CPP does not include a direct measure of maternal cognitive ability.

- **Historical data conventions.** The data use 1960s coding conventions and racial categories of the era (White, Negro, Oriental, Puerto Rican). Researchers should be aware of the historical context when interpreting these categories.

### Data Quality

- **CPPMASTER field names are OCR-generated.** Many card-level field names were derived from OCR of the original codebook microfilm. In v3.1, 5,222 additional field entries were added from JHU SAS program definitions, of which 44.5% have human-readable labels and 55.5% have only raw SAS variable names (e.g., `f05a1406`). While we have verified the most research-critical fields (cognitive scores, demographics, feeding), some field names in less commonly used cards may be imprecise.

- **Re-parsed card data coverage.** In v3.1, all 309 card CSVs were re-parsed using the SAS-enriched codebooks, expanding from ~7,600 to 13,154 named columns. In v3.2, the `cpp_comprehensive.csv` and `cpp_unified_wide.rds` files were rebuilt from these re-parsed CSVs, and 20 single-row standalone datasets were merged into the unified file. Columns with <1% coverage were moved to supplementary side-sheets, and 1,036 confirmed byte-position duplicate columns were removed. Some cards may still have fields in their raw `card_data` that are not covered by the combined OCR + SAS codebook entries. The raw data is preserved in the `master/card_XXXXX.csv` files for further extraction if needed.

- **Column count mismatches.** 72 of 309 parsed cards have fewer columns than their codebook specifies. This occurs because the parser merged overlapping fields when the codebook defines fields at the same column positions for different card revisions.

- **All-NA columns.** 169 card types have some columns that are defined in the codebook but contain no data in the actual records. These typically correspond to fields added in later revisions that were never populated, or to optional form sections.

- **Vol V OCR gaps.** Pages 66-90 and 116-140 of Vol V had particularly poor microfilm quality. These sections were re-processed but may contain residual OCR artifacts.

- **WISC VIQ/PIQ resolved in v3.** The v2 `wisc_piq` variable (which correlated r = 0.999 with `wisc_fsiq`) has been identified as the Full Scale Scaled Score, not Performance IQ. The v3 dataset contains the corrected Verbal IQ (cols 49-51, M = 91.9, SD = 13.6), corrected Performance IQ (cols 54-56, M = 96.4, SD = 15.0), and Full Scale IQ (cols 60-62, M = 95.6, SD = 14.8). Users of v2 should upgrade to v3 for any analysis involving VIQ or PIQ.

- **Placental weight data entry errors.** 18 values of `placental_wt` fall below 50 grams (minimum = 2g), which is biologically implausible. Normal placental weight ranges from approximately 200-900g. These are likely data entry errors (e.g., recording in different units or transcription mistakes). Consider setting values below 50g to NA.

- **Prior-pregnancy count structural zeros corrected.** The v3.2 exporter converted code 88 ("no prior pregnancy") to missing in `parity`, `prior_perinatal_loss`, and `prior_livebirths`. The corrected rule maps 88 to zero and retains 99 as unknown, restoring 16,054, 16,163, and 16,157 values, respectively. See `ERRATA.md`.

- **Consanguinity code 8 = "not ascertained."** The `consanguinity` variable has 42,498 cases with code 8, which means the item was not ascertained (unknown), not that consanguinity was assessed and found absent. Only codes 0 (none), 1 (first cousin or closer), and 2 (distant) represent substantive assessments.

- **Cigarettes per day special codes.** The `cigs_per_day` variable contains special codes: 61 = "61 or more" (ceiling, N=14), 70 = "less than one per day, regular" (N=550), and 80 = "irregular smoker" (N=479). These must be recoded before use as a continuous variable. For dose-response analyses, codes 70 and 80 can be set to 0.5 (sub-daily) or handled as a separate category.

- **Outcome group edge cases.** Six children have IQ scores (Stanford-Binet or WISC) but `outcome_grp` ≠ 3 ("Survived"). These likely reflect data entry errors in the outcome coding; the children were clearly alive at testing.

- **WISC Verbal IQ and verbal subtest sum (v3).** In the corrected v3 dataset, `wisc_verb_sum` (Information + Comprehension + Vocabulary + Digit Span) correlates r = 0.995 with `wisc_viq`, as expected. The low correlation (r = 0.60) reported in v2 was an artifact of the VIQ/PIQ column misidentification — the v2 `wisc_viq` variable was actually Performance IQ.

### Attrition

- **Follow-up rates vary by site and demographic group.** Among 53,724 survivors, 71.9% completed the 4-year Stanford-Binet and 75.4% the 7-year WISC. However, site-level WISC completion ranges from 28% to 91%. Follow-up was particularly low among Oriental (37%) and Puerto Rican (39%) subsamples.

- **Minimal SES-based differential attrition.** Cohen's d = 0.04 for education and d = -0.02 for SEI between completers and non-completers, indicating that SES-based attrition bias is small at the overall sample level.

### Family Structure

- **Twin sample is moderate.** Approximately 450 twin pairs have any IQ data; approximately 370 have WISC FSIQ. This limits power for twin-based heritability estimation.

- **Half-sibling detection is imperfect.** The scoring system cannot detect half-siblings when father characteristics are missing or unchanged between pregnancies. It also cannot detect half-siblings who share a father but have different mothers (different mother_ids in the dataset).

- **49 twin pairs remain ambiguous.** Thirty-eight same-sex pairs have intermediate Bayesian posteriors, and 11 have insufficient data for classification. These are assigned R coefficients based on individual posteriors where available or population expectations otherwise.

---

## 6. File Inventory

### Root Directory (`clean/`)

| File | Size | Description |
|------|------|-------------|
| **Tier 1** | | |
| `cpp_clean_core.csv` | 34 MB | Recommended analysis-ready core (59,391 x 185) |
| `cpp_clean_core.rds` | 5.6 MB | Matching R binary with factor labels (59,391 x 185) |
| `cpp_clean_expanded.csv` | 53 MB | Expanded analysis-ready dataset (59,391 x 315) |
| `cpp_clean_expanded.rds` | 8.7 MB | Matching expanded R binary (59,391 x 315) |
| `cpp_clean_v2.csv` | 20 MB | Legacy v2 dataset (59,391 x 107) — VIQ/PIQ mislabeled |
| `cpp_clean_v2_full.csv` | 23 MB | Legacy v2, full version with raw values (59,391 x 132) |
| `cpp_clean_v2.rds` | 4.2 MB | Legacy v2, R binary with factor labels (59,391 x 132) |
| `cpp_clean_v2_codebook.csv` | 10 KB | Codebook for the v2 variables |
| **Tier 2** | | |
| `cppvar_all_columns.csv` | 164 MB | Full CPPVAR extraction (59,391 x 1,236) |
| `CPP_Codebook.csv` | 278 KB | Publication-quality codebook (1,239 entries) |
| `cppvar_codebook.csv` | 208 KB | Raw auto-parsed codebook (1,140 entries) |
| **Tier 3** | | |
| `CPPMASTER_Data_Dictionary.csv` | 2.5 MB | 16,295 field data dictionary (8,050 OCR + 8,245 SAS) |
| `CPPMASTER_Form_Guide.csv` | 23 KB | 52-form guide |
| `CPPMASTER_Codebook.csv` | 588 KB | 6,280+ field codebook |
| `master_all_cards_index.csv` | 9 KB | Card metadata (309 types) |
| `vol3b_crossref.csv` | 70 KB | CPPVAR-to-CPPMASTER cross-reference (906 mappings) |
| `vol3b_card_mapping.csv` | 3 KB | Card number mapping |
| `cpp_comprehensive.csv` | 1.4 GB | All cards merged wide (60,010 x 7,077) |
| `cpp_comprehensive_codebook.csv` | 886 KB | Comprehensive file codebook |
| `cpp_comprehensive_supplementary.csv` | -- | Supplementary cols (<1% coverage, 60,010 x 2,806) |
| **Tier 4** | | |
| `cpp_unified_wide.rds` | 114 MB | All cards + standalone merged per linkage ID (60,016 x 4,862) |
| `cpp_unified_wide.csv` | -- | Same as above, CSV format (60,016 x 4,862) |
| `cpp_unified_manifest.csv` | 288 KB | Variable manifest documenting all 4,862 columns |
| `cpp_unified_supplementary.rds` | 2.9 MB | Supplementary columns (<1% coverage, 11,768 x 2,535 including ID; 2,534 data fields) |
| `cpp_unified_supplementary.csv` | -- | Same as above, CSV format |
| `cpp_unified_supplementary_codebook.csv` | -- | Codebook for supplementary variables (2,534 entries) |
| `cpp_columns_dropped.csv` | -- | Log of 3,150 removed columns with reasons |
| **Tier 5** | | |
| `cpp_kinship_links.csv` | 1.8 MB | 14,208 pairwise kinship links |
| `cpp_twin_zygosity.csv` | 115 KB | 640 twin pair zygosity classifications |
| `cpp_twin_pathology_linkage.csv` | -- | Twin-specific placental pathology (1,106 children x 133 cols) |
| **Tier 6** | | |
| `cpp_growth_trajectories.csv` | 24 MB | 755,739 longitudinal measurements |
| `cpp_growth_velocity.csv` | 5.6 MB | Growth gains between ages |
| `cpp_birthweight_zscores.csv` | 2.1 MB | Birth weight z-scores |
| `cpp_birthweight_reference.csv` | 2 KB | Internal BW reference curves |
| `cpp_hc_zscores.csv` | 9.0 MB | Head circumference z-scores |
| `cpp_hc_reference.csv` | 700 B | HC reference curves |
| `cpp_g_factors.csv` | 14 MB | 10 g-factor scores |
| `cpp_g_loadings.csv` | 5.4 KB | Factor loadings |
| `cpp_cognitive_scores.csv` | 11 MB | Raw + z-scored cognitive measures |
| `cpp_cognitive_loadings.csv` | 179 B | PCA loadings |
| `cpp_sb_items.csv` | 1.7 MB | SB item-level data |
| `cpp_sb_items_reconstructed.csv` | 2.1 MB | SB items with basal/ceiling |
| `cpp_item_scores.csv` | 3.3 MB | Developmental battery scores |
| `cpp_item_scores_codebook.csv` | 1 KB | Battery scores codebook |
| `cpp_ses_detailed.csv` | 4.0 MB | Detailed SES |
| `cpp_attrition_analysis.csv` | 3 KB | Attrition documentation |
| `cpp_disability_discordance.csv` | 5.0 MB | Disability criteria + flags |
| `cpp_discordant_pairs.csv` | 1.1 MB | Discordant sibling pairs |
| `cpp_weights.csv` | -- | Survey weights (17 columns, 4 schemes) |
| `cpp_weights_codebook.csv` | -- | Weight variable codebook |
| `cpp_multirow_XXXX.csv` | varies | 26 multi-row card types |
| **Distribution** | | |
| `SAS_Variable_Catalog.csv` | 1.1 MB | 5,851 unique SAS variable definitions from 24 programs |
| `SAS_Value_Labels.csv` | 32 KB | 1,088 value codes across 170 categorical formats |
| `SAS_Value_Labels_Reference.txt` | 28 KB | Human-readable value label reference |
| `SAS_Format_Field_Linkage.csv` | 14 KB | 120 validated format-to-field links |
| `CPP_Variable_Inventory.csv` | -- | Complete variable accounting (all sources) |
| `cppvar_sentinel_guide.csv` | -- | Sentinel value guide for 56 affected CPPVAR variables |
| `CPPMASTER_Quality_Notes.csv` | -- | Quality notes for card parsing issues |
| `OCR_Quality_Notes.csv` | -- | OCR quality assessment per volume |
| **Distribution** | | |
| `CPP_Data_Release.zip` | -- | Compressed archive of the complete data release |

### Subdirectories

| Directory | Contents |
|-----------|----------|
| `master/parsed/` | 309 parsed card CSVs + 309 companion field files (618 files) |
| `master/card_codebooks/` | 312 per-card codebook CSVs |
| `master/` | 309 raw card CSVs + card index |
| `standalone/` | 31 standalone dataset CSVs + 32 companion field files (63 files) |
| `archive/` | Legacy v1 files and intermediate outputs |

### OCR Directory (`ocr/`)

| File | Size | Description |
|------|------|-------------|
| `vol1_ocr.txt` | 256 KB | Vol I overview and user's guide |
| `vol2a_ocr.txt` through `vol2j_ocr.txt` | 168-597 KB each | Form reproductions (10 sub-volumes) |
| `vol3a_variable_dictionary.csv` | 178 KB | CPPVAR codebook (structured) |
| `vol3b_ocr.txt` | 401 KB | Field derivation methods |
| `vol4_ocr.txt` | 416 KB | Selected work files |
| `vol5_master_index.csv` | varies | CPPMASTER index (structured) |
| `vol6_ocr.txt` | varies | Permuted glossary |
| `vol7_ocr.txt` | varies | Person/time/subject categorization |
| `bibliog_ocr.txt` | 190 KB | Bibliography |
| `index_ocr.txt` | 98 KB | General index |

---

## 7. Citation

If you use this dataset, please cite the original CPP investigators and sponsoring institute:

> Niswander, K. R., & Gordon, M. (1972). *The Women and Their Pregnancies: The Collaborative Perinatal Study of the National Institute of Neurological Diseases and Stroke.* Philadelphia: W. B. Saunders.

And the NBER data archive:

> National Collaborative Perinatal Project. Data archived at the National Bureau of Economic Research. https://www2.nber.org/CPP/

### Key Publications

- Broman, S. H., Nichols, P. L., & Kennedy, W. A. (1975). *Preschool IQ: Prenatal and Early Developmental Correlates.* Hillsdale, NJ: Erlbaum.
- Broman, S. H., Nichols, P. L., Shaughnessy, P., & Kennedy, W. (1987). *Retardation in Young Children.* Hillsdale, NJ: Erlbaum.
- Hardy, J. B. (2003). The Collaborative Perinatal Project: Lessons and legacy. *Annals of Epidemiology*, 13(5), 303-311.
- Myrianthopoulos, N. C. (1975). An epidemiologic survey of twins in a large, prospectively studied population. *American Journal of Human Genetics*, 27(2), 158-165.
- Myrianthopoulos, N. C., & French, K. S. (1968). An application of the U.S. Bureau of the Census socioeconomic index to a large, diversified patient population. *Social Science & Medicine*, 2(3), 283-299.
- Rogan, W. J., & Gladen, B. C. (1993). Breast-feeding and cognitive development. *Early Human Development*, 31(3), 181-193.

---

## 8. Study Sites

The CPP enrolled participants at 12 university-affiliated medical centers across the United States. The sites were selected to provide geographic, racial, and socioeconomic diversity.

| Code | Institution | City | N Children | Notes |
|------|-------------|------|------------|-------|
| 05 | Boston Lying-In Hospital (Harvard Medical School, Children's Hospital Medical Center) | Boston, MA | 13,737 | Largest site; approximately 23% of total enrollment |
| 10 | Children's Hospital of Buffalo (University of Buffalo) | Buffalo, NY | 2,985 | |
| 15 | Charity Hospital of Louisiana (Tulane University, Louisiana State University) | New Orleans, LA | 2,634 | Predominantly Black patient population |
| 31 | Columbia University College of Physicians and Surgeons (Columbia Presbyterian Medical Center) | New York, NY | 2,262 | Smallest site |
| 37 | Johns Hopkins Hospital (Johns Hopkins University School of Medicine) | Baltimore, MD | 4,438 | |
| 45 | Medical College of Virginia (Virginia Commonwealth University) | Richmond, VA | 3,477 | |
| 50 | University of Minnesota Hospital | Minneapolis, MN | 3,321 | Predominantly White patient population |
| 55 | New York Medical College (Metropolitan Hospital) | New York, NY | 4,753 | Substantial Puerto Rican enrollment |
| 60 | University of Oregon Medical School | Portland, OR | 3,473 | |
| 66 | University of Pennsylvania (Pennsylvania Hospital, Children's Hospital of Philadelphia) | Philadelphia, PA | 10,458 | Second-largest site |
| 71 | Providence Lying-In Hospital (Brown University Child Study Center) | Providence, RI | 4,184 | |
| 82 | University of Tennessee College of Medicine (Gailor Hospital) | Memphis, TN | 3,669 | |
| | **Total** | | **59,391** | |

Enrollment began in 1959 and continued through 1966. Follow-up assessments were conducted from birth through 1974 (age 7-8 for the latest enrollees). Follow-up rates varied substantially by site, ranging from 28% to 91% for the age-7 WISC assessment.

---

## 9. Sample Characteristics

### Sample Sizes by Key Measure

| Measure | N | % of Total |
|---------|---|------------|
| Total children | 59,391 | 100% |
| Stanford-Binet IQ (age 4) | 38,653 | 65.1% |
| WISC Full Scale IQ (age 7) | 40,494 | 68.2% |
| Nursery feeding data (PED-3) | 47,042 | 79.2% |
| Birth weight | 55,535 | 93.5% |
| Gestational age | 55,676 | 93.7% |
| Sex of child | 55,923 | 94.2% |

### Demographics

| Variable | N | Mean | SD |
|----------|---|------|-----|
| Birth weight (grams) | 55,535 | 3,108 | 636 |
| Gestational age (weeks) | 55,676 | 39.0 | 3.7 |
| Maternal age (years) | 59,389 | 24.3 | 6.1 |
| Education (years) | 56,460 | 10.6 | 2.6 |
| Socioeconomic Index (0-9.5) | 55,934 | 4.69 | 2.17 |

### Racial Composition

| Race | N | % |
|------|---|---|
| White | 27,753 | 46.7% |
| Black | 27,241 | 45.9% |
| Oriental | 263 | 0.4% |
| Puerto Rican | 3,824 | 6.4% |
| Missing | 310 | 0.5% |

### Cognitive Test Means

| Test | N | Mean | SD |
|------|---|------|----|
| Stanford-Binet IQ (age 4) | 38,653 | 97.1 | 16.6 |
| WISC Full Scale IQ (age 7) | 40,494 | 95.6 | 14.8 |
| WISC Verbal IQ (age 7, v3 corrected) | 40,260 | 91.9 | 13.6 |
| WISC Performance IQ (age 7, v3 corrected) | 40,173 | 96.4 | 15.0 |

### Family Structure

| Category | Families | Children |
|----------|----------|----------|
| All enrolled | 48,197 | 59,391 |
| Singleton families (1 child) | 39,425 | 39,425 |
| Sibling families (2+ children) | 8,772 | 19,966 |
| Twin pairs | 640 | 1,254 |
| Triplet sets | 6 | 18 |
| Quadruplet sets | 1 | 4 |

---

## 10. Common Pitfalls

1. **Nursery feeding is NOT long-term breastfeeding.** `bf_days` captures only the first few days of life in the hospital nursery. Long-term breastfeeding duration (months) is not available in the standard data files.

2. **Sex = 3 means fetal loss.** 804 records with `sex=3` are early fetal losses (mean birth weight 1,891g, gestational age 16.3 weeks), not live births with ambiguous sex. Exclude these from live-birth analyses.

3. **Leading zeros in IDs.** `case_id` is 9 digits, `mother_id` is 7 digits. When reading CSV files, read these as character/string to preserve leading zeros: `fread("cpp_clean_core.csv", colClasses = c(case_id = "character"))`.

4. **WRAT is on card 31300, not in CPPVAR.** The WRAT scores come from the master file. Use columns 43-44 of card 31300 for the cognitively-loaded Reading score, NOT columns 41-42 (which is a grade rating with r(FSIQ) approximately 0).

5. **Two codebook files.** `CPP_Codebook.csv` (1,239 entries) is the curated, publication-quality version -- use this one. `cppvar_codebook.csv` (1,140 entries) is the raw auto-parsed version, retained for reproducibility.

6. **No maternal IQ.** Unlike the CNLSY, the CPP does not include a direct measure of maternal cognitive ability.

7. **Auditory-Vocal Association is not independent.** This variable correlates r = 0.996 with WISC Verbal IQ. It is essentially a prorated verbal score, not an independent measure. Do not use it alongside WISC VIQ in the same model.

8. **Bender Gestalt is positively scored.** Higher values mean better performance (accuracy/developmental score), not more errors. Do not reverse-score it.

9. **Feeding patterns are historically inverted.** In the 1960s CPP population, nursery breastfeeding was more common among lower-SES and Black mothers. The raw breastfeeding-IQ association is negative, not positive.

10. **Site variation in follow-up.** WISC completion ranges from 28% to 91% across sites. Site-level analyses should account for differential attrition.

11. **Legacy v2 WISC VIQ/PIQ are mislabeled.** In the historical v2 dataset, `wisc_viq` is actually Performance IQ and `wisc_piq` is actually the Full Scale Scaled Score (hence r = 0.999 with FSIQ). The current `cpp_clean_core` and `cpp_clean_expanded` datasets correct this: `wisc_viq` is true Verbal IQ (r = 0.995 with verbal subtest sum), `wisc_piq` is true Performance IQ (r = 0.888 with FSIQ), and `wisc_fs_scaled` is the Full Scale Scaled Score. Use a current semantic-name asset for analyses involving VIQ or PIQ.

12. **Parity ≠ birth order.** `parity` counts prior non-aborted pregnancies reaching at least 20 weeks. In corrected files, raw code 88 ("no prior pregnancy") is zero and 99 is missing. Use `prior_livebirths + 1` for observed live-birth order or `prior_preg + 1` for pregnancy order; these variables are not interchangeable.

13. **Cigarettes per day has special codes.** Values 70 and 80 in `cigs_per_day` mean "less than one per day" and "irregular smoker," not 70 or 80 cigarettes. Recode these before any continuous analysis.

14. **Placental weights under 50g are errors.** 18 records have `placental_wt` values below 50g (minimum 2g). These are data entry errors. Filter or set to NA.

15. **Twin pathology in `nichd_mother_path` is pregnancy-level only.** The integrated `nichd_mother_path` file stores placental pathology at the pregnancy level (plurality = 9), coalescing twin-pair records into one row. For twin-specific pathology, use either: (a) the c1201_/c1202_/c2201_ columns in `cpp_unified_wide`, which are now populated for twin children (v3.3+), or (b) `cpp_twin_pathology_linkage.csv` for a dedicated twin pathology file with clean SAS field names, an MVM-relevant flag, and a companion codebook. Coverage in unified_wide: c1201_ = 953 twins, c2201_ = 940 twins, c1202_ = 1,020 twins. Coverage in linkage table: 1,114 twins (411 complete pairs).

---

*Version 3.3.1 is a correction release. It restores prior-pregnancy structural zeros, standardizes the expanded clean-file schemas and identifiers, and coalesces 2,421 source-proven unified-file ID-alias groups. It also retains the twin-specific placental pathology linkage prepared in March 2026. Version 3.0 corrected the WISC VIQ/PIQ column identification and added 51 variables from the 7-year psychological battery. Version 3.1 added SAS-program enrichment and a full re-parse of 309 card CSVs. Version 3.2 rebuilt the unified and comprehensive wide datasets, merged 20 single-row standalone datasets, moved sparse columns to supplementary side-sheets, removed byte-position duplicate columns, fixed trailing-colon name artifacts, parsed SOCIO7YR, and supplied unified CSV and RDS formats. Processing scripts, validation logs, errata, and checksums are bundled with the data files.*
