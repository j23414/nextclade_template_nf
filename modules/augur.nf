#! /usr/bin/env nextflow

nextflow.enable.dsl=2

process align {
  input: path(fasta)
  output: path("${fasta.simpleName}_aligned.fasta")
  script:
  """
  augur align --sequences ${fasta} --output ${fasta.simpleName}_aligned.fasta
  """
}

process tree {
  input: path(aligned_fasta)
  output: path("${aligned_fasta.simpleName}_tree.nwk")
  script:
  """
  augur tree --alignment ${aligned_fasta} --output ${aligned_fasta.simpleName}_tree.nwk
  """
}

process export {
  input: path(nwk_tree)
  output: path("tree.json")
  script:
  """
  augur export v2 --input ${nwk_tree} --output tree.json
  """
}