#!/usr/bin/env nextflow

params.greeting = 'Hello world!' // default greeting
greeting_ch = Channel.of(params.greeting)

// split string into chunks of 6 letters
process SPLITLETTERS {
    input:
    val x

    output:
    path 'chunk_*'

    script:
    """
    printf '$x' | split -b 6 - chunk_
    """
}

// original: convert string from lowercase to uppercase
// modified: reverse string
process CONVERTTOUPPER {
    input:
    path y

    output:
    stdout

    script:
    """
    #cat $y | tr '[a-z]' '[A-Z]' 
    rev $y
    """
}

// run processes 
workflow {
    letters_ch = SPLITLETTERS(greeting_ch)
    results_ch = CONVERTTOUPPER(letters_ch.flatten()) // flatten multiple lists into one
    results_ch.view{ it } // print the current element (it)
}

// run script
// nextflow run hello.nf
// nextflow run hello.nf --greeting 'Bonjour le monde!'
