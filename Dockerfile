
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and RNA-seq tools
RUN apt-get update && apt-get install -y \
    fastqc \
    trimmomatic \
    rna-star \
    subread \
    python3 \
    python3-pip \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages required for count merging and QC reporting
RUN pip3 install --break-system-packages \
    pandas \
    multiqc
