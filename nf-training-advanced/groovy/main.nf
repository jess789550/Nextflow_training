// nextflow run .
// nextflow run . -resume -entry Jsontest

include { FASTP } from './modules/local/fastp/main.nf'

import groovy.json.JsonSlurper

// def getFilteringResult(json_file) {
//     fastpResult = new JsonSlurper().parseText(json_file.text) // takes the JSON file and produces basic metrics
// }

def getFilteringResult(json_file) {
    new JsonSlurper().parseText(json_file.text)
    ?.summary
    ?.after_filtering // just the after_filtering section of the report
}

// Get CSV file from remote source
// workflow {
//     params.input = "https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/samplesheet/v3.10/samplesheet_test.csv"

//     Channel.fromPath(params.input)
//     | splitCsv(header: true)
//     | view
// }

// workflow {
//     params.input = "https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/samplesheet/v3.10/samplesheet_test.csv"

//     Channel.fromPath(params.input)
//     | splitCsv(header: true)
//     | map { row ->
//         meta = row.subMap('sample', 'strandedness')
//         meta
//     }
//     | view
// }


// workflow {
//     params.input = "https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/samplesheet/v3.10/samplesheet_test.csv"

//     Channel.fromPath(params.input)
//     | splitCsv(header: true)
//     | map { row ->
//         (readKeys, metaKeys) = row.keySet().split { it =~ /^fastq/ } // partition the column names into those that begin with "fastq" and those that don't
//         reads = row.subMap(readKeys).values()
//         .findAll { it != "" } // Single-end reads will have an empty string
//         .collect { file(it) } // Turn those strings into paths
//         meta = row.subMap(metaKeys)
//         meta.id ?= meta.sample
//         meta.single_end = reads.size == 1
//         [meta, reads]
//     }
//     | FASTP

//     FASTP.out.json | view
// }

workflow {
    params.input = "https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/samplesheet/v3.10/samplesheet_test.csv"

    Channel.fromPath(params.input)
    | splitCsv(header: true)
    | map { row ->
        (readKeys, metaKeys) = row.keySet().split { it =~ /^fastq/ } // partition the column names into those that begin with "fastq" and those that don't
        reads = row.subMap(readKeys).values()
        .findAll { it != "" } // Single-end reads will have an empty string
        .collect { file(it) } // Turn those strings into paths
        meta = row.subMap(metaKeys)
        meta.id ?= meta.sample
        meta.single_end = reads.size == 1
        [meta, reads]
    }
    | FASTP

    FASTP.out.json
    | map { meta, json -> [meta, getFilteringResult(json)] } // create map for JSON
    | join( FASTP.out.reads ) // join new map to orignal reads
    | map { meta, fastpMap, reads -> [meta + fastpMap, reads] }
    | branch { meta, reads ->
        pass: meta.q30_rate >= 0.935 // Q30 rate is more than 93.5%
        fail: true // Q30 rate is less than 93.5%?
    }
    | set { reads }

    reads.fail | view { meta, reads -> "Failed: ${meta.id}" } 
    reads.pass | view { meta, reads -> "Passed: ${meta.id}" } 
}


workflow Jsontest {
    Channel.fromPath("results/fastp/json/*.json")
    | view
}
