# nextclade_template_nf

Small exploration of creating nextclade datasets based on the following template

* https://github.com/nextstrain/nextclade_dataset_template

```
nextflow run j23414/nextclade_template_nf -r main \
  --reference "GenBankID" \
  --fasta "path/to/reference/fasta_to_build_tree_json" \
  --metadata "path/to/metadata_containing_clade_membership_tsv"
```

Some parts may not be automated depending on what is required in these files

* Example: https://github.com/nextstrain/nextclade_data/tree/master/data/datasets/flu_vic_ha/references/KX058884/versions/2023-04-02T12%3A00%3A00Z/files

| File | Explaination|
| :--|:--|
| genemap.gff| | 
| primers.csv | | 
| qc.json | | 
| reference.fasta | | 
| sequences.fasta | | 
| tag.json | |
| tree.json| |
| virus_properties.json| |
