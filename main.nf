#! /usr/bin/env nextflow

nextflow.enable.dsl = 2

include { version as nextclade_version;
          generate_from_genbank } from './modules/nextclade.nf'

include { align as augur_align;
          tree as augur_tree;
          export as augur_export } from './modules/augur.nf'

workflow {
    nextclade_version()
    | view { it -> "Nextclade Version: $it"}
    
    channel.from("$params.reference")
    | view { it -> "Reference: $it"}
    | generate_from_genbank
    | view { it -> "Nextclade Dataset: $it"}

    if( params.fasta ) {
        channel.fromPath("$params.fasta")
        | view { it -> "Fasta Input: $it"}
        | augur_align
        | augur_tree
//        | augur_export
        | view
    }
}