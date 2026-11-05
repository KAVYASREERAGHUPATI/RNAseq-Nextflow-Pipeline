
process MERGE_COUNTS {

    tag "Merge gene counts"

    container 'melanoma_rna:1.0'

    publishDir "${params.outdir}/counts", mode: 'copy'

    input:
    path count_files

    output:
    path "gene_count_matrix.tsv", emit: count_matrix

    script:
    """
    python3 - <<'PY'
    import pandas as pd
    import glob
    import os

    files = sorted(glob.glob("*_counts.txt"))

    if not files:
        raise RuntimeError("No featureCounts files found")

    merged = None

    for f in files:
        sample = os.path.basename(f).replace("_counts.txt", "")

        df = pd.read_csv(f, sep="\\t", comment="#")

        counts = df[["Geneid", df.columns[-1]]].copy()
        counts.columns = ["Geneid", sample]

        if merged is None:
            merged = counts
        else:
            merged = merged.merge(counts, on="Geneid", how="outer")

    merged.to_csv("gene_count_matrix.tsv", sep="\\t", index=False)
    PY
    """
}
