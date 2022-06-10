#!/bin/bash
# Download DNA.fa
wget https://raw.githubusercontent.com/HackBio-Internship/wale-home-tasks/main/DNA.fa

# Count DNA sequence apart from the title
tail -n +2 DNA.fa | tr -d '\n' | wc -c
# Count Number of A,T,G and C base in sequence
echo -n "TGGGTTGATTCCACACCCCCGCCCGGCACCCGCGTCCGCGCCGTGGCCATCTACAAGCAGTCACAGCACA
TGACGGAGGTTGTGAGGCGCTGCCCCCACCATGAGCGCTGCTCAGATAGCGAT" | sed '/\(./)/\1\n/g' | sort | uniq -c

#Download miniconda and setup
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

#Install software
sudo apt update
sudo apt install fastqc
sudo apt -y install fastp
sudo apt install bwa
wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
tar -vxjf samtools-1.9.tar.bz2
cd samtools-1.9
make
cd ..

#Download dataset
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/ACBarrie_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/ACBarrie_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R2.fastq.gz

#Create output folder
mkdir Output

#Trimming with fastp
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

#Fastqc analysis
fastqc *.fastq.gz -o Output/


#bwa
cd Output

#download reference file
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/references/reference.fasta


 SAMPLES=(
"ACBarrie"
"Alsen"
)
bwa index reference.fasta
mkdir REPAIRED
mkdir aligned
for SAMPLE in "${SAMPLES[@]}"; do
repair.sh in1="Output/{SAMPLE}_R1.fastq.gz" in2="Output/{SAMPLE}_R2.fastq.gz" out1="REPAIRED/{SAMPLE}_R1.rep.fastq.gz" out2="REPAIRED/{SAMPLE}_R2.rep.fastq.gz" outsingle="REPAIRED/{SAMPLE}_single.fq"
bwa mem -t 1\
reference.fasta\
"REPAIRED/${SAMPLE}_R1.rep.fastq.gz" "REPAIRED/${SAMPLE}_R2.rep.fastq.gz" \
| samtools view -b \
> "aligned/${SAMPLE}.bam"
done


