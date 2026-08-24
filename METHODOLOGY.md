# CPP Data Release: Technical Methodology

**Version 2.0** | February 2026

This document provides a technical companion to the Release Notes. It describes the data processing pipeline, quality assurance procedures, family structure construction, derived variable computation, and error corrections in sufficient detail for reproduction or audit.

---

## 1. Source Data Description

### CPPVAR: The Variable File

`CPPVAR.ASC` is a fixed-width ASCII file containing 59,391 records, each exactly 1,600 characters wide, with no headers, delimiters, or metadata. Each record represents one child/pregnancy. The file was produced in the 1970s by the National Institute of Neurological Diseases and Stroke (NINDS) as a summary extraction from the original assessment forms. Variables are packed into specific column positions as documented in Volume III-A of the CPP codebook. Item numbers range from 4954 to 6180.

The first 9 characters encode a hierarchical case identifier:
- Columns 1-2: Institution code (12 sites)
- Column 3: Selection code
- Columns 4-7: Gravida number (identifies the mother)
- Column 8: Pregnancy order
- Column 9: Check digit / plurality code (see below)

The combination of columns 1-7 forms the `mother_id` (for sibling linkage), and all 9 columns form the `case_id` (unique per child).

**Check digit convention.** The 9th digit of the case identifier serves dual roles. In CPPVAR, singletons are encoded with digit 0 and multiple births with digits 1-4 to distinguish siblings within a pregnancy. In CPPMASTER clinical card records, singletons are encoded with digit 9 rather than 0. The unified merge normalizes all check digit 9 to 0 before joining (see Section 6, Error Correction 5).

**Provenance.** The file was obtained from the NBER CPP archive at `https://www2.nber.org/CPP/`. An identical copy exists at the National Archives and Records Administration (NARA). File size: 91 MB. Character encoding: ASCII.

### CPPMASTER: The Master File

`CPPMASTER.ASC` is a fixed-width ASCII file containing 6,107,562 records, each exactly 80 characters wide (standard IBM punch card width). Each record corresponds to a single punch card from an individual assessment form, containing a subset of the form's fields. The file preserves the original card-level data entry structure.

Record layout:
- Columns 1-5: Card type number (5-digit code encoding the card identity)
- Columns 6-14: Case identifier (9-digit, same format as CPPVAR)
- Columns 15-80: Data payload (66 characters)

The 5-digit card type number encodes the card's identity in a structured scheme: digit 1 is the sequence number (for multi-card forms), digit 2 is the subject area (0=admin, 1=psychology, 2=pathology, 3=obstetrics, 4=pediatrics, 5=family/SES, 8=special), digits 3-4 are the form number, and digit 5 is the revision number. For example, card 21300 is sequence 2 of psychology form 13, revision 0 -- the second card of the 7-year WISC examination.

The file contains 309 distinct card types across the seven subject areas. A single child's records may span dozens of card types covering different ages and assessment domains.

**Provenance.** Same as CPPVAR. File size: 478 MB.

### Standalone Files

The NBER CPP JH (Johns Hopkins) collection contains 35 standalone NARA ASCII files that were distributed separately from CPPVAR and CPPMASTER. These files contain data not available in the main files, including viral serology titers, drug exposure records, clinical visit logs, congenital malformation summaries (with Myrianthopoulos zygosity and father number fields), rupture of membranes data, socioeconomic indices, abnormality summaries, and speech/language/hearing scores. Accompanying the NARA files are 61 NICHD form files and 35 SAS read-in programs that document column layouts.

Thirty-one of these standalone datasets were parsed (totaling 1,475,442 records). Each has a companion `_fields.csv` documenting column positions and labels derived from the SAS programs or positional extraction.

### Original Documentation

The CPP documentation comprises 7 main volumes, 10 form-reproduction sub-volumes, a bibliography, and an index (approximately 5,000 pages total):

| Volume | Title | Pages | Content |
|--------|-------|-------|---------|
| I | Introduction and User's Guide | 136 | Study design, data structure overview |
| II (a-j) | Form Reproductions | 2,507 | Facsimiles of all original data collection forms |
| III-A | Variable File Dictionary | 207 | Column-by-column CPPVAR codebook |
| III-B | Variable File Field Derivation Methods | 681 | How each CPPVAR variable was derived from CPPMASTER cards |
| IV | Selected Work Files | 336 | Documentation for standalone datasets including CONGMALF |
| V | Master Index to Computerized Data Items | 290 | Field-level index for CPPMASTER cards |
| VI | Alphabetical Permuted Glossary | 312 | Keyword-searchable variable index |
| VII | Categorization by Person, Time, Subject | 685 | Variables organized by person (mother/child), time, and topic |

All documentation was available only as low-quality scanned microfiche PDFs hosted by NBER.

---

## 2. Parsing Pipeline

### Step 1: OCR of Documentation Volumes

All documentation PDFs were rendered to PNG images at 200 DPI using PyMuPDF (fitz). Each page image was processed with Tesseract 5.4.0 using page segmentation mode 6 (uniform text block).

The two highest-priority volumes received additional processing:

**Volume III-A (CPPVAR codebook):** Processed in 10 AI-assisted OCR batches. Each batch produced pipe-delimited text with fields: item_id, col_from, col_to, varname, label, description, type, codes, missing_codes. The OCR output required handling multiple format variations across batches (differences in field ordering, continuation entries spanning page breaks, inconsistent notation for value codes). The Python parser `parse_vol3a_to_dictionary.py` normalized these formats, merged continuation entries, and deduplicated overlapping records, producing a consolidated variable dictionary of 1,233 entries.

**Volume V (CPPMASTER index):** Processed in 12 AI-assisted OCR batches and consolidated by `ocr/consolidate_vol5.py` into a master index of 7,590 item entries across 286 card types. Each entry specifies the item number, source card type, column positions within the card, and field description. This index was used to construct per-card field-level codebooks.

### Step 2: CPPVAR Extraction

Using the structured Vol III-A codebook, the R script `extract_all_cppvar.R` performs a single-pass extraction:

1. Read all 59,391 lines of CPPVAR.ASC
2. For each of the 1,236 documented columns, apply `substr()` to extract the field at the documented column positions
3. Assign variable names generated from codebook descriptions
4. Write the result as `cppvar_all_columns.csv`

A separate script (`create_codebook.py`) enhances the raw auto-parsed codebook by adding human-readable labels, topical section assignments, and type classifications, producing the publication-quality `CPP_Codebook.csv` with 1,239 entries (the increase from 1,233 to 1,239 reflects the addition of sub-entries for multi-column fields that span distinct semantic items).

### Step 3: CPPMASTER Card Extraction

The R script `extract_all_master_cards.R` performs a single-pass scan of the 6.1-million-record master file:

1. Read all lines of CPPMASTER.ASC
2. For each line, extract the 5-digit card type from columns 1-5
3. Extract the 9-digit case identifier from columns 6-14
4. Extract the 66-character data payload from columns 15-80
5. Route each record to the appropriate card-type output file

This produces 309 individual card CSVs (one per card type), each containing two columns: `case_id` and `card_data` (the raw 66-character string). An index file records the record count per card type.

### Step 4: Card Codebook Construction

Per-card field-level codebooks were assembled from four sources, applied in order of priority:

**Source 1: Volume V master index (112 card types, 4,692 fields).** The consolidated Vol V OCR was matched to the 309 extracted card types. The Python script `build_master_codebook.py` parsed each Vol V entry to determine the card type, field position within the card, and field name. For each matched card, a codebook CSV was generated specifying: data_id, data_col_from, data_col_to, item_name.

**Source 2: Volume III-B cross-reference (112 card types, 1,009 fields).** The OCR'd Vol III-B documents how each CPPVAR variable was derived from CPPMASTER source cards. The Python script `parse_vol3b.py` parsed these derivation descriptions to extract card type numbers and column positions, producing additional codebook entries for cards not covered by Vol V.

**Source 3: Sequence variant recovery (33 card types).** Many forms have multiple sequence variants (e.g., cards 11200, 21200, 31200, 41200 for the four-card Stanford-Binet). When one sequence variant has a codebook but another does not, `recover_sequence_cards.py` recovers the missing codebook by copying field definitions from the sibling card with appropriate column-offset mapping.

**Source 4: SAS read-in programs (52 card types).** The 35 SAS programs in the NBER JH collection contain definitive INPUT statements specifying variable names and column positions for all CPP forms. These programs resolved all remaining undocumented card types, achieving 100% codebook coverage across all 309 card types.

### Step 5: Card Parsing

The Python script `parse_master_cards.py` parses each raw card CSV into a proper CSV with named columns:

1. Load the per-card codebook
2. Sort fields by position, deduplicate overlapping fields (keeping the first definition)
3. For each record, apply string slicing to extract each field from the 66-character data payload
4. Write the result as `card_XXXXX_parsed.csv` with a companion `card_XXXXX_fields.csv`

**Handling multi-revision cards.** When the codebook defines fields at the same column positions for different card revisions, the parser retains the non-overlapping interpretation. The 72 card types with column count mismatches (fewer parsed columns than codebook entries) result from this deduplication.

**Handling multi-row cards.** Twenty-six card types have multiple records per child (e.g., prenatal visits, medication records, lab results). These are distinguished during the comprehensive merge step and output as companion `cpp_multirow_XXXX.csv` files.

### Step 6: Standalone Dataset Parsing

The Python script `parse_standalone_datasets.py` parses 31 standalone ASCII files:

1. For files with accompanying SAS programs, parse the SAS INPUT statement to extract variable names, column positions, and labels
2. For files without SAS programs, use positional column extraction (col_10, col_11, etc.)
3. Always extract the 9-digit NINDB case identifier for linkage
4. Write each dataset as a CSV with a companion `_fields.csv`

The congenital malformations file (CONGMALF.ASC) received additional structured parsing by `parse_congmalf.py`, extracting the 21 one-year malformation recodes, 40 seven-year recodes, Myrianthopoulos zygosity classification (column 178), and father number (column 179) into named fields.

---

## 3. Quality Assurance

### Cross-Validation Against Published Statistics

Extracted variables were validated against published CPP statistics:

- **Birth weight sex difference.** Males (mean approximately 3,270g) heavier than females (mean approximately 3,160g) by approximately 110-120g, matching the expected 100-150g difference and confirming correct column alignment for birth weight.
- **IQ distributions by race.** WISC Full Scale IQ distributions matched published values from Broman et al. (1975): overall mean approximately 95.6. Stanford-Binet mean approximately 97.1.
- **Twin birth weight penalty.** Twins (mean approximately 2,400g) substantially lighter than singletons (mean approximately 3,200g).
- **Site-level sample sizes.** Record counts per institution matched published enrollment figures across all 12 sites.
- **Smoking prevalence.** 46.7% smokers, consistent with 1960s population rates.
- **Racial composition.** White 46.7%, Black 45.9%, Oriental 0.4%, Puerto Rican 6.4%, matching known CPP enrollment patterns.

### Internal Consistency Checks

- **IQ score distributions.** Both SB and WISC IQ distributions are unimodal, approximately normal, with means near 100 and SDs of 14-17, as expected for standardized IQ tests.
- **Birth weight range.** Valid values span 200-6,237g, consistent with the full range from extreme prematurity to macrosomia.
- **Gestational age distribution.** Mode at 40 weeks with expected left tail of preterm deliveries.
- **Apgar scores.** Five components (heart, respiratory, tone, reflex, color) each coded 0-2, summing to 0-10, with a strong mode at 8-10 as expected for a general obstetric population.

### WISC-Derived Variable Detection

Several variables on card 21300 (the WISC examination card) were suspected of being derived from WISC subtests rather than independent measures. Detection methodology:

1. Compute pairwise correlations between all cognitive variables on card 21300
2. Flag any variable with r > 0.95 against a known WISC composite
3. Fit linear regression predicting the suspect variable from WISC subtests
4. If R-squared > 0.95, classify as WISC-derived

Results:
- **Auditory-Vocal Association** (cols 33-34): r = 0.996 with WISC VIQ; R-squared = 0.992. This is a prorated verbal sum, not an independent test.
- **Tactile Finger Recognition** (cols 33-34 under different codebook label): r = 1.000 with WRAT Reading Raw. These are identical column positions under different documentation labels.
- **WRAT-labeled fields on card 21300** (cols 47-49): r approximately 0.99 with WISC verbal subtests. These are prorated verbal sums, not WRAT scores. Actual WRAT data is on card 31300.

### WRAT Field Boundary Verification

On card 31300, the WRAT Reading field presented an ambiguity between columns 41-42 and columns 43-44. Verification:

1. Extract both candidate fields
2. Compute correlation of each with WISC FSIQ
3. Columns 41-42: r approximately 0.0 with FSIQ -- coded grade rating, not cognitively loaded
4. Columns 43-44: r approximately 0.55 with FSIQ -- consistent with a reading achievement score

The OCR of Vol V confirmed that columns 43-44 contain the raw Reading score, while columns 41-42 contain a grade-level rating. The clean dataset uses columns 43-44.

---

## 4. Family Structure Construction

### Mother ID Linking

Children sharing the same 7-digit mother_id (columns 1-7 of the case identifier: institution + selection + gravida) are identified as offspring of the same mother. With 48,197 unique mothers and 59,391 children, 8,772 mothers have two or more children, yielding 19,966 children in sibling families.

### Pregnancy Order Inference

Column 8 of the case identifier encodes pregnancy order (1-9). Within each mother_id group, children are ordered by pregnancy sequence. Birth dates from CPPVAR columns 1103-1108 provide supplementary ordering verification.

### Twin Identification

Twin pairs are identified by three criteria applied conjunctively:
1. Same mother_id (columns 1-7)
2. Same pregnancy order (column 8)
3. Plurality code (column 9) greater than 0

The `birth_switch` variable (column 10: 1=single, 2=twin, 3=triplet, 4=quad) provides additional confirmation. Pairs are formed within each pregnancy group (identical columns 1-8, differing only in column 9).

Result: 640 twin pairs (1,254 twin/multiple-birth children), plus 6 triplet sets (18 children) and 1 quadruplet set (4 children).

### Zygosity Determination

Twin pairs are classified using a five-tier evidence schema, applied sequentially. Later tiers classify only pairs not already resolved by earlier tiers.

**Tier 0: Myrianthopoulos blood group determinations.**
Myrianthopoulos (1975) determined zygosity for CPP twin pairs using a 9-system blood group panel (ABO, Rh, MNSs, Kell, Duffy, Kidd, P, Lewis, Lutheran) tested on cord blood, combined with placental examination. These individual-level classifications were recovered from column 178 of CONGMALF.ASC (1 = MZ, 2 = DZ, 3 = unknown). This tier resolved 504 of 640 pairs (189 MZ definite, 315 DZ definite).

**Tier 1: Definitive biological markers.**
- Opposite-sex pairs not already classified: DZ definite (n=5)
- Monochorionic membrane from pathology card 12022 (column 30): MZ very probable (n=9). Applied before blood types because blood chimerism in monochorionic twins can produce discordant blood types.
- Blood type discordance (ABO from CPPVAR col 1129, Rh from col 1130): DZ definite among remaining same-sex pairs (n=21)

**Tier 2: Strong probabilistic markers.**
- Dichorionic membrane from card 12022: DZ probable (n=38). Approximately 70-80% of dichorionic same-sex pairs are DZ.

**Tier 3: Bayesian developmental trajectory classification.**
The remaining 63 same-sex pairs entered a Bayesian model trained on the 197 known MZ and 341 known DZ pairs from Tiers 0-2. The model integrates four empirically calibrated features:

1. *Wilson developmental trajectory slope* (Cohen's d = 0.56 in training data): Composite slope of standardized intrapair physical differences (weight, height, head circumference) regressed on age. MZ twins converge over development (negative slope), DZ twins diverge (positive slope), following Wilson's (1979) developmental convergence principle.

2. *Late concordance* (d = 1.00): Mean standardized intrapair difference at ages 4 and 7. By school age, the MZ-DZ concordance gap is at its widest.

3. *IQ difference* (d = 0.43): Absolute standardized WISC FSIQ difference. Partially independent of physical concordance.

4. *WISC subtest profile concordance* (d = 0.32): Cosine distance between WISC subtest profiles.

Priors were computed race-specifically using the Weinberg differential method. Classification thresholds: P(MZ) > 0.80 classified as MZ probable (n=10), P(MZ) < 0.20 as DZ probable (n=4). Remaining 38 same-sex pairs and 11 with insufficient data are classified as ambiguous.

**Robustness check.** An elastic net and random forest machine-learning approach using 800+ intrapair phenotypic features achieved AUC = 0.76 with 10-fold cross-validation, confirming that the simpler Bayesian model captures most of the discriminative signal available from phenotypic data alone.

### Sibling Classification

Non-twin sibling pairs (same mother, different pregnancies) are classified as full siblings or half-siblings using an 11-indicator scoring system across four tiers:

**Scoring:**
| Evidence | Points | Tier |
|----------|--------|------|
| Different CONGMALF father number | +8 | 0 |
| Same CONGMALF father number | -3 | 0 |
| v417 trajectory increase (later child gained half-sibs) | +3 | 1 |
| Father race change | +5 | 2 |
| Father birthplace change | +4 | 2 |
| Father age anomaly (inconsistent with same father) | +3 | 2 |
| Education jump of 5+ years | +2 | 3 |
| Father occupation change | +2 | 3 |
| Marital status changes count increase | +2 | 3 |
| Marital status change | +1 | 3 |
| Father at-home status change | +1 | 3 |
| Father race match | -2 | (same-father evidence) |
| Father age consistent | -1 | (same-father evidence) |
| Father education similar (<2yr difference) | -1 | (same-father evidence) |
| Both children v417 = 0 | -1 | (same-father evidence) |

**Thresholds:** Score >= 3 classified as half_sibling (R = 0.25). Score <= -2 classified as full_sibling (R = 0.50). Intermediate scores classified as ambiguous_sibling (R = 0.375).

Result: 10,948 full-sibling pairs, 1,457 half-sibling pairs, 1,163 ambiguous.

**ABO Mendelian exclusion diagnostic.** Applied to 10,879 sibling pairs with complete blood type data (mother ABO + both children ABO). Identified 32 pairs where no single father genotype could produce both children. However, all 32 involved impossible mother-child combinations (type O mother with AB child, or AB mother with type O child) -- serological errors, not evidence of different paternity. The base rate of such impossible combinations (0.14% of 50,201 trios) is consistent with the known approximately 0.1% per-test error rate in 1960s laboratories. No reclassifications were applied.

**IQ validation.** Full siblings r = 0.56 (n=7,330), half-siblings r = 0.35 (n=926), ambiguous r = 0.45 (n=614). The half-sibling correlation is higher than the theoretical approximately 0.22, likely reflecting shared maternal environment and assortative mating.

---

## 5. Derived Variable Construction

### g-Factor Extraction

Ten g-factor scores were computed using three methods (PCA, PAF, CFA) across four variable sets, plus an IRT-based score on Stanford-Binet items.

**Variable sets:**
- Set A (4 variables): WISC Information, Comprehension, Vocabulary, Digit Span (scaled scores)
- Set B (5 variables): Set A + Similarities (raw score)
- Set C (7 variables): Set A + WRAT Reading, Bender Gestalt (reversed), Auditory-Vocal Association
- Set D (10 variables): Set C + Similarities raw, WRAT Spelling, Conceptual Style Test, Embedded Figures

**Methods:**
- *PCA*: First principal component, varimax rotation omitted (single-factor extraction). Scores computed using complete-case analysis with R `prcomp()`.
- *PAF*: Principal axis factoring via R `psych::fa()` with single factor. Scores via regression method.
- *CFA*: Single-factor confirmatory model via R `lavaan::cfa()` with FIML estimation. Factor scores via regression.

**Quality control:** PAF and CFA on Set C (7 variables, age 7) produced Heywood cases (communalities > 1.0 for some variables), indicating model misspecification. These scores (`g_paf_7` and `g_cfa_7`) are flagged in `cpp_g_loadings.csv` and excluded from the recommended set. The corresponding PCA score (`g_pca_7`) does not suffer from this problem and is the recommended age-7 g-factor.

**IRT on Stanford-Binet:** A 2-parameter logistic (2PL) IRT model was fit to 35 reconstructed Stanford-Binet items (Year II through Year IV) using R `mirt::mirt()`. Items below the child's basal level were imputed as passes and items above the ceiling as fails before model fitting. Theta scores (`g_irt_sb_adaptive`) are the recommended age-4 g-factor.

**Inter-method agreement:** PCA, PAF, and CFA scores on the same variable set correlate r > 0.98. Cross-set correlations (e.g., Set A PCA vs. Set C PCA) range from r = 0.90 to 0.99. Age-4 IRT correlates approximately r = 0.70 with age-7 PCA scores.

### Growth Trajectories

Longitudinal weight, height, and head circumference measurements were compiled from multiple CPPMASTER card types spanning birth through age 7. The R script `build_value_adds.R` extracts measurements from:

- Birth: birth weight and length from CPPVAR and neonatal cards
- 4 months: PED-3 nursery history card (14031)
- 8 months: PED-5 pediatric exam
- 1 year: PED-6/PED-12 exam and first-year summary
- 4 years: PED-10 exam
- 7 years: PED-14 neurological exam and growth measurement cards

All weights are harmonized to grams, all lengths to centimeters. The output file (`cpp_growth_trajectories.csv`) is in long format with one row per child per age per measure (755,739 total measurements for 55,443 children).

### Birth Weight Z-Scores

Sex- and gestational-age-adjusted z-scores were computed using internal reference curves:

1. Restrict to live births with valid birth weight and gestational age (weeks 24-46)
2. Stratify by sex
3. Within each sex-GA cell, compute the mean and SD using loess smoothing across GA
4. Z-score = (observed BW - loess mean) / loess SD

The reference curves (`cpp_birthweight_reference.csv`) provide the loess-smoothed means and SDs. The resulting z-scores have mean approximately 0.003 and SD approximately 0.992, confirming appropriate calibration.

### Head Circumference Z-Scores

Age- and sex-specific HC z-scores were computed at 6 measurement ages using the same loess-smoothing approach. Reference curves are provided in `cpp_hc_reference.csv`.

### Disability Measures

Ten disability criteria were defined and computed in `build_disability_discordance.R`:

1. IQ < 70 (on either SB or WISC)
2. CNS defect (from PED-8/PED-12 diagnostic codes)
3. Congenital malformation (from CONGMALF and congenital condition codes)
4. Neuromuscular condition
5. Seizure disorder
6. Cerebral palsy
7. Hearing deficit
8. Visual deficit
9. Speech/language delay
10. Behavioral/developmental concern

Composite flags:
- `disabled_any`: Any one of the 10 criteria (prevalence approximately 33%)
- `disabled_strict`: IQ < 70 plus at least one other criterion (prevalence 2.3%) -- recommended for analyses
- `disabled_severe`: IQ < 50 plus at least one other criterion

### Discordant Sibling Pairs

Sibling and twin pairs discordant on key exposures were identified for natural-experiment designs:

- **Smoking discordance:** One pregnancy with maternal smoking, the other without
- **Breastfeeding discordance:** One child nursery breastfed, the other bottle-fed
- **Birth weight discordance:** Birth weight difference exceeding 500g

---

## 6. Error Corrections

### Error 1: Feeding Variable Label Swap

**Location:** CPPVAR columns 580-581.

**Original documentation (Vol III-A):** Column 580 labeled as "bottle-feeding days," column 581 as "breast-feeding days."

**Evidence for swap:** In the 1960s CPP population, hospital nursery breastfeeding was nearly universal among lower-SES women, while bottle-feeding was the norm among higher-SES white mothers. The empirical distributions at column 580 showed high rates among lower-SES mothers (consistent with breast, not bottle). Cross-validation against the PED-3 nursery card (card 14031), which has independently documented field positions from the Vol V master index, confirmed that column 580 corresponds to breast-feeding days and column 581 to bottle-feeding days.

**Correction:** Labels swapped in the clean dataset. Column 580 is extracted as `bf_days` (breast-feeding), column 581 as `bot_days` (bottle-feeding).

### Error 2: Birth Weight Column Offset

**Location:** CPPVAR columns 1094-1098.

**Original documentation (some secondary sources):** Birth weight at columns 1094-1097.

**Correct position (Vol III-A, Item 5918):** Columns 1095-1098.

**Evidence:** Column 1094 contains the pregnancy outcome group code (Item 5917: 1=fetal death, 2=neonatal death, 3=survived). The expected sex difference in birth weight (males approximately 100-150g heavier) was confirmed only at columns 1095-1098, not at columns 1094-1097.

**Correction:** Birth weight extracted from columns 1095-1098 in the clean dataset.

### Error 3: Column 365 Mislabeling

**Location:** CPPVAR column 365.

**Prior usage:** Referenced as "marital status" in some secondary analyses.

**Correct identity (Vol III-A, p57):** Item 5233, "Occupation, grouped" (1=never worked, 2=white collar, 3=blue collar, 7=welfare, 9=unknown).

**Evidence:** OCR of Vol III-A confirmed that true marital status is at column 36 (Item 4977: 1=single, 2=married, 3=common law, 4=widowed, 5=divorced, 6=separated).

**Correction:** Column 365 extracted as `occupation_cat` in the clean dataset. Column 36 extracted as `marital_status`.

### Error 4: Sex Code 3 Interpretation

**Location:** CPPVAR column 554, value 3.

**Documentation:** "Undetermined" -- ambiguous whether this indicates ambiguous genitalia in live births or sex not ascertained in fetal losses.

**Evidence:** The 804 records with sex=3 have mean birth weight 1,891g and mean gestational age 16.3 weeks. These are early fetal losses (well before viability), not live births with ambiguous sex. Most have outcome codes indicating abortion or fetal death.

**Correction:** Sex=3 documented as "fetal loss, sex undetermined" in the codebook. Excluded from live-birth analyses in the clean dataset (sex filtered to 1=male or 2=female for all IQ and growth analyses).

### Additional Discovery: WISC-Derived Variables on Card 21300

While not a codebook error per se (the column positions are correct), several fields on card 21300 are documented under names suggesting independent cognitive tests but are actually linear functions of WISC subtests:

| Field | Documented Name | Actual Identity | Evidence |
|-------|-----------------|-----------------|----------|
| Cols 33-34 | Auditory-Vocal Association | Prorated WISC Verbal IQ | r = 0.996 with WISC VIQ |
| Cols 35-36 | Bender Gestalt | WISC accuracy/developmental score | r = +0.70 with IQ (positive, not negative as expected for error count) |
| Cols 47-49 | WRAT Reading | Prorated WISC Verbal sum | r approximately 0.99 with verbal subtests |
| Cols 33-34 (alt label) | Tactile Finger Recognition | Same data as WRAT Reading Raw | r = 1.000 (identical column positions) |

These are documented in the clean dataset codebook and the Known Issues section of the main README. Researchers should avoid treating these as independent measures in factor analysis or as separate predictors in regression models.

### WRAT Reading Field Boundary Correction

On card 31300, the WRAT Reading data occupies two adjacent fields:

| Columns | Content | r(WISC FSIQ) |
|---------|---------|--------------|
| 41-42 | Grade-level rating | approximately 0.0 |
| 43-44 | Raw reading score | approximately 0.55 |

The OCR of Vol V confirmed the distinction. The clean dataset extracts columns 43-44 as `wrat_read`. Researchers working with the raw parsed card should be aware that columns 41-42 are not cognitively loaded.

### Error 5: CPPMASTER Check Digit Mismatch

**Location:** Column 9 (9th digit) of the case identifier in CPPMASTER.ASC.

**Discovery:** When merging CPPVAR and CPPMASTER records by case_id, a large number of CPPMASTER records failed to match any CPPVAR row. Investigation revealed that the CPPMASTER encodes case identifiers with a 9th check digit of '9' for clinical card records, while CPPVAR uses '0'. Multiple births use digits 1-4 to distinguish siblings within a pregnancy in both files; the discrepancy affects only singletons.

**Evidence:** Singleton case IDs in CPPVAR end in 0 (e.g., `050100010`), while the corresponding records in CPPMASTER end in 9 (e.g., `050100019`). After normalizing digit 9 to 0, match rates increased from partial to near-complete.

**Correction:** The unified merge pipeline normalizes all check digit 9 values to 0 before joining. This produces a unified dataset of 61,811 children: 59,391 from CPPVAR plus 2,420 additional children found only in CPPMASTER records. These CPPMASTER-only children are predominantly early dropouts who have obstetric and/or pathology card data but were never entered into the CPPVAR summary file.

### Error 6: Prior-pregnancy structural zeros converted to missing

**Location:** CPPVAR Item 4982 (columns 46–47), Item 4983 (columns 48–49), and Item 4984 (columns 50–51).

**Prior release behavior:** The analysis-ready exporter converted both codes 88 and 99 to `NA` in `parity`, `prior_perinatal_loss`, and `prior_livebirths`.

**Correct interpretation:** The original CPPVAR codebook defines 88 as "no prior pregnancy" and 99 as "unknown." For these three event-count variables, no prior pregnancy logically implies a count of zero; it is distinct from an unknown history.

**Correction:** Code 88 is converted to integer 0 and code 99 remains missing. This restores 16,054 structural zeros in `parity`, 16,163 in `prior_perinatal_loss`, and 16,157 in `prior_livebirths`. The exporter contains assertions for all three mappings. `recode_structural_zero_counts.py` repairs already-generated CSV assets by joining to the untouched CPPVAR extraction on `case_id`; `recode_structural_zero_counts_rds.R` performs the binary repair natively and verifies every column value, storage type, factor level, object class, and key after a full read-back.

**ID-format compatibility:** In v3.2, 2,397 CPPVAR records with a blank ninth character were incorrectly left-padded, which shifted the identifier fields. NCPP child cards 00011/00012/00013 and other raw files establish the right-completed form (`eight-character pregnancy prefix + 0`) for cross-source linkage. v3.3.1 accepts raw-blank, legacy left-padded, and right-completed aliases, emits the right-completed nine-digit key, and retains the original blank `plurality`/outcome semantics. Source-specific CONGMALF and SEI7YR aliases are handled only where an exact child-card/CPPVAR crosswalk validates the mapping.

---

## 7. Reproducibility

### Pipeline Execution Order

All scripts are located in the `cpp_data/` directory and should be run from that working directory.

```
 1. ocr_all_volumes.py            -- OCR all PDF documentation volumes
 2. parse_vol3a_to_dictionary.py   -- Parse Vol III-A OCR into structured codebook
 3. ocr/consolidate_vol5.py        -- Parse Vol V OCR into master index
 4. create_codebook.py             -- Build publication-quality CPP_Codebook.csv
 5. extract_all_cppvar.R           -- Extract all CPPVAR columns
 6. extract_all_master_cards.R     -- Extract all 309 card types from CPPMASTER
 7. parse_vol3b.py                 -- Cross-reference Vol 3b, build additional codebooks
 8. recover_sequence_cards.py      -- Recover codebooks for sequence variant cards
 9. build_master_codebook.py       -- Consolidate field-level CPPMASTER codebook
10. parse_master_cards.py --all    -- Parse all cards into named-column CSVs
11. fix_ocr_artifacts.py           -- Clean OCR artifacts
12. enrich_codebook_labels.py      -- Add human-readable labels to codebook
13. export_clean_data_v2.R         -- Build analysis-ready dataset
14. recode_structural_zero_counts.py -- Repair/audit generated CSV assets
15. recode_structural_zero_counts_rds.R -- Repair/audit generated RDS assets
16. update_unified_manifest_structural_zeros.R -- Refresh corrected-field statistics
17. parse_standalone_datasets.py   -- Parse 30 standalone datasets
18. parse_congmalf.py              -- Parse structured CONGMALF file
19. build_zygosity.R               -- Classify twin pair zygosity
20. build_family_links.R           -- Build kinship table
21. build_value_adds.R             -- Growth, BW z-scores, attrition, SES
22. build_multiple_g.R             -- Compute g-factor scores (PCA, PAF, CFA)
23. build_sb_irt_adaptive.R        -- Reconstruct SB items, fit IRT
24. build_item_batteries.R         -- Extract developmental battery scores
25. build_disability_discordance.R -- Build disability criteria and discordant pairs
26. build_comprehensive_csv.R      -- Merge all 309 cards into comprehensive file
27. build_precomputed_vars.R       -- Precompute derived variables
28. clean_g_factors.R              -- Remove pathological PAF-7/CFA-7 scores
29. verify_release.R               -- Final integrity checks
```

### Requirements

- **Python 3.8+** with standard library (csv, os, re)
- **R 4.0+** with data.table (required), psych, lavaan, mirt (for g-factor scripts)
- **Tesseract 5.4+** (for OCR step only)
- **PyMuPDF / fitz** (for PDF rendering step only)
- Source data files: `CPPVAR.ASC` and `CPPMASTER.ASC` in `data/` subdirectory
- Documentation PDFs in `docs/` subdirectory (for OCR step only)
- NBER JH files in `nber_files/` subdirectory (for standalone parsing)

### Integrity Verification

The script `verify_release.R` performs automated integrity checks on all output files, including:
- File existence and expected dimensions for all tiers
- Spot checks on key variables (IQ means, birth weight distributions, site counts)
- Family structure validation (twin counts, sibling family counts)
- Cross-file consistency (case_id counts, variable availability)

---

*This document describes the methods used to produce the CPP data release, version 2.0, February 2026.*
