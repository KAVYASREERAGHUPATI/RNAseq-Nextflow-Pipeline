process TRIMMOMATIC {

    tag "${patient_id}"

    container 'melanoma_rna:1.0'

    input:
    tuple val(patient_id), path(r1), path(r2)

    output:
    tuple val(patient_id),
          path("${patient_id}_R1_paired.fastq.gz"),
          path("${patient_id}_R2_paired.fastq.gz"),
          emit: trimmed_reads

    script:
    """
    TrimmomaticPE \\
        -threads ${task.cpus} \\
        ${r1} ${r2} \\
        ${patient_id}_R1_paired.fastq.gz \\
        ${patient_id}_R1_unpaired.fastq.gz \\
        ${patient_id}_R2_paired.fastq.gz \\
        ${patient_id}_R2_unpaired.fastq.gz \\
        ILLUMINACLIP:/usr/share/trimmomatic/TruSeq3-PE.fa:2:30:10 \\
        LEADING:3 \\
        TRAILING:3 \\
        SLIDINGWINDOW:4:20 \\
        MINLEN:36
    """
}
