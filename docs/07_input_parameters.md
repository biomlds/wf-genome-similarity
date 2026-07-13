### Input Options

| Nextflow parameter name  | Type | Description | Help | Default |
|--------------------------|------|-------------|------|---------|
| input | string | Directory containing `*.medaka.fasta.gz` genome assembly files. | Provide a flat directory containing compressed genome assemblies. The workflow will uncompress files as needed, but will not overwrite existing `*.medaka.fasta` files. |  |


### Output Options

| Nextflow parameter name  | Type | Description | Help | Default |
|--------------------------|------|-------------|------|---------|
| out_dir | string | Directory for output of all workflow results. |  | output |
| project_name | string | Name for the analysis project, passed to mentalist. | This name is used by mentalist to label the analysis and appears in the output files. | genome_similarity |
