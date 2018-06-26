# dnanexus_albacore_1D_barcoded v1.0

## What does this app do?
Albacore is software made by Oxford Nanopore Technologies for basecalling and demultiplexing raw Oxford Nanopore reads. This app runs a set of barcoded Oxford Nanopore fast5 files (containing raw signal data) and runs them through Albacore, which outputs demultiplexed fastq files.
The samplesheet is used to match samples with barcodes and rename the fastq files.  

## What are typical use cases for this app?
This app can be used as part of Oxford Nanopore workflows.

## What data are required for this app to run?
The app requires 4 inputs:
1. A tar.gz archive containing directories of fast5 files for basecalling and demultiplexing. 
2. A samplesheet csv file to match samples with barcodes.
3. The flowcell version (default: FLO-MIN106)
4. The sequencing kit version (default: SQK-LSK108)

## What does this app output?
The app has 2 outputs:
1. An array of gzipped fastq files
2. A tar.gz archive of the full albacore output

## How does this app work?
This app uses an Albacore docker image (https://hub.docker.com/r/mokaguys/albacore/) to perform basecalling and demultiplexing. The samplesheet is then parsed to match sample names with barcodes. This information is used to rename the fastq files which are uploaded as outputs. The full Albacore output folder is then compressed and also uploaded.    

## What are the limitations of this app
This app should only be used for multiplexed Oxford Nanopore data.

## This app was made by Viapath Genome Informatics 