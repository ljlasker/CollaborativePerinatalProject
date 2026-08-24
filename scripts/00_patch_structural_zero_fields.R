#!/usr/bin/env Rscript
# Rebuild documented no-prior-pregnancy structural zeros from raw CPPVAR in
# the expanded clean CSV and RDS. Unknown codes remain missing.

library(data.table)
BASE <- ".."
raw_path <- file.path(BASE, "clean", "cppvar_all_columns.csv")
csv_path <- file.path(BASE, "clean", "cpp_clean_expanded.csv")
rds_path <- file.path(BASE, "clean", "cpp_clean_expanded.rds")

rules <- list(
  parity = list(raw = "v46_parity_pregnancies_total_number", zero = "88", unknown = "99"),
  prior_perinatal_loss = list(raw = "v48_deaths_total_number_prior", zero = "88", unknown = "99"),
  prior_livebirths = list(raw = "v50_livebirths_total_number_prior", zero = "88", unknown = "99"),
  prior_preterm_births = list(raw = "v388_premature_births_total_number", zero = "8", unknown = "9"),
  prior_fetal_deaths = list(raw = "v389_fetal_deaths_abortion_less", zero = "8", unknown = "9"),
  prior_stillbirths = list(raw = "v391_stillbirths_deaths_20_weeks", zero = "8", unknown = "9"),
  prior_neonatal_deaths = list(raw = "v392_deaths_neonatal_stillbirths_total", zero = "88", unknown = "99"),
  full_sib_total = list(raw = "v396_siblings_full_total_number", zero = "88", unknown = "99"),
  full_sib_fetal_death = list(raw = "v399_siblings_full_stillborn_fetal", zero = "8", unknown = "9"),
  full_sib_neonatal_death = list(raw = "v405_siblings_full_death_neonatal", zero = "8", unknown = "9"),
  full_sib_death_post28d = list(raw = "v406_siblings_full_death_28", zero = "8", unknown = "9")
)

raw <- fread(raw_path,
  select = c("case_id", unname(vapply(rules, `[[`, character(1), "raw"))),
  colClasses = "character", strip.white = FALSE, showProgress = FALSE)
raw_trimmed <- sub(" +$", "", raw$case_id)
raw_canonical <- ifelse(nchar(raw_trimmed) == 8L,
                        paste0(raw_trimmed, "0"), raw_trimmed)
raw_legacy <- ifelse(nchar(raw_trimmed) == 8L,
                     sprintf("%09d", as.integer(raw_trimmed)), raw_trimmed)
id_aliases <- unique(data.table(
  alias = c(raw_trimmed, raw_canonical, raw_legacy),
  canonical = rep(raw_canonical, 3L)
))
if (id_aliases[, uniqueN(canonical), by = alias][V1 > 1L, .N])
  stop("Ambiguous CPPVAR case_id alias map")

normalize_id <- function(x) {
  value <- sub(" +$", "", as.character(x))
  hit <- match(value, id_aliases$alias)
  if (anyNA(hit)) stop(sprintf("%d case IDs have no CPPVAR alias match", sum(is.na(hit))))
  id_aliases$canonical[hit]
}

raw[, case_id := raw_canonical]
if (anyNA(raw$case_id) || anyDuplicated(raw$case_id))
  stop("Raw CPPVAR case_id is missing or non-unique after normalization")

patch_table <- function(x, asset) {
  x <- as.data.table(x)
  original <- copy(x)
  x[, case_id := normalize_id(case_id)]
  if (anyNA(x$case_id) || anyDuplicated(x$case_id))
    stop(sprintf("%s case_id is missing or non-unique", asset))
  idx <- match(x$case_id, raw$case_id)
  if (anyNA(idx)) stop(sprintf("%s has %d unmatched IDs", asset, sum(is.na(idx))))

  audit <- list()
  for (clean_name in names(rules)) {
    if (!clean_name %in% names(x)) next
    rule <- rules[[clean_name]]
    raw_value <- trimws(raw[[rule$raw]][idx])
    corrected <- suppressWarnings(as.integer(raw_value))
    corrected[is.na(raw_value) | raw_value == "" | raw_value == rule$unknown] <- NA_integer_
    corrected[raw_value == rule$zero] <- 0L
    before <- x[[clean_name]]
    changed <- (is.na(before) != is.na(corrected)) |
      (!is.na(before) & !is.na(corrected) & before != corrected)
    set(x, j = clean_name, value = corrected)
    stopifnot(all(x[[clean_name]][raw_value == rule$zero] == 0L),
              all(is.na(x[[clean_name]][raw_value == rule$unknown])))
    audit[[clean_name]] <- data.table(
      asset = asset, variable = clean_name, raw_variable = rule$raw,
      structural_zero_code = rule$zero, unknown_code = rule$unknown,
      raw_structural_zeros = sum(raw_value == rule$zero, na.rm = TRUE),
      raw_unknowns = sum(raw_value == rule$unknown, na.rm = TRUE),
      missing_before = sum(is.na(before)), missing_after = sum(is.na(corrected)),
      cells_changed = sum(changed))
  }
  if ("mother_id" %in% names(x)) x[, mother_id := substr(case_id, 1L, 7L)]
  untouched <- setdiff(names(original), c("case_id", "mother_id", names(rules)))
  if (!identical(original[, ..untouched], x[, ..untouched]))
    stop(sprintf("%s changed outside the authorized fields", asset))
  list(data = x, audit = rbindlist(audit))
}

csv_result <- patch_table(
  fread(csv_path, colClasses = list(character = "case_id"), showProgress = FALSE),
  "cpp_clean_expanded.csv")
rds_result <- patch_table(readRDS(rds_path), "cpp_clean_expanded.rds")
if (!identical(names(csv_result$data), names(rds_result$data)) ||
    nrow(csv_result$data) != nrow(rds_result$data))
  stop("Expanded clean CSV and RDS schemas do not agree")

fwrite(csv_result$data, csv_path)
saveRDS(rds_result$data, rds_path)
audit <- rbindlist(list(csv_result$audit, rds_result$audit))
fwrite(audit, "structural_zero_patch_audit.csv")
saveRDS(audit, "structural_zero_patch_audit.rds")
cat("Patched expanded clean CSV and RDS from authoritative raw CPPVAR.\n")
print(audit)
