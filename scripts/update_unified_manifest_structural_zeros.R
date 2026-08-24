# Refresh unified-manifest statistics for every field. This is required after
# structural-zero repair and canonical-ID row coalescing because the row count
# and therefore every missingness percentage may change.
# Usage: Rscript update_unified_manifest_structural_zeros.R \
#   corrected_unified.rds old_manifest.csv new_manifest.csv

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(bit64))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("Expected: corrected_unified.rds old_manifest.csv new_manifest.csv")
}
if (file.exists(args[[3L]])) stop("Refusing to overwrite existing manifest output")

unified <- readRDS(args[[1L]])
manifest <- fread(args[[2L]], colClasses = "character")
targets <- intersect(manifest$variable_name, names(unified))
missing_targets <- setdiff(manifest$variable_name, names(unified))
if (length(missing_targets)) {
  stop(sprintf("Corrected unified RDS lacks: %s", paste(missing_targets, collapse = ", ")))
}
for (target in targets) {
  value <- unified[[target]]
  summary_value <- if (inherits(value, "integer64"))
    suppressWarnings(as.double(value)) else value
  row <- manifest$variable_name == target
  numeric_value <- is.numeric(summary_value)
  manifest[row, `:=`(
    N_nonmissing = as.character(sum(!is.na(value))),
    pct_missing = as.character(round(100 * mean(is.na(value)), 2L)),
    is_numeric = ifelse(numeric_value, "TRUE", "FALSE"),
    mean = if (numeric_value && any(!is.na(summary_value)))
      as.character(round(mean(summary_value, na.rm = TRUE), 4L)) else "",
    sd = if (numeric_value && sum(!is.na(summary_value)) > 1L)
      as.character(round(sd(summary_value, na.rm = TRUE), 4L)) else ""
  )]
}

fwrite(manifest, args[[3L]])
print(manifest[variable_name %chin% c(
                 "case_id", "v2_parity", "v3_parity",
                 "v2_prior_perinatal_loss", "v3_prior_perinatal_loss",
                 "v2_prior_livebirths", "v3_prior_livebirths"),
               .(variable_name, N_nonmissing, pct_missing, mean, sd)])
