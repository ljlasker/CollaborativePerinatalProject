# Repair structural-zero pregnancy-history counts in an existing RDS asset.
#
# Usage:
#   Rscript scripts/recode_structural_zero_counts_rds.R \
#     clean_input.rds cppvar_all_columns.csv corrected_output.rds audit_summary.csv
#
# The output and audit paths must be new. The script repairs documented
# pregnancy-history structural zeros and authoritative expanded count fields,
# then reads the result back and
# verifies every column value, storage type, factor level, class, and key.

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% 4:5) {
  stop(paste(
    "Expected: clean_input.rds raw_cppvar.csv corrected_output.rds",
    "audit_summary.csv [allow-unmatched]"
  ))
}

clean_path <- args[[1L]]
raw_path <- args[[2L]]
output_path <- args[[3L]]
summary_path <- args[[4L]]
allow_unmatched <- length(args) == 5L && identical(args[[5L]], "allow-unmatched")

if (file.exists(output_path) || file.exists(summary_path)) {
  stop("Refusing to overwrite an existing output or audit-summary file")
}

rules <- data.table(
  clean = c("parity", "prior_perinatal_loss", "prior_livebirths",
            "prior_preterm_births", "prior_fetal_deaths", "prior_stillbirths",
            "prior_neonatal_deaths", "full_sib_total", "full_sib_fetal_death",
            "full_sib_neonatal_death", "full_sib_death_post28d"),
  raw = c("v46_parity_pregnancies_total_number", "v48_deaths_total_number_prior",
          "v50_livebirths_total_number_prior", "v388_premature_births_total_number",
          "v389_fetal_deaths_abortion_less", "v391_stillbirths_deaths_20_weeks",
          "v392_deaths_neonatal_stillbirths_total", "v396_siblings_full_total_number",
          "v399_siblings_full_stillborn_fetal", "v405_siblings_full_death_neonatal",
          "v406_siblings_full_death_28"),
  zero = c("88", "88", "88", "8", "8", "8", "88", "88", "8", "8", "8"),
  unknown = c("99", "99", "99", "9", "9", "9", "99", "99", "9", "9", "9"),
  authoritative = c(FALSE, FALSE, FALSE, rep(TRUE, 8L))
)

raw <- fread(
  raw_path,
  select = c("case_id", rules$raw),
  colClasses = "character",
  strip.white = FALSE,
  showProgress = FALSE
)
if (anyDuplicated(raw$case_id)) stop("Duplicate case_id in raw CPPVAR CSV")

# For 2,397 source rows the ninth child/check digit is blank. The documented
# layout is mother_id (columns 1--7), pregnancy order (column 8), and child digit
# (column 9), so the canonical singleton completion appends 0 on the right.
# v3.2's RDS exporter incorrectly left-padded these rows. Accept raw, canonical,
# and legacy forms as input aliases, but do not treat left-padding as canonical.
trimmed_case_id <- sub(" +$", "", raw$case_id)
canonical_case_id <- ifelse(nchar(trimmed_case_id) == 8L,
                            paste0(trimmed_case_id, "0"), trimmed_case_id)
legacy_case_id <- ifelse(nchar(trimmed_case_id) == 8L,
                         sprintf("%09d", as.integer(trimmed_case_id)),
                         trimmed_case_id)
aliases <- unique(data.table(
  alias = c(trimmed_case_id, canonical_case_id, legacy_case_id),
  raw_index = rep(seq_len(nrow(raw)), 3L)
))
if (aliases[, uniqueN(raw_index), by = alias][V1 > 1L, .N]) {
  stop("Ambiguous CPPVAR case_id alias")
}

clean <- readRDS(clean_path)
if (!is.data.frame(clean) || !"case_id" %in% names(clean)) {
  stop("RDS root must be a data.frame/data.table containing case_id")
}
original_class <- class(clean)
original_key <- if (is.data.table(clean)) key(clean) else NULL

clean_case_id <- as.character(clean$case_id)
raw_index <- match(clean_case_id, raw$case_id)
normalized_matches <- is.na(raw_index)
raw_index[normalized_matches] <- match(
  clean_case_id[normalized_matches], aliases$alias
)
raw_index[normalized_matches] <- aliases$raw_index[raw_index[normalized_matches]]
if (anyNA(raw_index) && !allow_unmatched) {
  stop(sprintf("%d RDS rows had no raw CPPVAR case_id match", sum(is.na(raw_index))))
}

target_map <- c(
  setNames(rules$clean, rules$clean),
  setNames(rules$clean, paste0("v2_", rules$clean)),
  setNames(rules$clean, paste0("v3_", rules$clean))
)
targets <- intersect(names(target_map), names(clean))
if (!length(targets)) stop("RDS contains none of the repairable count variables")

summary <- rbindlist(lapply(targets, function(target) {
  clean_name <- target_map[[target]]
  rule <- rules[clean == clean_name]
  raw_value <- raw[[rule$raw]][raw_index]
  before <- copy(clean[[target]])
  if (rule$authoritative) {
    corrected <- suppressWarnings(as.integer(trimws(raw_value)))
    corrected[is.na(raw_value) | trimws(raw_value) == "" |
                trimws(raw_value) == rule$unknown] <- NA_integer_
    corrected[trimws(raw_value) == rule$zero] <- 0L
    matched <- which(!is.na(raw_index))
    set(clean, i = matched, j = target, value = corrected[matched])
  } else {
    repair_rows <- which(trimws(raw_value) == rule$zero)
    set(clean, i = repair_rows, j = target, value = 0L)
  }
  after <- clean[[target]]
  changed <- (is.na(before) != is.na(after)) |
    (!is.na(before) & !is.na(after) & before != after)
  data.table(variable = target, cells_changed = sum(changed),
             structural_zeros = sum(trimws(raw_value) == rule$zero, na.rm = TRUE))
}))

saveRDS(clean, output_path, compress = "gzip")
repaired <- readRDS(output_path)

stopifnot(
  identical(class(repaired), original_class),
  identical(names(repaired), names(clean)),
  identical(nrow(repaired), nrow(clean)),
  identical(if (is.data.table(repaired)) key(repaired) else NULL, original_key)
)
for (column in names(clean)) {
  if (!identical(clean[[column]], repaired[[column]])) {
    stop(sprintf("RDS round-trip changed column %s", column))
  }
}
for (target in targets) {
  clean_name <- target_map[[target]]
  rule <- rules[clean == clean_name]
  raw_value <- raw[[rule$raw]][raw_index]
  stopifnot(all(repaired[[target]][which(trimws(raw_value) == rule$zero)] == 0L))
}

summary[, `:=`(
  rows = nrow(clean),
  unmatched_case_ids = sum(is.na(raw_index)),
  normalized_case_id_matches = sum(normalized_matches & !is.na(raw_index)),
  semantic_roundtrip = "PASS"
)]
fwrite(summary, summary_path)
print(summary)
