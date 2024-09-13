#!/usr/bin/env nextflow

// define parameters
params.greeting = 'Hello world!'

// import processes
include { SPLITLETTERS as SPLITLETTERS_one } from './modules.nf'
include { SPLITLETTERS as SPLITLETTERS_two } from './modules.nf'

include { CONVERTTOUPPER as CONVERTTOUPPER_one } from './modules.nf'
include { CONVERTTOUPPER as CONVERTTOUPPER_two } from './modules.nf'

// define workflows
workflow my_workflow_one {
    letters_ch1 = SPLITLETTERS_one(params.greeting)
    results_ch1 = CONVERTTOUPPER_one(letters_ch1.flatten())
    results_ch1.view { it }
}

workflow my_workflow_two {
    letters_ch2 = SPLITLETTERS_two(params.greeting)
    results_ch2 = CONVERTTOUPPER_two(letters_ch2.flatten())
    results_ch2.view { it }
}

workflow {
    my_workflow_one(Channel.of(params.greeting))
    my_workflow_two(Channel.of(params.greeting))
}

// nextflow run hello2.nf -entry my_workflow_one 
