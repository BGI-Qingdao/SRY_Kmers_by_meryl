# Introduction

    Detect SRY kmers from male and female population data.

    notice : this project is still with developing & debugging period!!!

# Usage

```
Usage   :
    ./SRY_kmers.sh [options]

Option  :
    --male_group    required    folder of male population.
                                NOTICE : for each individual, put it's fastq into a independant sub-folder.
                                NOITCE : fastq must be ended by fastq or fastq.gz or fq or fq.gz
    --female_group  required    folder of female population.
                                NOTICE : for each individual, put it's fastq into a independant sub-folder.
                                NOITCE : fastq must be ended by fastq or fastq.gz or fq or fq.gz.
    --kmers         optional    [default 21] kmer-size.
    --thread        optional    [default 16] max threads for meryl.
    --memory        optional    [default 50] max memory for meryl.
    --output        optional    [default output] output folder name.

Example :

    ./SRY_kmers.sh --male_group  xxx --female_group yyy --output ouput

Author  :
    xumengyang@genomics.cn
    guolidong@genomics.cn

```

# Q & A 

## How to get the distrubution of the number of SRY-kmers in assembly result ?

```
./bin/meryl-lookup -sequence genome.fasta -mers sry-kmers/sry-kmers.meryl -existence -threads 30 -output info.txt 
```
