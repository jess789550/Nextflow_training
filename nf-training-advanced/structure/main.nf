// nextflow run .

// workflow {
//     names = Channel.of("Argente", "Absolon", "Chowne")
// }

// ./bin
process PlotCars {
    container 'rocker/tidyverse:latest'

    output:
    path("*.png"), emit: "plot"
    path("*.tsv"), emit: "table"

    script:
    """
    cars.R
    """
}

// workflow {
//     PlotCars()

//     PlotCars.out.table | view { "Found a tsv: $it" }
//     PlotCars.out.plot | view { "Found a png: $it" }
// }


// cat << EOF > nextflow.config // Everything between EOF and the terminating EOF will be written into the nextflow.config file
// profiles {
//     docker {
//         docker.enabled = true
//     }
// }
// EOF  // End Of File
// rm -r work
// nextflow run . -profile docker

// code work/*/*/.command.run // inspect the command line file run by nextflow

// ./templates
process SayHiTemplate {
    debug true
    input: val(name)
    script: template 'adder.py'
}

// workflow {
//     SayHiTemplate("test")
// }

// ./lib
// workflow {
//     Channel.of("Montreal")
//     | map { new Metadata() }
//     | view { it.hi() }
// }

// process UseMeta {
//     input: val(meta)
//     output: path("out.txt")
//     script: "echo '${meta.hi()}' | tee out.txt"
// }

// workflow {
//     Channel.of("Montreal")
//     | map { place -> new Metadata(place) }
//     | UseMeta
//     | view
// }

// process UseMeta {
//     input: val(meta)
//     output: path("out.txt")
//     script: "echo '${meta.adapter} prefix is ${meta.getAdapterStart()}' | tee out.txt"
// }

process UseMeta {
    input: val(meta)
    output: path("out.txt")
    script:
    "echo '${meta.adapter} prefix is ${meta.getAdapterStart()} with sampleName ${meta.getSampleName()}' | tee out.txt"
}

// workflow {
//     Channel.of("Montreal")
//     | map { place -> new Metadata(place) }
//     | map { it + [adapter:"AACGTAGCTTGAC"] }
//     | UseMeta
//     | view
// }

//////////////////////////////////////////////////

import nextflow.util.KryoHelper

KryoHelper.register(Dog) // register the class with Kryo, the Java serialization framework

// Dog.groovy does not cache (revision number changes)
// workflow {
//     dog = new Dog(name: "fido")
//     log.info "Found a new dog: $dog"
// }

// nextflow run . -resume
workflow {
    Channel.of("Argente", "Absolon", "Chowne")
    | map { new Dog(name: it) }
    | view
}
