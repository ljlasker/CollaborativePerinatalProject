# export_clean_data_v2.R — Clean and export expanded CPP variable set
# Inputs: data/CPPVAR.ASC, data/CPPMASTER.ASC (card 21300 for 7-yr WISC)
# Outputs: clean/cpp_clean_v2.csv, clean/cpp_clean_v2_full.csv, clean/cpp_clean_v2.rds
# Key corrections vs v1: col 272=educ_cat not SEI, cols 294-295=SEI,
#   col 303 race codes, cols 580-581 label swap, col 585=vitamin K, col 586=Coombs

library(data.table)

BASE <- "."
out_dir <- file.path(BASE, "clean")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- 1. Parse CPPVAR.ASC ----
cat("\n--- Parsing CPPVAR.ASC ---\n")
cpp_path <- file.path(BASE, "data", "CPPVAR.ASC")
lines <- readLines(cpp_path)
cat(sprintf("  %d records, %d chars wide\n", length(lines), nchar(lines[1])))

cpp <- data.table(
  # ---- Identifiers (cols 1-9) ----
  case_id       = substr(lines, 1, 9),
  institution   = substr(lines, 1, 2),
  selection     = substr(lines, 3, 3),
  gravida_id    = substr(lines, 4, 7),
  preg_order    = substr(lines, 8, 8),
  plurality_raw = substr(lines, 9, 9),               # Item 4955: blank=no child,0=single,1=1st mult,2=2nd mult,3=3rd,4=4th

  # ---- Birth/pregnancy type (cols 10-12, from Vol 3a p17) ----
  birth_switch_raw = substr(lines, 10, 10),           # Item 4956: 1=single,2=twin,3=triplet,4=quad
  repeat_switch_raw = substr(lines, 11, 11),          # Item 4957: 0=no repeat,1=repeat study pregnancy
  repeat_order_raw = substr(lines, 12, 12),           # Item 4958: 0=no repeat,1=first,2=second,3=third+

  # ---- Cohort assignments (cols 13-27) ----
  cohort_1a_raw = substr(lines, 13, 13),              # Item 4959: Cohort I-A (1=presence)
  cohort_1c_raw = substr(lines, 15, 15),              # Item 4961: Cohort I-C (1=presence)
  core_raw      = substr(lines, 17, 17),              # Item 4963: Core (1=core)
  walkin_raw    = substr(lines, 18, 18),              # Item 4964: Walk-in (1=walk-in)

  # ---- Demographics (from Vol 3a) ----
  race_raw      = substr(lines, 303, 303),          # Item 5195: 1=White,2=Negro,3=Oriental,4=Puerto Rican
  patient_status_raw = substr(lines, 304, 304),      # Item 5196: 0=not on rev1, 1=clinic, 2=private
  religion_raw  = substr(lines, 285, 285),            # Item 5183: 1=Protestant,2=Catholic,3=Other,9=Unknown

  # ---- Socioeconomic (from Vol 3a) ----
  educ_yrs_raw  = substr(lines, 270, 271),            # Item 5175: Education of gravida (years, 00-18)
  educ_cat_raw  = substr(lines, 272, 272),            # Item 5176: Education categorized (1-6)
  income_raw    = substr(lines, 273, 274),            # Item 5177: Family income (thousands)
  income_cat_raw = substr(lines, 275, 275),           # Item 5178: Income categorized (1-7)
  housing_raw   = substr(lines, 276, 277),            # Item 5179: Housing density (persons/room × 10)
  sei_raw       = substr(lines, 294, 295),            # Item 5192: Socioeconomic Index (0.0-9.5)
  sei_cat_raw   = substr(lines, 296, 296),            # Item 5193: SEI categorized (1-5)

  # ---- Registration info ----
  reg_date_raw  = substr(lines, 297, 302),            # Item 5194: Registration date (mmddyy)
  birthplace_raw = substr(lines, 278, 278),           # Item 5180: Community size
  birthplace_state_raw = substr(lines, 283, 284),     # Item 5182: State code
  work_status_raw = substr(lines, 269, 269),          # Item 5174: Employment status

  # ---- Registration & pregnancy info (cols 31-58, from Vol 3a pp19-21) ----
  age_group_raw = substr(lines, 33, 33),              # Item 4975: Age grouped (1=10-14,...,8=45-58,9=unk)
  gest_at_reg_raw = substr(lines, 34, 35),            # Item 4976: Gestation at registration (weeks, 01-50, 51/99=unk)
  marital_status_raw = substr(lines, 36, 36),         # Item 4977: 1=single,2=married,3=common law,4=widowed,5=divorced,6=separated,9=unk
  trimester_at_reg_raw = substr(lines, 37, 37),       # Item 4978: 1=01-14wk,2=15-27wk,3=28-50wk,9=unk
  last_prior_outcome_raw = substr(lines, 38, 39),     # Item 4979: Last prior survival (00=no prior,01-07=death timing,99=unk)
  last_prior_bw_raw = substr(lines, 40, 43),          # Item 4980: Last prior birthweight (grams, 0000=no prior,9999=unk)
  prior_preg_raw = substr(lines, 44, 45),             # Item 4981: Prior pregnancies total (00-28,99=unk)
  parity_raw    = substr(lines, 46, 47),              # Item 4982: Parity, prior non-abortions ≥20wks (00-20,88=no prior,99=unk)
  prior_perinatal_loss_raw = substr(lines, 48, 49),   # Item 4983: Prior perinatal deaths (00-07,88=no prior,99=unk)
  prior_livebirths_raw = substr(lines, 50, 51),       # Item 4984: Prior livebirths (00-07,08=8+,88=no prior,99=unk)
  cigs_per_day_raw = substr(lines, 52, 53),           # Item 4985: Cigarettes/day now (00=none,01-60,61=61+,70=reg<1/day,80=irreg<4/mo,99=unk)
  smoker_raw    = substr(lines, 54, 54),              # Item 4986: Smoking status (0=non-smoker,1=smoker,9=unk)
  prenatal_visits_raw = substr(lines, 55, 56),        # Item 4987: Prenatal visits total (01-97,98=≥98,99=unk)
  years_smoked_raw = substr(lines, 57, 58),           # Item 4988: Years smoked at registration

  # ---- Reproductive history ----
  twinning_raw  = substr(lines, 293, 293),            # Item 5191: Twinning gravida (0/1/9)

  # ---- Medical conditions (counts, from summary classification cols 256-268) ----
  n_cardiovascular = substr(lines, 256, 256),         # Item 5161
  n_pulmonary   = substr(lines, 257, 257),            # Item 5162
  n_hematologic = substr(lines, 258, 258),            # Item 5163
  n_metabolic   = substr(lines, 259, 259),            # Item 5164
  n_venereal    = substr(lines, 260, 260),            # Item 5165
  n_urinary     = substr(lines, 261, 261),            # Item 5166
  n_gynecologic = substr(lines, 262, 262),            # Item 5167
  n_neuropsych  = substr(lines, 263, 263),            # Item 5168
  n_gi          = substr(lines, 264, 264),            # Item 5169
  n_integument  = substr(lines, 265, 265),            # Item 5170
  n_ob_complications = substr(lines, 266, 266),       # Item 5171
  n_puerperal   = substr(lines, 267, 267),            # Item 5172
  n_infectious  = substr(lines, 268, 268),            # Item 5173

  # ---- Consanguinity & sibling info (cols 286-292, from Vol 3a pp46-48) ----
  sib_seizures_all_raw = substr(lines, 286, 286),     # Item 5184: All sibs seizures (0-5,8=no prior,9=unk)
  consanguinity_raw = substr(lines, 287, 287),         # Item 5185: Consanguinity grav & FOB rev0 (0=none,1=1st cousin+,2=distant,9=unk)
  consanguinity_parents_raw = substr(lines, 289, 289), # Item 5187: Consanguinity gravida's parents (0-8)
  consanguinity_parents_yn_raw = substr(lines, 290, 290), # Item 5188: Consanguinity parents (0=no,1=yes,9=unk)
  consanguinity_grav_fob_raw = substr(lines, 291, 291),   # Item 5189: Consanguinity grav & FOB all rev (0-8)
  consanguinity_grav_fob_yn_raw = substr(lines, 292, 292), # Item 5190: Consanguinity grav & FOB (0=no,1=yes,9=unk)

  # ---- Pregnancy conditions by trimester (cols 305-310, from Vol 3a pp49-51) ----
  vaginal_bleeding_raw = substr(lines, 305, 305),     # Item 5197: Vaginal bleeding by trimester (0-8,9=unk)
  fever_raw     = substr(lines, 306, 306),             # Item 5198: Fever by trimester (0-8,9=unk)
  vomiting_raw  = substr(lines, 307, 307),             # Item 5199: Vomiting by trimester (0-8,9=unk)
  jaundice_raw  = substr(lines, 308, 308),             # Item 5200: Jaundice by trimester (0-8,9=unk)
  edema_raw     = substr(lines, 309, 309),             # Item 5201: Edema hands/face by trimester (0-8,9=unk)
  convulsions_raw = substr(lines, 310, 310),           # Item 5202: Convulsions by trimester (0-8,9=unk)

  # ---- Menstrual & medical history (cols 311-318, from Vol 3a pp51-52) ----
  dysmenorrhea_raw = substr(lines, 311, 311),          # Item 5203: Dysmenorrhea (0=none,1=slight,2=mod,3=severe,8=irreg,9=unk)
  menarche_age_raw = substr(lines, 312, 313),          # Item 5204: Age at menarche (yrs, 04-26, 99=unk)
  menstrual_irregular_raw = substr(lines, 314, 314),   # Item 5205: Menstrual cycle unusual interval (0-4,8=irreg,9=unk)
  confining_illness_raw = substr(lines, 315, 315),     # Item 5206: Confining illness past 12mo (0-8,9=unk)
  transfusions_raw = substr(lines, 316, 316),          # Item 5207: Transfusions prior (0=none,1=1+,9=unk)
  xray_raw      = substr(lines, 317, 317),             # Item 5208: X-ray exposures (0=none,1=abdomino-pelvic,2=other,9=unk)
  hosp_prior_raw = substr(lines, 318, 318),            # Item 5209: Hospitalizations 12+mo prior (0-8,9=unk)

  # ---- Obstetric measures (cols 319-346, from Vol 3a pp52-56) ----
  pelvic_inlet_raw = substr(lines, 319, 319),          # Item 5210: Pelvic summation inlet (0=adequate,1=contracted,2=borderline,9=unk)
  weight_gain_raw = substr(lines, 320, 321),           # Item 5211: Max weight gain pregnancy (lbs, 00-97,98=loss,99=unk)
  hypertension_raw = substr(lines, 322, 322),          # Item 5212: Hypertensive BP (0=none,1-7 count,8=8+,9=unk)
  albuminuria_raw = substr(lines, 323, 324),           # Item 5213: Albumin ≥2+ specimens count (00-97,99=unk)
  fetal_heart_raw = substr(lines, 325, 325),           # Item 5214: Fetal heart sound at admission (0=not heard,1=present)
  bleeding_admission_raw = substr(lines, 326, 326),    # Item 5215: Vaginal bleeding at admission (0=no,1=yes)
  glucosuria_raw = substr(lines, 327, 328),            # Item 5216: Glucose ≥2+ specimens count (00-97,99=unk)
  bp_sys_first_raw = substr(lines, 329, 331),          # Item 5217: First systolic BP (040-280,999=unk)
  bp_sys_cat_raw = substr(lines, 332, 333),            # Item 5218: First systolic BP coded (01-10,99=unk)
  bp_dia_first_raw = substr(lines, 334, 336),          # Item 5219: First diastolic BP (010-200,999=unk)
  bp_dia_cat_raw = substr(lines, 337, 338),            # Item 5220: First diastolic BP coded (01-11,99=unk)
  bleeding_any_raw = substr(lines, 339, 339),          # Item 5221: Vaginal bleeding before/during/after (0=no,1=yes,9=unk)
  acetonuria_raw = substr(lines, 340, 340),            # Item 5222: Acetonuria (0-5,7=trace,8=quest,9=unk)
  weight_predelivery_raw = substr(lines, 341, 343),    # Item 5223: Final weight prior to delivery (lbs, 050-372,999=unk)
  blood_type_raw = substr(lines, 344, 344),            # Item 5224: Blood type gravida (1=O,2=A,3=B,4=AB,9=unk)
  coombs_gravida_raw = substr(lines, 345, 345),        # Item 5225: Coombs test gravida (0=neg,1=pos,9=unk)
  rh_factor_raw = substr(lines, 346, 346),             # Item 5226: Rh factor gravida (1=pos,2=neg,9=unk)

  # ---- Marital/family status (cols 359-365, from Vol 3a pp56-57) ----
  marital_changes_raw = substr(lines, 359, 359),       # Item 5229: Marital status changes (0=none,1-7,8=8+,9=unk)
  persons_supported_raw = substr(lines, 360, 361),     # Item 5230: Persons supported (01-19,99=unk)
  persons_supported_cat_raw = substr(lines, 362, 362), # Item 5231: Persons supported grouped (1-6,9=unk)
  occupation_raw = substr(lines, 363, 364),            # Item 5232: Occupation (detailed 2-digit code)
  occupation_cat_raw = substr(lines, 365, 365),        # Item 5233: Occupation grouped (1=never,2=white collar,3=blue collar,7=welfare,9=unk)

  # ---- Family history (sibling info) ----
  sib_mental_retardation_raw = substr(lines, 476, 476), # Item 5330
  sib_seizures_raw = substr(lines, 472, 472),         # Item 5326: Seizures/convulsions gravida

  # ---- IQ scores ----
  sb_iq_raw     = substr(lines, 514, 516),            # Item 5358: Stanford-Binet IQ (age 4)
  sb_iq_cat_raw = substr(lines, 517, 517),            # Item 5359: IQ category code

  # ---- Pathology ----
  placental_wt_raw = substr(lines, 522, 525),         # Item 5364: Placental weight (grams)

  # ---- Nursery (PED-3) ----
  nursery_exam_raw = substr(lines, 577, 577),         # Item 5407: PED-3 present
  dysmaturity_raw = substr(lines, 578, 578),          # Item 5408: Dysmaturity stage
  antibiotics_raw = substr(lines, 579, 579),          # Item 5409: Antibiotics in nursery

  # ---- Nursery Feeding (PED-3) ----
  # NOTE: Vol 3a labels cols 580=bottle, 581=breast, BUT empirical distributions
  # confirm 580=breast (dominant, 93% >0) and 581=bottle (rare, 34% >0).
  # The Vol 3a documentation has a label swap error.
  bf_days_raw   = substr(lines, 580, 580),            # Breast-feeding days (0-8, 9=unknown)
  bot_days_raw  = substr(lines, 581, 581),            # Bottle-feeding days (0-8, 9=unknown)
  gavage_raw    = substr(lines, 582, 582),            # Gavage days
  tube_raw      = substr(lines, 583, 583),            # Tube feeding days
  other_feed_raw = substr(lines, 584, 584),           # Other feeding days
  vitamin_k_raw = substr(lines, 585, 585),            # Item 5415: Vitamin K (0/1/9)
  coombs_raw    = substr(lines, 586, 586),            # Item 5416: Coombs test (1=pos,2=neg,9=unk)

  # ---- Birth & Neonatal (confirmed from Vol 3a documentation) ----
  sex_raw       = substr(lines, 554, 554),            # Item 5386: Sex: 1=Male, 2=Female, 3=Undetermined, 9=Unknown
  ped_records_raw = substr(lines, 553, 553),           # Item 5385: Pediatric records present (0/1)
  birth_wt_g_raw = substr(lines, 1095, 1098),         # Item 5918: Birth weight in grams (0001-7400, 9999=unk)
  bw_interval_raw = substr(lines, 1099, 1100),        # Item 5919: Birth weight interval code (00-51, 99=unk)
  outcome_grp_raw = substr(lines, 1094, 1094),        # Item 5917: Pregnancy outcome group (1=fetal death, 2=neonatal death, 3=survived)
  outcome_detail_raw = substr(lines, 1092, 1093),     # Item 5916: Pregnancy outcome detail (00=liveborn, 01=abortion, 11=stillbirth, etc.)
  infant_death_raw = substr(lines, 1091, 1091),       # Item 5915: Infant death 0-12 months (0=none, 1-3=timing, 9=unk)
  gest_age_raw  = substr(lines, 1101, 1102),           # Item 5920: Gestational age in weeks (01-50, 00/51/99=unk)
  birth_date_raw = substr(lines, 1103, 1108),         # Item 5921: Birth date (MMDDYY)
  maternal_age_raw = substr(lines, 31, 32),            # Item 4974: Maternal age at registration (years)

  # ---- Apgar scores (1-minute, confirmed from Vol 3a p92-93) ----
  apgar_heart_raw = substr(lines, 555, 555),           # Item 5387: Heart rate (0=absent, 1=slow, 2=≥100)
  apgar_resp_raw  = substr(lines, 556, 556),           # Item 5388: Respiratory effort (0-2)
  apgar_tone_raw  = substr(lines, 557, 557),           # Item 5389: Muscle tone (0-2)
  apgar_reflex_raw = substr(lines, 558, 558),          # Item 5390: Reflex irritability (0-2)
  apgar_color_raw = substr(lines, 559, 559),           # Item 5391: Color (0-2)
  apgar_total_raw = substr(lines, 560, 561)            # Item 5392: Total score (00-10, 20-29=incomplete, 99=unk)
)
rm(lines); gc(verbose = FALSE)

# ---- 2. Clean & Label Variables ----
cat("\n--- Cleaning variables ---\n")

cpp[, mother_id := paste0(institution, selection, gravida_id)]

# ---- Identifiers & pregnancy type ----
cpp[, plurality := as.integer(plurality_raw)]
cpp[, birth_switch := as.integer(birth_switch_raw)]
cpp[, repeat_switch := as.integer(repeat_switch_raw)]
cpp[, repeat_order := as.integer(repeat_order_raw)]

# CORRECTED: 3=Oriental, 4=Puerto Rican per Vol 3a Item 5195
cpp[, race := as.integer(race_raw)]
cpp[race %in% c(8, 9), race := NA]
cpp[, race_label := factor(race, levels = 1:4,
                           labels = c("White", "Black", "Oriental", "Puerto Rican"))]

cpp[, patient_status := as.integer(patient_status_raw)]
cpp[patient_status %in% c(9), patient_status := NA]

cpp[, religion := as.integer(religion_raw)]
cpp[religion == 9, religion := NA]
cpp[, religion_label := factor(religion, levels = 1:3,
                               labels = c("Protestant", "Roman Catholic", "Other"))]

cpp[, educ_yrs := as.integer(educ_yrs_raw)]
cpp[educ_yrs %in% c(99), educ_yrs := NA]

cpp[, educ_cat := as.integer(educ_cat_raw)]
cpp[educ_cat %in% c(0, 9), educ_cat := NA]

cpp[, income := as.integer(income_raw)]
cpp[income == 99, income := NA]

cpp[, income_cat := as.integer(income_cat_raw)]
cpp[income_cat == 9, income_cat := NA]

cpp[, housing_density := as.integer(housing_raw)]
cpp[housing_density %in% c(99), housing_density := NA]

cpp[, sei := as.integer(sei_raw)]
cpp[sei %in% c(99), sei := NA]
cpp[, sei_decimal := sei / 10]

cpp[, sei_cat := as.integer(sei_cat_raw)]
cpp[sei_cat %in% c(0, 9), sei_cat := NA]

# Col 36, Item 4977 — NOT col 365 which is occupation
cpp[, marital := as.integer(marital_status_raw)]
cpp[marital %in% c(0, 9), marital := NA]
cpp[, marital_label := factor(marital, levels = 1:6,
                              labels = c("Single", "Married", "Common law", "Widowed", "Divorced", "Separated"))]

# ---- Registration & pregnancy history ----
cpp[, age_group := as.integer(age_group_raw)]
cpp[age_group == 9, age_group := NA]

cpp[, gest_at_reg := as.integer(gest_at_reg_raw)]
cpp[gest_at_reg %in% c(51, 99), gest_at_reg := NA]

cpp[, trimester_at_reg := as.integer(trimester_at_reg_raw)]
cpp[trimester_at_reg == 9, trimester_at_reg := NA]

cpp[, prior_preg := as.integer(prior_preg_raw)]
cpp[prior_preg == 99, prior_preg := NA]

# For these count fields, 88 is not an unknown value: it means that no prior
# pregnancy occurred, so the implied count is zero. Only 99 is unknown.
clean_prior_pregnancy_count <- function(raw_value) {
  value <- suppressWarnings(as.integer(raw_value))
  value[value == 88L] <- 0L
  value[value == 99L] <- NA_integer_
  value
}

cpp[, parity := clean_prior_pregnancy_count(parity_raw)]
cpp[, prior_perinatal_loss := clean_prior_pregnancy_count(prior_perinatal_loss_raw)]
cpp[, prior_livebirths := clean_prior_pregnancy_count(prior_livebirths_raw)]

# Guard against regression to the pre-August-2026 behavior that converted 88
# to NA and hid first-pregnancy structural zeros.
stopifnot(
  cpp[parity_raw == "88", all(parity == 0L)],
  cpp[prior_perinatal_loss_raw == "88", all(prior_perinatal_loss == 0L)],
  cpp[prior_livebirths_raw == "88", all(prior_livebirths == 0L)]
)

cpp[, cigs_per_day := as.integer(cigs_per_day_raw)]
cpp[cigs_per_day %in% c(99), cigs_per_day := NA]

cpp[, smoker := as.integer(smoker_raw)]
cpp[smoker == 9, smoker := NA]

cpp[, prenatal_visits := as.integer(prenatal_visits_raw)]
cpp[prenatal_visits == 99, prenatal_visits := NA]

cpp[, years_smoked := as.integer(years_smoked_raw)]
cpp[years_smoked %in% c(99), years_smoked := NA]

cpp[, consanguinity := as.integer(consanguinity_raw)]
cpp[consanguinity %in% c(4, 9), consanguinity := NA]
cpp[, consanguinity_yn := as.integer(consanguinity_grav_fob_yn_raw)]
cpp[consanguinity_yn == 9, consanguinity_yn := NA]

# ---- Pregnancy conditions ----
for (v in c("vaginal_bleeding", "fever", "vomiting", "jaundice", "edema", "convulsions")) {
  raw_col <- paste0(v, "_raw")
  cpp[, (v) := as.integer(get(raw_col))]
  cpp[get(v) %in% c(8, 9), (v) := NA]
}

cpp[, menarche_age := as.integer(menarche_age_raw)]
cpp[menarche_age %in% c(0, 99), menarche_age := NA]

cpp[, confining_illness := as.integer(confining_illness_raw)]
cpp[confining_illness == 9, confining_illness := NA]

cpp[, pelvic_inlet := as.integer(pelvic_inlet_raw)]
cpp[pelvic_inlet == 9, pelvic_inlet := NA]

cpp[, weight_gain := as.integer(weight_gain_raw)]
cpp[weight_gain %in% c(98, 99), weight_gain := NA]

cpp[, hypertension := as.integer(hypertension_raw)]
cpp[hypertension == 9, hypertension := NA]

cpp[, bp_sys_first := as.integer(bp_sys_first_raw)]
cpp[bp_sys_first == 999, bp_sys_first := NA]

cpp[, bp_dia_first := as.integer(bp_dia_first_raw)]
cpp[bp_dia_first == 999, bp_dia_first := NA]

cpp[, weight_predelivery := as.integer(weight_predelivery_raw)]
cpp[weight_predelivery == 999, weight_predelivery := NA]

cpp[, blood_type := as.integer(blood_type_raw)]
cpp[blood_type == 9, blood_type := NA]
cpp[, blood_type_label := factor(blood_type, levels = 1:4, labels = c("O", "A", "B", "AB"))]

cpp[, rh_factor := as.integer(rh_factor_raw)]
cpp[rh_factor == 9, rh_factor := NA]
cpp[, rh_label := factor(rh_factor, levels = 1:2, labels = c("Positive", "Negative"))]

# Col 365 — previously mislabeled as marital status
cpp[, occupation_cat := as.integer(occupation_cat_raw)]
cpp[occupation_cat == 9, occupation_cat := NA]
cpp[, occupation_label := factor(occupation_cat, levels = c(1, 2, 3, 7),
                                  labels = c("Never worked", "White collar", "Blue collar", "Welfare"))]

cpp[, sb_iq := as.integer(sb_iq_raw)]
cpp[sb_iq %in% c(888, 999, 0) | sb_iq < 30 | sb_iq > 200, sb_iq := NA]

cpp[, sb_iq_cat := as.integer(sb_iq_cat_raw)]
cpp[sb_iq_cat == 9, sb_iq_cat := NA]

cpp[, placental_wt := as.integer(placental_wt_raw)]
cpp[placental_wt %in% c(9999, 0), placental_wt := NA]

for (v in c("bf_days", "bot_days", "gavage", "tube", "other_feed")) {
  raw_col <- paste0(v, "_raw")
  cpp[, (v) := as.integer(get(raw_col))]
  cpp[get(v) == 9, (v) := NA]
}

cpp[, vitamin_k := as.integer(vitamin_k_raw)]
cpp[vitamin_k == 9, vitamin_k := NA]

cpp[, coombs := as.integer(coombs_raw)]
cpp[coombs == 9, coombs := NA]

cpp[, sex := as.integer(sex_raw)]
cpp[sex %in% c(0, 3, 9), sex := NA]
cpp[, sex_label := factor(sex, levels = 1:2, labels = c("Male", "Female"))]

cpp[, ped_records := as.integer(ped_records_raw)]

# CORRECTED: cols 1095-1098, NOT 1094-1097
cpp[, birth_wt_g := as.integer(birth_wt_g_raw)]
cpp[birth_wt_g %in% c(0, 9999), birth_wt_g := NA]
cpp[birth_wt_g < 200 | birth_wt_g > 7000, birth_wt_g := NA]

cpp[, bw_interval := as.integer(bw_interval_raw)]
cpp[bw_interval == 99, bw_interval := NA]

cpp[, outcome_grp := as.integer(outcome_grp_raw)]
cpp[outcome_grp == 9, outcome_grp := NA]
cpp[, outcome_grp_label := factor(outcome_grp, levels = 1:3,
                                   labels = c("Fetal death", "Neonatal death", "Survived"))]

cpp[, outcome_detail := as.integer(outcome_detail_raw)]
cpp[outcome_detail == 99, outcome_detail := NA]

cpp[, infant_death := as.integer(infant_death_raw)]
cpp[infant_death == 9, infant_death := NA]

cpp[, gest_age := as.integer(gest_age_raw)]
cpp[gest_age %in% c(0, 51, 99), gest_age := NA]
cpp[gest_age < 20 | gest_age > 50, gest_age := NA]

cpp[, maternal_age := as.integer(maternal_age_raw)]
cpp[maternal_age %in% c(99), maternal_age := NA]
cpp[maternal_age < 10 | maternal_age > 55, maternal_age := NA]

for (v in c("apgar_heart", "apgar_resp", "apgar_tone", "apgar_reflex", "apgar_color")) {
  raw_col <- paste0(v, "_raw")
  cpp[, (v) := as.integer(get(raw_col))]
  cpp[get(v) == 9, (v) := NA]
}

cpp[, apgar_total := as.integer(apgar_total_raw)]
cpp[apgar_total >= 20, apgar_total := NA]

cpp[, bf_ever := as.integer(bf_days > 0)]
cpp[is.na(bf_days), bf_ever := NA]

cpp[, feed_type := NA_character_]
cpp[bf_days > 0 & (bot_days == 0 | is.na(bot_days)), feed_type := "Breast-only"]
cpp[bf_days == 0 & bot_days > 0, feed_type := "Bottle-only"]
cpp[bf_days > 0 & bot_days > 0, feed_type := "Both"]
cpp[bf_days == 0 & (bot_days == 0 | is.na(bot_days)), feed_type := "None/other"]

cpp[, twinning := as.integer(twinning_raw)]
cpp[twinning == 9, twinning := NA]

cpp[, dysmaturity := as.integer(dysmaturity_raw)]
cpp[dysmaturity == 9, dysmaturity := NA]

cpp[, antibiotics := as.integer(antibiotics_raw)]
cpp[antibiotics == 9, antibiotics := NA]

# ---- 3. Extract 7-year cognitive battery from CPPMASTER.ASC (card 21300) ----
# PS-30 exam: WISC IQ + subtests, Bender Gestalt, WRAT, etc.
cat("\n--- Extracting 7-yr cognitive battery (card 21300) ---\n")
master_path <- file.path(BASE, "data", "CPPMASTER.ASC")

con <- file(master_path, "r")
psych7_records <- list()
repeat {
  batch <- readLines(con, n = 100000)
  if (length(batch) == 0) break
  mask <- substr(batch, 1, 5) == "21300"
  if (any(mask)) {
    for (line in batch[mask]) {
      psych7_records[[length(psych7_records) + 1]] <- list(
        case_id   = substr(line, 6, 14),

        # ---- WISC Subtests (cols 15-30, 2-digit scaled scores) ----
        # Vol 5 labels + empirical validation (correlation with FSIQ)
        # 88 = missing/not administered; all are 2-digit fields
        wisc_sub1     = as.integer(substr(line, 15, 16)),  # M=7.4, r=.66 (Arithmetic scaled?)
        wisc_info     = as.integer(substr(line, 17, 18)),  # M=9.2, r=.72 — Information
        wisc_comp_raw = as.integer(substr(line, 19, 20)),  # M=6.2, r=.53 — Comprehension raw
        wisc_comp     = as.integer(substr(line, 21, 22)),  # M=8.7, r=.60 — Comprehension scaled
        wisc_simil_raw = as.integer(substr(line, 23, 24)), # M=17.9, r=.70 — Similarities raw
        wisc_vocab    = as.integer(substr(line, 25, 26)),  # M=8.7, r=.76 — Vocabulary
        wisc_sub7     = as.integer(substr(line, 27, 28)),  # M=7.1, r=.63 (unknown subtest)
        wisc_digit    = as.integer(substr(line, 29, 30)),  # M=9.6, r=.66 — Digit Span

        # ---- Verbal/Performance totals (cols 31-32) ----
        wisc_verb_sum = as.integer(substr(line, 31, 32)),  # M=36.2, r=.90 — Sum of verbal scaled

        # ---- Other cognitive tests (cols 33-53) ----
        bender_raw    = as.integer(substr(line, 33, 34)),  # M=12.0, r=.70 — Bender Gestalt
        ps30_col35    = as.integer(substr(line, 35, 36)),  # M=9.6, r=.77 — scaled score
        bender_rotation = as.integer(substr(line, 37, 38)),# M=7.4, r=.57 — Bender rotation?
        ps30_col39    = as.integer(substr(line, 39, 40)),  # M=9.7, r=.70 — scaled score
        ps30_col41    = as.integer(substr(line, 41, 42)),  # M=33.3, r=.47 — raw total
        ps30_col43    = as.integer(substr(line, 43, 44)),  # M=10.1, r=.48 — scaled score
        auditory_vocal = as.integer(substr(line, 45, 46)), # M=29.3, r=.89 — Aud Vocal Assoc
        wrat_read     = as.integer(substr(line, 47, 48)),  # M=45.4, r=.90 — WRAT Reading
        ps30_col49    = as.integer(substr(line, 49, 50)),  # M=9.0, r=.88
        ps30_col51    = as.integer(substr(line, 51, 52)),  # M=48.3, r=.09 — low r
        ps30_col53    = as.integer(substr(line, 53, 54)),  # M=44.9

        # ---- WISC IQ Scores (cols 54-62, 3-digit) ----
        wisc_viq  = as.integer(substr(line, 54, 56)),      # Verbal IQ
        wisc_piq  = as.integer(substr(line, 57, 59)),      # Performance IQ
        wisc_fsiq = as.integer(substr(line, 60, 62)),      # Full Scale IQ

        # ---- Post-IQ fields (cols 63-80) ----
        ps30_col63 = as.integer(substr(line, 63, 64)),     # M=10.1, r=-.08 — exam metadata
        ps30_col65 = as.integer(substr(line, 65, 66)),     # M=17.8, r=.12
        ps30_col67 = as.integer(substr(line, 67, 68)),     # M=61.3, r=.60 — cognitive?
        ps30_col69 = as.integer(substr(line, 69, 70)),     # M=33.0
        ps30_col71 = as.integer(substr(line, 71, 72)),     # M=9.6
        ps30_col73 = as.integer(substr(line, 73, 74))      # M=59.6, r=.01
      )
    }
  }
}
close(con)

psych7_dt <- rbindlist(psych7_records)
cat(sprintf("  Card 21300 records: %d\n", nrow(psych7_dt)))

# Clean IQ and subtest scores
for (v in c("wisc_viq", "wisc_piq", "wisc_fsiq")) {
  psych7_dt[get(v) %in% c(888, 999, 0) | get(v) < 30 | get(v) > 200, (v) := NA]
}

subtest_cols <- c("wisc_sub1", "wisc_info", "wisc_comp_raw", "wisc_comp",
                  "wisc_simil_raw", "wisc_vocab", "wisc_sub7", "wisc_digit",
                  "wisc_verb_sum", "bender_raw", "ps30_col35", "bender_rotation",
                  "ps30_col39", "ps30_col41", "ps30_col43", "auditory_vocal",
                  "wrat_read", "ps30_col49", "ps30_col51", "ps30_col53",
                  "ps30_col63", "ps30_col65", "ps30_col67", "ps30_col69",
                  "ps30_col71", "ps30_col73")
for (v in subtest_cols) {
  psych7_dt[get(v) %in% c(88, 99), (v) := NA]
}

cat(sprintf("  Valid FSIQ: %d, Valid VIQ: %d, Valid PIQ: %d\n",
            sum(!is.na(psych7_dt$wisc_fsiq)),
            sum(!is.na(psych7_dt$wisc_viq)),
            sum(!is.na(psych7_dt$wisc_piq))))
cat(sprintf("  Valid subtests: Info=%d, Comp=%d, Vocab=%d, Digit=%d\n",
            sum(!is.na(psych7_dt$wisc_info)),
            sum(!is.na(psych7_dt$wisc_comp)),
            sum(!is.na(psych7_dt$wisc_vocab)),
            sum(!is.na(psych7_dt$wisc_digit))))

cpp <- merge(cpp, psych7_dt, by = "case_id", all.x = TRUE)

# ---- 5. Select final columns and export ----
cat("\n--- Exporting ---\n")

# Drop _raw extraction columns but keep legitimate raw score columns
cppvar_raw_cols <- grep("_raw$", names(cpp), value = TRUE)
keep_raw <- c("wisc_comp_raw", "wisc_simil_raw", "bender_raw")
cppvar_raw_cols <- setdiff(cppvar_raw_cols, keep_raw)
cpp[, (cppvar_raw_cols) := NULL]

med_cols <- grep("^n_", names(cpp), value = TRUE)
fwrite(cpp, file.path(out_dir, "cpp_clean_v2_full.csv"))
cat(sprintf("  Saved: cpp_clean_v2_full.csv (%d rows, %d cols)\n", nrow(cpp), ncol(cpp)))

keep_cols <- c("case_id", "mother_id", "institution", "selection",
               "gravida_id", "preg_order", "plurality", "birth_switch",
               "repeat_switch", "repeat_order",
               "sex", "sex_label", "ped_records",
               "race", "race_label", "religion", "religion_label",
               "patient_status", "maternal_age", "age_group",
               "educ_yrs", "educ_cat", "income", "income_cat",
               "housing_density", "sei", "sei_decimal", "sei_cat",
               "marital", "marital_label", "twinning",
               "occupation_cat", "occupation_label",
               # Pregnancy history
               "gest_at_reg", "trimester_at_reg",
               "prior_preg", "parity", "prior_perinatal_loss", "prior_livebirths",
               # Smoking
               "smoker", "cigs_per_day", "prenatal_visits", "years_smoked",
               # Consanguinity
               "consanguinity", "consanguinity_yn",
               # Pregnancy conditions
               "vaginal_bleeding", "fever", "vomiting", "jaundice",
               "edema", "convulsions",
               # Obstetric
               "pelvic_inlet", "weight_gain", "hypertension",
               "bp_sys_first", "bp_dia_first", "weight_predelivery",
               "blood_type", "blood_type_label", "rh_factor", "rh_label",
               "menarche_age", "confining_illness",
               # Birth & neonatal
               "birth_wt_g", "bw_interval", "gest_age",
               "outcome_grp", "outcome_grp_label", "infant_death",
               "apgar_total", "apgar_heart", "apgar_resp", "apgar_tone",
               "apgar_reflex", "apgar_color",
               # 4-year IQ
               "sb_iq", "sb_iq_cat",
               # 7-year IQ + subtests
               "wisc_viq", "wisc_piq", "wisc_fsiq",
               "wisc_sub1", "wisc_info", "wisc_comp_raw", "wisc_comp",
               "wisc_simil_raw", "wisc_vocab", "wisc_sub7", "wisc_digit",
               "wisc_verb_sum",
               # 7-year other cognitive tests
               "bender_raw", "bender_rotation",
               "auditory_vocal", "wrat_read",
               # Pathology/neonatal
               "placental_wt",
               "dysmaturity", "antibiotics", "vitamin_k", "coombs",
               "bf_ever", "bf_days", "bot_days", "gavage", "tube",
               "other_feed", "feed_type")
cpp_analysis <- cpp[, ..keep_cols]
fwrite(cpp_analysis, file.path(out_dir, "cpp_clean_v2.csv"))
cat(sprintf("  Saved: cpp_clean_v2.csv (%d rows, %d cols)\n", nrow(cpp_analysis), ncol(cpp_analysis)))

saveRDS(cpp, file.path(out_dir, "cpp_clean_v2.rds"))
cat("  Saved: cpp_clean_v2.rds\n")

# ---- 6. Summary statistics ----
cat("\n--- Summary ---\n")
cat(sprintf("Total children: %d, unique mothers: %d\n", nrow(cpp), length(unique(cpp$mother_id))))
cat(sprintf("With SB IQ (age 4): %d (%.1f%%)\n",
            sum(!is.na(cpp$sb_iq)), 100*mean(!is.na(cpp$sb_iq))))
cat(sprintf("With WISC FSIQ (age 7): %d (%.1f%%)\n",
            sum(!is.na(cpp$wisc_fsiq)), 100*mean(!is.na(cpp$wisc_fsiq))))
cat(sprintf("With BF data: %d (%.1f%%)\n",
            sum(!is.na(cpp$bf_ever)), 100*mean(!is.na(cpp$bf_ever))))

cat("\nRace:\n")
print(table(cpp$race_label, useNA = "ifany"))

cat(sprintf("\nSB IQ: M=%.1f, SD=%.1f\n",
            mean(cpp$sb_iq, na.rm=TRUE), sd(cpp$sb_iq, na.rm=TRUE)))
cat(sprintf("WISC FSIQ: M=%.1f, SD=%.1f\n",
            mean(cpp$wisc_fsiq, na.rm=TRUE), sd(cpp$wisc_fsiq, na.rm=TRUE)))

cat("\nFeeding type:\n")
print(table(cpp$feed_type, useNA = "ifany"))

cat("Done.\n")
