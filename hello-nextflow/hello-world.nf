/*
 * Pipeline parameters
 */
// params.greeting = "Bonjour le monde!"
params.input_file = "data/greetings.txt"

/*
 * Use echo to print 'Hello World!' to standard out
 */
process sayHello {
    
    publishDir 'results', mode: 'copy'
    
    input:
        val greeting

    output: 
        // stdout
        // path 'output.txt'
        path "${greeting}-output.txt"
    
    // """
    // echo 'Hello World!'
    // """
    // """
    // echo 'Hello World!' > output.txt
    // """
    // """
    // echo '$greeting' > output.txt
    // """
    """
    echo '$greeting' > '$greeting-output.txt'
    """
}

/*
 * Use a text replace utility to convert the greeting to uppercase
 */
process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    """
    cat '$input_file' | tr '[a-z]' '[A-Z]' > UPPER-${input_file}
    """
}

workflow {

    // // create a channel for inputs
    // greeting_ch = Channel.of('Hello world!')
    // greeting_ch = Channel.of(params.greeting)
    // greeting_ch = Channel.of('Hello','Bonjour','Holà')

    // create a channel for inputs from a file
    greeting_ch = Channel.fromPath(params.input_file).splitText() { it.trim() } // get file and split contents then remove blank lines
    
    // emit a greeting
    // sayHello()
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)
}

/* 
Commands to run 
*/
// nextflow run hello-world.nf
// nextflow run hello-world.nf -resume
// nextflow run hello-world.nf --greeting 'Bonjour le monde!'
// nextflow run hello-world.nf --greeting 'Holà!'
// nextflow run hello-world.nf --greeting 'Hello World!'
// nextflow run hello-world.nf -ansi-log false
// nextflow run hello-world.nf -ansi-log false --input_file data/greetings.txt
