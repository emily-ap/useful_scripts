#!/usr/bin/env python3
"""
get_ncbi_genome_data.py
------------------------
Pull full metadata (organism, isolate/strain name, BioSample, BioProject,
assembly stats, etc.) for a list of NCBI genome assembly accessions
(GCA_/GCF_) and write it to a CSV file.

Requires NCBI's official `datasets` command-line tool. This script will
check for it and, if missing, install it automatically on macOS/Linux.

USAGE
-----
    python3 get_ncbi_genome_data.py accessions.txt
    python3 get_ncbi_genome_data.py accessions.txt -o genome_data.csv
    python3 get_ncbi_genome_data.py GCA_001563335.1 GCA_000986845.1

`accessions.txt` should have one accession per line.

WHAT IT DOES
------------
1. Runs:  datasets summary genome accession --inputfile <accessions> --as-json-lines
   (in batches, so a large list doesn't hit any single-request limits)
2. Parses the JSON Lines output NCBI returns for each assembly.
3. Extracts a wide set of fields -- including isolate name, wherever NCBI
   put it (organism infraspecific name, or a BioSample attribute) -- and
   writes one row per accession to a CSV.

You can re-run this any time you have a new accession list -- that's the
whole point: keep this script, swap the input file.
"""

import argparse
import csv
import json
import os
import platform
import shutil
import stat
import subprocess
import sys
import tempfile
import urllib.request

NCBI_DL_BASE = "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2"

FIELDNAMES = [
    "accession",
    "current_accession",
    "organism_name",
    "tax_id",
    "isolate",
    "strain",
    "breed",
    "cultivar",
    "ecotype",
    "sex",
    "assembly_name",
    "assembly_level",
    "assembly_status",
    "assembly_type",
    "refseq_category",
    "release_date",
    "submitter",
    "bioproject_accession",
    "biosample_accession",
    "biosample_title",
    "collection_date",
    "geo_loc_name",
    "host",
    "isolation_source",
    "lat_lon",
    "total_sequence_length",
    "number_of_contigs",
    "contig_n50",
    "gc_percent",
    "number_of_chromosomes",
    "assembly_method",
    "sequencing_tech",
]


def find_or_install_datasets():
    """Return path to the `datasets` executable, installing it if needed."""
    exe = shutil.which("datasets")
    if exe:
        return exe

    print("NCBI 'datasets' CLI not found on PATH -- attempting to install it "
          "into ./ncbi_tools/ ...", file=sys.stderr)

    system = platform.system().lower()
    machine = platform.machine().lower()

    if system == "darwin":
        osdir = "mac"
    elif system == "linux":
        osdir = "linux-amd64" if machine in ("x86_64", "amd64") else "linux-arm64"
    else:
        print(f"Don't know how to auto-install on {system}/{machine}. "
              f"Please install manually from "
              f"https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/ "
              f"and re-run this script.", file=sys.stderr)
        sys.exit(1)

    install_dir = os.path.join(os.getcwd(), "ncbi_tools")
    os.makedirs(install_dir, exist_ok=True)

    for tool in ("datasets", "dataformat"):
        url = f"{NCBI_DL_BASE}/{osdir}/{tool}"
        dest = os.path.join(install_dir, tool)
        print(f"  downloading {url} -> {dest}", file=sys.stderr)
        urllib.request.urlretrieve(url, dest)
        st = os.stat(dest)
        os.chmod(dest, st.st_mode | stat.S_IEXEC | stat.S_IXGRP | stat.S_IXOTH)

    exe = os.path.join(install_dir, "datasets")
    print(f"Installed. Add {install_dir} to your PATH to use 'datasets' "
          f"directly in the future, e.g.:\n  export PATH=\"{install_dir}:$PATH\"",
          file=sys.stderr)
    return exe


def chunked(seq, size):
    for i in range(0, len(seq), size):
        yield seq[i:i + size]


def fetch_reports(datasets_exe, accessions, batch_size=100):
    """Yield one parsed JSON report dict per accession."""
    for batch in chunked(accessions, batch_size):
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
            f.write("\n".join(batch))
            infile = f.name
        try:
            cmd = [
                datasets_exe, "summary", "genome", "accession",
                "--inputfile", infile,
                "--as-json-lines",
            ]
            proc = subprocess.run(cmd, capture_output=True, text=True)
            if proc.returncode != 0:
                print(f"WARNING: 'datasets' exited {proc.returncode} for a "
                      f"batch of {len(batch)} accessions:\n{proc.stderr}",
                      file=sys.stderr)
            for line in proc.stdout.splitlines():
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    continue
        finally:
            os.unlink(infile)


def biosample_attr(biosample, *names):
    """Look up a BioSample attribute by name (case-insensitive), trying
    each name in order until one is found."""
    attrs = (biosample or {}).get("attributes") or []
    lookup = {a.get("name", "").lower(): a.get("value") for a in attrs}
    for name in names:
        if name.lower() in lookup:
            return lookup[name.lower()]
    return ""


def extract_row(report):
    organism = report.get("organism", {}) or {}
    infra = organism.get("infraspecific_names", {}) or {}
    assembly_info = report.get("assembly_info", {}) or {}
    biosample = assembly_info.get("biosample", {}) or {}
    stats = report.get("assembly_stats", {}) or {}

    isolate = infra.get("isolate") or biosample_attr(biosample, "isolate", "isolate_name")
    strain = infra.get("strain") or biosample_attr(biosample, "strain")

    return {
        "accession": report.get("accession", ""),
        "current_accession": report.get("current_accession", ""),
        "organism_name": organism.get("organism_name", ""),
        "tax_id": organism.get("tax_id", ""),
        "isolate": isolate or "",
        "strain": strain or "",
        "breed": infra.get("breed", ""),
        "cultivar": infra.get("cultivar", ""),
        "ecotype": infra.get("ecotype", ""),
        "sex": infra.get("sex", ""),
        "assembly_name": assembly_info.get("assembly_name", ""),
        "assembly_level": assembly_info.get("assembly_level", ""),
        "assembly_status": assembly_info.get("assembly_status", ""),
        "assembly_type": assembly_info.get("assembly_type", ""),
        "refseq_category": assembly_info.get("refseq_category", ""),
        "release_date": assembly_info.get("release_date", ""),
        "submitter": assembly_info.get("submitter", ""),
        "bioproject_accession": assembly_info.get("bioproject_accession", ""),
        "biosample_accession": biosample.get("accession", ""),
        "biosample_title": (biosample.get("description") or {}).get("title", ""),
        "collection_date": biosample_attr(biosample, "collection_date", "collection date"),
        "geo_loc_name": biosample_attr(biosample, "geo_loc_name", "geographic location"),
        "host": biosample_attr(biosample, "host"),
        "isolation_source": biosample_attr(biosample, "isolation_source"),
        "lat_lon": biosample_attr(biosample, "lat_lon"),
        "total_sequence_length": stats.get("total_sequence_length", ""),
        "number_of_contigs": stats.get("number_of_contigs", ""),
        "contig_n50": stats.get("contig_n50", ""),
        "gc_percent": stats.get("gc_percent", ""),
        "number_of_chromosomes": stats.get("total_number_of_chromosomes", ""),
        "assembly_method": assembly_info.get("assembly_method", ""),
        "sequencing_tech": assembly_info.get("sequencing_tech", ""),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", nargs="+",
                     help="A file of accessions (one per line) and/or "
                          "individual accessions given directly.")
    ap.add_argument("-o", "--output", default="genome_data.csv",
                     help="Output CSV path (default: genome_data.csv)")
    ap.add_argument("--raw-jsonl", default=None,
                     help="Optional path to also save the raw JSON-lines "
                          "response from NCBI (useful for fields this "
                          "script doesn't extract).")
    ap.add_argument("--batch-size", type=int, default=100,
                     help="Accessions per 'datasets' call (default: 100)")
    args = ap.parse_args()

    accessions = []
    for item in args.input:
        if os.path.isfile(item):
            with open(item) as f:
                accessions.extend(
                    line.strip() for line in f if line.strip() and not line.startswith("#")
                )
        else:
            accessions.append(item.strip())

    # de-dupe, keep order
    seen = set()
    accessions = [a for a in accessions if not (a in seen or seen.add(a))]

    if not accessions:
        print("No accessions given.", file=sys.stderr)
        sys.exit(1)

    print(f"Fetching metadata for {len(accessions)} accessions from NCBI...",
          file=sys.stderr)

    datasets_exe = find_or_install_datasets()

    found_accessions = set()
    raw_fh = open(args.raw_jsonl, "w") if args.raw_jsonl else None

    with open(args.output, "w", newline="") as out_f:
        writer = csv.DictWriter(out_f, fieldnames=FIELDNAMES)
        writer.writeheader()
        for report in fetch_reports(datasets_exe, accessions, args.batch_size):
            if raw_fh:
                raw_fh.write(json.dumps(report) + "\n")
            row = extract_row(report)
            found_accessions.add(row["accession"])
            writer.writerow(row)

    if raw_fh:
        raw_fh.close()

    missing = [a for a in accessions if a not in found_accessions]
    print(f"Done. Wrote {len(found_accessions)} rows to {args.output}",
          file=sys.stderr)
    if missing:
        print(f"WARNING: {len(missing)} accession(s) returned no data "
              f"(withdrawn/suppressed/typo?):", file=sys.stderr)
        for a in missing:
            print(f"  {a}", file=sys.stderr)


if __name__ == "__main__":
    main()
