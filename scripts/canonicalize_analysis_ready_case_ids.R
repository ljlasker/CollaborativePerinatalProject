#!/usr/bin/env Rscript

# Canonicalize analysis-ready CPP case IDs without altering row order or schema.
# For raw rows whose ninth child/check digit is blank, canonical completion is
# right-sided: mother_id(1:7) + pregnancy order(8) + singleton digit 0(9).
# The output path must not exist.

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("Usage: Rscript canonicalize_analysis_ready_case_ids.R INPUT RAW_CPPVAR.csv OUTPUT")
}
input <- args[[1L]]
raw_path <- args[[2L]]
output <- args[[3L]]
if (file.exists(output)) stop("Refusing to overwrite existing output")

raw_ids <- fread(raw_path, select = "case_id", colClasses = "character",
                 strip.white = FALSE, showProgress = FALSE)$case_id
raw_trimmed <- sub(" +$", "", raw_ids)
raw_canonical <- ifelse(nchar(raw_trimmed) == 8L,
                        paste0(raw_trimmed, "0"), raw_trimmed)
raw_legacy <- ifelse(nchar(raw_trimmed) == 8L,
                     sprintf("%09d", as.integer(raw_trimmed)), raw_trimmed)
aliases <- unique(data.table(
  alias = c(raw_trimmed, raw_canonical, raw_legacy),
  canonical = rep(raw_canonical, 3L)
))
if (aliases[, uniqueN(canonical), by = alias][V1 > 1L, .N])
  stop("Ambiguous CPPVAR case_id alias map")

is_rds <- grepl("\\.rds$", input, ignore.case = TRUE)
if (is_rds) {
  original <- readRDS(input)
  original_class <- class(original)
  original_names <- names(original)
  original_col_classes <- lapply(original, class)
  original_factor_levels <- lapply(original, function(x) if (is.factor(x)) levels(x) else NULL)
  d <- as.data.table(original)
} else {
  d <- fread(input, colClasses = "character", strip.white = FALSE,
             showProgress = TRUE)
}
if (!"case_id" %in% names(d) || nrow(d) != 59391L)
  stop("Expected a 59,391-row analysis-ready asset with case_id")

before <- as.character(d$case_id)
trimmed <- sub(" +$", "", before)
hit <- match(trimmed, aliases$alias)
if (anyNA(hit)) stop(sprintf("%d case IDs have no CPPVAR alias match", sum(is.na(hit))))
d[, case_id := aliases$canonical[hit]]
d[, mother_id := substr(case_id, 1L, 7L)]

changed <- sum(before != d$case_id)
if (changed != 2397L || any(nchar(d$case_id) != 9L) || anyDuplicated(d$case_id) ||
    any(d$mother_id != substr(d$case_id, 1L, 7L)))
  stop("Canonical-ID count, width, or uniqueness assertion failed")

if (is_rds) {
  setDF(d)
  if ("data.table" %in% original_class) setDT(d)
  expected_col_classes <- original_col_classes
  expected_col_classes[[match("mother_id", original_names)]] <- "character"
  if (!identical(class(d), original_class) || !identical(names(d), original_names) ||
      !identical(lapply(d, class), expected_col_classes) ||
      !identical(lapply(d, function(x) if (is.factor(x)) levels(x) else NULL),
                 original_factor_levels))
    stop("RDS schema/class changed during ID canonicalization")
  saveRDS(d, output)
  roundtrip <- readRDS(output)
  if (!identical(roundtrip$case_id, d$case_id)) stop("RDS round-trip ID check failed")
} else {
  fwrite(d, output, quote = "auto")
}

cat(sprintf("Canonicalized 2,397 right-completed case IDs and 7-digit mother IDs in %s; 59,391 unique IDs.\n",
            basename(output)))
