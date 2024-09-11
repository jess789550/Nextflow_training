ch1 = Channel.of(1, 2, 3) // each value only used once
ch2 = Channel.value(1) // can be used multiple times
params.ch2 = "1" // automatically put into value channel

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    //SUM(ch1, ch2).view()
    //SUM(ch1, params.ch2).view()
    //SUM(ch1, ch2.first()).view()
}

// nextflow run snippet.nf

list = ['hello', 'world']

Channel
    .fromList(list)
    .view()

Channel
    .fromPath('./data/meta/*.csv')
    .view()

Channel
    .fromPath('./data/ggal/*.fq', hidden: true) // hidden shows hidden files
    .view()

Channel
    .fromFilePairs('./data/ggal/*_{1,2}.fq', flat: true) // flat combines everything into 1 list
    .view()


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
