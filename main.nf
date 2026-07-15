nextflow.enable.dsl = 2


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
process runMentalist {
    tag "${params.project_name}"
    publishDir "${params.out_dir}/${params.project_name}", mode: 'copy', overwrite: true

    input:
        path preprocessed_dir

    output:
        path "*", emit: results

    script:
    """
    set -euo pipefail

    mkdir -p output_mount

    podman run --rm \\
      --userns=keep-id \\
      --user "\$(id -u):\$(id -g)" \\
      -v "\$PWD/preprocessed":/data/input:ro \\
      -v "\$PWD/output_mount":/data/output:rw \\
      mentalist:ONT-1.0.0-withEnterobase "${params.project_name}"

    # Copy contents directly, not the results directory
    cp -a output_mount/* .
    """
}


// Process 3: Generate versions
process getVersions {
    label "wftemplate"
    cpus 1
    memory "2 GB"

    output:
        path "versions.txt"

    script:
    """
    echo "nextflow,\$(nextflow -v | grep version | awk '{print \$2}')" >> versions.txt
    echo "podman,\$(podman --version | awk '{print \$2}')" >> versions.txt
    """
}


// Process 4: Get parameters
process getParams {
    label "wftemplate"
    cache false
    cpus 1
    memory "2 GB"

    output:
        path "params.json"

    script:
    def paramsJSON = new groovy.json.JsonBuilder(params).toPrettyString().replaceAll("'", "'\\\\''")
    """
    echo '$paramsJSON' > params.json
    """
}


// Process 5: Generate HTML report
process generateReport {
    label "wftemplate"
    publishDir "${params.out_dir}/${params.project_name}", mode: 'copy', pattern: "genome_similarity_report.html"

    input:
        path results_dir
        path params_json
        path versions

    output:
        path "genome_similarity_report.html"

    script:
    """
    export PYTHONPATH=\$PWD/bin:\$PYTHONPATH
    python3 -m workflow_glue genome_similarity_report genome_similarity_report.html \
        --jaccard_scores ${results_dir}/EnterobaseSalmWGMLSTscheme_k31_20220315/jaccard_score.tsv \
        --jaccard_pairwise ${results_dir}/EnterobaseSalmWGMLSTscheme_k31_20220315/jaccard_score_pairwise.tsv \
        --params ${params_json} \
        --versions ${versions} \
        --wf_version ${workflow.manifest.version}
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
    
    getVersions()
    getParams()
    
    generateReport(
        runMentalist.out.results,
        getParams.out,
        getVersions.out
    )
    
    runMentalist.out.results
        .subscribe { results ->
            println "Results published to: ${params.out_dir}/${params.project_name}"
        }
}
