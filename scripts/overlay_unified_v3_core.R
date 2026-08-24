#!/usr/bin/env Rscript

# Re-overlay the corrected v3 core after case-ID canonicalization so all 59,391
# CPPVAR records, including the 2,397 former blank-child-digit aliases, carry a
# complete and internally consistent v3_ copy in the unified RDS.

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(bit64))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L)
  stop("Usage: Rscript overlay_unified_v3_core.R UNIFIED.rds V3_CORE.rds OUTPUT.rds")
if (file.exists(args[[3L]])) stop("Refusing to overwrite existing output")

unified_original <- readRDS(args[[1L]])
unified_class <- class(unified_original)
unified <- as.data.table(unified_original)
v3 <- as.data.table(readRDS(args[[2L]]))

if (nrow(unified) != 60016L || nrow(v3) != 59391L ||
    anyDuplicated(unified$case_id) || anyDuplicated(v3$case_id))
  stop("Unexpected unified/v3 dimensions or duplicate IDs")
index <- match(v3$case_id, unified$case_id)
if (anyNA(index)) stop("Some corrected v3 IDs are absent from unified data")

source_names <- setdiff(names(v3), "case_id")
targets <- paste0("v3_", source_names)
available <- targets %in% names(unified)
missing_targets <- targets[!available]
source_names <- source_names[available]
targets <- targets[available]
if (!length(targets) || !"v3_mother_id" %in% targets)
  stop("Unified data has no usable v3 core overlap")

# The historical unified RDS stored v3_mother_id as integer64 and therefore
# discarded the leading zero for site 05. Standardize this linkage key to the
# documented seven-character representation before overlaying the core.
unified[, v3_mother_id := as.character(v3_mother_id)]

coerce_like <- function(source, target) {
  if (is.factor(target)) return(factor(as.character(source), levels = levels(target)))
  if (inherits(target, "integer64")) return(as.integer64(as.character(source)))
  if (is.character(target)) return(as.character(source))
  if (is.integer(target)) return(suppressWarnings(as.integer(as.character(source))))
  if (is.numeric(target)) return(suppressWarnings(as.numeric(as.character(source))))
  if (is.logical(target)) return(as.logical(source))
  stop(sprintf("Unsupported target class: %s", paste(class(target), collapse = "/")))
}

for (j in seq_along(source_names)) {
  source <- v3[[source_names[[j]]]]
  target_name <- targets[[j]]
  replacement <- coerce_like(source, unified[[target_name]])
  set(unified, i = index, j = target_name, value = replacement)
}

if (anyNA(unified$v3_mother_id[index]) ||
    any(unified$v3_mother_id[index] != substr(v3$case_id, 1L, 7L)))
  stop("v3 key overlay assertion failed")

if (!identical(class(unified), unified_class))
  stop("Unified RDS root class changed")
saveRDS(unified, args[[3L]])
roundtrip <- readRDS(args[[3L]])
if (nrow(roundtrip) != 60016L || anyDuplicated(roundtrip$case_id) ||
    anyNA(roundtrip$v3_mother_id[index]))
  stop("Unified v3 overlay round-trip check failed")
cat(sprintf("Overlaid %d v3 core fields for all 59,391 CPPVAR records.\n",
            length(source_names)))
cat(sprintf("Left %d newer v3-only fields outside the historical unified schema.\n",
            length(missing_targets)))
