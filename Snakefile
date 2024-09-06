import os
import yaml

# Load configuration
with open("config.yaml") as f:
    config = yaml.safe_load(f)

# Set up sample names
SAMPLES = config["samples"]

# Define paths
RAW_DIR = config["raw_data_dir"]
TRIM_DIR = config["trimmed_data_dir"]
ALIGNED_DIR = config["aligned_data_dir"]
REFERENCE_DIR = config["reference_data_dir"]
RESULTS_DIR = config["results_dir"]
COUNTS_DIR = config["counts_dir"]

# Reference genome and annotation
REFERENCE_GENOME = config["reference_genome"]
ANNOTATION_GTF = config["annotation_gtf"]

# Ensure the results directory exists
os.makedirs(RESULTS_DIR, exist_ok=True)
os.chmod(RESULTS_DIR, 0o777)  # Open directory permissions
os.umask(0o000)

rule all:
    input:
        expand(RESULTS_DIR + "{sample}_fastqc.zip", sample=SAMPLES),
        COUNTS_DIR + "counts.txt"

# Rule for quality control using FastQC
rule fastqc:
    input:
        RAW_DIR + "{sample}.fastq.gz"
    output:
        RESULTS_DIR + "{sample}_fastqc.zip"
    shell:
        """
        fastqc -o {RESULTS_DIR} {input}
        rm -f {RESULTS_DIR}{wildcards.sample}_fastqc.html  # Delete the HTML file
        chmod 777 {output} 
        """

# Rule for adaptor trimming using trim galore
rule trim_galore:
    input:
        RAW_DIR + "{sample}.fastq.gz"
    output:
        temp(TRIM_DIR + "{sample}_trimmed.fq.gz")  # Store trimmed FASTQ as temp
    shell:
        """
        trim_galore --fastqc -o {TRIM_DIR} {input}
        
        # Move trimming report and FastQC zip to results directory
        mv {TRIM_DIR}{wildcards.sample}.fastq.gz_trimming_report.txt {RESULTS_DIR}
        mv {TRIM_DIR}{wildcards.sample}_trimmed_fastqc.zip {RESULTS_DIR}

        rm -f {TRIM_DIR}{wildcards.sample}_trimmed_fastqc.html
        """

# Rule for index building using HISAT2
rule hisat2_index:
    input:
        reference_genome = REFERENCE_GENOME,
        annotation = ANNOTATION_GTF
    output:
        temp(expand(REFERENCE_DIR + "Athaliana_index.{i}.ht2", i=[1,2,3,4,5,6,7,8])),
        gtf_file = temp(REFERENCE_DIR + "Athaliana.gtf"),  # Declare GTF file
        assembly_file = temp(REFERENCE_DIR + "Athaliana.fa")
    shell:
        """
        gunzip -c {input.reference_genome} > {output.assembly_file}
        gunzip -c {input.annotation} > {output.gtf_file}
        hisat2-build {output.assembly_file} {REFERENCE_DIR}Athaliana_index
        """

# Rule for alignment using HISAT2
rule hisat2_align:
    input:
        trimmed_fq = TRIM_DIR + "{sample}_trimmed.fq.gz",
        index_files = expand(REFERENCE_DIR + "Athaliana_index.{i}.ht2", i=[1,2,3,4,5,6,7,8])
    output:
        temp(ALIGNED_DIR + "{sample}.sam")  # Make SAM file temp
    shell:
        """
        hisat2 -x {REFERENCE_DIR}Athaliana_index -U {input.trimmed_fq} -S {output}
        """

# Rule for converting SAM to BAM and sorting
rule samtools_sort:
    input:
        ALIGNED_DIR + "{sample}.sam"
    output:
        temp(ALIGNED_DIR + "{sample}.sorted.bam")  # Make BAM file temp
    shell:
        "samtools sort {input} -o {output}"

# Rule for generating count matrix using featureCounts
rule featurecounts:
    input:
        bam = expand(ALIGNED_DIR + "{sample}.sorted.bam", sample=SAMPLES),
        gtf = REFERENCE_DIR + "Athaliana.gtf"  # Use the unzipped GTF file
    output:
        COUNTS_DIR + "counts.txt"
    shell:
        """
        featureCounts -a {input.gtf} -o {output} {input.bam}
        """
