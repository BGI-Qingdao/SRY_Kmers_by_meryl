# Introduction

    Detect SRY kmers from male and female population data.

    notice : this project is still with developing & debugging stage!!!

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
    --suffix        required    suffix of sequence files.
    --kmers         optional    [default 21] kmer-size.
    --thread        optional    [default 16] max threads for meryl.
    --memory        optional    [default 50] max memory for meryl.
    --output        optional    [default output] output folder name.
    --mfs           optional    [default 0] the minimum number of individual that support femle kmers .
                                set this in case when you suspect that there are mixed males in the females.

Example :

    ./SRY_kmers.sh --male_group  xxx --female_group yyy \
                   --output ouput --suffix fasta.gz

Author  :
    xumengyang@genomics.cn
    guolidong@genomics.cn

```

# Q & A 

## How to do quality control of sry-kmer ?

```
# print hostgram first. the kmer-multiplicity refer to the number of suppert male individual .
./bin/meryl histogram sry-kmers/sry-kmers.meryl 
# find the first lowest count x and 
#  assume the lower-multiplicity kmer are sequencing error or rare hapoloty kmer 
#  so that we need to filter them
./bin/meryl greater-than x output sry-kmers.gtx.meryl sry-kmers/sry-kmers.meryl
```

**if your hostgram is abnormal, may be you can increase the --mfs to avoid misclassified male individuals in females.**



## How to get sry-kmer in text file ?

```
./bin/meryl print sry-kmers/sry-kmers.meryl 2>log | awk '{print $1}' >sry.kmer.txt
```

## How to get the distrubution of the numbers of SRY-kmers in assembly result ?

```
./bin/meryl-lookup -sequence genome.fasta -mers sry-kmers/sry-kmers.meryl -existence -threads 30 >info.txt 
```

## How to get the existence details of SRY-kmers in assembly result ?

```
# below command will print the "seqName <tab> kmer-startPos <tab> kmer-from-SRY"
./bin/meryl-lookup -sequence genome.fasta -mers sry-kmers/sry-kmers.meryl -dump -threads 30 2>log | awk '{if($4=='T')printf("%s\t%s\t%s\n",$1,$3,$5);}'
```
