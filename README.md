# Genome Similarity Workflow

EPI2ME workflow for genome similarity analysis using mentalist.


## Introduction

This workflow performs genome similarity analysis on compressed genome assemblies (`*.medaka.fasta.gz`). It:

1. **Preprocesses** input files by uncompressing `*.medaka.fasta.gz` files only when the corresponding `*.medaka.fasta` does not already exist
2. **Runs mentalist** to compute pairwise Jaccard similarity scores between genome assemblies
3. **Outputs** a `jaccard_score.csv` file containing the similarity matrix


## Compute requirements

Recommended requirements:

+ CPUs = 4
+ Memory = 8GB

Minimum requirements:

+ CPUs = 1
+ Memory = 2GB

Approximate run time: Variable depending on number of samples

ARM processor support: True


## Install and run

These are instructions to install and run the workflow on command line.
You can also access the workflow via the
[EPI2ME Desktop application](https://epi2me.nanoporetech.com/downloads/).

The workflow uses [Nextflow](https://www.nextflow.io/) to manage
compute and software resources,
therefore Nextflow will need to be
installed before attempting to run the workflow.

The workflow can currently be run using either
[Docker](https://docs.docker.com/get-started/)
or [Singularity](https://docs.sylabs.io/guides/3.0/user-guide/index.html)
to provide isolation of the required software.
Both methods are automated out-of-the-box provided
either Docker or Singularity is installed.
This is controlled by the
[`-profile`](https://www.nextflow.io/docs/latest/config.html#config-profiles)
parameter as exemplified below.

It is not required to clone or download the git repository
in order to run the workflow.
More information on running EPI2ME workflows can
be found in the
[documentation](https://epi2me.nanoporetech.com/epi2me-docs/wfquickstart/).

The following command can be used to obtain the workflow.
This will pull the repository in to the assets folder of
Nextflow and provide a list of all parameters
available for the workflow as well as an example command:

```
nextflow run main.nf --help
```

### Example usage

Run the workflow with an input directory containing `*.medaka.fasta.gz` files:

```
nextflow run main.nf \
    --input /path/to/assemblies \
    --project_name my_project \
    --out_dir /path/to/output \
    -profile standard
```


## Input example

This workflow accepts a flat directory containing compressed genome assembly files.

### Expected input structure

```
─── input_folder
    ├── SAMPLE1.medaka.fasta.gz
    ├── SAMPLE2.medaka.fasta.gz
    ├── SAMPLE3.medaka.fasta.gz
    └── ...
```

### File naming convention

Files must follow the pattern: `SAMPLENAME.medaka.fasta.gz`

Where `SAMPLENAME` is the unique identifier for each sample.

### Preprocessing behavior

- If `SAMPLENAME.medaka.fasta.gz` exists and `SAMPLENAME.medaka.fasta` does **not** exist: the `.gz` file will be uncompressed
- If both `SAMPLENAME.medaka.fasta.gz` and `SAMPLENAME.medaka.fasta` exist: the existing `.fasta` file is preserved (no overwrite)
- If only `SAMPLENAME.medaka.fasta` exists: it will be used as-is


## Pipeline overview

### 1. Preprocess medaka files

The workflow checks for `*.medaka.fasta.gz` files and uncompresses them only when the corresponding `*.medaka.fasta` file does not already exist. This ensures existing assembly files are never overwritten.

### 2. Run mentalist

The [mentalist](https://github.com/rrwick/mentalist) container is executed to compute pairwise Jaccard similarity scores between all genome assemblies in the input directory.

### 3. Output results

The workflow produces a `jaccard_score.csv` file containing the pairwise similarity matrix.


## Input parameters

### Input Options

| Nextflow parameter name  | Type | Description | Help | Default |
|--------------------------|------|-------------|------|---------|
| input | string | Directory containing `*.medaka.fasta.gz` genome assembly files. | Provide a flat directory containing compressed genome assemblies. The workflow will uncompress files as needed, but will not overwrite existing `*.medaka.fasta` files. |  |


### Output Options

| Nextflow parameter name  | Type | Description | Help | Default |
|--------------------------|------|-------------|------|---------|
| out_dir | string | Directory for output of all workflow results. |  | output |
| project_name | string | Name for the analysis project, passed to mentalist. | This name is used by mentalist to label the analysis and appears in the output files. | genome_similarity |


## Outputs

| Title | File path | Description | Per sample or aggregated |
|-------|-----------|-------------|--------------------------|
| Jaccard Similarity Scores | jaccard_score.csv | Pairwise Jaccard similarity scores between genome assemblies. | aggregated |


## Related protocols

This workflow is designed to take input sequences that have been produced from [Oxford Nanopore Technologies](https://nanoporetech.com/) devices.

Find related protocols in the [Nanopore community](https://community.nanoporetech.com/docs/).


## Troubleshooting

+ If the workflow fails please run it with the demo data set to ensure the workflow itself is working. This will help us determine if the issue is related to the environment, input parameters or a bug.
+ See how to interpret some common nextflow exit codes [here](https://labs.epi2me.io/trouble-shooting/).
+ Ensure the `mentalist:ONT-1.0.0-withEnterobase` container is available on your system.


## FAQs

+ **Q: What happens if I have both `.gz` and uncompressed files?**
  A: The workflow will skip uncompression for samples that already have the `.fasta` file, preserving your existing assemblies.

+ **Q: Can I provide uncompressed `.fasta` files directly?**
  A: Yes. If you only provide `*.medaka.fasta` files (no `.gz`), the preprocessing step will pass them through unchanged.

If your question is not answered here, please report any issues or suggestions on the [github issues](https://github.com/epi2me-labs/wf-template/issues) page or start a discussion on the [community](https://community.nanoporetech.com/).
