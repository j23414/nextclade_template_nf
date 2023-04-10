#! /usr/bin/env nextflow

nextflow.enable.dsl = 2

include { version as nextclade_version;
          generate_from_genbank } from './modules/nextclade.nf'

workflow {
    nextclade_version()
    | view
    
    channel.from("$params.reference")
    | generate_from_genbank
    | view
}