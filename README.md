## RNA-SeqBox: RNA-seq Analysis Workflow

by [Iris Martinez Hevia](https://github.com/irishevia)

This repository contains a Dockerized RNA-seq analysis pipeline built with Snakemake. The workflow processes RNA sequencing data through steps like quality control, trimming, alignment, and quantification, ultimately generating a count matrix for downstream analysis.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Input Files](#input-files)
- [Output Files](#output-files)
- [References](#references)
- [License](#license)

## Overview

This RNA-seq workflow includes the following steps:

1. **Quality control** of raw FASTQ files using FastQC
2. **Adaptor trimming** with Trim Galore
3. **Read alignment** with HISAT2
4. **SAM to BAM conversion** using Samtools
5. **Count matrix generation** with featureCounts

All tools are pre-installed in the Docker container.

The demo data used to test this pipeline consists of four raw RNA-seq samples from *Arabidopsis thaliana* (SRR671946, SRR671947, SRR671948, SRR671949). These samples are part of the experiment published in:

Vidal EA, Moyano TC, Krouk G, Katari MS, Tanurdzic M, McCombie WR, Coruzzi GM, Gutiérrez RA. *Integrated RNA-seq and sRNA-seq analysis identifies novel nitrate-responsive genes in Arabidopsis thaliana roots*. BMC Genomics. 2013 Oct 11;14:701. (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3906980/).

## Requirements

- Docker ([Docker Documentation](https://docs.docker.com/))

## Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/irishevia/RNA-SeqBox.git
    cd RNA-SeqBox
    ```

2. **Build the Docker image**:

    ```bash
    docker build -t rna-seq-box -f Dockerfile .
    ```

## Usage

1. **Prepare input files**: Place your raw sequencing data in the `data/raw` directory, and the compressed genome assembly and annotation files for your organism in the `data/reference` directory.

2. **Configure the workflow**: Edit the `config.yaml` file to specify your input sample id and reference genome.

3. **Run the pipeline**: Use Docker to execute the Snakemake workflow:

    ```bash
    docker run -v $(pwd):/data -w /data rna-seq-box snakemake --cores 4
    ```

## Input Files

The following input files are required:

- **Fastq files**: Raw sequencing data in `.fastq.gz` format, placed in the `data/raw` directory.
  
  To download sample datasets from NCBI using SRA Toolkit (https://hpc.nih.gov/apps/sratoolkit.html), use `fastq-dump`. Example:

    ```bash
    fastq-dump --gzip SRR671946
    ```

- **Genome assembly**: A reference genome in `.fa.gz` format, placed in the `data/reference` directory.
  The genome assembly file used for this demo is the TAIR10 Arabidopsis thaliana (https://plants.ensembl.org/Arabidopsis_thaliana/Info/Index) `Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz`.

- **Genome annotation**: A `.gtf.gz` annotation file, also in the `data/reference` directory. The one used in the demo analysis is `Arabidopsis_thaliana.TAIR10.59.gtf.gz`.

- **Reference genome path**: Update the path to your reference genome in `config.yaml`.

## Output Files

The workflow generates the following key output files:

- **Count Matrix**: A table of gene counts for each sample, located in the `data/counts` folder.
- **Fastq QC Report**: Two zip folders with FastQC reports for each sample, both pre- and post-trimming, including trimming reports, located in the `results` folder.

## References

- [Snakemake Documentation](https://snakemake.readthedocs.io/)
- [Docker Documentation](https://docs.docker.com/)
- [FastQC Documentation](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [Trim Galore Documentation](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
- [HISAT2 Documentation](http://daehwankimlab.github.io/hisat2/)
- [Samtools Documentation](http://www.htslib.org/)
- [featureCounts Documentation](http://bioinf.wehi.edu.au/featureCounts/)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
