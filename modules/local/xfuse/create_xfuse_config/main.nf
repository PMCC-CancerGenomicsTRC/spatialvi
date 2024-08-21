process XFUSE { 
    label 'process_low'

    container "vstreetoncook/xfuse:latest"

    input:
    path(data)

    output:
    path(my-config.toml), emit: toml

    script:
    """"
    xfuse init my-config.toml 
    """"
}