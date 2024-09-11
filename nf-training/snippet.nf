// ch1 = Channel.of(1, 2, 3) // each value only used once
// ch2 = Channel.value(1) // can be used multiple times
// params.ch2 = "1" // automatically put into value channel

// process SUM {
//     input:
//     val x
//     val y

//     output:
//     stdout

//     script:
//     """
//     echo \$(($x+$y))
//     """
// }

//workflow {
    //SUM(ch1, ch2).view()
    //SUM(ch1, params.ch2).view()
    //SUM(ch1, ch2.first()).view()
//}

// nextflow run snippet.nf

/////////////////////////////////////////////////////////////////

// list = ['hello', 'world']

// Channel
//     .fromList(list)
//     .view()

// Channel
//     .fromPath('./data/meta/*.csv')
//     .view()

// Channel
//     .fromPath('./data/ggal/*.fq', hidden: true) // hidden shows hidden files
//     .view()

// Channel
//     .fromFilePairs('./data/ggal/*_{1,2}.fq', flat: true) // flat combines everything into 1 list
//     .view()

/////////////////////////////////////////////////////////////////

// Query NCBI SRA archive

// params.ncbi_api_key = '<Your API key here>'

// params.accession = ['ERR908507', 'ERR908506']

// process FASTQC {
//     input:
//     tuple val(sample_id), path(reads_file)

//     output:
//     path("fastqc_${sample_id}_logs")

//     script:
//     """
//     mkdir fastqc_${sample_id}_logs
//     fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads_file}
//     """
// }

// workflow {
//     reads = Channel.fromSRA(params.accession, apiKey: params.ncbi_api_key)
//     FASTQC(reads)
// }

/////////////////////////////////////////////////////////////////

// process PYSTUFF {
//     debug true

//     script:
//     """
//     #!/usr/bin/env python

//     x = 'Hello'
//     y = 'world!'
//     print ("%s - %s" % (x, y))
//     """
// }

// workflow {
//     PYSTUFF()
// }

/////////////////////////////////////////////////////////////////

// params.compress = 'gzip'
// params.file2compress = "$projectDir/data/ggal/transcriptome.fa"

// process FOO {
//     debug true

//     input:
//     path file

//     script:
//     if (params.compress == 'gzip')
//         """
//         echo "gzip -c $file > ${file}.gz"
//         """
//     else if (params.compress == 'bzip2')
//         """
//         echo "bzip2 -c $file > ${file}.bz2"
//         """
//     else
//         throw new IllegalArgumentException("Unknown compressor $params.compress")
// }

// workflow {
//     FOO(params.file2compress)
// }

// nextflow run snippet.nf --compress bzip2

/////////////////////////////////////////////////////////////////

// // reads = Channel.fromPath('data/ggal/*_1.fq')
// // transcriptome = "/data/ggal/transcriptome.fa"
// params.reads = "$projectDir/data/ggal/*_1.fq"
// params.transcriptome_file = "$projectDir/data/ggal/transcriptome.fa"

// Channel
//     .fromPath(params.reads)
//     .set { read_ch } // name channel

// process COMMAND {
//     debug true

//     input:
//     path reads
//     path transcriptome

//     script:
//     """
//     echo $reads $transcriptome
//     """
// }

// workflow {
//     // COMMAND(reads, transcriptome)
//     COMMAND(read_ch, params.transcriptome_file) // define inputs for the process
// }

/////////////////////////////////////////////////////////////////

// sequences = Channel.fromPath("$projectDir/data/ggal/*_1.fq")
// methods = ['regular', 'espresso', 'latte']

// process ALIGNSEQUENCES {
//     debug true

//     input:
//     path seq
//     each mode // repeat for each mode

//     script:
//     """
//     echo t_coffee -in $seq -mode $mode
//     """
// }

// workflow {
//     ALIGNSEQUENCES(sequences, methods)
// }

/////////////////////////////////////////////////////////////////

// process SPLITLETTERS {
//     output:
//     path 'chunk_*'

//     script:
//     """
//     printf 'Hola' | split -b 1 - chunk_
//     """
// }

// workflow {
//     letters = SPLITLETTERS()
//     letters.flatMap().view() // flatMap() outputs each file on a new line instead of 1 list
// }


/////////////////////////////////////////////////////////////////

// reads_ch = Channel.fromFilePairs('data/ggal/*_{1,2}.fq')

// process FOO {
//     input:
//     tuple val(sample_id), path(sample_id_paths)

//     output:
//     tuple val(sample_id), path("${sample_id}.bam") // need double quotes for ${}

//     script:
//     """
//     echo your_command_here --sample $sample_id_paths > ${sample_id}.bam
//     """
// }

// workflow {
//     sample_ch = FOO(reads_ch)
//     sample_ch.view()
// }

/////////////////////////////////////////////////////////////////

// reads_ch = Channel.fromFilePairs('data/ggal/*_{1,2}.fq')

// process FOO {
//     input:
//     tuple val(sample_id), path(sample_id_paths)

//     output:
//     tuple val(sample_id), path('sample.bam'), emit: bam // with emit you can reference bam later to view those outputs
//     tuple val(sample_id), path('sample.bai'), emit: bai

//     script:
//     """
//     echo your_command_here --sample $sample_id_paths > sample.bam
//     echo your_command_here --sample $sample_id_paths > sample.bai
//     """
// }

// workflow {
//     FOO(reads_ch)
//     FOO.out.bam.view()
//     FOO.out.bai.view()
// }

/////////////////////////////////////////////////////////////////

// params.dbtype = 'nr'
// params.prot = 'data/prots/*.tfa'
// proteins = Channel.fromPath(params.prot)

// process FIND {
//     debug true

//     input:
//     path fasta
//     val type

//     when:
//     fasta.name =~ /^BB11.*/ && type == 'nr' // filter by name of file and type

//     script:
//     """
//     echo blastp -query $fasta -db nr
//     """
// }

// workflow {
//     result = FIND(proteins, params.dbtype)
// }

/////////////////////////////////////////////////////////////////

reads_ch = Channel.fromFilePairs('data/ggal/*_{1,2}.fq')

process FOO {
    publishDir "results/bam", pattern: "*.bam"
    publishDir "results/bai", pattern: "*.bai"
    publishDir "results/$sample_id", pattern: "*.{bam, bai}" // store in separate folders by sample id
    cpus 2
    memory 1.GB
    time '1h'
    disk '10 GB'
    container 'image/name'

    input:
    tuple val(sample_id), path(sample_id_paths)

    output:
    tuple val(sample_id), path("*.bam")
    tuple val(sample_id), path("*.bai")

    script:
    """
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bam
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bai
    """
}

workflow {
    FOO(reads_ch)
}
