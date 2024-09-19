// nextflow run .

// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type') // [id:row.id, repeat:row.repeat, type:row.type]
//         [meta, [
//             file(row.fastq1, checkIfExists: true),
//             file(row.fastq2, checkIfExists: true)]]
//     }
//     | view
// }

// // Bad example
// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type')
//         [meta, [
//             file(row.fastq1, checkIfExists: true),
//             file(row.fastq2, checkIfExists: true)]]
//     }
//     | set { samples }


//     samples
//     | map { sleep 10; it }
//     | view { meta, reads -> "Should be unmodified: $meta" }

//     samples
//     | map { meta, reads ->
//         meta.type = meta.type == "tumor" ? "abnormal" : "normal" // overwrite meta.type so not safe
//         [meta, reads]
//     }
//     | view { meta, reads -> "Should be modified: $meta" }
// }

// // Good example
// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type')
//         [meta, [
//             file(row.fastq1, checkIfExists: true),
//             file(row.fastq2, checkIfExists: true)]]
//     }
//     | set { samples }


//     samples
//     | map { sleep 10; it }
//     | view { meta, reads -> "Should be unmodified: $meta" }

//     samples
//     | map { meta, reads ->
//         newmap = [type: meta.type == "tumor" ? "abnormal" : "normal"] // define variable newmap
//         [meta + newmap, reads] // use +
//     }
//     | view { meta, reads -> "Should be modified: $meta" }
// }

process MapReads {
    input:
    tuple val(meta), path(reads)
    path(genome)

    output:
    tuple val(meta), path("*.bam")

    "touch out.bam"
}

// workflow {
//     reference = Channel.fromPath("data/genome.fasta").first()

//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type')
//         [meta, [file(row.fastq1, checkIfExists: true), file(row.fastq2, checkIfExists: true)]]
//     }
//     | map { meta, reads -> [meta.subMap('id', 'type'), meta.repeat, reads] }
//     | groupTuple
//     | map { meta, repeats, reads -> [meta + [repeatcount:repeats.size()], repeats, reads] }
//     | transpose
//     | map { meta, repeat, reads -> [meta + [repeat:repeat], reads]}
//     | set { samples }

//     MapReads( samples, reference )
//     | view
// }

// workflow {
//     reference = Channel.fromPath("data/genome.fasta").first()

//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type')
//         [meta, [file(row.fastq1, checkIfExists: true), file(row.fastq2, checkIfExists: true)]]
//     }
//     | map { meta, reads -> [meta.subMap('id', 'type'), meta.repeat, reads] }
//     | groupTuple
//     | map { meta, repeats, reads -> [meta + [repeatcount:repeats.size()], repeats, reads] }
//     | transpose
//     | map { meta, repeat, reads -> [meta + [repeat:repeat], reads]}
//     | set { samples }

//     MapReads( samples, reference )
//     | map { meta, bam ->
//         //groupKey method takes the grouping object as a first parameter and the number of expected elements in the second parameter
//         key = groupKey(meta.subMap('id', 'type'), meta.repeatcount) //  group bams that share the id and type
//         [key, bam]
//     }
//     | groupTuple
//     | view
// }

process CombineBams {
    input:
    tuple val(meta), path("input/in_*_.bam")

    output:
    tuple val(meta), path("combined.bam")

    "cat input/*.bam > combined.bam"
}

// workflow {
//     reference = Channel.fromPath("data/genome.fasta").first()

//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header:true )
//     | map { row ->
//         meta = row.subMap('id', 'repeat', 'type')
//         [meta, [file(row.fastq1, checkIfExists: true), file(row.fastq2, checkIfExists: true)]]
//     }
//     | map { meta, reads -> [meta.subMap('id', 'type'), meta.repeat, reads] }
//     | groupTuple
//     | map { meta, repeats, reads -> [meta + [repeatcount:repeats.size()], repeats, reads] }
//     | transpose
//     | map { meta, repeat, reads -> [meta + [repeat:repeat], reads]}
//     | set { samples }

//     MapReads( samples, reference )
//     | map { meta, bam ->
//         key = groupKey(meta.subMap('id', 'type'), meta.repeatcount)
//         [key, bam]
//     }
//     | groupTuple
//     | CombineBams
//     | view
// }

process GenotypeOnInterval {
    input:
    tuple val(meta), path(bam), path(bed)

    output:
    tuple val(meta), path("genotyped.bam")

    "cat $bam $bed > genotyped.bam"
}

process MergeGenotyped {
    publishDir 'results/genotyped'
    // publishDir 'results/genotyped', saveAs: { "${meta.id}.${meta.type}.genotyped.bam" } // make sure files have unique names - error cannot find meta.id

    input:
    tuple val(meta), path("input/in_*_.bam")

    output:
    tuple val(meta), path("merged.genotyped.bam")

    "cat input/*.bam > merged.genotyped.bam"
    // "cat input/*.bam > ${meta.id}.${meta.type}.genotyped.bam" // make sure files have unique names - error cannot find meta.id
}

workflow {
    reference = Channel.fromPath("data/genome.fasta").first()

    Channel.fromPath("data/samplesheet.csv")
    | splitCsv( header:true )
    | map { row ->
        meta = row.subMap('id', 'repeat', 'type')
        [meta, [file(row.fastq1, checkIfExists: true), file(row.fastq2, checkIfExists: true)]]
    }
    | map { meta, reads -> [meta.subMap('id', 'type'), meta.repeat, reads] }
    | groupTuple
    | map { meta, repeats, reads -> [meta + [repeatcount:repeats.size()], repeats, reads] }
    | transpose
    | map { meta, repeat, reads -> [meta + [repeat:repeat], reads]}
    | set { samples }
    
    // take existing BED file and turn into channel of maps
    Channel.fromPath("data/intervals.bed")
    | splitCsv(header: ['chr', 'start', 'stop', 'name'], sep: '\t')
    | collectFile { entry -> ["${entry.name}.bed", entry*.value.join("\t")] }
    | view
    | set { intervals }

    MapReads( samples, reference )
    | map { meta, bam ->
        key = groupKey(meta.subMap('id', 'type'), meta.repeatcount)
        [key, bam]
    }
    | groupTuple
    | CombineBams
    | map { meta, bam -> [meta.subMap('id', 'type'), bam] }
    | combine( intervals ) 
    | GenotypeOnInterval // combine BAM and BED interval files
    | map { groupKey, bamfile -> [groupKey.target, bamfile] }
    | groupTuple
    | MergeGenotyped // merge genotyped BAMs together
    | view
}

