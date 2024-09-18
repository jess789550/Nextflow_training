// nextflow run .

// Get file names
// workflow {
//     Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
//     | view
// }

// workflow {
//     Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
//     | map { id, reads ->
//         tokens = id.tokenize("_") // split id by _
//     }
//     | view
// }

// Map metadata and FASTQ files
// workflow {
//     Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
//     | map { id, reads ->
//             (sample, replicate, type) = id.tokenize("_")
//             replicate -= ~/^rep/
//             meta = [sample:sample, replicate:replicate, type:type] // assign split metadata into variables
//             [meta, reads]
//         }
//     | view
// }

// "treatment" metadata captured in our meta map
// workflow {
//     Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
//     | map { id, reads ->
//         reads.collect { it.getParent() } // get full path
//     }
//     | view
// }


// workflow {
//     Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
//     | map { id, reads -> reads*.getParent() // If we want to call a set method on every item in a Collection, Groovy provides this convenient "spread dot" notation
//        }
//     | view
// }



workflow {
    Channel.fromFilePairs("data/reads/*/*_R{1,2}.fastq.gz")
    | map { id, reads ->
        (sample, replicate, type) = id.tokenize("_")
        (treatmentFwd, treatmentRev) = reads*.parent*.name*.minus(~/treatment/) // Remove treatment prefix
        meta = [
            sample:sample,
            replicate:replicate,
            type:type,
            treatmentFwd:treatmentFwd,
            treatmentRev:treatmentRev,
        ]
        [meta, reads]
    }
    | view
}
