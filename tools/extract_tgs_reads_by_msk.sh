#!/bin/bash

if [[ $# != 4 || $1 == "-h" || $1 == "--help" ]] ;  then 
    echo "Usage : extract_tgs_reads_by_msk.sh <msk.meryl> <tgs_read> <min_density> <format>"
    echo "      *   format must be fa or fq;"
    echo "      *   gzip file must ended by gz;"
    echo "      *   format can ne fa/fq"
    exit 
fi

SRY_MERYL=$1
READ=$2
MIN_DENSITY=$3
FORMAT=$4
CPU=16
# import meryl into path
ROOT_PATH=`dirname $0`
ROOT_PATH=`realpath $ROOT_PATH`
PATH=$ROOT_PATH"/../bin/:"$PATH

#### classify reads
meryl-lookup -sequence $READ  -mers $SRY_MERYL -existence -threads $CPU \
    | awk '{if($4>0)printf("%s %s %s\n",$1,$2,$4);}' >read_info.txt

#### filter read by msk density
awk -v MIN_DENSITY=$MIN_DENSITY '{if($3/$2 >= MIN_DENSITY) print $1}' read_info.txt >read_name.txt

# extract the reads by read_name.txt
if [[ $FORMAT == 'fa' ]] ; then
    name=`basename $READ`
    if [[ ${name: -3} == ".gz" ]] ; then
        name=${name%%.gz}
        gzip -dc $READ | awk  -F '>| '  ' {if( FILENAME == ARGV[1] ) { s[$1]=1} else { if( NF>1){ if ($2 in s ){ print $0 ; c=1;} else {c=0} } else { if(c==1) { print $0 ;}  } } }' read_name.txt - >$name".fa.filtered"
    else
        awk  -F '>| '  ' {if( FILENAME == ARGV[1] ) { s[$1]=1} else { if( NF>1){ if ($2 in s ){ print $0 ; c=1;} else {c=0} } else { if(c==1) { print $0 ; }  } } }' read_name.txt $READ >$name".fa.filtered"
    fi
else
    name=`basename $READ`
    if [[ ${name: -3} == ".gz" ]] ; then
        name=${name%%.gz}
        gzip -dc $READ | awk  -F '>|@| '  ' {if( FILENAME == ARGV[1] ) { s[$1]=1} else { if(FNR %4==1 && NF>1){ if ($2 in s ){ print $0 ; c=1;} else {c=0} } else { if(c==1) { print $0 ; }  } } }' read_name.txt  - >$name".fq.filtered"
    else 
        awk  -F '>|@| '  ' {if( FILENAME == ARGV[1] ) { s[$1]=1} else { if(FNR %4==1 && NF>1){ if ($2 in s ){ print $0 ; c=1;} else {c=0} } else { if(c==1) { print $0 ; }  } } }' read_name.txt  $READ >$name".fq.filtered"
    fi
fi
