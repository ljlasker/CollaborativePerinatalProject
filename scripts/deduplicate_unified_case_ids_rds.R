#!/usr/bin/env Rscript
# RDS companion to deduplicate_unified_case_ids.R. Coalesces raw,
# right-completed, and legacy left-padded aliases without changing schema.

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(bit64))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 5L)
  stop("Usage: Rscript deduplicate_unified_case_ids_rds.R INPUT.rds RAW_CPPVAR.csv SOURCE_ALIASES.csv OUTPUT.rds AUDIT.csv")
input <- args[[1L]]; raw_path <- args[[2L]]; source_alias_path <- args[[3L]]
output <- args[[4L]]; audit_path <- args[[5L]]
if (file.exists(output) || file.exists(audit_path))
  stop("Refusing to overwrite an existing output or audit file")

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
source_aliases <- fread(source_alias_path, colClasses = "character")
if (!all(c("source_id8", "canonical_id") %in% names(source_aliases)) ||
    any(nchar(source_aliases$source_id8) != 8L) ||
    any(source_aliases$canonical_id != paste0(source_aliases$source_id8, "0")))
  stop("Invalid source-specific case-ID alias crosswalk")
aliases <- unique(rbind(
  aliases,
  source_aliases[, .(alias = source_id8, canonical = canonical_id)],
  source_aliases[, .(alias = sprintf("%09d", as.integer(source_id8)), canonical = canonical_id)],
  source_aliases[, .(alias = canonical_id, canonical = canonical_id)]
))
if (aliases[, uniqueN(canonical), by = alias][V1 > 1L, .N])
  stop("Ambiguous CPPVAR case_id alias map")
normalize_id <- function(x) {
  value <- sub(" +$", "", as.character(x))
  hit <- match(value, aliases$alias)
  value[!is.na(hit)] <- aliases$canonical[hit[!is.na(hit)]]
  value
}
original <- readRDS(input)
original_class <- class(original)
d <- as.data.table(original)
original_names <- copy(names(d))
original_col_classes <- lapply(d, class)
original_factor_levels <- lapply(d, function(x) if (is.factor(x)) levels(x) else NULL)
if (!"case_id" %in% names(d) || anyDuplicated(d$case_id))
  stop("Input requires a unique exact case_id column")
d[, `.row_order` := .I]
d[, `.normalized_id` := normalize_id(case_id)]
if (anyNA(d$.normalized_id)) stop("Some case IDs could not be normalized")
dup_groups <- d[, .N, by = .normalized_id][N > 1L]

data_cols <- setdiff(names(d), c("case_id", ".row_order", ".normalized_id"))
nonmissing <- integer(nrow(d))
for (v in data_cols) {
  x <- d[[v]]
  nonmissing <- nonmissing + (!is.na(x) & (!is.character(x) | x != ""))
}
d[, `.nonmissing` := nonmissing]
setorder(d, .normalized_id, -.nonmissing, .row_order)
d[, `.dup_rank` := seq_len(.N), by = .normalized_id]
primary <- d[.dup_rank == 1L]
audit <- data.table(
  variable = data_cols,
  filled_from_secondary = integer(length(data_cols)),
  conflicting_nonmissing = integer(length(data_cols))
)
max_rank <- max(d$.dup_rank)
if (max_rank >= 2L) for (rank in 2:max_rank) {
  secondary <- d[.dup_rank == rank]
  secondary_index <- match(secondary$.normalized_id, primary$.normalized_id)
  if (anyNA(secondary_index)) stop("Internal duplicate-row match failed")
  for (j in seq_along(data_cols)) {
    v <- data_cols[[j]]
    p <- primary[[v]][secondary_index]
    s <- secondary[[v]]
    p_missing <- is.na(p) | (is.character(p) & p == "")
    s_missing <- is.na(s) | (is.character(s) & s == "")
    fill <- p_missing & !s_missing
    conflict <- !p_missing & !s_missing & as.character(p) != as.character(s)
    if (any(fill)) set(primary, i = secondary_index[fill], j = v, value = s[fill])
    audit$filled_from_secondary[[j]] <- audit$filled_from_secondary[[j]] + sum(fill)
    audit$conflicting_nonmissing[[j]] <- audit$conflicting_nonmissing[[j]] + sum(conflict)
  }
}

first_order <- d[, .(first_order = min(.row_order)), by = .normalized_id]
primary <- merge(primary, first_order, by = ".normalized_id", all.x = TRUE, sort = FALSE)
setorder(primary, first_order)
primary[, case_id := .normalized_id]
primary[, c(".row_order", ".normalized_id", ".nonmissing", ".dup_rank", "first_order") := NULL]
setcolorder(primary, original_names)
duplicate_rows <- sum(dup_groups$N - 1L)
if (nrow(primary) != nrow(d) - duplicate_rows || anyDuplicated(primary$case_id))
  stop("Deduplication row-count or uniqueness assertion failed")

# data.table inputs remain data.tables; this is the shipped unified RDS class.
if (!identical(class(primary), original_class) || !identical(names(primary), original_names) ||
    !identical(lapply(primary, class), original_col_classes) ||
    !identical(lapply(primary, function(x) if (is.factor(x)) levels(x) else NULL),
               original_factor_levels))
  stop("RDS schema, class, or factor-level preservation check failed")

audit[, `:=`(input_rows = nrow(d), output_rows = nrow(primary),
             duplicate_groups_coalesced = nrow(dup_groups),
             duplicate_rows_coalesced = duplicate_rows)]
saveRDS(primary, output)
fwrite(audit, audit_path)
roundtrip <- readRDS(output)
if (!identical(class(roundtrip), original_class) || !identical(names(roundtrip), original_names) ||
    nrow(roundtrip) != nrow(primary) || anyDuplicated(roundtrip$case_id))
  stop("RDS round-trip verification failed")
cat(sprintf("Coalesced %d alias groups (%d duplicate rows): %d -> %d rows; %d conflicts.\n",
            nrow(dup_groups), duplicate_rows, nrow(d), nrow(primary),
            sum(audit$conflicting_nonmissing)))
