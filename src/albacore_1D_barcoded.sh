#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

# Download fast5 .tar.gz archive
dx-download-all-inputs

# Move fast5 archive to home and extract
mv $fast5_path ~/
tar zxf $fast5_name

# Create output directories
mkdir -p $HOME/albacore_output $HOME/out/fastq_files $HOME/out/albacore_output_all

# Run Albacore
# --reads_per_fastq_batch specifies how many reads go into each fastq. Setting to 0 means all reads go into single fastq.
# --barcoding tells albacore to also perform demultiplexing
dx-docker run -v $HOME:/data mokaguys/albacore:v2.2 read_fast5_basecaller.py \
    --input /data/ \
    --worker_threads 11 \
    -s /data/albacore_output \
    --flowcell $flowcell \
    --kit $sequencing_kit \
    --output_format fastq \
    --reads_per_fastq_batch 0 \
    --recursive \
    --barcoding

# Albacore outputs each fastq into a 'barcodeXX/' subfolder
# We need to use the samplesheet to match sample names to barcodes, 
# and then rename and copy the fastq to the output directory

# First sections of samplesheet aren't required here, so set a flag (reached_data_section) that allows us to 
# skip over first sections. 
reached_data_section=false
# Read through samplesheet line by line. Line is read into $samplesheet_line variable.
while read samplesheet_line; do
    # If the reached_data_section flag is true, then this line contains sample info
    if $reached_data_section; then
        # sample name in is in second field of csv, and barcode is in fifth field
        sample_name=$(echo $samplesheet_line | cut -d ',' -f2)
        barcode=$(echo $samplesheet_line | cut -d ',' -f5)
        # Check file exists. (If it doesn't for some reason, skip to prevent whole run from failing)
        if [ -f $HOME/albacore_output/workspace/pass/${barcode}/*.fastq ]; then
            # Copy the fastq from the matching barcode folder in albacore output, and rename using the sample name 
            cp $HOME/albacore_output/workspace/pass/${barcode}/*.fastq $HOME/out/fastq_files/${sample_name}.fastq
            # Gzip the fastq.
            gzip $HOME/out/fastq_files/${sample_name}.fastq
        fi
    fi
    # If the line starts with 'Sample_ID' then this is the header row for the data section
    # Set reached_data_section flag to true so that when the next line is read (i.e. first sample line), the code
    # in the above if block will execute
    if [[ $samplesheet_line == Sample_ID* ]]; then
        reached_data_section=true
    fi
done < $samplesheet_path

# tar and gzip the full albacore output folder and add to job outputs folder
tar czf $HOME/out/albacore_output_all/albacore_output_all.tar.gz albacore_output

# Upload output
dx-upload-all-outputs