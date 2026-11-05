process STAR_INDEX {

    tag "STAR genome index"

    container 'melanoma_rna:1.0'

    input:
    path reference
    path gtf

    output:
    path "star_index", emit: star_index

    script:
    """
    mkdir -p star_index

    STAR \\
        --runMode genomeGenerate \\
        --runThreadN ${task.cpus} \\
        --genomeDir star_index \\
        --genomeFastaFiles ${reference} \\
        --sjdbGTFfile ${gtf}
    """
}
