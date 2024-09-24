# Nextflow Training [![gitlocalized ](https://gitlocalize.com/repo/8431/pt/badge.svg)](#)[![gitlocalized ](https://gitlocalize.com/repo/8431/fr/badge.svg)](#)[![gitlocalized ](https://gitlocalize.com/repo/8431/es/badge.svg)](#)

## » <https://training.nextflow.io> «

[![Open in GitPod](https://img.shields.io/badge/Gitpod-%20Open%20in%20Gitpod-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/nextflow-io/training)

Welcome to the Nextflow training repository!
We are excited to have you on the path to writing reproducible and scalable scientific workflows using Nextflow.

-   👉🏻 Written training material: <https://training.nextflow.io>

-   👩🏻‍💻 Instructions on loading this repository within a GitPod environment: <https://training.nextflow.io/basic_training/setup/>

-   📚 Nextflow documentation: <https://www.nextflow.io/docs/latest/>

## Contributions

We welcome fixes and improvements from the community. Please fork the repository and create pull-requests with any improvements to the docs.

You can find instructions about how to develop the training material code in [`CONTRIBUTING.md`](CONTRIBUTING.md). If you want to contribute with a translation instead, check [`TRANSLATING.md`](TRANSLATING.md).

## Credits & Copyright

All training material was originally written by [Seqera](https://seqera.io) but has been made open-source ([CC BY-NC-ND](https://creativecommons.org/licenses/by-nc-nd/4.0/)) for the community.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" src="docs/assets/img/cc_by-nc-nd.svg" /></a>

> Copyright 2020-2023, Seqera. All examples and descriptions are licensed under the <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.


## Notes
Processes are tasks to be run and channels control the input/output of data.

Processes have different parts:
* *Directives* are initial declarations that define optional settings
* *Input* defines the expected input channel(s)
* *Output* defines the expected output channel(s)
* *When* is an optional clause statement to allow conditional processes
* *Script* is a string statement that defines the command to be executed by the process' task

Operators allow you to manipulate channels:
* Filtering operators
* Transforming operators
* Splitting operators
* Combining operators
* Forking operators
* Maths operators
* Other operators

Run another nextflow pipeline that is in another GitHub repository:
```
nextflow run nextflow-io/rnaseq-nf -r v2.1 -with-docker // -r specific revision
```

Configuration priority:
*  Parameters specified on the command line (--parameter)
*  Parameters that are provided using the -params-file option
*  Config file that are provided using the -c option
*  The config file named nextflow.config in the current directory
*  The config file named nextflow.config in the pipeline project directory
*  The config file $HOME/.nextflow/config
*  Values defined within the pipeline script itself (e.g., main.nf)

Sequera Cloud Platform: https://cloud.seqera.io/user/jess789/launchpad
* The launching of pre-configured pipelines with ease.
* Programmatic integration to meet the needs of an organization.
* Publishing pipelines to shared workspaces.
* Management of the infrastructure required to run data analysis at scale.

Cache and resume:
* Resume workflow
* View status of previous runs
```
nextflow log <run_id> -t template.html > prov.html
nextflow <file.nf> -resume
```

Troubleshooting:
* Can set errorStrategy to "ignore" or "retry"
* Can set maximum number of retries
* Can set different actions for different exit codes
```
process FOO {
    cpus 4
    memory { 2.GB * task.attempt } // increase memory depending on how many times task attempted
    time { 1.hour * task.attempt } // increase time process can run for depending on how many times task attempted
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' } // retry if exit code is 140 otherwise terminate
    maxRetries 3 

    script:
    """
    your_command --cpus $task.cpus --mem $task.memory
    """
}
```

NextFlow pipelines can be run on the DNAnexus Cloud Platform by converting the script into an app/applet: 
https://documentation.dnanexus.com/user/running-apps-and-workflows/running-nextflow-pipelines

Metadata:
* Metadata should be explicit - be extremely wary of metadata encoded in filenames
* Metadata should travel through channels with the data in a tuple element.

./lib:
Classes defined in lib directory can be used for a variety of purposes. For example, the nf-core/rnaseq workflow uses five custom classes:
* NfcoreSchema.groovy for parsing the schema.json file and validating the workflow parameters.
* NfcoreTemplate.groovy for email templating and nf-core utility functions.
* Utils.groovy for provision of a single checkCondaChannels method.
* WorkflowMain.groovy for workflow setup and to call the NfcoreTemplate class.
* WorkflowRnaseq.groovy for the workflow-specific functions.

Work directory contains:
* .command.begin: Metadata related to the beginning of the execution of the process task
* .command.err: Error messages (stderr) emitted by the process task
* .command.log: Complete log output emitted by the process task
* .command.out: Regular output (stdout) by the process task
* .command.sh: The command that was run by the process task call
* .exitcode: The exit code resulting from the command
