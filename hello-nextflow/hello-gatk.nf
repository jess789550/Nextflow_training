/*
 * Pipeline parameters
 */

// Execution environment setup
params.projectDir = "/workspace/gitpod/hello-nextflow"
$projectDir = params.projectDir

// Primary input
// params.reads_bam = "${projectDir}/data/bam/reads_mother.bam"
// params.reads_bam = [
//     "${projectDir}/data/bam/reads_mother.bam",
//     "${projectDir}/data/bam/reads_father.bam",
//     "${projectDir}/data/bam/reads_son.bam"
// ]

// // Primary input (list of input files, one per line)
// params.reads_bam = "${projectDir}/data/sample_bams.txt"

// Primary input (samplesheet in CSV format with ID and file path, one sample per line)
params.reads_bam = "${projectDir}/data/samplesheet.csv"

// Accessory files
params.genome_reference = "${projectDir}/data/ref/ref.fasta"
params.genome_reference_index = "${projectDir}/data/ref/ref.fasta.fai"
params.genome_reference_dict = "${projectDir}/data/ref/ref.dict"
params.calling_intervals = "${projectDir}/data/intervals.list"

// Base name for final output file
params.cohort_name = "family_trio"

/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1'

    input:
        // path input_bam
        tuple val(id), path(input_bam)

    output:
        // path "${input_bam}.bai"
        // tuple path(input_bam), path("${input_bam}.bai")
        tuple val(id), path(input_bam), path("${input_bam}.bai")

    """
    samtools index '$input_bam'
    """
}

/*
 * Call variants with GATK HapolotypeCaller in GVCF mode
 */
process GATK_HAPLOTYPECALLER {

    container "docker.io/broadinstitute/gatk:4.5.0.0"

    input:
        // path input_bam
        // path input_bam_index
        // tuple path(input_bam), path(input_bam_index)
        tuple val(id), path(input_bam), path(input_bam_index)
        path ref_fasta
        path ref_index
        path ref_dict
        path interval_list

    output:
        // path "${input_bam}.g.vcf"
        // path "${input_bam}.g.vcf.idx"
        tuple val(id), path("${input_bam}.g.vcf"), path("${input_bam}.g.vcf.idx")

    """
    gatk HaplotypeCaller \
        -R ${ref_fasta} \
        -I ${input_bam} \
        -O ${input_bam}.g.vcf \
        -L ${interval_list} \
        -ERC GVCF
    """
}

/*
 * Consolidate GVCFs and apply joint genotyping analysis
 */
process GATK_JOINTGENOTYPING {

    container "docker.io/broadinstitute/gatk:4.5.0.0"

    input:
        path(sample_map)
        val(cohort_name)
        path ref_fasta
        path ref_index
        path ref_dict
        path interval_list

    output:
        path "${cohort_name}.joint.vcf"
        path "${cohort_name}.joint.vcf.idx"

    """
    gatk GenomicsDBImport \
        --sample-name-map ${sample_map} \
        --genomicsdb-workspace-path ${cohort_name}_gdb \
        -L ${interval_list}

    gatk GenotypeGVCFs \
        -R ${ref_fasta} \
        -V gendb://${cohort_name}_gdb \
        -O ${cohort_name}.joint.vcf \
        -L ${interval_list}
    """
}

workflow {

    // // Create input channel (single file via CLI parameter)
    // reads_ch = Channel.of(params.reads_bam)
    
    // // Create input channel (multiple files via CLI parameter)
    // reads_ch = Channel.fromList(params.reads_bam)

    // // Create input channel from list of input files in plain text
    // reads_ch = Channel.fromPath(params.reads_bam).splitText()

    // Create input channel from samplesheet in CSV format
    reads_ch = Channel.fromPath(params.reads_bam)
                    .splitCsv(header: true)
                    .map { row -> [row.id, file(row.reads_bam)] }

    // Create index file for input BAM file
    SAMTOOLS_INDEX(reads_ch)

    // Call variants from the indexed BAM file
    GATK_HAPLOTYPECALLER(
        // reads_ch,
        SAMTOOLS_INDEX.out,
        params.genome_reference,
        params.genome_reference_index,
        params.genome_reference_dict,
        params.calling_intervals
    )

    // Create a sample map of the output GVCFs
    sample_map = GATK_HAPLOTYPECALLER.out.collectFile() { id, gvcf, idx ->
            ["${params.cohort_name}_map.tsv", "${id}\t${gvcf}\t${idx}\n"]
    }

    // Consolidate GVCFs and apply joint genotyping analysis
    GATK_JOINTGENOTYPING(
        sample_map,
        params.cohort_name,
        params.genome_reference,
        params.genome_reference_index,
        params.genome_reference_dict,
        params.calling_intervals
    )
}

/*
* Commands to run
*/
// nextflow run hello-gatk.nf
// nextflow run hello-gatk.nf -ansi-log false
