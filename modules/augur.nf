#! /usr/bin/env nextflow

nextflow.enable.dsl=2

process align {
  input: tuple path(fasta), path(reference_genome_gff)
  output: path("${fasta.simpleName}_aligned.fasta")
  script:
  """
  augur align \
  --sequences ${fasta} \
  --reference-sequence ${reference_genome_gff} \
  --output ${fasta.simpleName}_aligned.fasta \
  --fill-gaps \
  --nthreads `nproc`
  """
}

process tree {
  input: path(aligned_fasta)
  output: path("${aligned_fasta.simpleName}_tree.nwk")
  script:
  """
  augur tree \
  --alignment ${aligned_fasta} \
  --output ${aligned_fasta.simpleName}_tree.nwk
  """
}

process refine {
  input: tuple path(tree_nwk), path(aligned_fasta), path(metadata)
  output: tuple path("tree.nwk"), path("branch_labels.json")
  script:
  """
  augur refine \
  --tree ${tree_nwk} \
  --alignment ${aligned_fasta} \
  --metadata ${metadata} \
  --output-tree tree.nwk \
  --output-node-data branch_labels.json
  """
}

process ancestral {
  input: tuple path(tree_nwk), path(aligned_fasta)
  output: path("nt-muts.json")
  script:
  """
  augur ancestral \
  --tree ${tree_nwk} \
  --alignment ${aligned_fasta} \
  --output-node-data nt-muts.json \
  --inference joint
  """
}

process translate {
  input: tuple path(nt_muts), path(tree_nwk), path(reference_genome_gff)
  output: path("aa-muts.json")
  script:
  """
  augur translate \
  --tree ${tree_nwk} \
  --ancestral-sequences ${nt_muts} \
  --reference-sequence ${reference_genome_gff} \
  --output aa-muts.json
  """
}

process traits_clade_membership {
  input: tuple path(tree_nwk), path(metadata)
  output: path("clade_membership.json")
  script:
  """
  augur traits \
  --tree ${tree_nwk} \
  --metadata ${metadata} \
  --output clade_membership.json \
  --columns clade_membership
  """
}

process export {
  input: tuple path(nwk_tree), path(jsons)
  output: path("tree.json")
  script:
  """
  augur export v2 \
    --tree ${nwk_tree} \
    --node-data ${jsons} \
    --output tree.json
  """
}