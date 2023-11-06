process KMERFINDER {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::kmerfinder=3.0.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kmerfinder:3.0.2--hdfd78af_0' :
        'biocontainers/kmerfinder:3.0.2--hdfd78af_0' }"

    input:
    tuple val(meta), path(reads)
    path(kmerfinderDB)

    output:
    tuple val(meta), path("*_results.txt")  , emit: report
    path "versions.yml"                     , emit: versions

    script:
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def in_reads    = reads.size() == 1 ? "${reads}" : "${reads[0]} ${reads[1]}"

    """
    kmerfinder.py \\
        --infile $in_reads \\
        --output_folder . \\
        --db_path ${kmerfinderDB}/bacteria.ATG \\
        -tax ${kmerfinderDB}/bacteria.name \\
        -x

    mv results.txt ${prefix}_results.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kmerfinder: \$(echo "3.0.2")
    END_VERSIONS
    """
}
