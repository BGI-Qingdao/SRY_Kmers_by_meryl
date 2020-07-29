# Introduction

    Detect SSK( sex special kmers) from male and female population data.

    notice : this project is still with developing & debugging stage!!!

# Usage

```
Usage   :
    ./SSK.sh [options]

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

    ./SSK.sh --male_group  xxx --female_group yyy \
                   --output ouput --suffix fasta.gz

Author  :
    xumengyang@genomics.cn
    guolidong@genomics.cn

```

# Q & A 

## How to do quality control of msk ?
![image](https://github.com/BGI-Qingdao/SSK_by_meryl/blob/master/sry-kmers-hist.png)
```
# print hostgram first. the kmer-multiplicity refer to the number of suppert male individual .
./bin/meryl histogram msk/msk.meryl 
# find the first lowest count x and 
#  assume the lower-multiplicity kmer are sequencing error or rare hapoloty kmer 
#  so that we need to filter them
./bin/meryl greater-than x output msk/msk.gtx.meryl msk/msk.meryl

## rename folders
mv msk/msk.meryl msk/msk.all.meryl
ln -s msk/msk.gtx.meryl msk/msk.meryl
```

**if your histogram is abnormal, maybe you can increase the --mfs to avoid misclassified male individuals in females.**



## How to get msk in text file ?

```
./bin/meryl print msk/msk.meryl 2>log | awk '{print $1}' >msk.txt
```

## How to get the distrubution of the numbers of SSK in assembly result ?

```
./bin/meryl-lookup -sequence genome.fasta -mers msk/msk.meryl -existence -threads 30 >info.txt 
```

## How to get the existence details of SSK in assembly result ?

```
# below command will print the "seqName <tab> kmer-startPos <tab> kmer-from-SSK"
./bin/meryl-lookup -sequence genome.fasta -mers msk/msk.meryl -dump -threads 30 2>log | awk '{if($4=="T" )printf("%s\t%s\t%s\n",$1,$3,$5);}'
```
