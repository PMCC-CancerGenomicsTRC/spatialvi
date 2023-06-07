// TODO nf-core: install with nf-core modules install once merged
process SPACERANGER_COUNT {
    tag "$meta.id"
    label 'process_high'

    // TODO push to nf-core docker
    container "ghcr.io/grst/spaceranger:2.1.0"

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit 1, "SPACERANGER_COUNT module does not support Conda. Please use Docker / Singularity / Podman instead."
    }


    input:
    tuple val(meta), path(reads), path(image), path(alignment), path(slidefile)
    path(reference)
    path(probeset)

    output:
    tuple val(meta), path("**/outs/**"), emit: outs
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Add flags for optional inputs on demand.
    def probeset = probeset ? "--probe-set=\"${probeset}\"" : ""
    def alignment = alignment ? "--loupe-alignment=\"${alignment}\"" : ""
    def slidefile = slidefile ? "--slidefile=\"${slidefile}\"" : ""
    // Choose the appropriate flag depending on the input type, e.g.
    // --darkimage for fluorescence, --cytaimage for cytassist, ...
    // Defaults to `--image` for brightfield microscopy.
    def img_type = task.ext.img_type ?: "--image"
    """
    spaceranger count \\
        --id="${prefix}" \\
        --sample="${meta.id}" \\
        --fastqs=. \\
        ${img_type}="${image}" \\
        --slide="${meta.slide}" \\
        --area="${meta.area}" \\
        --transcriptome="${reference}" \\
        --localcores=${task.cpus} \\
        --localmem=${task.memory.toGiga()} \\
        $probeset \\
        $alignment \\
        $slidefile \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaceranger: \$(spaceranger -V | sed -e "s/spaceranger spaceranger-//g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p "${prefix}/outs/"
    touch ${prefix}/outs/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaceranger: \$(spaceranger -V | sed -e "s/spaceranger spaceranger-//g")
    END_VERSIONS
    """
}
