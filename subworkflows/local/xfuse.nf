include { XFUSE_CONVERT } from '../../modules/local/xfuse/covert/main'

workflow XFUSE {
    take:
    ch_image
    ch_bcmatrix
    ch_tissuepositions
    ch_scalefactors
    ch_annotation
    val_scale

    main:
    XFUSE_CONVERT( ch_image, ch_bcmatrix, ch_tissuepositions, ch_scalefactors, ch_annotation, val_scale )


    // XFUSE_CONFIG( XFUSE_CONVERT.out.h5 )
    // XFUSE_RUN( XFUSE_CONFIG.out.toml )

    emit:
    // XFUSE_RUN.out.
    xfuseoutput = XFUSE_CONVERT.out.h5

}