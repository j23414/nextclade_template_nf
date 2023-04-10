#! /usr/bin/env nextflow

nextflow.enable.dsl=2

process version {
    output: path("version.txt")

    script:
    """
    nextclade --version &> version.txt
    """
}

process generate_from_genbank {
  input: val(genbank_id)
  output: path("virus_nextclade_dataset")
  script:
  """
  curl -fsSL --output generate_from_genbank.py https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/generate_from_genbank.py 

  # Huh, this relies on the files folder being in the same directory as the script
  mkdir files
  # Guess the script is really copying over these files which will need to be adjusted later
  curl -fsSL --output files/primers.csv https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/primers.csv
  curl -fsSL --output files/qc.json https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/qc.json
  curl -fsSL --output files/sequences.fasta https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/sequences.fasta
  curl -fsSL --output files/tag.json https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/tag.json
  curl -fsSL --output files/tree.json https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/tree.json
  curl -fsSL --output files/virus_properties.json https://raw.githubusercontent.com/nextstrain/nextclade_dataset_template/main/files/virus_properties.json

  python generate_from_genbank.py --reference ${genbank_id} --output-dir virus_nextclade_dataset
  """
}