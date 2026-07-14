import groovy.json.JsonBuilder
nextflow.enable.dsl = 2

include {
    getParams;
} from './lib/common'



// params {
//     help = false
//     input = null
//     out_dir = "output"
//     project_name = "genome_similarity"
// }


// Process 1: Preprocess medaka files
// Checks for *.medaka.fasta.gz and uncompresses only when *.medaka.fasta is missing
process preprocessMedakaFiles {
    label "wftemplate"
    cpus 1
    memory "2 GB"

    input:
        path input_dir

    output:
        path "preprocessed"

    script:
    """
    mkdir -p preprocessed
    # Copy all files to preprocessed directory
    cp -r $input_dir/* preprocessed/ 2>/dev/null || true

    # Uncompress *.medaka.fasta.gz ONLY if *.medaka.fasta is missing
    for gz_file in preprocessed/*.medaka.fasta.gz; do
        [ -f "\$gz_file" ] || continue
        base_name="\${gz_file%.gz}"
        if [ ! -f "\$base_name" ]; then
            echo "Uncompressing: \$gz_file"
            gunzip -c "\$gz_file" > "\$base_name"
        else
            echo "Skipping (already exists): \$base_name"
        fi
    done
    """
}


// Process 2: Run mentalist container
// runMentalist V1
// process runMentalist {
//     label "mentalist"
//     publishDir "${params.out_dir}", mode: 'copy', pattern: "jaccard_score.csv"

//     input:
//         path preprocessed_dir

//     output:
//         path "jaccard_score.csv"

//     script:
//     """
//     # Stage preprocessed files into /data/input
//     cp -r $preprocessed_dir/* /data/input/

//     # Run mentalist with project name
//     mentalist "$params.project_name"

//     # Copy results
//     cp /data/output/jaccard_score.csv .
//     """
// }


process runMentalist {

    tag "${project_name}"

    publishDir "${params.out_dir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
    val input_folder_path
    val project_name

    output:
    path "results", emit: results

    script:
    """
    set -euo pipefail

    mkdir -p output_mount
    mkdir -p results

    podman run --rm \\
      --userns=keep-id \\
      --user "\$(id -u):\$(id -g)" \\
      -v "${input_folder_path}":/data/input:ro \\
      -v "\$PWD/output_mount":/data/output:rw \\
      mentalist:ONT-1.0.0-withEnterobase "${project_name}"

    cp -a output_mount/. results/
    """
}

// Main workflow
workflow {
    if (params.help) {
        log.info"""
        Genome Similarity Workflow
        ==========================
        Usage:
          nextflow run main.nf --input /path/to/assemblies --project_name myproject
        """
        exit 0
    }

    if (!params.input) {
        error "Please provide --input parameter pointing to folder with *.medaka.fasta.gz files"
    }

    preprocessMedakaFiles(params.input)
    runMentalist(preprocessMedakaFiles.out)
}
