process XFUSE { 
    label 'process_low'

    container "vstreetoncook/xfuse:latest"

    input:
    path(image)
    path(bcmatrix)
    path(tissuepositions)
    path(scalefactors)
    path(annotation)
    path(scale)

    output:
    path(*/data.h5), emit: h5

    script:

    def annotation_flag = annotation ? "--annotation $annotation" : ''
    def scale_flag = scale ? "--scale $scale" : ''
    
    """"
    xfuse convert visium\\
        --image $image\\
        --bc-matrix $bcmatrix\\
        --tissue-positions $tissuepositions \\
        --annotation $annotation \\
        --scale-factors $scalefactors \\
        --scale $scale \\
    """"
}