#!/bin/bash

wget https://raw.githubusercontent.com/HackBio-Internship/wale-home-tasks/main/DNA.fa
tail -n +2 DNA.fa | tr -d '\n' | wc -c
echo -n "TGGGTTGATTCCACACCCCCGCCCGGCACCCGCGTCCGCGCCGTGGCCATCTACAAGCAGTCACAGCACA
TGACGGAGGTTGTGAGGCGCTGCCCCCACCATGAGCGCTGCTCAGATAGCGAT" | sed '/\(./)/\1\n/g' | sort | uniq -c
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sudo apt update
sudo apt install fastqc
sudo apt -y install fastp
sudo apt install bwa
mkdir Output
SAMPLES=(
"ACBarrie"
"Alsen"
)
for SAMPLE in "${SAMPLES[@]}"; do
fastp \
i "$PWD/${SAMPLE}_R1.fastq.gz"\
-I "$PWD/${SAMPLE}_R2.fastq.gz"\
-o "Output/${SAMPLE}_R1.fastq.gz"\
-O "Output/${SAMPLE}_R2.fastq.gz"\
--html "Output/${SAMPLE}_fastp.html"
done

mkdir Outputfastqc
fastqc raw_reads/ACBarrie_R1.fastq.gz -o Outputfastqc/

