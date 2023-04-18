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
  input: tuple path(nwk_tree), path(clade_membership_json)
  output: path("tree.json")
  script:
  """
  // Requires some metadata as node-data.json, maybe with "strain" and "clade_membership" column? 
  // Could include pathogen specific features such as gene constellations for flu
  augur export v2 \
    --input ${nwk_tree} \
    --node-data ${clade_membership_json} \
    --output tree.json
  """
}

process traits {
  input: tuple path(nwk_tree), path(clade_membership_csv)
  output: path("clade_membership.json") // strain,clade_membership
  script:
  """
  augur traits \
    --tree ${nwk_tree} \
    --metadata ${clade_membership_csv} \
    --output clade_membership.json
  """
}