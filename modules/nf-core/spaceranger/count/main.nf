process SPACERANGER_COUNT {
    tag "$meta.id"
    label 'process_high'

    container "nf-core/spaceranger:3.0.0"

    input:
    tuple val(meta), path(reads), path(image), path(cytaimage), path(darkimage), path(colorizedimage), path(alignment), path(slidefile)
    path(reference)
    path(probeset)

    output:
    tuple val(meta), path("outs/filtered_feature_bc_matrix.h5"), emit: countsh5
    tuple val(meta), path("outs/spatial/tissue_lowres_image.png"), emit: lowres
    tuple val(meta), path("outs/spatial/scalefators_json.json"), emit: scalefactors
    tuple val(meta), path("outs/spatial/tissue_positions.csv"), emit: tissuepositions
    tuple val(meta), path("outs/probe_set.csv"), emit: probeset
    tuple val(meta), path("outs/metrics_summary.csv"), emit: metrics
    tuple val(meta), path("outs/raw_feature_bc_matrix/barcodes.tsv.gz"), emit: barcodesgz
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "SPACERANGER_COUNT module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Add flags for optional inputs on demand.
    def probeset = probeset ? "--probe-set=\"${probeset}\"" : ""
    def alignment = alignment ? "--loupe-alignment=\"${alignment}\"" : ""
    def slidefile = slidefile ? "--slidefile=\"${slidefile}\"" : ""
    def image = image ? "--image=\"${image}\"" : ""
    def cytaimage = cytaimage ? "--cytaimage=\"${cytaimage}\"" : ""
    def darkimage = darkimage ? "--darkimage=\"${darkimage}\"" : ""
    def colorizedimage = colorizedimage ? "--colorizedimage=\"${colorizedimage}\"" : ""
    """
    spaceranger count \\
        --id="${prefix}" \\
        --sample="${meta.id}" \\
        --fastqs=. \\
        --slide="${meta.slide}" \\
        --area="${meta.area}" \\
        --transcriptome="${reference}" \\
        --localcores=${task.cpus} \\
        --localmem=${task.memory.toGiga()} \\
        $image $cytaimage $darkimage $colorizedimage \\
        $probeset \\
        $alignment \\
        $slidefile \\
        $args
    mv ${prefix}/outs outs

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaceranger: \$(spaceranger -V | sed -e "s/spaceranger spaceranger-//g")
    END_VERSIONS
    """

    stub:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "SPACERANGER_COUNT module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    """
    mkdir -p outs/
    touch outs/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spaceranger: \$(spaceranger -V | sed -e "s/spaceranger spaceranger-//g")
    END_VERSIONS
    """
}
