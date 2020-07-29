# Introduction

    Detect SSK( sex-specific-kmers) from male and female population data.

    note : this project is still under developing & debugging !!!

# Usage

```
Usage   :
    ./SSK.sh [options]

Option  :
    --male_group    required    folder of male population.
                                NOTE : for each individual, put all of its fastqs into a separate sub-folder.
                                NOTE : fastq must be ended by fastq or fastq.gz or fq or fq.gz
    --female_group  required    folder of female population.
                                NOTE : for each individual, put all of its fastqs into a separate sub-folder.
                                NOTE : fastq must be ended by fastq or fastq.gz or fq or fq.gz.
    --suffix        required    suffix of sequence files.
    --kmers         optional    [default 21] kmer-size.
    --thread        optional    [default 16] max threads for meryl.
    --memory        optional    [default 50] max memory for meryl.
    --output        optional    [default output] output folder name.
    --mfs           optional    [default 0] the minimum number of individuals that support female kmers .
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
![image](https://github.com/BGI-Qingdao/SSK_finder/blob/master/sry-kmers-hist.png)
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



## How to get SSK kmers ?

```
./bin/meryl print msk/msk.meryl 2>log | awk '{print $1}' >msk.txt
```

## How to get the mapping statistics of SSK against the assembly result ?

```
./bin/meryl-lookup -sequence genome.fasta -mers msk/msk.meryl -existence -threads 30 >info.txt 
```

## How to get the mapping positions of SSK against the assembly result ?

```
# below command will print the "seqName <tab> kmer-startPos <tab> kmer-from-SSK"
./bin/meryl-lookup -sequence genome.fasta -mers msk/msk.meryl -dump -threads 30 2>log | awk '{if($4=="T" )printf("%s\t%s\t%s\n",$1,$3,$5);}'
```
