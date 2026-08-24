# Public file names

The analysis-ready files use semantic names that describe their contents rather
than names that can be mistaken for release versions.

| Canonical file | Contents | Compatibility alias |
|---|---|---|
| `cpp_clean_core.csv` | 59,391 rows x 185-column stable core | `cpp_clean_v3.csv` |
| `cpp_clean_core.rds` | Matching stable-core R object | `cpp_clean_v3.rds` |
| `cpp_clean_expanded.csv` | 59,391 rows x 315-column expanded dataset | `cpp_clean_v1.csv` |
| `cpp_clean_expanded.rds` | Matching expanded R object | `cpp_clean_v1.rds` |
| `cpp_clean_expanded_codebook.csv` | Expanded-dataset codebook | `cpp_clean_v1_codebook.csv` |

Each compatibility alias is byte-identical to its canonical counterpart in the
same release. Existing scripts can therefore continue to use an older name,
while new analyses should use the canonical semantic name.

Release versions are identified by the GitHub release tag and changelog, not by
the `v1` or `v3` strings in the compatibility filenames.
