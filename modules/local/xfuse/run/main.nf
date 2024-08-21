process XFUSE { 
    label 'process_low'

    container "vstreetoncook/xfuse:latest"

    input:
    path(config)

    output:
    
    path(*/data.h5), emit: h5

    script:

    """"
    xfuse run config\\
        --save_path my-run
    """"
}