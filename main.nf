#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process hello {
    input:
    val name

    output:
    stdout

    script:
    """
    echo "Hello, ${name}!"
    """
}

workflow {
    // Define the input names
    names = ['Alice', 'Bob', 'Charlie']

    // Create a channel from the list of names
    nameChannel = Channel.from(names)

    // Use the channel to run the hello process
    hello(nameChannel)
}