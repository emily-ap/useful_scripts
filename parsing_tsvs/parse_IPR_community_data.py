"""
Date: 2026-09-22
This script adds headers to columns of the dataframe, adds bin IDs, and creates a second dataframe of only specific columns.
You need to have a premade proteins2bins.tsv in which all it contains is <BIN ID>\t<protein ID>
"""

import csv
import os
import sys

import pandas as pd

# Check if a file name was provided
# sys.argv[0] is the script name itself, so we need 4 total elements
# (script, input.tsv, proteins2bins.tsv, output_base_name).
if len(sys.argv) < 4:
    print("Please provide command line arguments: \n script.py input.tsv proteins2bins.tsv output_base_name")
    sys.exit(1)

# Get the absolute file paths
file_path = os.path.abspath(sys.argv[1])
protein_2_bin_path = os.path.abspath(sys.argv[2])
out = f"{sys.argv[3]}.tsv"
out_selected = f"{sys.argv[3]}.selected.tsv"


COLUMN_NAMES = [
    "protein_accession",
    "Sequence_MD5_digest",
    "Sequence_length",
    "Analysis",
    "Signature_accession",
    "Signature_description",
    "Start",
    "Stop",
    "E-value",
    "Status",
    "Date_of_run",
    "IPR_annotations_accession",
    "IPR_annotations_description",
    "GO_annotations_and_source",
    "Pathway_annotations",
]
NCOLS = len(COLUMN_NAMES)  # 15

# InterProScan TSV rows don't all have the same number of fields: the
# IPR accession/description columns only appear when a match has an
# InterPro cross-reference, and GO/Pathways only appear when that
# cross-reference also has GO/pathway annotations. So a single file can
# have a mix of 11-, 13-, and 15-field lines. Read it manually (NOT with
# pd.read_csv, which assumes a rectangular table and also would treat
# the first data line as a header) and pad every row out to 15 fields.
rows = []
with open(file_path, newline="") as f:
    reader = csv.reader(f, delimiter="\t")
    for row in reader:
        if not row:
            continue
        if len(row) < NCOLS:
            row = row + [None] * (NCOLS - len(row))
        elif len(row) > NCOLS:
            row = row[:NCOLS]
        rows.append(row)

df_w_col_names = pd.DataFrame(rows, columns=COLUMN_NAMES)

# add the bin IDs to the data using sys.argv[2]
# Expected format: a 2-column, tab-separated file with no header:
#   bin_id    protein_accession
# Proteins that aren't in this file get a blank Bin_ID (NaN) rather than
# being dropped, since not every protein necessarily has a bin assignment.
protein_to_bin = pd.read_csv(
    protein_2_bin_path,
    sep="\t",
    header=None,
    names=["Bin_ID", "protein_accession"],
    usecols=[0, 1],
)
df_w_col_names = df_w_col_names.merge(protein_to_bin, on="protein_accession", how="left")

# keep only rows where column 9 is < 1e-05 (or blank)
# Column 9 (1-indexed, in the original 15-column layout) is E-value.
# InterProScan represents "no value" as either an empty field or a
# literal "-", so coerce to numeric first and treat anything that
# doesn't parse as a number as blank (kept), not as failing the cutoff.
evalue_numeric = pd.to_numeric(df_w_col_names["E-value"], errors="coerce")
is_blank = evalue_numeric.isna()
df1 = df_w_col_names[is_blank | (evalue_numeric < 1e-05)].reset_index(drop=True)

# make a second data frame with only the selected columns
# in bash this would be: cut -f1,5,6,7,8,9,12,13,16
SELECTED_COLUMNS = [
    "protein_accession",             # 1
    "Signature_accession",           # 5
    "Signature_description",         # 6
    "Start",                         # 7
    "Stop",                          # 8
    "E-value",                       # 9
    "IPR_annotations_accession",     # 12
    "IPR_annotations_description",   # 13
    "Bin_ID",                        # 16 (the column we added)
]
df2 = df1[SELECTED_COLUMNS]

# get ready to output the data as .tsv files
# (df1 and df2 are already built above)

# Overwrite the old file with the new updated file
df1.to_csv(out, sep="\t", index=False)
df2.to_csv(out_selected, sep="\t", index=False)

print(f"Files successfully created: \n Output file with column names & bins IDs: {out} \n Output file with only selected columns, column names, and bin IDs: {out_selected}")
