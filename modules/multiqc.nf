
process MULTIQC {

    tag "${report_type}"

    container 'melanoma_rna:1.0'

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path qc_files
    val report_type

    output:
    path "multiqc_${report_type}.html", emit: multiqc_report
    path "multiqc_${report_type}_data", emit: multiqc_data

    script:
    """
    multiqc . \\
        --force \\
        --filename multiqc_${report_type}.html \\
        --data-dir multiqc_${report_type}_data
    """
}
