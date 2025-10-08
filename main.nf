/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC as FASTQC_RAW } from './modules/nf-core/fastqc/main'
include { FASTQC as FASTQC_TRIMMED } from './modules/nf-core/fastqc/main'
include { TRIMMOMATIC } from './modules/nf-core/trimmomatic/main'

workflow {
    // Create a channel for input reads
    reads_ch = Channel
        .fromPath(params.reads, checkIfExists: true)
        .splitCsv(header:true, sep:'\t')
        .map { row ->
            def meta = [id: row.sample_id, single_end: false]
            tuple(meta,[file(row.forward),file(row.reverse)])
        }

    nanopore_reads_ch = Channel.empty()

    // Run FASTQC on raw reads
    FASTQC_RAW(reads_ch)

    // Run TRIMMOMATIC
    TRIMMOMATIC(reads_ch)
    trimmed_reads_ch = TRIMMOMATIC.out.trimmed_reads

    // Run FASTQC on trimmed reads
    FASTQC_TRIMMED(trimmed_reads_ch)
}
