#!/usr/bin/env Rscript

# Independent semantic validation for the v3.3.1 corrected release assets.
# Usage:
#   Rscript validate_patch_release.R RAW_CPPVAR V1_RDS V3_RDS UNIFIED_RDS SUPPLEMENTARY_RDS

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 5L) {
  stop(
    "Usage: Rscript validate_patch_release.R RAW_CPPVAR V1_RDS V3_RDS ",
    "UNIFIED_RDS SUPPLEMENTARY_RDS",
    call. = FALSE
  )
}

paths <- normalizePath(args, mustWork = TRUE)
names(paths) <- c("raw", "v1", "v3", "unified", "supplementary")

rules <- data.table(
  clean = c(
    "parity", "prior_perinatal_loss", "prior_livebirths",
    "prior_preterm_births", "prior_fetal_deaths", "prior_stillbirths",
    "prior_neonatal_deaths", "full_sib_total", "full_sib_fetal_death",
    "full_sib_neonatal_death", "full_sib_death_post28d"
  ),
  raw = c(
    "v46_parity_pregnancies_total_number",
    "v48_deaths_total_number_prior",
    "v50_livebirths_total_number_prior",
    "v388_premature_births_total_number",
    "v389_fetal_deaths_abortion_less",
    "v391_stillbirths_deaths_20_weeks",
    "v392_deaths_neonatal_stillbirths_total",
    "v396_siblings_full_total_number",
    "v399_siblings_full_stillborn_fetal",
    "v405_siblings_full_death_neonatal",
    "v406_siblings_full_death_28"
  ),
  zero = c(88L, 88L, 88L, 8L, 8L, 8L, 88L, 88L, 8L, 8L, 8L),
  unknown = c(99L, 99L, 99L, 9L, 9L, 9L, 99L, 99L, 9L, 9L, 9L)
)

canonical_id <- function(x) {
  value <- sub("\\s+$", "", as.character(x))
  short <- grepl("^[0-9]{8}$", value)
  value[short] <- paste0(value[short], "0")
  value
}

decode_count <- function(value, zero, unknown) {
  value <- suppressWarnings(as.integer(trimws(as.character(value))))
  value[value == zero] <- 0L
  value[value == unknown] <- NA_integer_
  value
}

same_missing_numeric <- function(actual, expected) {
  actual <- suppressWarnings(as.numeric(as.character(actual)))
  identical(is.na(actual), is.na(expected)) &&
    isTRUE(all.equal(actual[!is.na(expected)], as.numeric(expected[!is.na(expected)]),
                     tolerance = 0, check.attributes = FALSE))
}

raw <- fread(paths[["raw"]], select = c("case_id", rules$raw),
             colClasses = list(character = "case_id"))
raw[, canonical_case_id := canonical_id(case_id)]
stopifnot(nrow(raw) == 59391L, uniqueN(raw$canonical_case_id) == 59391L)

expected <- setNames(vector("list", nrow(rules)), rules$clean)
for (i in seq_len(nrow(rules))) {
  expected[[rules$clean[[i]]]] <- decode_count(
    raw[[rules$raw[[i]]]], rules$zero[[i]], rules$unknown[[i]]
  )
}

validate_asset <- function(path, expected_rows, expected_columns, clean_names,
                           prefixes = "", allow_extra_ids = FALSE) {
  asset <- readRDS(path)
  stopifnot(nrow(asset) == expected_rows, ncol(asset) == expected_columns,
            "case_id" %in% names(asset))
  ids <- canonical_id(asset$case_id)
  stopifnot(identical(as.character(asset$case_id), ids),
            all(nchar(ids) == 9L), uniqueN(ids) == length(ids))
  raw_index <- match(ids, raw$canonical_case_id)
  if (length(clean_names)) {
    if (allow_extra_ids) {
      stopifnot(sum(!is.na(raw_index)) == 59391L)
    } else {
      stopifnot(!anyNA(raw_index))
    }
  }

  matched <- which(!is.na(raw_index))
  for (prefix in prefixes) {
    for (clean_name in clean_names) {
      column <- paste0(prefix, clean_name)
      stopifnot(column %in% names(asset))
      wanted <- expected[[clean_name]][raw_index[matched]]
      if (!same_missing_numeric(asset[[column]][matched], wanted)) {
        observed <- suppressWarnings(as.numeric(as.character(asset[[column]][matched])))
        different <- which(
          xor(is.na(observed), is.na(wanted)) |
            (!is.na(observed) & !is.na(wanted) & observed != wanted)
        )
        examples <- head(different, 5L)
        detail <- paste0(
          ids[matched][examples], " (actual=", observed[examples],
          ", raw-decoded=", wanted[examples], ")", collapse = "; "
        )
        stop(sprintf(
          "Semantic mismatch: %s in %s (%s cells); %s",
          column, basename(path), length(different), detail
        ), call. = FALSE)
      }
    }
  }
  data.table(
    asset = basename(path), rows = nrow(asset), columns = ncol(asset),
    unique_ids = uniqueN(ids), cppvar_ids_matched = sum(!is.na(raw_index)),
    semantic_checks = length(clean_names) * length(prefixes), status = "PASS"
  )
}

core <- rules$clean[1:3]
checks <- rbindlist(list(
  validate_asset(paths[["v1"]], 59391L, 315L, rules$clean),
  validate_asset(paths[["v3"]], 59391L, 185L, core),
  validate_asset(paths[["unified"]], 60016L, 4862L, core,
                 prefixes = c("v2_", "v3_"), allow_extra_ids = TRUE),
  validate_asset(paths[["supplementary"]], 11768L, 2535L, character())
))

print(checks)
cat("All corrected-release dimension, uniqueness, and source-semantic checks passed.\n")
