
process STAR_ALIGN {

    tag "${patient_id}"

    container 'melanoma_rna:1.0'

    input:
    tuple val(patient_id), path(r1), path(r2)
    path star_index

    output:
    // Coordinate-sorted BAM file
    tuple val(patient_id),
          path("${patient_id}_Aligned.sortedByCoord.out.bam"),
          emit: aligned_bam

    // STAR alignment statistics for MultiQC
    tuple val(patient_id),
          path("${patient_id}_Log.final.out"),
          emit: mapping_stats

    script:
    """
    STAR --runThreadN ${task.cpus} --genomeDir ${star_index} --readFilesIn ${r1} ${r2} --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outFileNamePrefix ${patient_id}_
    """
}
