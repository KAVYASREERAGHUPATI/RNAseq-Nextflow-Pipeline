process FASTQC_TRIMMED {

    tag "${patient_id}"

    container 'melanoma_rna:1.0'

    input:
    tuple val(patient_id), path(r1), path(r2)

    output:
    tuple val(patient_id),
          path("*_fastqc.zip"),
          emit: fastqc_trimmed_results

    script:
    """
    fastqc \\
        --threads ${task.cpus} \\
        ${r1} \\
        ${r2}
    """
}
