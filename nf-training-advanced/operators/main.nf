// Map manipulates input and View prints output
// workflow {
//     Channel.of( 1, 2, 3, 4, 5 )
//     | map { it * it }
//     | view
// }

// def squareIt = { it * it }
// def addTwo = { it + 2 }

// workflow {
//     Channel.of( 1, 2, 3, 4, 5 )
//     | map( squareIt >> addTwo )
//     | view
// }

// def timesN = { multiplier, it -> it * multiplier }
// def timesTen = timesN.curry(10)

// workflow {
//     Channel.of( 1, 2, 3, 4, 5 )
//     | map( timesTen )
//     | view { "Found '$it' (${it.getClass()})"}
// }

// Split CSV allow you to view CSV files
// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header: true )
//     | map { row ->
//         [row.id, [file(row.fastq1), file(row.fastq2)]]
//     }
//     | view
// }

// Multi Map outputs multiple channels from a single input
// workflow {
//     Channel.fromPath("data/samplesheet.ugly.csv")
//     | splitCsv( header: true )
//     | multiMap { row ->
//         tumor:
//             metamap = [id: row.id, type:'tumor', repeat:row.repeat]
//             [metamap, file(row.tumor_fastq_1), file(row.tumor_fastq_2)]
//         normal:
//             metamap = [id: row.id, type:'normal', repeat:row.repeat]
//             [metamap, file(row.normal_fastq_1), file(row.normal_fastq_2)]
//     }
//     | set { samples }

//     samples.tumor | view { "Tumor: $it"}
//     samples.normal | view { "Normal: $it"}
// }

// Branch is similar to multiMap but needs cleaner data
// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv( header: true )
//     | map { row -> [[id: row.id, repeat: row.repeat, type: row.type], [file(row.fastq1), file(row.fastq2)]] }
//     | branch { meta, reads ->
//     tumor: meta.type == "tumor"
//         return [meta + [type: 'abnormal'], reads]
//     normal: true
//     }
//     | set { samples }

//     samples.tumor | view { "Tumor: $it"}
//     samples.normal | view { "Normal: $it"}
// }


// Multiple inputs
// process MultiInput {
//     debug true
//     input:
//     val(smallNum)
//     val(bigNum)

//     "echo -n small is $smallNum and big is $bigNum"
// }

// workflow {
//     Channel.of( 1, 2, 3, 4, 5 )
//     | multiMap {
//         small: it
//         large: it * 10
//     }
//     | set { numbers }

//     MultiInput(numbers.small, numbers.large)
// }

// groupTuple combines elements that share a common key and transpose is the inverse of groupTuple
// workflow {
//     Channel.fromPath("data/samplesheet.csv")
//     | splitCsv(header: true)
//     | map { row ->
//         meta = [id: row.id, type: row.type]
//         [meta, row.repeat, [row.fastq1, row.fastq2]]
//     }
//     | groupTuple
//     | transpose  // try with/without this line
//     | view
// }

// flatMap can change the output
// mkdir -p data/datfiles/sample{1,2}
// touch data/datfiles/sample1/data.{1,2,3,4,5,6,7}.dat
// touch data/datfiles/sample2/data.{1,2,3,4}.dat
// tree data/datfiles

// workflow {
//     Channel.fromPath("data/datfiles/sample*/*.dat")
//     | map { [it.getParent().name, it] }
//     | groupTuple
//     | flatMap { id, files -> files.collate(3).collect { chunk -> [id, chunk] } }
//     | view
// }

// collectFile allows you to write files 
// workflow {
//     characters = Channel.of(
//         ['name': 'Jake', 'title': 'Detective'],
//         ['name': 'Rosa', 'title': 'Detective'],
//         ['name': 'Terry', 'title': 'Sergeant'],
//         ['name': 'Amy', 'title': 'Detective'],
//         ['name': 'Charles', 'title': 'Detective'],
//         ['name': 'Gina', 'title': 'Administrator'],
//         ['name': 'Raymond', 'title': 'Captain'],
//         ['name': 'Michael', 'title': 'Detective'],
//         ['name': 'Norm', 'title': 'Detective']
//     )

//     characters
//     | map { it.name }
//     | collectFile(name: 'characters.txt', newLine: true, storeDir: 'results')
//     | view
// }

// Generate CSV file
// process WriteBio {
//     input: val(character)
//     output: path('bio.txt')
//     script:
//     def article = character.title.toLowerCase() =~ ~/^[aeiou]/ ? 'an' : 'a' // This line includes two Groovy synax features: The ternary operator - a terse if/else block, and The find operator =~

//     """
//     echo ${character.name} is ${article} ${character.title} > bio.txt
//     """
// }

// workflow {
//     characters = Channel.of(
//         ['name': 'Jake', 'title': 'Detective'],
//         ['name': 'Rosa', 'title': 'Detective'],
//         ['name': 'Terry', 'title': 'Sergeant'],
//         ['name': 'Amy', 'title': 'Detective'],
//         ['name': 'Charles', 'title': 'Detective'],
//         ['name': 'Gina', 'title': 'Administrator'],
//         ['name': 'Raymond', 'title': 'Captain'],
//         ['name': 'Michael', 'title': 'Detective'],
//         ['name': 'Norm', 'title': 'Detective']
//     )

//     characters
//     | WriteBio
//     | collectFile
//     | view
// }

// Dealing with headers when writing CSV files
process WriteBio {
    input: val(character)
    output: tuple val(character), path('bio.csv')
    script:
    """
    echo "precinct,name,title" > bio.csv
    echo 99th,${character.name},${character.title} >> bio.csv
    """
}

workflow {
    characters = Channel.of(
        ['name': 'Jake', 'title': 'Detective'],
        ['name': 'Rosa', 'title': 'Detective'],
        ['name': 'Terry', 'title': 'Sergeant'],
        ['name': 'Amy', 'title': 'Detective'],
        ['name': 'Charles', 'title': 'Detective'],
        ['name': 'Gina', 'title': 'Administrator'],
        ['name': 'Raymond', 'title': 'Captain'],
        ['name': 'Michael', 'title': 'Detective'],
        ['name': 'Norm', 'title': 'Detective']
    )

    characters
    | WriteBio
    | collectFile(storeDir: 'results', keepHeader: true) { character, file -> ["${character.title}s.csv", file]}
    | view
}


// Run file
/*
cd /workspace/gitpod/nf-training-advanced/operators
nextflow run .
*/
