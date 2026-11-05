
nextflow.enable.dsl = 2

// ======================================================
// Import RNA-seq processing modules
// ======================================================

include { FASTQC } from './modules/fastqc'
include { TRIMMOMATIC } from './modules/trimmomatic'
include { FASTQC_TRIMMED } from './modules/fastqc_trimmed'
include { STAR_INDEX } from './modules/star_index'
include { STAR_ALIGN } from './modules/star_align'
include { FEATURECOUNTS } from './modules/featurecounts'
include { MERGE_COUNTS } from './modules/merge_counts'

// Import MultiQC with three different aliases
include { MULTIQC as MULTIQC_RAW } from './modules/multiqc'
include { MULTIQC as MULTIQC_TRIMMED } from './modules/multiqc'
include { MULTIQC as MULTIQC_ALIGNMENT } from './modules/multiqc'

// ======================================================
// Main RNA-seq workflow
// ======================================================

workflow {

    // Read paired-end RNA-seq samplesheet
    reads_ch = Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.patient_id,
                file(row.r1, checkIfExists: true),
                file(row.r2, checkIfExists: true)
            )
        }

    // Reference genome and GTF annotation
    reference_ch = Channel.value(
        file(params.reference, checkIfExists: true)
    )

    gtf_ch = Channel.value(
        file(params.gtf, checkIfExists: true)
    )

    // Step 1: Raw FASTQ quality control
    FASTQC(reads_ch)

    // Step 2: Adapter and quality trimming
    TRIMMOMATIC(reads_ch)

    // Step 3: Quality control after trimming
    FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads)

    // Step 4: STAR genome indexing
    STAR_INDEX(
        reference_ch,
        gtf_ch
    )

    // Step 5: STAR read alignment
    STAR_ALIGN(
        TRIMMOMATIC.out.trimmed_reads,
        STAR_INDEX.out.star_index
    )

    // Step 6: Gene-level quantification
    FEATURECOUNTS(
        STAR_ALIGN.out.aligned_bam,
        gtf_ch
    )

    // Step 7: Merge gene counts
    MERGE_COUNTS(
        FEATURECOUNTS.out.gene_counts
            .map { patient_id, count_file -> count_file }
            .collect()
    )

    // ==================================================
    // MultiQC: Raw FASTQ quality
    // ==================================================

    raw_qc_ch = FASTQC.out.fastqc_results
        .map { patient_id, zip_files -> zip_files }
        .collect()

    MULTIQC_RAW(
        raw_qc_ch,
        'raw'
    )

    // ==================================================
    // MultiQC: Trimmed FASTQ quality
    // ==================================================

    trimmed_qc_ch = FASTQC_TRIMMED.out.fastqc_trimmed_results
        .map { patient_id, zip_files -> zip_files }
        .collect()

    MULTIQC_TRIMMED(
        trimmed_qc_ch,
        'trimmed'
    )

    // ==================================================
    // MultiQC: STAR and featureCounts statistics
    // ==================================================

    alignment_qc_ch = STAR_ALIGN.out.mapping_stats
        .map { patient_id, log_file -> log_file }
        .mix(
            FEATURECOUNTS.out.assignment_stats
                .map { patient_id, summary_file -> summary_file }
        )
        .collect()

    MULTIQC_ALIGNMENT(
        alignment_qc_ch,
        'alignment'
    )
}
