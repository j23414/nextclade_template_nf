#! /usr/bin/env nextflow

nextflow.enable.dsl = 2

include { version as nextclade_version;
          generate_from_genbank } from './modules/nextclade.nf'

include { nextalign } from './modules/nextalign.nf'

include { tree as augur_tree;
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
    | map {it -> it.get(0)}
    | view { it -> "Nextclade Dataset: $it"}

    ref_fasta_ch = generate_from_genbank.out
    | map {it -> it.get(1)}

    ref_gff_ch = generate_from_genbank.out
    | map {it -> it.get(2)}

    if( params.fasta ) {
        aln_ch = channel.fromPath("$params.fasta")
        | view { it -> "Fasta Input: $it"}
        | combine(ref_fasta_ch)    
        | combine(ref_gff_ch)
        | nextalign
        | map { it -> it.get(0) }

        aln_ch
        | augur_tree
        | combine(aln_ch)
        | combine(channel.fromPath("$params.metadata"))
        | augur_refine

        tree_ch = augur_refine.out 
        | map { it -> it.get(0) }

        branch_labels_ch = augur_refine.out
        | map { it -> it.get(1) }

        tree_ch 
        | combine(aln_ch)
        | augur_ancestral
        | combine(tree_ch)
        | combine(ref_gff_ch)
        | augur_translate

        tree_ch
        | combine(channel.fromPath("$params.metadata"))
        | augur_traits_clade_membership

        jsons_ch = branch_labels_ch
        | combine(augur_ancestral.out)
        | combine(augur_translate.out)
        | combine(augur_traits_clade_membership.out)
        | map { it -> [it] }

        tree_ch 
        | combine(jsons_ch)
        | augur_export
        | map { it -> it.simpleName}
        | view { it -> "Augur Export: $it" }
    }
}