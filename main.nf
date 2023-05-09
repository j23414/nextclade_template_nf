#! /usr/bin/env nextflow

nextflow.enable.dsl = 2

include { version as nextclade_version;
          generate_from_genbank } from './modules/nextclade.nf'

include { align as augur_align;
          tree as augur_tree;
          refine as augur_refine;
          ancestral as augur_ancestral;
          translate as augur_translate;
          traits_clade_membership as augur_traits_clade_membership;
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
        | combine(channel.fromPath("$params.reference"))        
        | augur_align
        | augur_tree
        | combine(augur_align.out)
        | augur_refine
//        | combine(channel.fromPath("$params.metadata"))
//        | augur_traits
//        | augur_export
        | view
    }
}