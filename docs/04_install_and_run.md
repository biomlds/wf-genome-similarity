
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

### Requirements

+ Nextflow
+ Docker or Singularity
+ The `mentalist:ONT-1.0.0-withEnterobase` container

### Example usage

Run the workflow with an input directory containing `*.medaka.fasta.gz` files:

```
nextflow run main.nf \
    --input /path/to/assemblies \
    --project_name my_project \
    --out_dir /path/to/output \
    -profile standard
```
