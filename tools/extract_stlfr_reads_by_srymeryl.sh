#!/bin/bash

if [[ $# != 3 || $1 == "-h" || $1 == "--help" ]] ; then
    echo ./extract_stlfr_reads_by_srymer.sh SRY_kmer.meryl split_reads.1.fq.gz split_reads.2.fq.gz
    exit
fi

SRY_MERYL=$1
READ1=$2
READ2=$3
CPU=16
# import meryl into path
ROOT_PATH=`dirname $0`
ROOT_PATH=`realpath $ROOT_PATH`
PATH=$ROOT_PATH"/../bin/:"$PATH

#### classify reads
meryl-lookup -sequence $READ1  -mers $SRY_MERYL -existence -threads $CPU \
    | awk '{if($6>0)printf("%s %s\n",$1,$6);}' \
    | awk -F '#|/| ' '{printf("%s\t%s\n",$2,$4);}' \
    >temp.read1.read_info

meryl-lookup -sequence $READ2  -mers $SRY_MERYL -existence -threads $CPU \
    | awk '{if($6>0)printf("%s %s\n",$1,$6);}' \
    | awk -F '#|/| ' '{printf("%s\t%s\n",$2,$4);}' \
    >temp.read2.read_info

### classify barcodes
awk '{t[$1]+=$2;}END {for(x in t ) {if (t[x] > 0 )printf("%s\t%s\n",x,t[x]);}}' temp.read1.read_info >temp.b1.barcode
awk '{t[$1]+=$2;}END {for(x in t ) {if (t[x] > 0 )printf("%s\t%s\n",x,t[x]);}}' temp.read2.read_info >temp.b2.barcode
cat temp.b1.barcode temp.b2.barcode > temp.barcode
awk '{t[$1]+=$2;}END {for(x in t ) {if (t[x] > 0 && x != "0_0_0" )printf("%s\t%s\n",x,t[x]);}}' temp.barcode >hit.barcode

###filter barcode again
awk '{if($2>1)print $1}'   hit.barcode>filtered.barcode

###cluster reads
gzip -dc $READ1 | awk -F '#|/| '  '{ if( FILENAME == ARGV[1] ) {t[$1]=1;} else{ if(FNR%4==1){ if( $2 in t ){pass=1;}else{pass=0;} } if(pass==1) print $0  }}'  filtered.barcode  - >output.read1.fq
gzip -dc $READ2 | awk -F '#|/| '  '{ if( FILENAME == ARGV[1] ) {t[$1]=1;} else{ if(FNR%4==1){ if( $2 in t ){pass=1;}else{pass=0;} } if(pass==1) print $0  }}'  filtered.barcode  - >output.read2.fq
