# Use an official Ubuntu as a base image
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    default-jre \
    curl \
    bzip2 \
    perl \
    sudo \
    git

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -afy

# Update PATH
ENV PATH=/opt/conda/bin:$PATH

# Install mamba
RUN conda install -n base -c conda-forge mamba

# Create a Snakemake environment and install Snakemake
RUN mamba create -c conda-forge -c bioconda -n snakemake snakemake cutadapt samtools && \
    echo "source activate snakemake" > ~/.bashrc

# Install FastQC
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip -O /opt/fastqc.zip && \
    unzip /opt/fastqc.zip -d /opt && \
    chmod +x /opt/FastQC/fastqc && \
    ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc

# Install Trim Galore
RUN wget https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/0.6.6.zip -O /opt/trim_galore.zip && \
    unzip /opt/trim_galore.zip -d /opt && \
    chmod +x /opt/TrimGalore-0.6.6/trim_galore && \
    ln -s /opt/TrimGalore-0.6.6/trim_galore /usr/local/bin/trim_galore

# Install HISAT2
RUN wget https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download -O /opt/hisat2.zip && \
    unzip /opt/hisat2.zip -d /opt && \
    cp /opt/hisat2-2.2.1/hisat2* /usr/local/bin/ && \
    chmod +x /usr/local/bin/hisat2*

# Install featureCounts
RUN wget https://downloads.sourceforge.net/project/subread/subread-2.0.1/subread-2.0.1-Linux-x86_64.tar.gz -O /opt/subread.tar.gz && \
    tar -xvzf /opt/subread.tar.gz -C /opt && \
    cp /opt/subread-2.0.1-Linux-x86_64/bin/featureCounts /usr/local/bin/ && \
    chmod +x /usr/local/bin/featureCounts

# Clean up temporary files to reduce image size
RUN rm -rf /var/lib/apt/lists/* /opt/*.zip /opt/*.tar.gz /root/.cache

# Set the working directory inside the container
WORKDIR /data

# Set default shell
SHELL ["/bin/bash", "-c"]

# Activate the snakemake environment by default
ENTRYPOINT ["/bin/bash", "-c", "source activate snakemake && exec bash"]
