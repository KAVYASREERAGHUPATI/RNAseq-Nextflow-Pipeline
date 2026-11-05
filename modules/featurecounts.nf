
process FEATURECOUNTS {

    tag "${patient_id}"

    container 'melanoma_rna:1.0'

    input:
    tuple val(patient_id), path(bam)
    path gtf

    output:
    // Gene-level raw counts
    tuple val(patient_id),
          path("${patient_id}_counts.txt"),
          emit: gene_counts

    // Assignment statistics for MultiQC
    tuple val(patient_id),
          path("${patient_id}_counts.txt.summary"),
          emit: assignment_stats

    script:
    """
    featureCounts \\
        -T ${task.cpus} \\
        -p \\
        --countReadPairs \\
        -a ${gtf} \\
        -o ${patient_id}_counts.txt \\
        ${bam}
    """
}
